//
//  Geometry.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDSize` is a codable struct for defining the size of a drawable.
public struct RSDSize : Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case width, height
    }
    public let width: Double
    public let height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

extension RSDSize : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        true
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let _ = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        return .init(propertyType: .primitive(.number))
    }
    
    public static func examples() -> [RSDSize] {
        [RSDSize(width: 10.0, height: 20.0)]
    }
}
