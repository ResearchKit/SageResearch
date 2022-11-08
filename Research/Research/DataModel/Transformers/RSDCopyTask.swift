//
//  RSDCopyTask.swift
//  Research
//

import Foundation


/// Protocol to describe a task that should be copied for each run of the task rather than simply passed.
/// This is used to allow an architecture where the task model uses a pointer to an in-memory object that is
/// used during navigation.
public protocol RSDCopyTask : RSDTask, RSDCopyWithIdentifier, RSDTaskTransformer {
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameters:
    ///     - identifier: The new identifier.
    ///     - schemaInfo: The schema info.
    func copy(with identifier: String, schemaInfo: RSDSchemaInfo?) -> Self
}

extension RSDCopyTask {
    
    /// Returns `0`.
    public var estimatedFetchTime: TimeInterval {
        return 0
    }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - taskIdentifier: The task info for the task (if applicable).
    ///     - schemaInfo: The schema info for the task (if applicable).
    ///     - callback: The callback with the task or an error if the task failed, run on the main thread.
    public func fetchTask(with taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        DispatchQueue.main.async {
            let copy = self.copy(with: taskIdentifier, schemaInfo: schemaInfo)
            callback(copy, nil)
        }
    }
}
