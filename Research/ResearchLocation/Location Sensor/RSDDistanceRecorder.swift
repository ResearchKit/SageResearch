//
//  RSDDistanceRecorder.swift
//  ResearchUI
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import CoreLocation
import CoreMotion
import ResearchMotion
import Research

extension RSDDistanceRecorderConfiguration : RSDAsyncActionVendor {
    
    /// Instantiate a `RSDDistanceRecorder` (iOS only).
    /// - parameter taskViewModel: The current task path to use to initialize the controller.
    /// - returns: A new instance of `RSDDistanceRecorder` or `nil` if the platform does not
    ///            support distance recording.
    public func instantiateController(with taskViewModel: RSDPathComponent) -> RSDAsyncAction? {
        return RSDDistanceRecorder(configuration: self, taskViewModel: taskViewModel, outputDirectory: taskViewModel.outputDirectory)
    }
}


/// `RSDDistanceRecorder` is intended to be used for recording location where the participant is walking,
/// running, cycling, or other activities **outdoors** where the distance travelled is of interest. By
/// default, this recorder *only* logs the relative distance, altitude, course, and speed travelled by
/// the participant. To log GPS coordinates, the configuration file must *explicitly* be set to do so,
/// and it is recommended to *only* log the coordinates if the user is a tester in order to ensure the
/// participant's privacy is respected.
///
/// At the end of the motion travelled step, the recorder also uses CoreMotion to query the pedometer
/// for the overall distance and step count as measured by the pedometer which are then added to the
/// `RSDCollectionResult` returned by this recorder when it is stopped.
///
/// This recorder is only available on iOS devices. CoreMotion is not supported by other platforms.
/// Additionally, for a watchOS application that needs to measure distance travelled, creating an
/// HKWorkoutSession offers a more efficient use of the device battery with equivalent accuracy
/// in determining the distance travelled by the participant while performing a distance measuring
/// activity.
///
/// This recorder is designed to be run in the background so that the user can lock the screen and place
/// the phone in their pocket or bag. This requires setting the capabilities in your app to include
/// background audio.
///
/// Additionally, you will need to add the privacy permission for location and motion sensors to the
/// application `Info.plist` file. As of this writing (syoung 02/08/2018), those keys are:
/// - `Privacy - Motion Usage Description`
/// - `Privacy - Location Always and When In Use Usage Description`
/// - `Privacy - Location When In Use Usage Description`
///
/// - note: **Both** location privacy keys are required.
///
/// - seealso: `RSDDistanceRecorderConfiguration` and `RSDDistanceRecord`
@available(iOS 10.0, *)
public class RSDDistanceRecorder : RSDSampleRecorder, CLLocationManagerDelegate {
    
    /// The result identifiers used for the additional results recorded
    /// by the distance recorder.
    public enum ResultIdentifier : String, CodingKey {
        
        /// The step count returned by the pedometer.
        case stepCount
        
        /// The distance measurement returned by the pedometer.
        case pedometerDistance
        
        /// The total distance measured by summing the relative distance travelled during the
        /// motion step (when the participant is expected to be moving).
        ///
        /// - note: it is possible to "game" this result because the calculation of this result
        /// does not account for coordinate measurement accuracy or the course and speed at which
        /// the user is travelling. It is used only to give feedback to a partipant. The pedometer
        /// distance and a path constructed by using the course, speed, and relative distance
        /// recorded samples should be used by a research study for more accurate data collection.
        case gpsDistance
    }
    
    /// Convenience property for getting the location configuration.
    public var locationConfiguration: RSDDistanceRecorderConfiguration? {
        return self.configuration as? RSDDistanceRecorderConfiguration
    }
    
    /// Should relative distance only be saved to the log? Default = `true`.
    public var relativeDistanceOnly: Bool = true
    
    /// Whether or not the user is expected to be standing still or moving. This is used to mark
    /// when to start calculating distance travelled while moving as a part of a larger overall
    /// data gathering effort that might include how much a person is moving during other steps
    /// when they should be standing still (while recording heart rate, for example).
    public var isStandingStill: Bool = false {
        didSet {
            if !isStandingStill {
                totalDistance = 0.0
                startTotalDistance = Date()
                endTotalDistance = Date.distantFuture
            } else if endTotalDistance == Date.distantFuture {
                endTotalDistance = Date()
            }
        }
    }
    
    /// Total distance (measured in meters) from the start of recording.
    @objc dynamic public private(set) var totalDistance: Double = 0.0
    
    /// Most recent location recorded.
    public private(set) var mostRecentLocation: CLLocation?

    /// Date timestamp for when the moving step was triggered.
    private var startTotalDistance = Date()
    
