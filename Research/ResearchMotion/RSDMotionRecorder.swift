//
//  RSDMotionRecorder.swift
//  RSDModuleValidation
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
import CoreMotion
import AVFoundation
import Research

extension RSDMotionRecorderConfiguration : RSDAsyncActionVendor {
    
    /// Instantiate a `RSDMotionRecorder`.
    /// - parameter taskViewModel: The current task path to use to initialize the controller.
    /// - returns: A new instance of `RSDMotionRecorder`.
    public func instantiateController(with taskViewModel: RSDPathComponent) -> RSDAsyncAction? {
        return RSDMotionRecorder(configuration: self, taskViewModel: taskViewModel, outputDirectory: taskViewModel.outputDirectory)
    }
}

extension Notification.Name {
    /// Notification name posted by a `RSDMotionRecorder` instance when it is starting. If you intend to
    /// listen for this notification in order to shut down passive motion recorders, you must pass
    /// nil for the operation queue so it gets handled synchronously on the calling queue.
    public static let RSDMotionRecorderWillStart = Notification.Name(rawValue: "RSDMotionRecorderWillStart")
}

extension RSDIdentifier {
    /// Identifier key used to pass a reference to the RSDMotionRecorder instance in the above notification's userInfo.
    public static let motionRecorderInstance: RSDIdentifier = "motionRecorderInstance"
}

/// `RSDMotionRecorder` is a subclass of `RSDSampleRecorder` that implements recording core motion
/// sensor data.
///
/// You will need to add the privacy permission for  motion sensors to the application `Info.plist`
/// file. As of this writing (syoung 02/09/2018), the required key is:
/// - `Privacy - Motion Usage Description`
///
/// - note: This recorder is only available on iOS devices. CoreMotion is not supported by other
///         platforms.
///
/// - seealso: `RSDMotionRecorderType`, `RSDMotionRecorderConfiguration`, and `RSDMotionRecord`.
@available(iOS 10.0, *)
public class RSDMotionRecorder : RSDSampleRecorder {
    /// The currently-running instance, if any. You should confirm that this is nil
    /// (on the main queue) before starting a passive recorder instance.
    public static var current: RSDMotionRecorder?
    
    /// The most recent device motion sample. This property is updated on the motion queue.
    /// This is an `@objc dynamic` property so that listeners can be set up using KVO to
    /// observe changes to this property.
    @objc dynamic public private(set) var currentDeviceMotion: CMDeviceMotion?
    
    /// The most recent accelerometer data sample. This property is updated on the motion queue.
    /// This is an `@objc dynamic` property so that listeners can be set up using KVO to
    /// observe changes to this property.
    @objc dynamic public private(set) var currentAccelerometerData: CMAccelerometerData?
    
    /// The most recent gyro data sample. This property is updated on the motion queue.
    /// This is an `@objc dynamic` property so that listeners can be set up using KVO to
    /// observe changes to this property.
    @objc dynamic public private(set) var currentGyroData: CMGyroData?
    
    /// The most recent magnetometer data sample. This property is updated on the motion queue.
    /// This is an `@objc dynamic` property so that listeners can be set up using KVO to
    /// observe changes to this property.
    @objc dynamic public private(set) var currentMagnetometerData: CMMagnetometerData?
    
    /// The motion sensor configuration for this recorder.
    public var motionConfiguration: RSDMotionRecorderConfiguration? {
        return self.configuration as? RSDMotionRecorderConfiguration
    }
    
    /// The recorder types to use for this recording. This will be set to the `recorderTypes`
    /// from the `coreMotionConfiguration`. If that value is `nil`, then the defaults are
    /// `[.accelerometer, .gyro]` because all other non-compass measurements can be calculated
    /// from the accelerometer and gyro.
    lazy public var recorderTypes: Set<RSDMotionRecorderType> = {
        return self.motionConfiguration?.recorderTypes ?? [.accelerometer, .gyro]
    }()
    
    /// The sampling frequency of the motion sensors. This will be set to the `frequency`
    /// from the `coreMotionConfiguration`. If that value is `nil`, then the default sampling
    /// rate is `100` samples per second.
    lazy public var frequency: Double = {
        return self.motionConfiguration?.frequency ?? 100
    }()
    
    /// For best results, only use a single motion manager to handle all motion sensor data.
    public private(set) var motionManager: CMMotionManager?
    
