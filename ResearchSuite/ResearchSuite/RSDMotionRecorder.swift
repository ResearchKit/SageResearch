//
//  RSDMotionRecorder.swift
//  RSDModuleValidation
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
    
import Foundation
import CoreMotion

/// `RSDMotionRecorderType` is used to enumerate the sensors and calculated measurements
/// that can be recorded by the `RSDMotionRecorder`.
///
/// `RSDMotionRecorder` records each sample from either the raw CoreMotion sensors
/// (accelerometer, gyro, and magnetometer) or the calculated vectors returned when requesting
/// `CMDeviceMotion` data updates. The `CMDeviceMotion` data is split into the components
/// enumerated by this enum into a single vector (sensor or calculated) per type.
///
/// By default, the requested types are are saved to a single logging file as instances of
/// `RSDMotionRecord` structs.
///
/// Spliting the device motion into components in this manner stores the data in using a
/// consistent JSON schema that can represent the sensor data returned by both iOS and Android
/// devices. Thus, allowing research studies to target a broader audience. Additionally, this
/// schema allows for a single table to be used to store the data which can then be filtered
/// by type to perform calculations and DSP on the input sources.
///
public enum RSDMotionRecorderType : String, Codable, RSDEnumSet {
    
    /// Raw accelerometer reading. `CMAccelerometerData` accelerometer.
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_raw_accelerometer_events
    case accelerometer
    
    /// Raw gyroscope reading. `CMGyroData` rotationRate.
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events
    case gyro

    /// Raw magnetometer reading. `CMMagnetometerData` magneticField.
    /// - seealso: https://developer.apple.com/documentation/coremotion/cmmagnetometerdata
    case magnetometer
    
    /// Calculated orientation of the device using the gyro and magnetometer (if appropriate).
    ///
    /// This is included in the `CMDeviceMotion` data object.
    ///
    /// - note: If the `magneticField` is included in the configuration's list of desired
    /// recorder types then the reference frame is `.xMagneticNorthZVertical`. Otherwise,
    /// the motion recorder will use `.xArbitraryZVertical`.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    case attitude
    
    /// Calculated vector for the direction of gravity in the coordinates of the device.
    ///
    /// This is included in the `CMDeviceMotion` data object.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    case gravity
    
    /// The magnetic field vector with respect to the device for devices with a magnetometer.
    /// Note that this is the total magnetic field in the device's vicinity without device
    /// bias (Earth's magnetic field plus surrounding fields, without device bias),
    /// unlike `CMMagnetometerData` magneticField.
    ///
    /// This is included in the `CMDeviceMotion` data object.
    ///
    /// - note: If this recorder type is included in the configuration, then the attitude
    /// reference frame will be set to `.xMagneticNorthZVertical`. Otherwise, the magnetic
    /// field vector will be returned as `{ 0, 0, 0 }`.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    case magneticField
    
    /// The rotation rate of the device for devices with a gyro.
    ///
    /// This is included in the `CMDeviceMotion` data object.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    case rotationRate
    
    /// Calculated vector for the user's acceleration in the coordinates of the device.
    /// This is the acceleration component after subtracting the gravity vector.
    ///
    /// This is included in the `CMDeviceMotion` data object.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    case userAcceleration
    
    /// A list of all the enum values.
    public static var all: Set<RSDMotionRecorderType> {
        return [.accelerometer, .attitude, .gravity, .gyro, .magneticField, .magnetometer, .rotationRate, .userAcceleration]
    }
    
    /// List of the device motion types that are calculated from multiple sensors and returned
    /// by listening to device motion updates.
    ///
    /// - seealso: https://developer.apple.com/documentation/coremotion/getting_processed_device_motion_data
    public static var deviceMotionTypes: Set<RSDMotionRecorderType> {
        return [.attitude, .gravity, .magneticField, .rotationRate, .userAcceleration]
    }
    
    /// List of the raw motion sensor types.
    public static var rawSensorTypes: Set<RSDMotionRecorderType> {
        return [.accelerometer, .gyro, .magnetometer]
    }
}

/// `RSDMotionRecorder` is a subclass of `RSDSampleRecorder` that implements recording core motion
/// sensor data.
///
/// - note: This recorder is only available on iOS devices. Not supported by other platforms.
///
/// - seealso: `RSDMotionRecorderType`, `RSDMotionRecorderConfiguration`, and `RSDMotionRecord`.
@available(iOS 10.0, *)
public class RSDMotionRecorder : RSDSampleRecorder {

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
    private var motionManager: CMMotionManager?
    
    /// The pedometer is used to request motion sensor permission since for motion sensors
    /// there is no method specifically intended for that purpose.
    private var pedometer: CMPedometer?
    
    /// The motion queue is the operation queue that is used for the motion updates callback.
    private let motionQueue = OperationQueue()
    
