//
//  RSDThemedUIStep.swift
//  ResearchStack2
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

import Foundation

/// `RSDThemedUIStep` is a UI step that supports theme customization of the color and/or images used.
public protocol RSDThemedUIStep : RSDUIStep {
    
    /// The view info used to create a custom step.
    var viewTheme: RSDViewThemeElement? { get }
    
    /// The color theme.
    var colorTheme: RSDColorThemeElement? { get }
    
    /// The image theme.
    var imageTheme: RSDImageThemeElement? { get }
}

/// `RSDUIThemeElement` is used to tell the application UI view controllers how to style a given step.
public protocol RSDUIThemeElement {
    
    /// The resource bundle to use for fetching the theme elements.
    var bundle: Bundle? { get }
}

/// `RSDViewThemeElement` tells the UI where to find the view controller to use when instantiating the
/// `RSDStepController`.
public protocol RSDViewThemeElement : RSDUIThemeElement {
    
    /// The storyboard view controller identifier or the nib name for this view controller.
    var viewIdentifier: String { get }
    
    /// If the storyboard identifier is non-nil then the view is assumed to be accessible within the storyboard
    /// via the `viewIdentifier`.
    var storyboardIdentifier: String? { get }
}

/// `RSDColorThemeElement` tells the UI what the background color and foreground color are for a given view as
/// well as whether or not the foreground elements should use "light style".
public protocol RSDColorThemeElement : RSDUIThemeElement {
    

    #if os(watchOS)
    /// **Available** for watchOS.
    ///
    /// The background color for this step. If undefined then the background color appropriate to the light
    /// style will be used.
    /// - returns: The color or `nil` if undefined.
    func backgroundColor() -> UIColor?
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// The background color for this step. If undefined then the background color appropriate to the light
    /// style will be used.
    /// - returns: The color or `nil` if undefined.
    func backgroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor?
    #endif
    

    #if os(watchOS)
    /// **Available** for watchOS.
    ///
    /// The foreground color for this step. If undefined then the foreground color appropriate to the light
    /// style will be used.
    /// - returns: The color or `nil` if undefined.
    func foregroundColor() -> UIColor?
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// The foreground color for this step. If undefined then the foreground color appropriate to the light
    /// style will be used.
    /// - returns: The color or `nil` if undefined.
    func foregroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor?
    #endif
    
    /// Hint for whether or not the view uses light style for things like the progress bar and navigation buttons.
    var usesLightStyle: Bool { get }
}

/// A hint as to where the UI should place an image.
public enum RSDImagePlacementType : String, Codable, RSDStringEnumSet {
    
    /// Smaller presentation of an icon image before the content.
    case iconBefore
    
    /// Smaller presentation of an icon image after the content.
    case iconAfter
    
    /// Fullsize in the background.
    case fullsizeBackground
    
    /// Top half of the background.
    case topBackground
    
    /// Return all the types defined in this enum.
    public static var all: Set<RSDImagePlacementType> {
        return [.iconBefore, .iconAfter, .fullsizeBackground, .topBackground]
    }
}

extension RSDImagePlacementType : RSDDocumentableStringEnum {
}

/// `RSDImageThemeElement` extends the UI step to include an image.
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
    
    #if os(watchOS)
    /// **Available** for watchOS.
    ///
    /// The animated images to display.
    /// - returns: The images for this step.
    func images() -> [UIImage]
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// The animated images to display.
    /// - returns: The images for this step.
    func images(compatibleWith traitCollection: UITraitCollection?) -> [UIImage]
    #endif
}
