//
//  RSDDesignSystem.swift
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

/// A task that implements this module is expected to include a pointer to the design system UI/UX rules to
/// use that are specific to the tasks within this module.
public protocol RSDTaskDesign {
    
    /// Get the design system for a given task module.
    var designSystem: RSDDesignSystem { get }
}


/// The design rules are intended as a way of consolidating UI/UX design system rules in a logical grouping.
/// A task module can define a design system that should be used for the tasks defined within that module.  
open class RSDDesignSystem {
    
    /// Static marker that should be rev'd to whatever is the latest version for the design system views.
    public static let currentVersion = 1

    /// The version for the design system. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int
    
    /// The color rules associated with this version of the design system.
    open private(set) var colorRules: RSDColorRules
    
    /// The font rules associated with this version of the design system.
    open private(set) var fontRules: RSDFontRules
    
    public init(version: Int, colorRules: RSDColorRules, fontRules: RSDFontRules) {
        self.version = version
        self.colorRules = colorRules
        self.fontRules = fontRules
    }
    
    public init(palette: RSDColorPalette = RSDStudyConfiguration.shared.colorPalette) {
        let colorRules = RSDColorRules(palette: palette)
        self.version = colorRules.version
        self.colorRules = colorRules
        self.fontRules = RSDStudyConfiguration.shared.fontRules
    }
    
    /// The button type for the button. This refers to whether or not the button is used to represent a
    /// primary or secondary action.
    public enum ButtonType: String, Codable, CaseIterable {
        case primary, secondary, toggle, bodyLink, headerLink
    }
    
    /// The supported text types for the text fields and labels.
    public struct TextType : RawRepresentable, Codable, ExpressibleByStringLiteral, Hashable {
        public let rawValue: String
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        // Version 2
        public static let largeNumber: TextType = "largeNumber"
        public static let smallNumber: TextType = "smallNumber"
        public static let xLargeHeader: TextType = "xLargeHeader"
        public static let largeHeader: TextType = "largeHeader"
        public static let largeBody: TextType = "largeBody"
        public static let xSmallNumber: TextType = "xSmallNumber"
        public static let mediumHeader: TextType = "mediumHeader"
        public static let body: TextType = "body"
        public static let bodyDetail: TextType = "bodyDetail"
        public static let italicDetail: TextType = "italicDetail"
        public static let smallHeader: TextType = "smallHeader"
        public static let small: TextType = "small"
        public static let hint: TextType = "hint"    // placeholder
        public static let microHeader: TextType = "microHeader"
        public static let microDetail: TextType = "microDetail"
        
        // Version 1
        @available(*, deprecated, message: "Use `xLargeHeader`")
        public static let heading1: TextType = "heading1"
        
        @available(*, deprecated, message: "Use `largeHeader`")
        public static let heading2: TextType = "heading2"
        
        @available(*, deprecated, message: "Use `mediumHeader` or `largeHeader`")
        public static let heading3: TextType = "heading3"
        
        @available(*, deprecated, message: "Use `mediumHeader`")
        public static let heading4: TextType = "heading4"
        
        @available(*, deprecated, message: "Use `smallHeader`")
        public static let fieldHeader: TextType = "fieldHeader"
        
        @available(*, deprecated, message: "Use `largeNumber`")
        public static let counter: TextType = "counter"
    }
}