    /// Override to implement requesting permission to access the user's motion sensors.
    override public func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        pedometer = CMPedometer()
        let now = Date()
        pedometer!.queryPedometerData(from: now.addingTimeInterval(-2*60), to: now) { [weak self] (_, error) in
            guard let strongSelf = self else { return }
            if let err = error {
                debugPrint("Failed to query pedometer: \(err)")
            }
            let status: RSDAsyncActionStatus = (error == nil) ? .permissionGranted : .failed
            strongSelf.updateStatus(to: status, error: error)
            completion(strongSelf, nil, error)
            strongSelf.pedometer = nil
        }
    }
    
    /// Override to start the motion sensor updates.
    override public func startRecorder(_ completion: @escaping ((RSDAsyncActionStatus, Error?) -> Void)) {
        guard self.motionManager == nil else {
            completion(.failed, RecorderError.alreadyRunning)
            return
        }
        
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
        let sample = RSDMotionRecord(startUptime: startUptime, stepPath: currentStepPath, data: data)
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
        let samples = recorderTypes.rsd_mapAndFilter {
            RSDMotionRecord(startUptime: startUptime, stepPath: currentStepPath, data: data, referenceFrame: frame, sensorType: $0) }
        self.writeSamples(samples)
    }
    
    /// Override to stop updating the motion sensors.
    override public func stopRecorder(_ completion: @escaping ((RSDAsyncActionStatus) -> Void)) {
        
        // Call completion immediately with a "stopping" status.
        completion(.stopping)
        
        DispatchQueue.main.async {
            
            // Stop the updates synchronously
            if let motionManager = self.motionManager {
                for motionType in self.recorderTypes {
                    switch motionType {
                    case .accelerometer:
                        motionManager.stopAccelerometerUpdates()
                    default:
                        motionManager.stopDeviceMotionUpdates()
                    }
                }
            }
            self.motionManager = nil
            
            // and then call finished.
            self.updateStatus(to: .finished, error: nil)
        }
    }
}

    
/// The default configuration to use for a `RSDMotionRecorder`.
///
/// - example:
///
/// ```
///     // Example json for a codable configuration.
///        let json = """
///             {
///                "identifier": "foo",
///                "type": "motion",
///                "startStepIdentifier": "start",
///                "stopStepIdentifier": "stop",
///                "requiresBackgroundAudio": true,
///                "recorderTypes": ["accelerometer", "gyro", "magnetometer"],
///                "frequency": 50
///            }
///            """.data(using: .utf8)! // our data in native (JSON) format
/// ```
public struct RSDMotionRecorderConfiguration : RSDRecorderConfiguration, RSDAsyncActionControllerVendor, Codable {
    
    /// A short string that uniquely identifies the asynchronous action within the task. If started
    /// asynchronously, then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    public let identifier: String
    
    /// The standard permission type associated with this configuration.
    public let type: RSDStandardPermissionType
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    public var startStepIdentifier: String?
    
    /// An identifier marking the step at which to stop the action. If `nil`, then the action will be
    /// stopped when the task is stopped.
    public var stopStepIdentifier: String?
    
    /// Whether or not the recorder requires background audio. Default = `false`.
    ///
    /// If `true` then background audio can be used to keep the recorder running if the screen is locked
    /// because of the idle timer turning off the device screen.
    ///
    /// If the app uses background audio, then the developer will need to turn `ON` the "Background Modes"
    /// under the "Capabilities" tab of the Xcode project, and will need to select "Audio, AirPlay, and
    /// Picture in Picture".
    ///
    public var requiresBackgroundAudio: Bool {
        return _requiresBackgroundAudio ?? false
    }
    private let _requiresBackgroundAudio: Bool?
    
    /// The `CoreMotion` device sensor types to include with this configuration. If `nil` then the
    /// `RSDMotionRecorder` defaults will be used.
    public var recorderTypes: Set<RSDMotionRecorderType>?
    
    /// The sampling frequency of the motion sensors. If `nil`, then `RSDMotionRecorder` default
    /// frequency will be used.
    public var frequency: Double?
    
    /// This recorder configuration requires `RSDStandardPermissionType.motion`.
    /// - note: The use of this recorder requires adding “Privacy - Motion Usage Description” to the
    ///         application "info.plist" file.
    public var permissions: [RSDPermissionType] {
        return [RSDStandardPermissionType.motion]
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, recorderTypes, startStepIdentifier, stopStepIdentifier, frequency, _requiresBackgroundAudio = "requiresBackgroundAudio"
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: The configuration identifier.
    ///     - recorderTypes: The `CoreMotion` device sensor types to include with this configuration.
    ///     - requiresBackgroundAudio: Whether or not the recorder requires background audio. Default = `false`.
    ///     - frequency: The sampling frequency of the motion sensors.
    public init(identifier: String, recorderTypes: Set<RSDMotionRecorderType>?, requiresBackgroundAudio: Bool = false, frequency: Double? = nil) {
        self.type = .motion
        self.identifier = identifier
        self.recorderTypes = recorderTypes
        self._requiresBackgroundAudio = requiresBackgroundAudio
        self.frequency = frequency
    }
    
    /// Do nothing. No validation is required for this recorder.
    public func validate() throws {
    }
    
    /// Instantiate a `RSDMotionRecorder`.
    /// - parameter taskPath: The current task path to use to initialize the controller.
    /// - returns: A new instance of `RSDMotionRecorder`.
    public func instantiateController(with taskPath: RSDTaskPath) -> RSDAsyncActionController? {
        return RSDMotionRecorder(configuration: self, taskPath: taskPath, outputDirectory: taskPath.outputDirectory)
    }
}

/// A `RSDMotionRecord` is a `Codable` implementation of `RSDSampleRecord` that can be used
/// to record a sample from one of the core motion sensors or calculated vectors of the
/// `CMDeviceMotion` data object.
public struct RSDMotionRecord : RSDSampleRecord {
    
