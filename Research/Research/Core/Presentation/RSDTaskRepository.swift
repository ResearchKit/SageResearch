//
//  RSDTaskRepository.swift
//  Research
//

import Foundation

/// The task repository is used by an app to configure fetching tasks.
open class RSDTaskRepository {
    
    /// Singleton for the shared task repository.
    public static var shared = RSDTaskRepository()
    
    public init() {
    }
    
    /// The completion handler for a fetched task.
    public typealias FetchCompletionHandler = (RSDTaskInfo, RSDTask?, Error?) -> Void
    
    /// Pointer to a task transformer used to retain the transformer while the task is being fetched.
    private var _taskTransformers = [UUID : RSDTaskTransformer]()
    
    /// Fetch the task for a given task info. The base class implementation will fetch the task from the
    /// `resourceTransformer` that is optionally included on the task info or from an embedded resource.
    open func fetchTask(for taskInfo: RSDTaskInfo, completion: @escaping FetchCompletionHandler) {
        do {
            let taskTransformer = try self.taskTransformer(for: taskInfo)
            let schemaInfo = self.schemaInfo(for: taskInfo)
            let uuid = UUID()
            _taskTransformers[uuid] = taskTransformer
            taskTransformer.fetchTask(with: taskInfo.identifier, schemaInfo: schemaInfo) { [weak self] (task, error) in
                completion(taskInfo, task, error)
                self?._taskTransformers[uuid] = nil
            }
        } catch let error {
            DispatchQueue.main.async {
                completion(taskInfo, nil, error)
            }
        }
    }
    
    /// Returns the schema to use for the given task info.
    open func schemaInfo(for taskInfo: RSDTaskInfo) -> RSDSchemaInfo? {
        return taskInfo.schemaInfo
    }
    
    /// Returns the task transformer for the given task info.
    open func taskTransformer(for taskInfo: RSDTaskInfo) throws -> RSDTaskTransformer {
        if let transformer = taskInfo.resourceTransformer {
            return transformer
        }
        else if let transformer = taskInfo as? RSDTaskTransformer {
            return transformer
        }
        else {
            return RSDResourceTransformerObject(resourceName: taskInfo.identifier)
        }
    }
}
