//
//  RSDImagePickerStep.swift
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

/// What source should be used for the image selection?
/// - note: The app is required to include the appropriate permission strings in its `Info.plist` file.
public enum RSDImagePickerSourceType : String, Codable {
    
    /// “Privacy - Camera Usage Description”
    /// Specifies the reason for your app to access the device’s camera.
    /// - seealso: `NSCameraUsageDescription`
    case camera
    
    /// “Privacy - Photo Library Usage Description”
    /// Specifies the reason for your app to access the user’s photo library.
    /// - seealso: `NSPhotoLibraryUsageDescription`
    case photoLibrary
}

/// The capture mode sets whether to capture video or a photo.
public enum RSDImagePickerMediaType : String, Codable {
    case photo
    case video
}

/// The image picker step protocol implements a step that is 
public protocol RSDImagePickerStep : RSDStandardPermissionsStep {
    
    /// What source should be used for picking an image? If nil, the default
    /// is `.camera`.
    var sourceType: RSDImagePickerSourceType? { get }
    
    /// What are the allowed media types?
    var mediaTypes: [RSDImagePickerMediaType]? { get }
}

extension RSDImagePickerStep {
    
    /// The default source type is `.camera`.
    public func defaultSourceType() -> RSDImagePickerSourceType {
        return .camera
    }
    
    /// The default media types are `[.photo]`.
    public func defaultMediaTypes() -> [RSDImagePickerMediaType] {
        return [.photo]
    }
    
    /// The standard permissions for this picker are determined by the source type.
    public var standardPermissions: [RSDStandardPermission]? {
        switch (self.sourceType ?? defaultSourceType()) {
        case .camera:
            let types = self.mediaTypes ?? defaultMediaTypes()
            if types.contains(.video) {
                return [.camera, .microphone]
            } else {
                return [.camera]
            }

        case .photoLibrary:
            return [.photoLibrary]
        }
    }
}
