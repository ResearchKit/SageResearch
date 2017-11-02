//
//  RSDUIThemeElement.swift
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

public protocol RSDUIThemeElement {
    
    /**
     The resource bundle to use for fetching the theme elements.
     */
    var bundle: Bundle? { get }
}

public protocol RSDDecodableBundleInfo {
    var bundleIdentifier : String? { get }
}

extension RSDDecodableBundleInfo {
    public var bundle: Bundle? {
        guard let identifier = bundleIdentifier else { return nil }
        return Bundle(identifier: identifier)
    }
}

public protocol RSDViewThemeElement : RSDUIThemeElement {
    
    /**
     The storyboard view controller identifier or the nib name for this view controller.
     */
    var viewIdentifier: String { get }
    
    /**
     If the storyboard identifier is non-nil then the view is assumed to be accessible within the storyboard via the `viewIdentifier`.
     */
    var storyboardIdentifier: String? { get }
}

public protocol RSDColorThemeElement : RSDUIThemeElement {
    
    /**
     The background color for this step. If undefined then the background color appropriate to the light style will be used.
     */
    func backgroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor?
    
    /**
     The foreground color for this step. If undefined then the foreground color appropriate to the light style will be used.
     */
    func foregroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor?
    
    /**
     Hint for whether or not the view uses light style for things like the progress bar and navigation buttons.
     */
    var usesLightStyle: Bool { get }
}

public enum RSDImagePlacementType : String, Codable {
    case iconBefore
    case iconAfter
    case fullsizeBackground
    case topBackground
}

/**
 Extends the UI step to include static images.
 */
public protocol RSDImageThemeElement : RSDUIThemeElement, RSDResizableImage {
    
    /**
     The preferred placement of the image. Default placement is `iconBefore` if undefined.
     */
    var placementType: RSDImagePlacementType? { get }
    
    /**
     The image size. If undefined then default sizing will be used.
     */
    var size: CGSize? { get }
}

public protocol RSDFetchableImageThemeElement : RSDImageThemeElement {
    
    /**
     A method for fetching the image.
     
     @param size        The size of the image to return.
     @param callback    The callback with the image, run on the main thread.
     */
    func fetchImage(for size: CGSize, callback: @escaping ((UIImage?) -> Void))
}

public protocol RSDAnimatedImageThemeElement : RSDImageThemeElement {
    
    /**
     The animation duration.
     */
    var animationDuration: TimeInterval { get }
    
    /**
     The animated images to display.
     @param traitCollection     The trait collection
     @return                    The images for this step.
     */
    func images(compatibleWith traitCollection: UITraitCollection?) -> [UIImage]
}