    /// The pedometer is used to request motion sensor permission since for motion sensors
    /// there is no method specifically intended for that purpose.
    private var pedometer: CMPedometer?
    
    /// The motion queue is the operation queue that is used for the motion updates callback.
    private let motionQueue = OperationQueue()
    
    /// Override to implement requesting permission to access the participant's motion sensors.
    override public func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        self.updateStatus(to: .requestingPermission , error: nil)
        if RSDMotionAuthorization.authorizationStatus() == .authorized {
            self.updateStatus(to: .permissionGranted , error: nil)
            completion(self, nil, nil)
        } else {
            RSDMotionAuthorization.requestAuthorization { [weak self] (authStatus, error) in
                guard let strongSelf = self else { return }
                let status: RSDAsyncActionStatus = (authStatus == .authorized) ? .permissionGranted : .failed
                strongSelf.updateStatus(to: status, error: error)
                completion(strongSelf, nil, error)
            }
        }
    }
    
    /// Override to start the motion sensor updates.
    override public func startRecorder(_ completion: @escaping ((RSDAsyncActionStatus, Error?) -> Void)) {
        guard self.motionManager == nil else {
            completion(.failed, RecorderError.alreadyRunning)
            return
        }
        
        // Tell the world that a new motion recorder instance is running.
        NotificationCenter.default.post(name: .RSDMotionRecorderWillStart, object: self, userInfo: [RSDIdentifier.motionRecorderInstance: self])
        
        // Call completion before starting all the sensors
        // then add a block to the main queue to start the sensors
        // on the next run loop.
        completion(.running, nil)
        DispatchQueue.main.async { [weak self] in
            self?._startNextRunLoop()
        }
    }
    
    private func _startNextRunLoop() {
        guard self.status <= .running else { return }
        RSDMotionRecorder.current = self

        // set up the motion manager and the frequency
        let updateInterval: TimeInterval = 1.0 / self.frequency
        let motionManager = CMMotionManager()
        self.motionManager = motionManager
        
        // start each sensor
        var deviceMotionStarted = false
        for motionType in recorderTypes {
            switch motionType {
            case .accelerometer:
                startAccelerometer(with: motionManager, updateInterval: updateInterval, completion: nil)
            case .gyro:
                startGyro(with: motionManager, updateInterval: updateInterval, completion: nil)
            case .magnetometer:
                startMagnetometer(with: motionManager, updateInterval: updateInterval, completion: nil)
            default:
                if !deviceMotionStarted {
                    deviceMotionStarted = true
                    startDeviceMotion(with: motionManager, updateInterval: updateInterval, completion: nil)
                }
            }
        }
        
        // Set up the interruption observer.
        self.setupInterruptionObserver()
    }
    
    func startAccelerometer(with motionManager: CMMotionManager, updateInterval: TimeInterval, completion: ((Error?) -> Void)?) {
        motionManager.stopAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.startAccelerometerUpdates(to: motionQueue) { [weak self] (data, error) in
            if data != nil, self?.status == .running {
                self?.currentAccelerometerData = data
                self?.recordRawSample(data!)
            } else if error != nil, self?.status != .failed {
                self?.didFail(with: error!)
            }
            completion?(error)
        }
    }
    
    func startGyro(with motionManager: CMMotionManager, updateInterval: TimeInterval, completion: ((Error?) -> Void)?) {
        motionManager.stopGyroUpdates()
        motionManager.gyroUpdateInterval = updateInterval
        motionManager.startGyroUpdates(to: motionQueue) { [weak self] (data, error) in
            if data != nil, self?.status == .running {
                self?.currentGyroData = data
                self?.recordRawSample(data!)
            } else if error != nil, self?.status != .failed {
                self?.didFail(with: error!)
            }
            completion?(error)
        }
    }
    
    func startMagnetometer(with motionManager: CMMotionManager, updateInterval: TimeInterval, completion: ((Error?) -> Void)?) {
        motionManager.stopMagnetometerUpdates()
        motionManager.magnetometerUpdateInterval = updateInterval
        motionManager.startMagnetometerUpdates(to: motionQueue) { [weak self] (data, error) in
            if data != nil, self?.status == .running {
                self?.currentMagnetometerData = data
                self?.recordRawSample(data!)
            } else if error != nil, self?.status != .failed {
                self?.didFail(with: error!)
            }
            completion?(error)
        }
    }
    
    func recordRawSample(_ data: RSDVectorData) {
        let sample = RSDMotionRecord(stepPath: currentStepPath, data: data, referenceClock: self.clock)
        self.writeSample(sample)
    }
    
    func startDeviceMotion(with motionManager: CMMotionManager, updateInterval: TimeInterval, completion: ((Error?) -> Void)?) {
        motionManager.stopDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = updateInterval
        let frame: CMAttitudeReferenceFrame = recorderTypes.contains(.magneticField) ? .xMagneticNorthZVertical : .xArbitraryZVertical
        motionManager.startDeviceMotionUpdates(using: frame, to: motionQueue) { [weak self] (data, error) in
            if data != nil, self?.status == .running {
                self?.currentDeviceMotion = data
                self?.recordDeviceMotionSample(data!)
            } else if error != nil, self?.status != .failed {
                self?.didFail(with: error!)
            }
            completion?(error)
        }
    }
    
    func recordDeviceMotionSample(_ data: CMDeviceMotion) {
        let frame = motionManager?.attitudeReferenceFrame ?? CMAttitudeReferenceFrame.xArbitraryZVertical
        let samples = recorderTypes.compactMap {
            RSDMotionRecord(stepPath: currentStepPath, data: data, referenceFrame: frame, sensorType: $0, referenceClock: self.clock)
        }
        self.writeSamples(samples)
    }
    
    /// Override to stop updating the motion sensors.
    override public func stopRecorder(_ completion: @escaping ((RSDAsyncActionStatus) -> Void)) {
        
        // Call completion immediately with a "stopping" status.
        completion(.stopping)
        
        DispatchQueue.main.async {
            
            self.stopInterruptionObserver()
            
            // Stop the updates synchronously
            if let motionManager = self.motionManager {
                for motionType in self.recorderTypes {
                    switch motionType {
                    case .accelerometer:
                        motionManager.stopAccelerometerUpdates()
                    case .gyro:
                        motionManager.stopGyroUpdates()
                    case .magnetometer:
                        motionManager.stopMagnetometerUpdates()
                    default:
                        motionManager.stopDeviceMotionUpdates()
                    }
                }
            }
            if RSDMotionRecorder.current == self {
                RSDMotionRecorder.current = nil
            }
            self.motionManager = nil
            
            // and then call finished.
            self.updateStatus(to: .finished, error: nil)
        }
    }
    
    /// Returns the string encoding format to use for this file. Default is `nil`. If this is `nil`
    /// then the file will be formatted using JSON encoding.
    override public func stringEncodingFormat() -> RSDStringSeparatedEncodingFormat? {
        if self.motionConfiguration?.usesCSVEncoding == true {
            return CSVEncodingFormat<RSDMotionRecord>()
        } else {
            return nil
        }
    }
    
    // MARK: Phone interruption
    
    private var _audioInterruptObserver: Any?
    
    func setupInterruptionObserver() {
        
        // If the task should cancel if interrupted by a phone call, then set up a listener.
        _audioInterruptObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            guard let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: rawValue), type == .began
                else {
                    return
            }

            // The motion sensor recorder is not currently designed to handle phone calls and resume. Until
            // there is a use-case for prioritizing pause/resume of this recorder (not currently implemented),
            // just stop the recorder. syoung 05/21/2019
            self?.didFail(with: RSDSampleRecorder.RecorderError.interrupted)
        })
    }
    
    func stopInterruptionObserver() {
        if let observer = _audioInterruptObserver {
            NotificationCenter.default.removeObserver(observer)
            _audioInterruptObserver = nil
        }
    }
}


