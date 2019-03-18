//
//  RSDColorMappingThemeElementObject.swift
//  Research
//
//  Created by Shannon Young on 3/18/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
        if let tile = colorRules.color(for: self.style(for: placement)) {
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
