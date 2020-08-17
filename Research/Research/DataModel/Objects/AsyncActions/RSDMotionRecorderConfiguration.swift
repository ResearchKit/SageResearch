//
//  RSDMotionRecorderConfiguration.swift
//  Research
//
//  Copyright © 2018-2020 Sage Bionetworks. All rights reserved.
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
import JsonModel

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
public enum RSDMotionRecorderType : String, Codable, StringEnumSet {
    
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
    
    /// Calculated vector for the participant's acceleration in the coordinates of the device.
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
@available(iOS 10.0, *)
public struct RSDMotionRecorderConfiguration : RSDRestartableRecorderConfiguration, Codable {
    
    /// A short string that uniquely identifies the asynchronous action within the task. If started
    /// asynchronously, then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    public let identifier: String
    
    /// The standard permission type associated with this configuration.
    public private(set) var asyncActionType: RSDAsyncActionType = .motion
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    public var startStepIdentifier: String?
    
    /// An identifier marking the step at which to stop the action. If `nil`, then the action will be
    /// stopped when the task is stopped.
    public var stopStepIdentifier: String?
    
    /// Should the file used in a previous run of a recording be deleted?
    /// Default = `true`.
    public var shouldDeletePrevious: Bool {
        return _shouldDeletePrevious ?? true
    }
    private let _shouldDeletePrevious: Bool?
    
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
    public var permissionTypes: [RSDPermissionType] {
        #if os(iOS)
            return [RSDStandardPermissionType.motion]
        #else
            return []
        #endif
    }
    
    /// Set the flag to `true` to encode the samples as a CSV file.
    public var usesCSVEncoding : Bool?
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, asyncActionType = "type", recorderTypes, startStepIdentifier, stopStepIdentifier, frequency, _requiresBackgroundAudio = "requiresBackgroundAudio", usesCSVEncoding, _shouldDeletePrevious = "shouldDeletePrevious"
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: The configuration identifier.
    ///     - recorderTypes: The `CoreMotion` device sensor types to include with this configuration.
    ///     - requiresBackgroundAudio: Whether or not the recorder requires background audio. Default = `false`.
    ///     - frequency: The sampling frequency of the motion sensors.
    public init(identifier: String, recorderTypes: Set<RSDMotionRecorderType>?, requiresBackgroundAudio: Bool = false, frequency: Double? = nil, shouldDeletePrevious: Bool? = nil) {
        self.identifier = identifier
        self.recorderTypes = recorderTypes
        self._requiresBackgroundAudio = requiresBackgroundAudio
        self.frequency = frequency
        self._shouldDeletePrevious = shouldDeletePrevious
    }
    
    /// Do nothing. No validation is required for this recorder.
    public func validate() throws {
    }
}

extension RSDMotionRecorderConfiguration : SerializableAsyncActionConfiguration {
}

extension RSDMotionRecorderType : DocumentableStringEnum {
}

extension RSDMotionRecorderConfiguration : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .identifier || key == .asyncActionType
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .asyncActionType:
            return .init(constValue: RSDAsyncActionType.motion)
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .recorderTypes:
            return .init(propertyType: .referenceArray(RSDMotionRecorderType.documentableType()))
        case .startStepIdentifier, .stopStepIdentifier:
            return .init(propertyType: .primitive(.string))
        case .frequency:
            return .init(propertyType: .primitive(.number))
        case ._requiresBackgroundAudio:
            return .init(defaultValue: .boolean(false))
        case .usesCSVEncoding:
            return .init(propertyType: .primitive(.boolean))
        case ._shouldDeletePrevious:
            return .init(defaultValue: .boolean(true))
        }
    }

    public static func examples() -> [RSDMotionRecorderConfiguration] {
        var example = RSDMotionRecorderConfiguration(identifier: "motion", recorderTypes: [.accelerometer, .gyro], requiresBackgroundAudio: true, frequency: 50)
        example.startStepIdentifier = "start"
        example.stopStepIdentifier = "stop"
        return [example]
    }
}