/// A `RSDMotionRecord` is a `Codable` implementation of `RSDSampleRecord` that can be used
/// to record a sample from one of the core motion sensors or calculated vectors of the
/// `CMDeviceMotion` data object.
///
/// - example:
///
/// ```
///     // Example json for a codable record.
///        func testMotionRecord_Attitude() {
///            let json = """
///                {
///                    "timestamp" : 1.2498140833340585,
///                    "stepPath" : "Cardio Stair Step/heartRate.after/heartRate",
///                    "sensorType" : "attitude",
///                    "referenceCoordinate" : "North-West-Up",
///                    "heading" : 270.25,
///                    "eventAccuracy" : 4,
///                    "x" : 0.064788818359375,
///                    "y" : -0.1324615478515625,
///                    "z" : -0.9501953125,
///                    "w" : 1
///                }
///                """.data(using: .utf8)! // our data in native (JSON) format
/// ```
///
/// - seealso: "CodableMotionRecorderTests.swift" unit tests for additional examples.
public struct RSDMotionRecord : RSDSampleRecord, RSDDelimiterSeparatedEncodable {
    
    /// System clock time.
    public let uptime: TimeInterval?
    
    /// Time that the system has been awake since last reboot.
    public let timestamp: TimeInterval?
    
    /// An identifier marking the current step.
    public let stepPath: String
    
