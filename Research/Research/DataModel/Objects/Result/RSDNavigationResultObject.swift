//
//  RSDNavigationResultObject.swift
//  
//
import Foundation
import JsonModel
import ResultModel

public final class RSDNavigationResultObject : RSDNavigationResult {

    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling. This property is transient and should not be copied or serialized.
    public var skipToIdentifier: String?
    
    public private(set) var wrappedResult: ResultData
    
    public init(wrappedResult: ResultData) {
        self.wrappedResult = wrappedResult
    }
    
    public var typeName: String {
        wrappedResult.typeName
    }
    
    public var identifier: String {
        wrappedResult.identifier
    }
    
    public var startDate: Date {
        get { wrappedResult.startDate }
        set { wrappedResult.startDate = newValue }
    }
    
    public var endDate: Date {
        get { wrappedResult.endDate }
        set { wrappedResult.endDate = newValue }
    }
    
    public func deepCopy() -> RSDNavigationResultObject {
        .init(wrappedResult: wrappedResult.deepCopy())
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedResult.encode(to: encoder)
    }
}