    /// Date timestamp for when the moving step was finished.
    private var endTotalDistance = Date.distantFuture
    
    /// Is the participant outdoors?
    /// - returns: `true` if the horizontal accuracy indicates that the participant is outdoors.
    public func isOutdoors() -> Bool {
        var isOutdoors = false
        self.processingQueue.sync {
            if _recentLocations.count > 0 {
                let sorted = _recentLocations.sorted(by: { $0.horizontalAccuracy < $1.horizontalAccuracy })
                let median = sorted[Int(sorted.count / 2)]
                isOutdoors = median.horizontalAccuracy <= kLocationRequiredAccuracy
            }
        }
        return isOutdoors
    }
    
    // MARK: Recorder state management

    public private(set) var locationManager: CLLocationManager?
    private var pedometer: CMPedometer?
    private let processingQueue = DispatchQueue(label: "org.sagebase.Research.location.processing")
    private var _permissionCompletion: RSDAsyncActionCompletionHandler?
    
    /// Override to request GPS and motion permissions.
    override public func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        
        // Get the current status and exit early if the status is restricted or denied.
        let status = CLLocationManager.authorizationStatus()
        if status == .denied || status == .restricted || status == .authorizedWhenInUse {
            let status: RSDAuthorizationStatus = (status == .restricted) ? .restricted : .denied
            let error = RSDPermissionError.notAuthorized(RSDStandardPermission.location, status)
            debugPrint("Failed to start the location recorder: \(status)")
            self.updateStatus(to: .failed, error: error)
            completion(self, nil, error)
            return
        }

