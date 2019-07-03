//
//  RSDFontRules.swift
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

import Foundation

#if os(macOS)
import AppKit
public typealias RSDFont = NSFont
#else
import UIKit
public typealias RSDFont = UIFont
#endif

/// The font rules object is a concrete implementation of the design rules used for a given version of the
/// SageResearch frameworks. A module can use this class as-is or override the class to enforce a set of rules
/// pinned to the tasks included within a module. This is important to allow a module to be validated against
/// a given UI/UX. The frameworks can later change to reflect new devices, OS changes, and design system
/// updates to incorporate the results of more design studies.
open class RSDFontRules  {
    
    /// The version for the font rules. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int
    
    public init(version: Int? = nil) {
        self.version = version ?? RSDColorMatrix.shared.currentVersion
    }
    
    #if os(iOS) || os(tvOS)
    /// On iOS and tvOS, this method allows for using a different font size depending upon the trait
    /// collection. Default implementation calls through to `font(for:)` but a module that is designed to
    /// run on an iPad or Apple TV could use this method to define a different set of fonts for those devices.
    ///
    /// - note: If future versions of the Sage Design System include a different set of fonts for iPad or
    /// Apple TV devices, this method should check for version and return the current implementation for
    /// the version before the version that is being implemented.
    ///
    /// - parameters:
    ///     - textType: The text type for the font.
    ///     - traitCollection: The trait collection for the label or button.
    /// - returns: The font to use for this text.
    @available(iOS 10.3, tvOS 10.2, *)
    open func font(for textType: RSDDesignSystem.TextType, compatibleWith traitCollection: UITraitCollection?) -> RSDFont {
        return self.font(for: textType)
    }
    #endif
    
    /// Returns the font to use for the given button type and state.
    ///
    /// - parameters:
    ///     - buttonType: The button type.
    ///     - state: The button state.
    /// - returns: The font to use for this text.
    open func buttonFont(for buttonType: RSDDesignSystem.ButtonType, state: RSDControlState) -> RSDFont {
        switch buttonType {
            
        case .primary, .secondary:
            return RSDFont.systemFont(ofSize: 20, weight: .bold)
            
        case .bodyLink:
            return baseFont(for: .body)
            
        case .headerLink:
            return baseFont(for: .smallHeader)
            
        case .toggle:
            switch state {
            case .selected:
                return RSDFont.systemFont(ofSize: 16, weight: .bold)
            default:
                return RSDFont.systemFont(ofSize: 16, weight: .regular)
            }
        }
    }
    
    /// Returns the font to use for a given text type.
    ///
    /// - parameter textType: The text type for the font.
    /// - returns: The font to use for this text.
    open func font(for textType: RSDDesignSystem.TextType) -> RSDFont {
        // TODO: syoung 07/03/2019 Implement dynamic text handling.
        return baseFont(for: textType)
    }
    
    /// Returns a font in the given size and weight in the font family specified for this design.
    /// Typically, you will want to use `font(for textType: RSDDesignSystem.TextType)` instead for
    /// copy and dynamic text. This method should only be used where the design calls for a
    /// specific size to match the graphic design of the view.
    ///
    /// - parameters:
    ///     - fontSize: The font size.
    ///     - weight: The font weight.
    /// - returns: The font to use for this size and weight.
    open func font(ofSize fontSize: CGFloat, weight: RSDFont.Weight) -> RSDFont {
        return RSDFont.systemFont(ofSize: fontSize, weight: weight)
    }
    
    /// Returns the base font for a given text type. This is the font size defined in the Sage
    /// Design System table. For dynamic fonts, this can be resized based upon user preferences by
    /// using the `font(for textType: RSDDesignSystem.TextType)` instead.
    ///
    /// This is *only* to be used directly where the text needs to fix within a specific size, but
    /// match the "style" of a given text type.
    ///
    /// - parameter textType: The text type for the font.
    /// - returns: The *base* font to use for this text.
    open func baseFont(for textType: RSDDesignSystem.TextType) -> RSDFont {
        switch textType {
            
        // Version 2
        case .largeNumber:
            return RSDFont.systemFont(ofSize: 72, weight: .light)
        case .smallNumber:
            return RSDFont.systemFont(ofSize: 48, weight: .light)
        case .xSmallNumber:
            return RSDFont.systemFont(ofSize: 20, weight: .light)

        case .xLargeHeader:
            return RSDFont.systemFont(ofSize: 30, weight: .bold)
        case .largeHeader:
            return RSDFont.systemFont(ofSize: 24, weight: .bold)
        case .mediumHeader:
            return RSDFont.systemFont(ofSize: 18, weight: .bold)
        case .smallHeader:
            return RSDFont.systemFont(ofSize: 16, weight: .bold)
        case .microHeader:
            return RSDFont.systemFont(ofSize: 14).rsd_smallCaps()
        
        case .largeBody:
            return RSDFont.systemFont(ofSize: 24, weight: .light)
        case .body:
            return RSDFont.systemFont(ofSize: 18)
        case .bodyDetail:
            return RSDFont.systemFont(ofSize: 16)
        case .italicDetail:
            return RSDFont.italicSystemFont(ofSize: 16)
        case .small, .hint:
            return RSDFont.systemFont(ofSize: 16)
        case .microDetail:
            return RSDFont.systemFont(ofSize: 14)
            
        // Version 1
        case .heading1:
            return RSDFont.systemFont(ofSize: 30, weight: .bold)
        case .heading2:
            return RSDFont.systemFont(ofSize: 24, weight: .bold)
        case .heading3:
            return RSDFont.systemFont(ofSize: 20, weight: .heavy)
        case .heading4:
            return RSDFont.systemFont(ofSize: 18, weight: .bold)
        case .fieldHeader:
            return RSDFont.systemFont(ofSize: 16, weight: .heavy)
        case .counter:
            return RSDFont.systemFont(ofSize: 80, weight: .light)
            
        default:
            assertionFailure("\(textType) is not defined. Returning `body` type.")
            return RSDFont.systemFont(ofSize: 18)
        }
    }
    
    /// Returns whether or not the specified text type is dynamic.
    /// - parameter textType: The text type for the font.
    open func isDynamic(_ textType: RSDDesignSystem.TextType) -> Bool {
        switch textType {
        case .xLargeHeader, .largeHeader, .mediumHeader, .smallHeader,
             .body, .bodyDetail, .italicDetail, .small, .hint, .microDetail:
            return true
        default:
            return false
        }
    }
}

#if os(macOS)
extension NSFont {
    
    func rsd_smallCaps() -> RSDFont {
        return self
    }
}
#else
extension UIFont {
    
    func rsd_smallCaps() -> RSDFont {
        let settings: [[UIFontDescriptor.FeatureKey : Int]] = [[.featureIdentifier: kLowerCaseType, .typeIdentifier: kLowerCaseSmallCapsSelector]]
        let attributes: [UIFontDescriptor.AttributeName : Any] = [.featureSettings: settings]
        let fontDescriptor = self.fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: fontDescriptor, size: pointSize)
    }
}
#endif


