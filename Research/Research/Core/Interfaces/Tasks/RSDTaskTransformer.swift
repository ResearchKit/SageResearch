//
//  RSDTaskTransformer.swift
//  Research
//

import Foundation


/// A completion handler for fetching a task using the task info `fetchTask()` method.
public typealias RSDTaskFetchCompletionHandler = (RSDTask?, Error?) -> Void

/// The possible errors thrown when fetching a task.
public enum RSDTaskFetchError : Error {
    
    /// Unknown error
    case unknown
    
    /// The participant's device is offline and a network connect is required to fetch the task.
    case offline
}

/// `RSDTaskTransformer` The task transformer is a lightweight protocol for vending a task. This can be used by
/// an `RSDTaskInfoStep` to fetch a task or depending upon the design of the application, it could be used to
/// fetch a task that is loaded from a table or collection view before presenting the task.
public protocol RSDTaskTransformer : AnyObject {
    
    /// The estimated time to fetch the task. This can be used by the UI to determine whether or not to
    /// display a loading state while fetching the task. If `0` then the task is assumed to be cached on the device.
    var estimatedFetchTime: TimeInterval { get }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - factory: The factory to use for creating the task and steps.
    ///     - taskIdentifier: The task info for the task (if applicable).
    ///     - schemaInfo: The schema info for the task (if applicable).
    ///     - callback: The callback with the task or an error if the task failed, run on the main thread.
    func fetchTask(with taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler)
}
