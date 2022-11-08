//
//  RSDSchemaInfoObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDSchemaInfoObject` is a concrete implementation of the `RSDSchemaInfo` protocol.
public struct RSDSchemaInfoObject : RSDSchemaInfo, Codable, Hashable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, revision
    }
    
    private let identifier: String
    private let revision: Int
    
    /// A short string that uniquely identifies the associated result schema.
    public var schemaIdentifier: String? {
        return identifier
    }
    
    /// A revision number associated with the result schema.
    public var schemaVersion: Int {
        return revision
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the associated result schema.
    ///     - revision: A revision number associated with the result schema.
    public init(identifier: String, revision: Int) {
        self.identifier = identifier
        self.revision = revision
    }
}

extension RSDSchemaInfoObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { true }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .revision:
            return .init(propertyType: .primitive(.integer))
        }
    }
    
    public static func examples() -> [RSDSchemaInfoObject] {
        [RSDSchemaInfoObject(identifier: "foo", revision: 2)]
    }
}

