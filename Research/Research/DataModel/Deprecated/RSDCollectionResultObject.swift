//
//  RSDCollectionResultObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// `RSDCollectionResultObject` is used include multiple results associated with a single step or async action that
/// may have more that one result.
@available(*,deprecated, message: "Will be deleted in a future version. Use `JsonModel.CollectionResultObject` instead.")
public final class RSDCollectionResultObject : SerializableResultData, CollectionResult, RSDNavigationResult, Codable, RSDCopyWithIdentifier {
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let serializableType: SerializableResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// The list of input results associated with this step. These are generally assumed to be answers to
    /// field inputs, but they are not required to implement the `RSDAnswerResult` protocol.
    public var children: [ResultData]
    
    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling.
    public var skipToIdentifier: String?
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    public init(identifier: String, children: [ResultData] = [], startDate: Date = Date(), endDate: Date = Date()) {
        self.identifier = identifier
        self.serializableType = .collection
        self.children = children
        self.startDate = startDate
        self.endDate = endDate
    }
    
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case serializableType = "type", identifier, startDate, endDate, children, skipToIdentifier
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `children`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.skipToIdentifier = try container.decodeIfPresent(String.self, forKey: .skipToIdentifier)
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate) ?? Date()
        self.serializableType = try container.decode(SerializableResultType.self, forKey: .serializableType)
        
        let resultsContainer = try container.nestedUnkeyedContainer(forKey: .children)
        self.children = try decoder.factory.decodePolymorphicArray(ResultData.self, from: resultsContainer)
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(serializableType, forKey: .serializableType)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encodeIfPresent(skipToIdentifier, forKey: .skipToIdentifier)
        
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .children)
        for result in children {
            let nestedEncoder = nestedContainer.superEncoder()
            try result.encode(to: nestedEncoder)
        }
    }
    
    public func copy(with identifier: String) -> RSDCollectionResultObject {
        RSDCollectionResultObject(identifier: identifier,
                                  children: self.children.map { $0.deepCopy() },
                                  startDate: self.startDate,
                                  endDate: self.endDate)
    }
    
    public func deepCopy() -> RSDCollectionResultObject {
        self.copy(with: self.identifier)
    }
}

