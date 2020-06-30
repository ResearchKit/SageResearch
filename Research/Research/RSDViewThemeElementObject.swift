//
//  RSDViewThemeElementObject.swift
//  Research
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
import JsonModel

public final class ViewThemeSerializer : AbstractPolymorphicSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `ViewThemeElement` tells the UI where to find the view controller or fragment to use
        when instantiating the view.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        examples = [
            RSDViewThemeElementObject.examples().first!,
        ]
    }
    
    public private(set) var examples: [RSDViewThemeElement]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDViewThemeElementType.documentableType()))
    }
    
    public func add(_ example: SerializableViewTheme) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
    
    override public func typeName(from decoder: Decoder) throws -> String {
        do {
            return try super.typeName(from: decoder)
        } catch DecodingError.keyNotFound(_, _) {
            // The kotlin implementation for decoding the viewTheme is *not* polymorphic, but this
            // implementation pre-dated that implementation and JsonModel factory serialization
            // used here allows for a default type. syoung 04/23/2020
            return RSDViewThemeElementType.defaultTheme.rawValue
        }
    }
}

public protocol SerializableViewTheme : RSDViewThemeElement, PolymorphicRepresentable, Encodable {
    var type: RSDViewThemeElementType { get }
}

public extension SerializableViewTheme {
    var typeName: String { return type.rawValue }
}

public struct RSDViewThemeElementType : TypeRepresentable, Codable, Equatable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDColorPlacementThemeElementObject`.
    public static let defaultTheme: RSDViewThemeElementType = "default"
}

extension RSDViewThemeElementType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDViewThemeElementType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        [RSDViewThemeElementType.defaultTheme.rawValue]
    }
}

/// `RSDViewThemeElementObject` tells the UI where to find the view controller to use when instantiating
/// the `RSDStepController`.
public struct RSDViewThemeElementObject: SerializableViewTheme, DecodableBundleInfo {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case _type = "type", storyboardIdentifier, _viewIdentifier = "viewIdentifier", bundleIdentifier, packageName, fragmentIdentifier, fragmentLayout
    }
    public var type: RSDViewThemeElementType { .defaultTheme }
    
    // Kotlin support requires a "type" and does not support a default decodable.
    private var _type: RSDViewThemeElementType? = .defaultTheme
    
    // MARK: Apple
    
    /// The storyboard view controller identifier or the nib name for this view controller.
    public var viewIdentifier: String { _viewIdentifier ?? "null" }
    private var _viewIdentifier: String?
    
    /// If the storyboard identifier is non-nil then the view is assumed to be accessible within the
    /// storyboard via the `viewIdentifier`.
    public let storyboardIdentifier: String?
    
    /// The bundle identifier for the nib or storyboard.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    // MARK: Android
    
    /// An identifier for the Fragment.
    public let fragmentIdentifier: String?
    
    /// The name of the custom Fragment layout.
    public let fragmentLayout: String?
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - viewIdentifier: The storyboard view controller identifier or the nib name for this view
    ///       controller.
    ///     - bundleIdentifier: The bundle identifier for the nib or storyboard. Default = `nil`.
    ///     - storyboardIdentifier: The storyboard identifier. Default = `nil`.
    public init(viewIdentifier: String,
                bundleIdentifier: String? = nil,
                storyboardIdentifier: String? = nil,
                fragmentLayout: String? = nil,
                fragmentIdentifier: String? = nil) {
        self._viewIdentifier = viewIdentifier
        self.bundleIdentifier = bundleIdentifier
        self.storyboardIdentifier = storyboardIdentifier
        self.fragmentLayout = fragmentLayout
        self.fragmentIdentifier = fragmentIdentifier
    }
}

extension RSDViewThemeElementObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == ._viewIdentifier || key == ._type
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let _ = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        return .init(propertyType: .primitive(.string))
    }
    
    public static func examples() -> [RSDViewThemeElementObject] {
        let viewThemeA = RSDViewThemeElementObject(viewIdentifier: "FooStepNibIdentifier", bundleIdentifier: "org.example.SharedResources")
        let viewThemeB = RSDViewThemeElementObject(viewIdentifier: "FooStepViewIdentifier", bundleIdentifier: nil, storyboardIdentifier: "FooBarStoryboard")
        return [viewThemeA, viewThemeB]
    }
}
