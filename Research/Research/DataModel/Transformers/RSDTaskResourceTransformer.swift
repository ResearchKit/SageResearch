//
//  RSDTaskResourceTransformer.swift
//  Research
//

import Foundation


/// `RSDTaskResourceTransformer` is an implementation of a `RSDTaskTransformer` that uses a `RSDResourceTransformer`
/// to support transforming a resource either using an online URL or an embedded file.
public protocol RSDTaskResourceTransformer : RSDTaskTransformer, RSDResourceTransformer {
    
    /// The factory to use in decoding the task from an embedded resource.
    var factory : RSDFactory { get }
}

extension RSDTaskResourceTransformer {
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - taskIdentifier: The task info for the task (if applicable).
    ///     - schemaInfo: The schema info for the task (if applicable).
    ///     - callback: The callback with the task or an error if the task failed, run on the main thread.
    public func fetchTask(with taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        DispatchQueue.global().async {
            do {
                let task = try self.factory.decodeTask(with: self, taskIdentifier: taskIdentifier, schemaInfo: schemaInfo)
                DispatchQueue.main.async {
                    callback(task, nil)
                }
            } catch let err {
                DispatchQueue.main.async {
                    callback(nil, err)
                }
            }
        }
    }
}
