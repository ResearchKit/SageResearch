//
//  RSDImageThemeElement.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDImageThemeElement` extends the UI step to include an image. 
///
/// - seealso: `RSDFetchableImageThemeElement` and `RSDAnimatedImageThemeElement`
public protocol RSDImageThemeElement : RSDUIThemeElement {
    
    /// A unique identifier that can be used to validate that the image shown in a reusable view
    /// is the same image as the one fetched.
    var imageIdentifier: String { get }
    
    /// The preferred placement of the image. Default placement is `iconBefore` if undefined.
    var placementType: RSDImagePlacementType? { get }
    
    /// The image size. If `.zero` then default sizing will be used.
    var size: CGSize { get }
}

/// `RSDFetchableImageThemeElement` defines an image that can be fetched asynchronously.
public protocol RSDFetchableImageThemeElement : RSDImageThemeElement, RSDImageVendor {
}

/// `RSDAnimatedImageThemeElement` defines a series of images that can be animated.
public protocol RSDAnimatedImageThemeElement : RSDImageThemeElement {
    
    /// The animation duration.
    var animationDuration: TimeInterval { get }
    
    /// This is used to set how many times the animation should be repeated where `0` means infinite.
    var animationRepeatCount: Int? { get }
    
    #if os(watchOS) || os(macOS)
    /// **Available** for watchOS and macOS.
    ///
    /// The animated images to display.
    /// - returns: The images for this step.
    func images() -> [RSDImage]
    
    #else
    /// **Available** for iOS and tvOS.
    ///
    /// The animated images to display.
    /// - returns: The images for this step.
    func images(compatibleWith traitCollection: UITraitCollection?) -> [RSDImage]
    #endif
}
