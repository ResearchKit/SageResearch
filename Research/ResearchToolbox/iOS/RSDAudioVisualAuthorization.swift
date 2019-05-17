//
//  RSDAudioVisualPermissionManager.swift
//  Research
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

import Foundation
import AVFoundation

/// `RSDAudioVisualAuthorization` is a wrapper for the AVFoundation library that allows a general-purpose
/// step or task to query this library for authorization if and only if that library is required by the
/// application.
///
/// - seealso: `RSDPermissionsStepViewController`
public struct RSDAudioVisualAuthorization {
    
    /// Returns authorization status for `.camera` and `.microphone` permissions.
    public static func authorizationStatus(for permission: RSDStandardPermissionType) -> RSDAuthorizationStatus {
        switch permission {
        case .camera:
            return _avAuthorizationStatus(for: .video)
        case .microphone:
            return _avAuthorizationStatus(for: .audio)
        default:
            return .notDetermined
        }
    }
    
    private static func _avAuthorizationStatus(for mediaType: AVMediaType) -> RSDAuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }
    
    public static func requestAuthorization(for permission: RSDStandardPermission, _ completion: @escaping ((RSDAuthorizationStatus, Error?) -> Void)) {
        switch permission.permissionType {
        case .camera:
            _requestAuthorization(for: .video, permission, completion)
        case .microphone:
            _requestAuthorization(for: .audio, permission, completion)
        default:
            assertionFailure("This is not a recognized audiovisual permission.")
            let error = RSDPermissionError.notAuthorized(permission, .denied)
            completion(.denied, error)
        }
    }
    
    private static func _requestAuthorization(for mediaType : AVMediaType, _ permission:RSDStandardPermission, _ completion: @escaping ((RSDAuthorizationStatus, Error?) -> Void)) {

        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                completion(.authorized, nil)
            } else {
                let error = RSDPermissionError.notAuthorized(permission, .denied)
                completion(.denied, error)
            }
        }
    }
}
