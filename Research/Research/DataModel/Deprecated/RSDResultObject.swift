//
//  RSDResultObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// `RSDResultObject` is a concrete implementation of the base result associated with a task, step, or asynchronous action.
@available(*,deprecated, message: "Use `JsonModel.ResultObject` instead.")
public struct RSDResultObject : SerializableResultData, RSDNavigationResult, Codable {

    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let serializableType: SerializableResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date
    
    /// The end date timestamp for the result.
    public var endDate: Date
    
    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling.
    public var skipToIdentifier: String?
    
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case serializableType = "type", identifier, startDate, endDate, skipToIdentifier
    }
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    public init(identifier: String, startDate: Date = Date(), endDate: Date = Date(), skipToIdentifier: String? = nil) {
        self.identifier = identifier
        self.serializableType = .base
        self.startDate = startDate
        self.endDate = endDate
        self.skipToIdentifier = skipToIdentifier
    }
    
    public func deepCopy() -> RSDResultObject {
        self
    }
}

