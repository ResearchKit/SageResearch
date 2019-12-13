//
//  RSDImageData.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// `RSDImageVendor` is a protocol for defining an abstract method for fetching an image.
@available(*, deprecated, message: "Use `RSDImageData` instead.")
public protocol RSDImageVendor : RSDImageData {
    
    /// The size of the image.
    var size: CGSize { get }
    
    /// Fetch the image.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the identifier and image, run on the main thread.
    func fetchImage(for size: CGSize, callback: @escaping ((String?, RSDImage?) -> Void))
}

/// The image data protocol is used to define a placeholder for image data.
public protocol RSDImageData {
    
    /// A unique identifier that can be used to validate that the image shown in a reusable view
    /// is the same image as the one fetched.
    var imageIdentifier: String { get }
}

/// A resource image data is embedded within a resource bundle using the given platform's standard
/// asset management tools.
public protocol RSDResourceImageData : RSDImageData, RSDResourceDataInfo {
}

extension RSDResourceImageData {
    
    /// The image identifier for a resource image is the `resourceName`.
    public var imageIdentifier: String {
        guard let bundleId = self.bundleIdentifier ?? self.packageName
            else {
                return self.resourceName
        }
        return "\(bundleId).\(self.resourceName)"
    }
    
    /// The Android resource type for an image is always "drawable".
    public var resourceType: RSDResourceNameType? {
        return .drawable
    }
}

/// This framework includes different decodables that implement both the `RSDResourceImageData`
/// protocol and the `RSDImageThemeElement` protocol. This shared protocol provides for a
/// consistent implementation for both by setting the `resourceName` to the same as the `imageName`.
public protocol RSDThemeResourceImageData : RSDImageThemeElement, RSDResourceImageData, RSDDecodableBundleInfo {
}

extension RSDThemeResourceImageData {
    
    public var resourceName: String {
        return self.imageName
    }
}
