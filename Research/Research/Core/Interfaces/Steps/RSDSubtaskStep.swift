//
//  RSDSubtaskStep.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// `RSDSubtaskStep` is a step that contains a task reference.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDSubtaskStep : RSDStep {
    
    /// The task for this step.
    var task: RSDTask { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDSubtaskStep {
    
    public var identifier: String {
        return self.task.identifier
    }
    
    public func instantiateStepResult() -> ResultData {
        return task.instantiateTaskResult()
    }
    
    public func validate() throws {
        try self.task.validate()
    }
}
