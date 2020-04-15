//
//  RSDFontRules.swift
//  ResearchPlatformContext
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
        return preferredFont(for: textType, compatibleWith: traitCollection)
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
            return font(ofSize: 20, weight: .bold)
            
        case .bodyLink:
            return baseFont(for: .body)
            
        case .headerLink:
            return baseFont(for: .smallHeader)
            
        case .toggle:
            switch state {
            case .selected:
                return font(ofSize: 16, weight: .bold)
            default:
                return font(ofSize: 16, weight: .regular)
            }
        }
    }
    
    /// Returns the font to use for a given text type.
    ///
    /// - parameter textType: The text type for the font.
    /// - returns: The font to use for this text.
    open func font(for textType: RSDDesignSystem.TextType) -> RSDFont {
        return preferredFont(for: textType)
    }
    
    /// Returns a font in the given size and weight in the font family specified for this design.
    /// Typically, you will want to use `font(for textType: RSDDesignSystem.TextType)` instead for
    /// copy and dynamic text. This method should only be used where the design calls for a
    /// specific size to match the graphic design of the view.
    ///
    /// - note: All other methods on this class will call through to this method, so for custom
    ///         fonts, you can override this method only if the only change is a custom font.
    ///
    /// - parameters:
    ///     - fontSize: The font size.
    ///     - weight: The font weight.
    /// - returns: The font to use for this size and weight.
    open func font(ofSize fontSize: CGFloat, weight: RSDFont.Weight = .regular) -> RSDFont {
        if self.version <= 1 {
            return RSDFont.systemFont(ofSize: fontSize, weight: weight)
        }
        else {
            return RSDFont.latoFont(ofSize: fontSize, weight: weight)
        }
    }
    
    /// Returns an italic font in the given size and weight in the font family specified for this design.
    /// Typically, you will want to use `font(for textType: RSDDesignSystem.TextType)` instead for
    /// copy and dynamic text. This method should only be used where the design calls for a
    /// specific size to match the graphic design of the view.
    ///
    /// - note: All other methods on this class will call through to this method, so for custom
    ///         fonts, you can override this method only if the only change is a custom font.
    ///
    /// - parameters:
    ///     - fontSize: The font size.
    ///     - weight: The font weight.
    /// - returns: The font to use for this size and weight.
    open func italicFont(ofSize fontSize: CGFloat, weight: RSDFont.Weight = .regular) -> RSDFont {
        if version <= 1 {
            return self.font(ofSize: fontSize, weight: weight).rsd_italic()
        }
        else {
            return RSDFont.italicLatoFont(ofSize: fontSize, weight: weight)
        }
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
            return font(ofSize: 72, weight: .light)
        case .smallNumber:
            return font(ofSize: 48, weight: .light)
        case .xSmallNumber:
            return font(ofSize: 20, weight: .light)

        case .xLargeHeader:
            return font(ofSize: 30, weight: .bold)
        case .largeHeader:
            return font(ofSize: 24, weight: .bold)
        case .mediumHeader:
            return font(ofSize: 18, weight: .bold)
        case .smallHeader:
            return font(ofSize: 16, weight: .bold)
        case .microHeader:
            return font(ofSize: 14).rsd_smallCaps()
        
        case .largeBody:
            return font(ofSize: 24, weight: .light)
        case .body:
            return font(ofSize: 18)
        case .bodyDetail:
            return font(ofSize: 16)
        case .italicDetail:
            return italicFont(ofSize: 16)
        case .small, .hint:
            return font(ofSize: 16)
        case .microDetail:
            return font(ofSize: 14)
            
        default:
            assertionFailure("\(textType) is not defined. Returning `body` type.")
            return font(ofSize: 18)
        }
    }
    
    #if os(iOS) || os(tvOS)
    
    /// Using a mapping of the base font size, look for the text style to use for that text type
    /// and return the font size ratio preferred by the user based on their accessibility settings.
    /// - parameter textType: The text type for the font.
    /// - returns: The ratio of preferred font size to base font size.
    open func preferredFontSizeRatio(for textType: RSDDesignSystem.TextType, compatibleWith traitCollection: UITraitCollection? = nil) -> CGFloat {
        guard let style = textStyle(for: textType),
            let base = baseSize[style.rawValue]
            else {
                return 1.0
        }
        let font = UIFont.preferredFont(forTextStyle: style, compatibleWith: traitCollection)
        return font.pointSize / base
    }
    
    private func preferredFont(for textType: RSDDesignSystem.TextType, compatibleWith traitCollection: UITraitCollection? = nil) -> RSDFont {
        let font = baseFont(for: textType)
        let sizeRatio = self.preferredFontSizeRatio(for: textType)
        let fontSize = round(font.pointSize * sizeRatio)
        return font.withSize(fontSize)
    }
    
    
    /// Returns the mapping of the text style that most closely aligns with the design system text type.
    @available(iOS 10.0, tvOS 10.2, *)
    private func textStyle(for textType: RSDDesignSystem.TextType) -> UIFont.TextStyle? {
        switch textType {
        case .xLargeHeader:
            #if os(iOS)
            return .largeTitle
            #else
            return .title1
            #endif
            
        case .largeHeader:
            return .title1
        case .mediumHeader:
            return .title2
        case .smallHeader:
            return .title3
        case .body:
            return .body
        case .bodyDetail, .italicDetail:
            return .callout
        case .small, .hint:
            return .footnote
        case .microDetail:
            return .caption1
        default:
            return nil
        }
    }
    
    /// Mapping of text style to font size on iPhone if the "Large Text" accessibility setting
    /// is turned off.
    private let baseSize: [String : CGFloat] = [
        "UICTFontTextStyleBody": 17.0,
        "UICTFontTextStyleCallout": 16.0,
        "UICTFontTextStyleCaption1": 12.0,
        "UICTFontTextStyleCaption2": 11.0,
        "UICTFontTextStyleFootnote": 13.0,
        "UICTFontTextStyleHeadline": 17.0,
        "UICTFontTextStyleSubhead": 15.0,
        "UICTFontTextStyleTitle0": 34.0,
        "UICTFontTextStyleTitle1": 28.0,
        "UICTFontTextStyleTitle2": 22.0,
        "UICTFontTextStyleTitle3": 20.0,
    ]
    
    #else
    
    private func preferredFont(for textType: RSDDesignSystem.TextType) -> RSDFont {
        return baseFont(for: textType)
    }
    
    #endif
}

#if os(macOS)
extension NSFont {
    
    func rsd_smallCaps() -> RSDFont {
        return self
    }
    
    func rsd_italic() -> RSDFont {
        return self
    }
}
#else
extension UIFont {
    
    public func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits)
            else {
                debugPrint("WARNING!!! Failed to create font with \(traits)")
                return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func rsd_smallCaps() -> RSDFont {
        let settings: [[UIFontDescriptor.FeatureKey : Int]] = [[.featureIdentifier: kLowerCaseType, .typeIdentifier: kLowerCaseSmallCapsSelector]]
        let attributes: [UIFontDescriptor.AttributeName : Any] = [.featureSettings: settings]
        let fontDescriptor = self.fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: fontDescriptor, size: pointSize)
    }
    
    func rsd_italic() -> RSDFont {
        return self.withTraits(traits: .traitItalic)
    }
}
#endif