        // Request permission to use the pedometer.
        RSDMotionAuthorization.requestAuthorization { [weak self] (_,_) in
            // If querying the pedometer failed, then keep going anyway b/c the pedometer
            // is just a "nice to have".
            self?._requestLocationPermission(completion)
        }
    }
    
    private func _requestLocationPermission(_ completion: @escaping RSDAsyncActionCompletionHandler) {
        DispatchQueue.main.async {
            // **Only** if the status is not determined, should permission be requested.
            let status = CLLocationManager.authorizationStatus()
            guard status == .notDetermined else {
                debugPrint("Status has been previously authorized: \(status)")
                self.updateStatus(to: .permissionGranted, error: nil)
                completion(self, nil, nil)
                return
            }
            
            self._permissionCompletion = completion
            self._setupLocationManager()
            self.locationManager!.requestAlwaysAuthorization()
        }
    }

    private func _setupLocationManager() {
        guard self.locationManager == nil else { return }
        
        // setup the location manager when asking for permissions
        let manager = CLLocationManager()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        self.locationManager = manager
    }
    
    /// Override to start updating the GPS location.
    override public func startRecorder(_ completion: @escaping ((RSDAsyncActionStatus, Error?) -> Void)) {
        do {
            try self._startLocationManager()
            completion(.running, nil)
        } catch let err {
            completion(.failed, err)
        }
    }

    private func _startLocationManager() throws {
        let status = CLLocationManager.authorizationStatus()
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            let status: RSDAuthorizationStatus = (status == .restricted) ? .restricted : .denied
            throw RSDPermissionError.notAuthorized(RSDStandardPermission.location, status)
        }
        
        _setupLocationManager()
        
        if let motionStepId = self.locationConfiguration?.motionStepIdentifier {
            self.isStandingStill = (self.currentStepIdentifier != motionStepId)
        }
        
        self.locationManager!.startUpdatingLocation()
    }
    
    /// Override to stop updating GPS location.
    override public func stopRecorder(_ completion: @escaping ((RSDAsyncActionStatus) -> Void)) {
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        self.locationManager = nil
        super.stopRecorder(completion)
    }

    /// Override to stop updating GPS location.
    override public func pause() {
        if !self.isPaused && self.status == .running  {
            self.locationManager?.stopUpdatingLocation()
        }
        super.pause()
    }

    /// Override to start updating the GPS location.
    override public func resume() {
        if self.isPaused && self.status == .running {
            self.locationManager?.startUpdatingLocation()
        }
        super.resume()
    }
    
    /// Override to check if the step being moved to is the step when the participant's
    /// distance should be tracked and to add the pedometer reading once the participant
    /// is standing still.
    override public func moveTo(step: RSDStep, taskViewModel: RSDPathComponent) {
        
        // Call super. This will update the step path and add a step change marker.
        super.moveTo(step: step, taskViewModel: taskViewModel)
        
        // Look to see if the configuration has a motion step and update state accordingly.
        if let motionStepId = self.locationConfiguration?.motionStepIdentifier {
            let newState = (step.identifier != motionStepId)
            if newState != isStandingStill {
                isStandingStill = newState
                if isStandingStill {
                    // If changed from moving to standing still then add the pedometer data
                    _addPedometerData()
                }
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    /// If the location manager failed, then check if the manager was requesting permission
    /// and call the completion handler if appropriate.
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let completion = _permissionCompletion {
            self.updateStatus(to: .failed, error: error)
            completion(self, nil, error)
            _permissionCompletion = nil
        } else {
            self.didFail(with: error)
        }
    }
    
    /// If the authorization changes, then check if authorization has been granted.
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            let status: RSDAuthorizationStatus = (status == .restricted) ? .restricted : .denied
            let error = RSDPermissionError.notAuthorized(RSDStandardPermission.location, status)
            self.locationManager(manager, didFailWithError: error)
            return
        }
        if let completion = _permissionCompletion {
            self.updateStatus(to: .permissionGranted, error: nil)
            completion(self, nil, nil)
            _permissionCompletion = nil
        }
    }
    
    /// When location updates are received, process them on the processing queue.
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else { return }
        
        self.processingQueue.async {
            
            let samples = locations.map { (location) ->RSDDistanceRecord in
            
                // Calculate time interval since start time
                let timeInterval = location.timestamp.timeIntervalSince(self.startDate)
                let uptime = self.clock.startUptime + timeInterval

                // Update the total distance
                let distance = self._updateTotalDistance(location)
                
                // Create the sample
                let sample = RSDDistanceRecord(uptime: uptime, timestamp: timeInterval, stepPath: self.currentStepPath, location: location, previousLocation: self.mostRecentLocation, totalDistance: distance, relativeDistanceOnly: self.relativeDistanceOnly)
                
                // If this is a valid location then store as the previous location
                self._updateMostRecent(location, timeInterval: timeInterval)
                
                return sample
            }
            
            self.writeSamples(samples)
        }
    }
    
    /// Returns the string encoding format to use for this file. Default is `nil`. If this is `nil`
    /// then the file will be formatted using JSON encoding.
    override public func stringEncodingFormat() -> RSDStringSeparatedEncodingFormat? {
        if self.locationConfiguration?.usesCSVEncoding == true {
            return CSVEncodingFormat<RSDDistanceRecord>()
        } else {
            return nil
        }
    }
    
    // MARK: Data management
    
    private var _stepStartLocation : CLLocation?
    private var _lastAccurateLocation : CLLocation?
    private var _recentLocations : [CLLocation] = []
    private let kLocationRequiredAccuracy : CLLocationAccuracy = 20.0
    
    private func _addPedometerData() {
        // Get the results of the pedometer for the time when in motion.
        pedometer = CMPedometer()
        pedometer!.queryPedometerData(from: startTotalDistance, to: endTotalDistance) { [weak self] (data, _) in
            guard let pedometerData = data else { return }
            self?._recordPedometerData(pedometerData)
        }
    }
    
    private func _recordPedometerData(_ data: CMPedometerData) {
        
        let stepCountResult = AnswerResultObject(identifier: ResultIdentifier.stepCount.stringValue,
                                                 value: .integer(data.numberOfSteps.intValue))
        self.appendResults(stepCountResult)
        
        let pedometerDistanceResult = AnswerResultObject(identifier: ResultIdentifier.pedometerDistance.stringValue,
                                                         value: .number(data.distance?.doubleValue ?? 0.0))
        self.appendResults(pedometerDistanceResult)
        
        let gpsDistanceResult = AnswerResultObject(identifier: ResultIdentifier.gpsDistance.stringValue,
                                                   value: .number(totalDistance))
        self.appendResults(gpsDistanceResult)
        
        // Release the pedometer
        pedometer = nil
    }
    
    private func _updateTotalDistance(_ location: CLLocation) -> Double? {

        let timestamp = location.timestamp
        guard timestamp >= self.startDate.addingTimeInterval(-60)
            else {
                return nil
        }

        // Determine if this location is accurate enough to use in calculations
        let isOutdoors = location.horizontalAccuracy > 0 && location.horizontalAccuracy <= kLocationRequiredAccuracy
        var distance: Double?
        
        if let lastLocation = _lastAccurateLocation, timestamp >= self.startTotalDistance, timestamp <= self.endTotalDistance {
            if isSimulator {
                // If running in the simulator then have the simulator run a 12 minute mile.
                totalDistance += timestamp.timeIntervalSince(lastLocation.timestamp) * 2.2352
            } else if isOutdoors {
                // If the time is after the start time, then add the distance travelled to the total distance.
                // This is a rough measurement and does not (at this time) include any spline drawing to measure the
                // actual curve of the distance travelled. It also does not check for bearing to see if the user
                // is actually standing still.
                totalDistance += lastLocation.distance(from: location)
            } else {
                // If the user is indoors then don't calculate a change in distance, but still
                // update any KVO observers.
                totalDistance += 0
            }
            distance = totalDistance
        } 
        
        // Save the previous location as the last accurate location
        if isOutdoors || isSimulator {
            _lastAccurateLocation = location
            if _stepStartLocation == nil {
                _stepStartLocation = _lastAccurateLocation
            }
        }
        
        return distance
    }

    private func _updateMostRecent(_ location: CLLocation, timeInterval: TimeInterval) {
        // If this is a valid location then store as the previous location
        guard location.horizontalAccuracy >= 0 else { return }
        mostRecentLocation = location
        if (timeInterval > 0) {
            _recentLocations.append(location)
            if _recentLocations.count > 5 {
                _recentLocations.remove(at: 0)
            }
        }
    }
}