    /// The date timestamp when the measurement was taken (if available).
    public let timestampDate: Date?
    
    /// The sensor type for this record sample.
    /// - note: If `nil` then this is a decoded log file marker used to mark step transitions.
    public let sensorType: RSDMotionRecorderType?
    
    /// A number marking the sensor accuracy of the magnetic field sensor.
    public let eventAccuracy: Int?
    
    /// Used for an `attitude` record type to describe the reference frame.
    public let referenceCoordinate: RSDAttitudeReferenceFrame?
    
    /// The heading angle in the range [0,360) degrees with respect to the CMAttitude reference frame.
    /// A negative value is returned for `CMAttitudeReferenceFrame.xArbitraryZVertical` and
    /// `CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical` reference coordinates.
    public let heading: Double?
    
    /// The `x` component of the vector measurement for this sensor sample.
    public let x: Double?
    
    /// The `y` component of the vector measurement for this sensor sample.
    public let y: Double?
    
    /// The `z` component of the vector measurement for this sensor sample.
    public let z: Double?
    
    /// The `w` component of the vector measurement for this sensor sample.
    /// Used by the attitude quaternion.
    public let w: Double?
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case uptime, timestamp, stepPath, timestampDate, sensorType, eventAccuracy, referenceCoordinate, heading, x, y, z, w
    }
    
    fileprivate init(uptime: TimeInterval?, timestamp: TimeInterval?, stepPath: String, timestampDate: Date?, sensorType: RSDMotionRecorderType?, eventAccuracy: Int?, referenceCoordinate: RSDAttitudeReferenceFrame?, heading: Double?, x: Double?, y: Double?, z: Double?, w: Double?) {
        self.uptime = uptime
        self.timestamp = timestamp
        self.stepPath = stepPath
        self.timestampDate = timestampDate
        self.sensorType = sensorType
        self.eventAccuracy = eventAccuracy
        self.referenceCoordinate = referenceCoordinate
        self.heading = heading
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    /// Initialize from a raw sensor data point.
    /// - parameters:
    ///     - startUptime: System clock uptime when the recorder was started.
    ///     - stepPath: The current step path.
    ///     - data: The raw sensor data to record.
    public init(stepPath: String, data: RSDVectorData, referenceClock: RSDClock? = nil) {
        
        self.uptime = referenceClock?.relativeUptime(to: data.timestamp)
        self.timestamp = referenceClock?.zeroRelativeTime(to: data.timestamp) ?? data.timestamp
        self.stepPath = stepPath
        self.timestampDate = nil
        self.heading = nil
        self.eventAccuracy = nil
        self.referenceCoordinate = nil
        self.w = nil
        
        self.sensorType = data.sensorType
        self.x = data.vector.x
        self.y = data.vector.y
        self.z = data.vector.z
    }
    
    /// Initialize from a `CMDeviceMotion` for a given sensor type or calculated vector.
    /// - parameters:
    ///     - startUptime: System clock uptime when the recorder was started.
    ///     - stepPath: The current step path.
    ///     - data: The `CMDeviceMotion` data sample from which to record information.
    ///     - referenceFrame: The `CMAttitudeReferenceFrame` for this recording.
    ///     - sensorType: The recorder type for which to record the vector.
    public init?(stepPath: String, data: CMDeviceMotion, referenceFrame: CMAttitudeReferenceFrame, sensorType: RSDMotionRecorderType, referenceClock: RSDClock? = nil) {
        
        var eventAccuracy: Int?
        var referenceCoordinate: RSDAttitudeReferenceFrame?
        let vector: RSDVector
        var w: Double?
        var heading: Double?
        
        switch sensorType {
        case .attitude:
            vector = data.attitude.quaternion
            w = data.attitude.quaternion.w
            referenceCoordinate = RSDAttitudeReferenceFrame(frame: referenceFrame)
            eventAccuracy = Int(data.magneticField.accuracy.rawValue)
            if #available(iOS 11.0, *) {
                heading = (data.heading >= 0) ? data.heading : nil
            }
            
        case .gravity:
            vector = data.gravity
            
        case .magneticField:
            vector = data.magneticField.field
            eventAccuracy = Int(data.magneticField.accuracy.rawValue)
            if #available(iOS 11.0, *) {
                heading = data.heading
            }
            
        case .rotationRate:
            vector = data.rotationRate
            
        case .userAcceleration:
            vector = data.userAcceleration
            
        default:
            return nil
        }
        
        self.uptime = referenceClock?.relativeUptime(to: data.timestamp)
        self.timestamp = referenceClock?.zeroRelativeTime(to: data.timestamp) ?? data.timestamp
        self.stepPath = stepPath
        self.timestampDate = nil
        self.sensorType = sensorType
        self.eventAccuracy = eventAccuracy
        self.referenceCoordinate = referenceCoordinate
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
        self.w = w
        self.heading = heading
    }
}

