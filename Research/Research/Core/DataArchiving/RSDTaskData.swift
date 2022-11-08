//
//  RSDTaskData.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// A compact object for storing information about a task run that can be used by a task to influence
/// subsequent task runs.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTaskData {
    
    /// The identifier for the task.
    var identifier: String { get }
    
    /// A timestamp for when the task was run. If `nil` then the timestamp was not stored with the data
    /// for this task.
    var timestampDate: Date? { get }
    
    /// Return a JSON type object. Elements may be any one of the serializable JSON types.
    var json: JsonSerializable { get }
}
