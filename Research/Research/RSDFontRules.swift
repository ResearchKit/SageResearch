//
//  RSDFontRules.swift
//  Research
//
//  Created by Shannon Young on 3/19/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import Foundation

#if os(macOS)
import AppKit
public typealias RSDFont = NSFont
#else
import UIKit
public typealias RSDFont = UIFont
#endif

/// The font rules object is a concrete implementation of the design rules used for a give version of the
/// SageResearch frameworks. A module can use this class as-is or override the class to enforce a set of rules
/// pinned to the tasks included within a module. This is important to allow a module to be validated against
/// a given UI/UX. The frameworks can later change to reflect new devices, OS changes, and design system
/// updates to incorporate the results of more design studies.
open class RSDFontRules  {
    public static let currentVersion: Int = 0
    
    /// The version for the font rules. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int
    
    public init(version: Int? = nil) {
        self.version = version ?? RSDFontRules.currentVersion
    }
    
    #if os(iOS) || os(tvOS)
    /// On iOS and tvOS, this method allows for using a different font size depending upon the trait
    /// collection. Default implementation calls through to `font(for:)` but a module that is designed to
    /// run on an iPad or Apple TV could use this method to define a diffent set of fonts for those devices.
    @available(iOS 10.3, tvOS 10.2, *)
    open func font(for textType: RSDDesignSystem.TextType, compatibleWith traitCollection: UITraitCollection?) -> RSDFont {
        return self.font(for: textType)
    }
    #endif
    
    /// Returns the font to use for a given text type.
    open func font(for textType: RSDDesignSystem.TextType) -> RSDFont {
        switch textType {
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
        case .body, .bodyDetail:
            return RSDFont.systemFont(ofSize: 18)
        case .small:
            return RSDFont.systemFont(ofSize: 14)
        case .microHeader:
            return RSDFont.systemFont(ofSize: 12, weight: .semibold).rsd_smallCaps()
        case .counter:
            return RSDFont.systemFont(ofSize: 80, weight: .light)
        }
    }
}


extension UIFont {
    
    func rsd_smallCaps() -> UIFont {
        let settings: [[UIFontDescriptor.FeatureKey : Int]] = [[.featureIdentifier: kLowerCaseType, .typeIdentifier: kLowerCaseSmallCapsSelector]]
        let attributes: [UIFontDescriptor.AttributeName : Any] = [.featureSettings: settings]
        let fontDescriptor = self.fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: fontDescriptor, size: pointSize)
    }
}