/// A string-value representation for the attitude reference frame.
public enum RSDAttitudeReferenceFrame : String, Codable {
    
    /// Describes a reference frame in which the Z axis is vertical and the X axis points in
    /// an arbitrary direction in the horizontal plane.
    case xArbitraryZVertical = "Z-Up"
    
    /// Describes a reference frame in which the Z axis is vertical and the X axis points toward
    /// magnetic north.
    ///
    /// - note: Using this reference frame may require user interaction to calibrate the magnetometer.
    case xMagneticNorthZVertical = "North-West-Up"
    
    init(frame : CMAttitudeReferenceFrame) {
        switch frame {
        case .xMagneticNorthZVertical:
            self = .xMagneticNorthZVertical
        default:
            self = .xArbitraryZVertical
        }
    }
}

/// `RSDVector` is a convenience protocol for converting various CoreMotion sensor
/// values to a common schema.
public protocol RSDVector {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension CMAcceleration : RSDVector {
}

extension CMRotationRate : RSDVector {
}

extension CMQuaternion : RSDVector {
}

extension CMMagneticField : RSDVector {
}

// `RSDVector` is a convenience protocol for converting various CoreMotion sensor
/// data to a common schema.
public protocol RSDVectorData {
    
    /// Time at which the item is valid. (clock uptime)
    var timestamp: TimeInterval { get }
    
    /// The vector associated with this motion sensor
    var vector: RSDVector { get }
    
    /// The raw motion sensor type.
    var sensorType: RSDMotionRecorderType { get }
}

extension CMAccelerometerData : RSDVectorData {
    
    /// `self.acceleration`
    public var vector: RSDVector {
        return self.acceleration
    }
    
    /// `.accelerometer`
    public var sensorType: RSDMotionRecorderType {
        return .accelerometer
    }
}

extension CMGyroData : RSDVectorData {
    
    /// `self.rotationRate`
    public var vector: RSDVector {
        return self.rotationRate
    }
    
    /// `.gyro`
    public var sensorType: RSDMotionRecorderType {
        return .gyro
    }
}

extension CMMagnetometerData : RSDVectorData {
    
    /// `self.magneticField`
    public var vector: RSDVector {
        return self.magneticField
    }
    
    /// `.magnetometer`
    public var sensorType: RSDMotionRecorderType {
        return .magnetometer
    }
}


// Documentation and Tests

// TODO: syoung 09/27/2019 Look into whether or not there is a simple way to use the Documentable protocols in other frameworks.
extension RSDMotionRecord { //}: DocumentableStruct {
    
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    static func examples() -> [Encodable] {
        
        let uptime = RSDClock.uptime()
        let timestamp = 0.0
        
        let gyro = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .gyro, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let accelerometer = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .accelerometer, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let magnetometer = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .magnetometer, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let gravity = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .gravity, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let userAccel = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .userAcceleration, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let rotationRate = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .userAcceleration, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let attitude = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .attitude, eventAccuracy: nil, referenceCoordinate: .xArbitraryZVertical, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: 1)
        let magneticField = RSDMotionRecord(uptime: uptime, timestamp: timestamp, stepPath: "step1", timestampDate: nil, sensorType: .magneticField, eventAccuracy: 4, referenceCoordinate: nil, heading: 270, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: 1)
        
        return [gyro, accelerometer, magnetometer, gravity, userAccel, rotationRate, attitude, magneticField]
    }
}
