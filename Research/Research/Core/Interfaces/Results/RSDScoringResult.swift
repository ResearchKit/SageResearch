//
//  RSDScoringResult.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// An `RSDScoringResult` is an archivable result that can also save a json data scoring object for display
/// in a user's history or to influence future results.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDScoringResult : ResultData, RSDArchivable {
    
    /// Return a JSON type object. Elements may be any one of the JSON types
    /// (NSNull, NSNumber, String, Array, [String : Any]).
    func dataScore() throws -> JsonSerializable?
}
