//
//  RSDPermissionType.swift
//  ResearchSuite
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

/// `RSDPermissionType` is a generic configuration object with information about a given permission.
/// The permission type can be used by the app to handle gracefully requesting authorization from
/// the user for access to sensors and hardware required by the app.
public protocol RSDPermissionType {
    
    /// An identifier for the permission.
    var identifier: String { get }
}

/// Standard permission types
public enum RSDStandardPermissionType: String, RSDPermissionType, Codable {
    
    /// “Privacy - Camera Usage Description”
    /// Specifies the reason for your app to access the device’s camera.
    /// - seealso: `NSCameraUsageDescription`
    case camera
    
    /// “Privacy - Motion Usage Description”
    /// Specifies the reason for your app to access the device’s accelerometer.
    /// - seealso: `NSMotionUsageDescription`
    case coremotion
    
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
    
    /// “Privacy - Photo Library Usage Description”
    /// Specifies the reason for your app to access the user’s photo library.
    /// - seealso: `NSPhotoLibraryUsageDescription`
    case photoLibrary
    
    /// An identifier for the permission.
    public var identifier: String {
        return rawValue
    }
}
