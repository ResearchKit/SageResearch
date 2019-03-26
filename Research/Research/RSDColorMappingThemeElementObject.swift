//
//  RSDColorMappingThemeElementObject.swift
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
#else
import UIKit
#endif


/// `RSDColorMappingThemeElementObject` tells the UI what the background color and foreground color are for a
/// given view as well as whether or not the foreground elements should use "light style".
public struct RSDColorMappingThemeElementObject : RSDColorMappingThemeElement, RSDDecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case bundleIdentifier, colorMapping, customColor, colorStyle
    }
    
    struct ColorTile : Codable {
        let usesLightStyle : Bool
        let color : String
    }
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    /// The color placement mapping.
    let colorMapping: [String : RSDColorRules.Style]?
    
    /// The custom color tile to use for a color placement.
    let customColor: ColorTile?
    
    /// A color style defined for all color placements.
    let colorStyle: RSDColorRules.Style?
    
    #if os(watchOS) || os(macOS)
    /// **Available** for watchOS and macOS.
    ///
    /// The background color for this step. If undefined then the background color will be determined by the
    /// step view controller.
    /// - returns: The color or `nil` if undefined.
    public func backgroundColor(for placement: RSDColorPlacement, using colorRules: RSDColorRules) -> RSDColorTile? {
        if let tile = colorRules.mapping(for: self.style(for: placement)) {
            return tile.normal
        }
        else if let custom = self.customColor,
            let color = RSDColor.rsd_color(named: custom.color, in: self.bundle) {
            return RSDColorTile(color, usesLightStyle: custom.usesLightStyle)
        }
        else {
            return nil
        }
    }
    
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// The background color for this step. If undefined then the background color will be determined by the
    /// step view controller.
    /// - returns: The color or `nil` if undefined.
    public func backgroundColor(for placement: RSDColorPlacement, using colorRules: RSDColorRules, compatibleWith traitCollection: UITraitCollection?) -> RSDColorTile? {
        if let tile = colorRules.mapping(for: self.style(for: placement)) {
            return tile.normal
        }
        else if let custom = self.customColor,
            let color = RSDColor.rsd_color(named: custom.color, in: self.bundle, compatibleWith: traitCollection) {
            return RSDColorTile(color, usesLightStyle: custom.usesLightStyle)
        }
        else {
            return nil
        }
    }
    #endif
    
    func style(for placement: RSDColorPlacement) -> RSDColorRules.Style {
        if let mapping = self.colorMapping, let style = mapping[placement.stringValue] {
            return style
        }
        else {
            return self.colorStyle ?? ((self.customColor != nil) ? .custom : .white)
        }
    }
    

    /// Default initializer.
    ///
    /// - parameters:
    ///     - colorStyle: The color style for this view.
    public init(colorStyle: RSDColorRules.Style? = nil,
                colorMapping: [String : RSDColorRules.Style]? = nil) {
        self.colorStyle = colorStyle
        self.colorMapping = nil
        self.customColor = nil
        self.bundleIdentifier = nil
    }
    
    @available(*, deprecated)
    internal init(colorTheme: RSDColorThemeElementObject) {
        self.colorMapping = colorTheme.colorStyle?.mapValues {
            switch $0 {
            case .customBackground:
                return .custom
            case .lightBackground:
                return .white
            case .darkBackground:
                return .primary
            }
        }
        if let colorName = colorTheme._backgroundColorName {
            self.colorStyle = .custom
            self.customColor = ColorTile(usesLightStyle: colorTheme.usesLightStyle, color: colorName)
        }
        else {
            self.colorStyle = colorTheme.usesLightStyle ? .primary : .white
            self.customColor = nil
        }
        self.bundleIdentifier = colorTheme.bundleIdentifier
    }
}

extension RSDColorMappingThemeElementObject : RSDDocumentableDecodableObject {

    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    static func colorThemeExamples() -> [[String : RSDJSONValue]] {
        let exA: [String : RSDJSONValue] = [
            "bundleIdentifier" : "FooModule",
            "customColor" : [ "color" : "sky", "usesLightStyle" : false]
        ]
        let exB: [String : RSDJSONValue] = [
            "colorStyle" : "successGreen"
        ]
        let exC: [String : RSDJSONValue] = [
            "colorMapping" : [
                "header" : "primary",
                "body" : "white",
                "footer" : "white"
            ]
        ]
        return [exA, exB, exC]
    }

    static func examples() -> [[String : RSDJSONValue]] {
        return colorThemeExamples()
    }
}
