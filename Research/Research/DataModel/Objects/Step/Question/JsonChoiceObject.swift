//
//  JsonChoiceObject.swift
//  Research
//

import Foundation
import JsonModel

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol JsonComparable : RSDComparable {
    var matchingValue: JsonElement? { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public extension JsonComparable {
    var matchingAnswer: Any? {
        matchingValue?.jsonObject()
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol JsonChoice : RSDChoice, JsonComparable {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public extension JsonChoice {
    var answerValue: Codable? {
        matchingValue ?? JsonElement.null
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public struct JsonChoiceObject : JsonChoice, Codable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case matchingValue = "value", text, detail, _isExclusive = "exclusive", icon
    }
    
    public let matchingValue: JsonElement?
    public let text: String?
    public let detail: String?
    
    public var isExclusive: Bool {
        _isExclusive ?? false
    }
    private let _isExclusive: Bool?
    
    public var imageData: RSDImageData? {
        icon
    }
    public let icon: RSDResourceImageDataObject?
    
    public init(matchingValue: JsonElement?,
                text: String?,
                detail: String? = nil,
                isExclusive: Bool? = nil,
                icon: RSDResourceImageDataObject? = nil) {
        self.matchingValue = matchingValue
        self.text = text
        self.detail = detail
        self._isExclusive = isExclusive
        self.icon = icon
    }
    
    public init(text: String) {
        self.text = text
        self.matchingValue = .string(text)
        self.detail = nil
        self._isExclusive = nil
        self.icon = nil
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension JsonChoiceObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .matchingValue:
            return .init(propertyType: .any, propertyDescription: "The matching value is any json element, but all json elements within the collection of choices should have the same json type.")
        case .text, .detail:
            return .init(propertyType: .primitive(.string))
        case ._isExclusive:
            return .init(propertyType: .primitive(.boolean))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [JsonChoiceObject] {
        return [JsonChoiceObject(matchingValue: .integer(1), text: "None of the above")]
    }
}

