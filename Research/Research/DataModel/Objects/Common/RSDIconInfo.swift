//
//  RSDIconInfo.swift
//  Research
//

import Foundation
import JsonModel

/// The icon info is a simple image holder that also contains a title and subtitle for the image.
public struct RSDIconInfo : Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case title, subtitle, icon
    }
    
    /// Title for the image.
    public let title: String
    
    /// Subtitle for the image.
    public let subtitle: String?
    
    /// The icon for this info object.
    public let icon: RSDResourceImageDataObject?
}

extension RSDIconInfo : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .title
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .title, .subtitle:
            return .init(propertyType: .primitive(.string))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [RSDIconInfo] {
        [RSDIconInfo(title: "Foo", subtitle: "ba", icon: RSDResourceImageDataObject(imageName: "foo"))]
    }
}
