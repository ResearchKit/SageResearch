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

struct ColorTile : Codable {
    let usesLightStyle : Bool
    let color : String
}

protocol InternalColorMapping : RSDDecodableBundleInfo {
    var customColor: ColorTile? { get }
    func style(for placement: RSDColorPlacement) -> RSDColorRules.Style
}

extension InternalColorMapping {
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
}

/// `RSDColorPlacementThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a dictionary of color placements to the color style for that placement.
public struct RSDColorPlacementThemeElementObject : RSDColorMappingThemeElement, RSDDecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, placement, customColor
    }
    
    /// The type for the class
    public let type: RSDColorMappingThemeElementType

    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    /// The color placement mapping.
    let placement: [String : RSDColorRules.Style]
    
    /// The custom color tile to use for a color placement.
    let customColor: ColorTile?

    /// Default initializer.
    ///
    /// - parameters:
    ///     - placement: The placement mapping for the sections of the view.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(placement: [String : RSDColorRules.Style],
                customColorName: String? = nil,
                usesLightStyle: Bool? = nil,
                bundleIdentifier: String? = nil) {
        self.type = .placementMapping
        self.placement = placement
        if let name = customColorName {
            self.customColor = ColorTile(usesLightStyle: usesLightStyle ?? false, color: name)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = nil
    }
    
}

extension RSDColorPlacementThemeElementObject : InternalColorMapping {
    
    func style(for placement: RSDColorPlacement) -> RSDColorRules.Style {
        if let style = self.placement[placement.stringValue] {
            return style
        }
        else {
            return ((self.customColor != nil) ? .custom : .white)
        }
    }
}

extension RSDColorPlacementThemeElementObject : RSDDocumentableDecodableObject {

    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    static func colorThemeExamples() -> [[String : RSDJSONValue]] {
        let exA: [String : RSDJSONValue] = [
            "type" : "placementMapping",
            "bundleIdentifier" : "FooModule",
            "customColor" : [ "color" : "sky", "usesLightStyle" : false],
            "placement" : [
                "header" : "primary",
                "body" : "white",
                "footer" : "white"
            ]
        ]
        return [exA]
    }

    static func examples() -> [[String : RSDJSONValue]] {
        return colorThemeExamples()
    }
}

/// `RSDSingleColorThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a single style for the entire view.
public struct RSDSingleColorThemeElementObject : RSDColorMappingThemeElement, RSDDecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, colorStyle, customColor
    }
    
    /// The type for the class
    public let type: RSDColorMappingThemeElementType
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    /// The color placement mapping.
    let colorStyle: RSDColorRules.Style?
    
    /// The custom color tile to use for a color placement.
    let customColor: ColorTile?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - colorStyle: The color style for this mapping.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(colorStyle: RSDColorRules.Style?,
                customColorName: String? = nil,
                usesLightStyle: Bool? = nil,
                bundleIdentifier: String? = nil) {
        self.type = .singleColor
        self.colorStyle = colorStyle
        if let name = customColorName {
            self.customColor = ColorTile(usesLightStyle: usesLightStyle ?? false, color: name)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = nil
    }
}

extension RSDSingleColorThemeElementObject : InternalColorMapping {
    
    func style(for placement: RSDColorPlacement) -> RSDColorRules.Style {
        return colorStyle ?? ((self.customColor != nil) ? .custom : .white)
    }
}

extension RSDSingleColorThemeElementObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func colorThemeExamples() -> [[String : RSDJSONValue]] {
        let exA: [String : RSDJSONValue] = [
            "type" : "singleColor",
            "bundleIdentifier" : "FooModule",
            "customColor" : [ "color" : "sky", "usesLightStyle" : false]
        ]
        let exB: [String : RSDJSONValue] = [
            "type" : "singleColor",
            "colorStyle" : "successGreen"
        ]
        return [exA, exB]
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        return colorThemeExamples()
    }
}

// TODO: syoung 03/26/2019 Remove once modules that use this color scheme are converted.
@available(*, deprecated)
extension RSDColorThemeElementObject : InternalColorMapping, RSDColorMappingThemeElement {
    
    var customColor: ColorTile? {
        guard let name = _backgroundColorName else { return nil }
        return ColorTile(usesLightStyle: self.usesLightStyle, color: name)
    }
    
    func style(for placement: RSDColorPlacement) -> RSDColorRules.Style {
        if let depStyle = self.colorStyle?[placement.stringValue] {
            switch depStyle {
            case .customBackground:
                return .custom
            case .lightBackground:
                return .white
            case .darkBackground:
                return .primary
            }
        }
        if _backgroundColorName != nil {
            return .custom
        }
        else {
            return usesLightStyle ? .primary : .white
        }
    }
}
