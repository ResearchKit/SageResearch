//
//  RSDImage.swift
//  ResearchPlatformContext
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
public typealias RSDImage = NSImage
#else
import UIKit
public typealias RSDImage = UIImage
#endif

import JsonModel
import Research

extension RSDImage : RSDImageData {
    
    /// Returns `self.hash` as a string.
    public var imageIdentifier: String {
        return self.accessibilityIdentifier ?? "\(self.hash)"
    }
    
    #if os(macOS) || os(watchOS)
    var accessibilityIdentifier: String? {
        return nil
    }
    #endif
}

extension RSDImage : RSDImageThemeElement {

    /// The image name is the same as the image identifier.
    public var imageName: String {
        return imageIdentifier
    }
    
    /// Use `size`.
    public var imageSize: RSDSize? {
        return RSDSize(width: Double(self.size.width), height: Double(self.size.height))
    }
    
    /// MARK: Not used.
    
    public var placementType: RSDImagePlacementType? { return nil }
    public var factoryBundle: ResourceBundle? { return nil }
    public var bundleIdentifier: String? { return nil }
    public var packageName: String? { return nil }
}
