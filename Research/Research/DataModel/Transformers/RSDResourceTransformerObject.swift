//
//  RSDResourceTransformerObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDResourceTransformerObject` is a concrete implementation of a codable resource transformer.
/// The transformer can be used to create an object decoded from an embedded resource.
public final class RSDResourceTransformerObject : Codable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case resourceName, packageName, bundleIdentifier, rawFileExtension, resourceType
    }
    
    /// Either a fully qualified URL string or else a relative reference to either an embedded resource or
    /// a relative URL defined globally by overriding the `RSDResourceConfig` class methods.
    public let resourceName: String
    
    /// The bundle identifier for the embedded resource.
    public let bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// The factory to use in decoding this object.
    public var factory: RSDFactory = RSDFactory.shared
    
    /// The raw file extension for the resource.
    public var rawFileExtension: String?
    
    /// The Android resource name type.
    public var resourceType: String?
    
    /// Default initializer for creating the object.
    ///
    /// - parameters:
    ///     - resourceName: The name of the resource.
    ///     - bundleIdentifier: The bundle identifier for the embedded resource.
    ///     - classType: The classType for converting the resource to an object.
    public init(resourceName: String, bundleIdentifier: String? = nil) {
        self.resourceName = resourceName
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Default initializer for creating the object.
    ///
    /// - parameters:
    ///     - resourceName: The name of the resource.
    ///     - bundleIdentifier: The bundle identifier for the embedded resource.
    public init(resourceName: String, bundle: ResourceBundle) {
        self.resourceName = resourceName
        self.bundleIdentifier = bundle.bundleIdentifier
        self.factoryBundle = bundle
    }
}

extension RSDResourceTransformerObject : RSDResourceDataInfo {
}

extension RSDResourceTransformerObject : RSDTaskResourceTransformer {
}

extension RSDResourceTransformerObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .resourceName
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .resourceName:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Either a fully qualified URL string or else a relative reference to an embedded resource.")
        case .bundleIdentifier:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The bundle identifier for the embedded resource.")
        case .packageName:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The package name for the embedded resource.")
        case .rawFileExtension:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The raw file extension of the resource.")
        case .resourceType:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The Android resource type of the resource.")
        }
    }
    
    public static func examples() -> [RSDResourceTransformerObject] {
        let exampleA = RSDResourceTransformerObject(resourceName: "FactoryTest_TaskFoo", bundleIdentifier: "org.sagebase.ResearchTests")
        let exampleB = RSDResourceTransformerObject(resourceName: "TaskBar")
        return [exampleA, exampleB]
    }
}