/// A `RSDDistanceRecord` is a `Codable` implementation of `RSDSampleRecord` that can be used
/// to record CoreLocation samples for use in determining distance travelled.
///
/// - example:
///
/// ```
///     // Example json for a codable record.
///     let json = """
///                {
///                 "uptime" : 99652.677386361029,
///                 "relativeDistance" : 2.1164507282484935,
///                 "verticalAccuracy" : 3,
///                 "horizontalAccuracy" : 6,
///                 "stepPath" : "Cardio 12MT/run/runDistance",
///                 "course" : 76.873546882061802,
///                 "totalDistance" : 63.484948023273581,
///                 "speed" : 1.0289180278778076,
///                 "timestampDate" : "2018-01-04T23:49:34.135-08:00",
///                 "timestamp" : 210.47070598602295,
///                 "altitude" : 23.375564581136974
///                }
///                """.data(using: .utf8)! // our data in native (JSON) format
/// ```
public struct RSDDistanceRecord: RSDSampleRecord, RSDDelimiterSeparatedEncodable {
    
    /// The absolute clock time.
    public let uptime: TimeInterval?
    
    /// Relative time to when the recorder was started.
    public let timestamp: TimeInterval?
    
    /// An identifier marking the current step.
    public let stepPath: String
    
    /// The date timestamp when the measurement was taken.
    public let timestampDate: Date?
    
    /// The Unix timestamp (seconds since 1970-01-01T00:00:00.000Z) when the measurement was taken.
    public let timestampUnix: TimeInterval?
    
    /// Returns the horizontal accuracy of the location in meters; `nil` if the lateral location is invalid.
    public let horizontalAccuracy: Double?
    
    /// Returns the lateral distance between the current location and the previous location in meters.
    public let relativeDistance: Double?
    
    /// Returns the latitude coordinate of the current location; `nil` if *only* relative distance
    /// should be recorded.
    public let latitude: Double?
    
    /// Returns the longitude coordinate of the current location; `nil` if *only* relative distance
    /// should be recorded.
    public let longitude: Double?
    
    /// Returns the vertical accuracy of the location in meters; `nil` if the altitude is invalid.
    public let verticalAccuracy: Double?
    
    /// Returns the altitude of the location in meters. Can be positive (above sea level) or negative (below sea level).
    public let altitude: Double?
    
    /// Sum of the relative distance measurements if the participant is supposed to be moving.
    /// Otherwise, this value will be `nil`.
    public let totalDistance: Double?
    
    /// Returns the course of the location in degrees true North; `nil` if course is invalid.
    /// - Range: 0.0 - 359.9 degrees, 0 being true North.
    public let course: Double?
    
    /// Returns the bearing to the location from the previous location in radians (clockwise from) true North.
    /// - Range: [0.0..2π), 0 being true North.
    public let bearingRadians: Double?
    
    /// Returns the speed of the location in meters/second; `nil` if speed is invalid.
    public let speed: Double?
    
