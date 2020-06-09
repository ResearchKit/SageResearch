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
import JsonModel

/// The type of the color mapping theme element. This is used to decode a `RSDColorMappingThemeElement` using
/// a `RSDFactory`. It can also be used to customize the UI.
public struct RSDColorMappingThemeElementType : TypeRepresentable, Codable, Equatable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDColorPlacementThemeElementObject`.
    public static let placementMapping: RSDColorMappingThemeElementType = "placementMapping"
    
    /// Defaults to creating a `RSDSingleColorThemeElementObject`.
    public static let singleColor: RSDColorMappingThemeElementType = "singleColor"
    
    public static func allStandardTypes() -> [RSDColorMappingThemeElementType] {
        return [.placementMapping, .singleColor]
    }
}

extension RSDColorMappingThemeElementType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDColorMappingThemeElementType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        allStandardTypes().map{ $0.rawValue }
    }
}

public final class ColorMappingSerializer : AbstractPolymorphicSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `ColorMappingThemeElement` defines the colors to use on a given screen. Typically, this
        includes the background color for the header or a background color that is applied to the
        full screen.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        examples = [
            RSDColorPlacementThemeElementObject.examples().first!,
            RSDSingleColorThemeElementObject.examples().first!,
        ]
    }
    
    public private(set) var examples: [RSDColorMappingThemeElement]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDColorMappingThemeElementType.documentableType()))
    }
    
    public func add(_ example: SerializableColorMapping) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

public protocol SerializableColorMapping : RSDColorMappingThemeElement, PolymorphicRepresentable, Encodable {
    var type: RSDColorMappingThemeElementType { get }
}

public extension SerializableColorMapping {
    var typeName: String { return type.rawValue }
}

/// A color data object is a lightweight codable implementation for storing custom color data.
public struct RSDColorDataObject : Codable, RSDColorData {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case colorIdentifier = "color", usesLightStyle
    }
    
    /// The color identifier. Typically, the name in an asset catalog or a hexcode.
    public let colorIdentifier: String
    
    /// Whether or not text and images displayed on top of this color should use light style.
    public let usesLightStyle : Bool
    
    public init(colorIdentifier: String, usesLightStyle : Bool) {
        self.colorIdentifier = colorIdentifier
        self.usesLightStyle = usesLightStyle
    }
}

/// `RSDColorPlacementThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a dictionary of color placements to the color style for that placement.
public struct RSDColorPlacementThemeElementObject : SerializableColorMapping, DecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, packageName, placement, customColor
    }

    /// The type for the class.
    public let type: RSDColorMappingThemeElementType

    /// The color placement mapping.
    let placement: [String : RSDColorStyle]
    
    /// The custom color tile to use for a color placement.
    let customColor: RSDColorDataObject?
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package name.
    public var packageName: String?

    /// Default initializer.
    ///
    /// - parameters:
    ///     - placement: The placement mapping for the sections of the view.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(placement: [String : RSDColorStyle],
                customColorName: String? = nil,
                usesLightStyle: Bool = false,
                bundleIdentifier: String? = nil,
                packageName: String? = nil) {
        self.type = .placementMapping
        self.placement = placement
        if let name = customColorName {
            self.customColor = RSDColorDataObject(colorIdentifier: name, usesLightStyle: usesLightStyle)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = bundleIdentifier
        self.packageName = packageName
    }
    
    /// The custom color used by this theme element.
    public var customColorData: RSDColorData? {
        return self.customColor
    }
    
    /// The background color style for a given placement.
    public func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle {
        if let style = self.placement[placement.stringValue] {
            return style
        }
        else {
            return ((self.customColor != nil) ? .custom : .background)
        }
    }
}

extension RSDColorDataObject : DocumentableStruct {
    
    public static func codingKeys() -> [CodingKey] {
        return self.CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        return true
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .colorIdentifier:
            return .init(propertyType: .primitive(.string))
        case .usesLightStyle:
            return .init(propertyType: .primitive(.boolean))
        }
    }
    
    public static func examples() -> [RSDColorDataObject] {
        return [RSDColorDataObject(colorIdentifier: "sky", usesLightStyle: false)]
    }
}

extension RSDColorPlacementThemeElementObject : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .type, .placement:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .type:
            return .init(constValue: RSDColorMappingThemeElementType.placementMapping)
        case .placement:
            return .init(propertyType: .referenceDictionary(RSDColorStyle.documentableType()))
        case .bundleIdentifier:
            return .init(propertyType: .primitive(.string))
        case .packageName:
            return .init(propertyType: .primitive(.string))
        case .customColor:
            return .init(propertyType: .reference(RSDColorDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [RSDColorPlacementThemeElementObject] {
        let exA = RSDColorPlacementThemeElementObject(placement: [
                                                                    "header" : .primary,
                                                                    "body" : .white,
                                                                    "footer" : .white
                                                                ],
                                                      customColorName: "sky",
                                                      usesLightStyle: false,
                                                      bundleIdentifier: "FooModule",
                                                      packageName: "org.sagebase.foo")
        return [exA]
    }
}

/// `RSDSingleColorThemeElementObject` tells the UI what the background color and foreground color are for
/// a given view as well as whether or not the foreground elements should use "light style".
///
/// The mapping is handled using a single style for the entire view.
public struct RSDSingleColorThemeElementObject : SerializableColorMapping, DecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case type, bundleIdentifier, packageName, colorStyle, customColor
    }
    
    /// The type for the class.
    public let type: RSDColorMappingThemeElementType
    
    /// The bundle identifier.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package name.
    public var packageName: String?
    
    /// The color placement mapping.
    let colorStyle: RSDColorStyle?
    
    /// The custom color tile to use for a color placement.
    let customColor: RSDColorDataObject?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - colorStyle: The color style for this mapping.
    ///     - customColorName: The name of the custom color.
    ///     - usesLightStyle: If using a custom color, the light style for the custom color.
    ///     - bundleIdentifier: The bundle identifier if using a color asset file.
    public init(colorStyle: RSDColorStyle?,
                customColorName: String? = nil,
                usesLightStyle: Bool = false,
                bundleIdentifier: String? = nil,
                packageName: String? = nil) {
        self.type = .singleColor
        self.colorStyle = colorStyle
        if let name = customColorName {
            self.customColor = RSDColorDataObject(colorIdentifier: name, usesLightStyle: usesLightStyle)
        }
        else {
            self.customColor = nil
        }
        self.bundleIdentifier = bundleIdentifier
        self.packageName = packageName
    }
    
    /// The custom color used by this theme element.
    public var customColorData: RSDColorData? {
        return self.customColor
    }
    
    /// The background color style for a given placement.
    public func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle {
        return colorStyle ?? ((self.customColor != nil) ? .custom : .white)
    }
}

extension RSDSingleColorThemeElementObject : DocumentableStruct {
    
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .type
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .type:
            return .init(constValue: RSDColorMappingThemeElementType.singleColor)
        case .colorStyle:
            return .init(propertyType: .reference(RSDColorStyle.documentableType()))
        case .bundleIdentifier:
            return .init(propertyType: .primitive(.string))
        case .packageName:
            return .init(propertyType: .primitive(.string))
        case .customColor:
            return .init(propertyType: .reference(RSDColorDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [RSDSingleColorThemeElementObject] {
        return [RSDSingleColorThemeElementObject(colorStyle: nil,
                                                 customColorName: "sky",
                                                 usesLightStyle: false,
                                                 bundleIdentifier: "FooModule",
                                                 packageName: "org.sagebase.foo"),
                RSDSingleColorThemeElementObject(colorStyle: .successGreen)]
    }
}
