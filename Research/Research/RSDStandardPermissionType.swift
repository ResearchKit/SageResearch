//
//  RSDPermissionType.swift
//  ResearchStack2
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

/// General-purpose enum for authorization status.
public enum RSDAuthorizationStatus : Int {
    
    /// Standard mapping of the authorization status.
    case authorized, notDetermined, restricted, denied
    
    /// There is a cached value for the authorization status that was previously denied but the user may
    /// have since updated the Settings to allow permission.
    case previouslyDenied
    
    /// Is the authorization status blocking the activity that requires it? This will return true if the
    /// status is restricted, denied, or previously denied.
    public func isDenied() -> Bool {
        switch self {
        case .authorized, .notDetermined:
            return false
        default:
            return true
        }
    }
}

/// Standard permission types.
///
/// - note: This framework intentionally does not include any direct reference to Health Kit.
///         First, including Health Kit in applications that do not use that SDK makes it
///         confusing and difficult for researchers to set up the app. Second, the goal of
///         this framework is to include a model that is platform-agnostic and can be used
///         independently of the device. (syoung 11/1/7/2017)
///
public enum RSDStandardPermissionType: String, RSDPermissionType, Codable {
    
    /// “Privacy - Camera Usage Description”
    /// Specifies the reason for your app to access the device’s camera.
    /// - seealso: `NSCameraUsageDescription`
    case camera

    /// “Privacy - Location When In Use Usage Description”
    /// Specifies the reason for your app to access the user’s location information while your app is in use.
    /// - seealso: `NSLocationWhenInUseUsageDescription`
    case locationWhenInUse
    
    /// “Privacy - Location Always Usage Description”
    /// Specifies the reason for your app to access the user’s location information at all times.
    /// - seealso: `NSLocationAlwaysUsageDescription`
    case location
    
    /// “Privacy - Microphone Usage Description”
    /// Specifies the reason for your app to access any of the device’s microphones.
    /// - seealso: `NSMicrophoneUsageDescription`
    case microphone
    
    /// “Privacy - Motion Usage Description”
    /// Specifies the reason for your app to access the device’s accelerometer.
    /// - seealso: `NSMotionUsageDescription`
    case motion
    
    /// “Privacy - Photo Library Usage Description”
    /// Specifies the reason for your app to access the user’s photo library.
    /// - seealso: `NSPhotoLibraryUsageDescription`
    case photoLibrary
    
    /// An identifier for the permission.
    public var identifier: String {
        return rawValue
    }
    
    /// The mapped async action type for this permission
    public var asyncActionType: RSDAsyncActionType {
        return RSDAsyncActionType(rawValue: self.rawValue)
    }
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDStandardPermissionType] {
        return [.camera, .locationWhenInUse, .location, .microphone, .motion, .photoLibrary]
    }
}

extension RSDStandardPermissionType : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}

/// A Codable struct that can be used to store messaging information specific to the use-case specific to
/// the associated activity, task, or step.
public struct RSDStandardPermission : Codable {
    
    private enum CodingKeys : String, CodingKey {
        case permissionType
        case title
        case reason
        case _restrictedMessage = "restrictedMessage"
        case _deniedMessage = "deniedMessage"
    }
    
    public static let camera = RSDStandardPermission(permissionType: .camera)
    public static let microphone = RSDStandardPermission(permissionType: .microphone)
    public static let motion = RSDStandardPermission(permissionType: .motion)
    public static let photoLibrary = RSDStandardPermission(permissionType: .photoLibrary)
    public static let location = RSDStandardPermission(permissionType: .location)
    public static let locationWhenInUse = RSDStandardPermission(permissionType: .locationWhenInUse)

    /// Default initializer.
    public init(permissionType : RSDStandardPermissionType, title: String? = nil, reason: String? = nil, deniedMessage: String? = nil, restrictedMessage: String? = nil) {
        self.permissionType = permissionType
        self.title = title
        self.reason = reason
        self._deniedMessage = deniedMessage
        self._restrictedMessage = restrictedMessage
    }
    
    /// The permission type for this permission.
    public let permissionType : RSDStandardPermissionType
    
    /// A title for this permission.
    public let title: String?
    
    /// Additional reason for requiring the permission.
    public let reason: String?
    
    /// The message to show when displaying an alert that the user cannot run a step or task because their
    /// access is restricted.
    public var restrictedMessage: String {
        if let message = _restrictedMessage { return message }
        switch self.permissionType {
        case .camera:
            return Localization.localizedString("CAMERA_PERMISSION_RESTRICTED")
        case .location, .locationWhenInUse:
            return Localization.localizedString("LOCATION_PERMISSION_RESTRICTED")
        case .microphone:
            return Localization.localizedString("MICROPHONE_PERMISSION_RESTRICTED")
        case .photoLibrary:
            return Localization.localizedString("PHOTO_LIBRARY_PERMISSION_RESTRICTED")
            
        default:
            // permissions that are not currently part of restricted access. For these cases,
            // return a general-purpose message.
            assertionFailure("\(self.permissionType) is not expected to be restricted. Please fix.")
            return Localization.localizedString("GENERAL_PERMISSION_RESTRICTED")
        }
    }
    private var _restrictedMessage: String?
    
    /// The message to show when displaying an alert that the user cannot run a step or task because their
    /// access is denied.
    public var deniedMessage: String {
        if let message = _deniedMessage { return message }
        switch self.permissionType {
        case .camera:
            return Localization.localizedString("CAMERA_PERMISSION_DENIED")
        case .location:
            return Localization.localizedString("LOCATION_BACKGROUND_PERMISSION_DENIED")
        case .locationWhenInUse:
            return Localization.localizedString("LOCATION_IN_USE_PERMISSION_DENIED")
        case .microphone:
            return Localization.localizedString("MICROPHONE_PERMISSION_DENIED")
        case .motion:
            return Localization.localizedString("MOTION_PERMISSION_DENIED")
        case .photoLibrary:
            return Localization.localizedString("PHOTO_LIBRARY_PERMISSION_DENIED")
        }
    }
    private var _deniedMessage: String?
    
    /// Returns the message appropriate to the status.
    public func message(for status: RSDAuthorizationStatus) -> String? {
        switch status {
        case .denied, .previouslyDenied:
            return self.deniedMessage
        case .restricted:
            return self.restrictedMessage
        default:
            return nil
        }
    }
}

/// `RSDPermissionError` errors are thrown when a task, step, or async action does not have a permission that
/// is required to run the action.
public enum RSDPermissionError : Error {
    
    /// Permission denied.
    case notAuthorized(RSDStandardPermission, RSDAuthorizationStatus)
    
    /// The localized message for this error.
    public var localizedDescription: String {
        switch(self) {
        case .notAuthorized(let permission, let status):
            return permission.message(for: status) ?? "\(permission) : \(status)"
        }
    }
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "RSDPermissionErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .notAuthorized(_, let status):
            return status.rawValue
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        return ["NSDebugDescription": self.localizedDescription]
    }
}