    /// Returns the floor of the building where the location was recorded; `nil` if floor is not available.
    public let floor: Int?
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case uptime, timestamp, stepPath, timestampDate, timestampUnix, horizontalAccuracy, relativeDistance, latitude, longitude, verticalAccuracy, altitude, totalDistance, course, bearingRadians, speed, floor
    }
    
    fileprivate init(uptime: TimeInterval?, timestamp: TimeInterval?, stepPath: String, timestampDate: Date?, timestampUnix: TimeInterval?, horizontalAccuracy: Double?, relativeDistance: Double?, latitude: Double?, longitude: Double?, verticalAccuracy: Double?, altitude: Double?, totalDistance: Double?, course: Double?, bearingRadians: Double?, speed: Double?, floor: Int?) {
        self.uptime = uptime
        self.timestamp = timestamp
        self.stepPath = stepPath
        self.timestampDate = timestampDate
        self.timestampUnix = timestampUnix
        self.horizontalAccuracy = horizontalAccuracy
        self.relativeDistance = relativeDistance
        self.latitude = latitude
        self.longitude = longitude
        self.verticalAccuracy = verticalAccuracy
        self.altitude = altitude
        self.totalDistance = totalDistance
        self.course = course
        self.bearingRadians = bearingRadians
        self.speed = speed
        self.floor = floor
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - uptime: The clock uptime.
    ///     - timestamp: Relative time to when the recorder was started.
    ///     - stepPath: An identifier marking the current step.
    ///     - location: The `CLLocation` to record.
    ///     - previousLocation: The previous `CLLocation` or `nil` if this is the first sample.
    ///     - totalDistance: Sum of the relative distance measurements.
    ///     - relativeDistanceOnly: Whether or not **only** relative distance should be recorded. Default = `true`
    public init(uptime: TimeInterval?, timestamp: TimeInterval?, stepPath: String, location: CLLocation, previousLocation: CLLocation?, totalDistance: Double?, relativeDistanceOnly: Bool = true) {
        self.uptime = uptime
        self.timestamp = timestamp
        self.stepPath = stepPath
        self.totalDistance = totalDistance
        self.timestampDate = location.timestamp
        self.timestampUnix = location.timestamp.timeIntervalSince1970
        self.speed = location.speed >= 0 ? location.speed : nil
        self.course = location.course >= 0 ? location.course : nil
        self.floor = location.floor?.level
        
        // Record the horizontal accuracy and relative distance
        if location.horizontalAccuracy >= 0 {
            self.horizontalAccuracy = location.horizontalAccuracy
            if let previous = previousLocation, previous.horizontalAccuracy >= 0 {
                self.bearingRadians = previous.rsd_bearingInRadians(to: location)
                self.relativeDistance = location.distance(from: previous)
            } else {
                self.bearingRadians = nil
                self.relativeDistance = nil
            }
            if relativeDistanceOnly {
                self.latitude = nil
                self.longitude = nil
            } else {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            }
        } else {
            self.horizontalAccuracy = nil
            self.bearingRadians = nil
            self.relativeDistance = nil
            self.latitude = nil
            self.longitude = nil
        }
        
        // Record the vertical accuracy
        if location.verticalAccuracy >= 0 {
            self.verticalAccuracy = location.verticalAccuracy
            self.altitude = location.altitude
        } else {
            self.verticalAccuracy = nil
            self.altitude = nil
        }
    }
}

extension CLLocation {
    static func rsd_toRadians(from degrees: CLLocationDegrees) -> Double {
        return (degrees / 180.0) * .pi
    }
    
    static func rsd_toDegrees(from radians: Double) -> CLLocationDegrees {
        return (radians / .pi) * 180.0
    }
    
    func rsd_bearingInRadians(to endLocation: CLLocation) -> Double {
        // https://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
        let theta_a = CLLocation.rsd_toRadians(from: self.coordinate.latitude)
        let La = CLLocation.rsd_toRadians(from: self.coordinate.longitude)
        let theta_b = CLLocation.rsd_toRadians(from: endLocation.coordinate.latitude)
        let Lb = CLLocation.rsd_toRadians(from: endLocation.coordinate.longitude)
        let delta_L = Lb - La
        let X = cos(theta_b) * sin(delta_L)
        let Y = cos(theta_a) * sin(theta_b) - sin(theta_a) * cos(theta_b) * cos(delta_L)
        
        return atan2(X, Y)
    }
}


// Documentation and Tests

// TODO: syoung 09/27/2019 Look into whether or not there is a simple way to use the Documentable protocols in other frameworks.
extension RSDDistanceRecord { //: DocumentableStruct {
    
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func examples() -> [Encodable] {
        let now = Date()
        let example = RSDDistanceRecord(uptime: 99494.629004376795, timestamp: 52.422324001789093, stepPath: "Cardio 12MT/run/runDistance", timestampDate: now, timestampUnix: now.timeIntervalSince1970, horizontalAccuracy: 6, relativeDistance: 2.1164507282484935, latitude: nil, longitude: nil, verticalAccuracy: 3, altitude: 23.375564581136974, totalDistance: 63.484948023273581, course: 76.873546882061802, bearingRadians: 1.3416965, speed: 1.0289180278778076, floor: 3)
        
        return [example]
    }
}
