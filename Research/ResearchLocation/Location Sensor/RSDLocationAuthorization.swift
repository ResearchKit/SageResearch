//
//  RSDLocationAuthorization.swift
//  Research
//
//  Copyright © 2018, 2019 Sage Bionetworks. All rights reserved.
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
import CoreLocation
import Research

/// `RSDLocationAuthorization` is a wrapper for the CoreLocation library that allows a general-purpose
/// step or task to query this library for authorization if and only if that library is required by the
/// application.
///
/// - seealso: `RSDPermissionsStepViewController`
public final class RSDLocationAuthorization : RSDAuthorizationAdaptor {
    
    public static let shared = RSDLocationAuthorization()
    
    /// This adaptor is intended for checking for location permissions.
    private static let validPermissions: [RSDPermissionType] = [RSDStandardPermissionType.location, RSDStandardPermissionType.locationWhenInUse]
    public let permissions: [RSDPermissionType] = RSDLocationAuthorization.validPermissions
    
    private let locationManager: CLLocationManager = CLLocationManager()

    /// Returns the authorization status for the location manager.
    public func authorizationStatus(for permission: String) -> RSDAuthorizationStatus {
        guard let permissionType = RSDStandardPermissionType(rawValue: permission)
            else {
                debugPrint("'\(permission)' is not a valid standard permission type.")
                return .notDetermined
        }
        
        if !self.permissions.contains(where: { $0.identifier == permissionType.identifier }) {
            debugPrint("'\(permission)' is not a valid location permission type.")
            return .notDetermined
        }

        return RSDLocationAuthorization.authorizationStatus(for: permissionType)
    }
    
    /// Requests permission to access the motion sensors.
    public func requestAuthorization(for permission: RSDPermission, _ completion: @escaping ((RSDAuthorizationStatus, Error?) -> Void)) {
        guard let permissionType = RSDStandardPermissionType(rawValue: permission.identifier)
            else {
                let errStr = "'\(permission.identifier)' is not a valid standard permission type."
                let error = RSDPermissionError.notHandled(errStr)
                debugPrint(errStr)
                completion(.denied, error)
                return
        }
        
        RSDLocationAuthorization.requestAuthorization(for: permissionType, locationManager: self.locationManager, completion)
    }
    
    /// Returns authorization status for `.location` and `.locationWhenInUse` permissions.
    public static func authorizationStatus(for permission: RSDStandardPermissionType) -> RSDAuthorizationStatus {
        switch permission {
        case .location:
            return _locationAuthorizationStatus(true)
        case .locationWhenInUse:
            return _locationAuthorizationStatus(false)
        default:
            return .notDetermined
        }
    }
    
    private static func _locationAuthorizationStatus(_ requiresBackground: Bool) -> RSDAuthorizationStatus {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedWhenInUse:
            return requiresBackground ? .denied : .authorized
        default:
            return .authorized
        }
    }
    
    public static func requestAuthorization(for permissionType: RSDStandardPermissionType, locationManager: CLLocationManager, _ completion:@escaping ((RSDAuthorizationStatus, Error?) -> Void)) {
        if !self.validPermissions.contains(where: { $0.identifier == permissionType.identifier }) {
            let errStr = "'\(permissionType.identifier)' is not a valid location permission type."
            let error = RSDPermissionError.notHandled(errStr)
            debugPrint(errStr)
            completion(.denied, error)
            return
        }
        
        switch permissionType {
        case RSDStandardPermissionType.location:
            locationManager.requestAlwaysAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
        
        completion(self.authorizationStatus(for: permissionType), nil)
    }
}