    /// The clock uptime.
    public let uptime: TimeInterval
    
    /// Relative time to when the recorder was started.
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
    
    /// Used for a `attitude` record type to describe the reference frame.
    public let referenceCoordinate: RSDAttitudeReferenceFrame?
    
    /// The heading angle in the range [0,360] degrees with respect to the CMAttitude reference frame.
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
    
    private enum CodingKeys : String, CodingKey {
        case uptime, timestamp, stepPath, timestampDate, sensorType, eventAccuracy, referenceCoordinate, heading, x, y, z, w
    }
    
    fileprivate init(uptime: TimeInterval, timestamp: TimeInterval?, stepPath: String, timestampDate: Date?, sensorType: RSDMotionRecorderType?, eventAccuracy: Int?, referenceCoordinate: RSDAttitudeReferenceFrame?, heading: Double?, x: Double?, y: Double?, z: Double?, w: Double?) {
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
    public init(startUptime: TimeInterval, stepPath: String, data: RSDVectorData) {
        
        self.uptime = data.timestamp
        self.timestamp = data.timestamp - startUptime
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
    public init?(startUptime: TimeInterval, stepPath: String, data: CMDeviceMotion, referenceFrame: CMAttitudeReferenceFrame, sensorType: RSDMotionRecorderType) {
        
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
        
        self.uptime = data.timestamp
        self.timestamp = data.timestamp - startUptime
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
    /// - note: Using this reference frame may require device movement to calibrate the magnetometer.
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

extension RSDMotionRecorderType : RSDDocumentableEnum {
}

extension RSDMotionRecorderConfiguration : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .recorderTypes, .startStepIdentifier, .stopStepIdentifier, .frequency, ._requiresBackgroundAudio, .type]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .recorderTypes:
                if idx != 1 { return false }
            case .startStepIdentifier:
                if idx != 2 { return false }
            case .stopStepIdentifier:
                if idx != 3 { return false }
            case .frequency:
                if idx != 4 { return false }
            case ._requiresBackgroundAudio:
                if idx != 5 { return false }
            case .type:
                if idx != 6 { return false }
            }
        }
        return keys.count == 7
    }
    
    static func examples() -> [Encodable] {
        
        var example = RSDMotionRecorderConfiguration(identifier: "motion", recorderTypes: [.accelerometer, .gyro], requiresBackgroundAudio: true, frequency: 50)
        example.startStepIdentifier = "start"
        example.stopStepIdentifier = "stop"
        return [example]
    }
}

extension RSDMotionRecord : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.uptime, .timestamp, .stepPath, .timestampDate, .sensorType, .eventAccuracy, .referenceCoordinate, .heading, .x, .y, .z, .w]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .uptime:
                if idx != 0 { return false }
            case .timestamp:
                if idx != 1 { return false }
            case .stepPath:
                if idx != 2 { return false }
            case .timestampDate:
                if idx != 3 { return false }
            case .sensorType:
                if idx != 4 { return false }
            case .eventAccuracy:
                if idx != 5 { return false }
            case .referenceCoordinate:
                if idx != 6 { return false }
            case .heading:
                if idx != 7 { return false }
            case .x:
                if idx != 8 { return false }
            case .y:
                if idx != 9 { return false }
            case .z:
                if idx != 10 { return false }
            case .w:
                if idx != 11 { return false }
            }
        }
        return keys.count == 12
    }
    
    static func examples() -> [Encodable] {
        
        let uptime = ProcessInfo.processInfo.systemUptime
        
        let gyro = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .gyro, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let accelerometer = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .accelerometer, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let magnetometer = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .magnetometer, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let gravity = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .gravity, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let userAccel = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .userAcceleration, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let rotationRate = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .userAcceleration, eventAccuracy: nil, referenceCoordinate: nil, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: nil)
        let attitude = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .attitude, eventAccuracy: nil, referenceCoordinate: .xArbitraryZVertical, heading: nil, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: 1)
        let magneticField = RSDMotionRecord(uptime: uptime, timestamp: 0, stepPath: "step1", timestampDate: nil, sensorType: .magneticField, eventAccuracy: 4, referenceCoordinate: nil, heading: 270, x: 0.064788818359375, y: -0.1324615478515625, z: -0.9501953125, w: 1)
        
        return [gyro, accelerometer, magnetometer, gravity, userAccel, rotationRate, attitude, magneticField]
    }
}
