//
//  RSDSubtaskStep.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// `RSDSubtaskStep` is a step that contains a task reference.
public protocol RSDSubtaskStep : RSDStep {
    
    /// The task for this step.
    var task: RSDTask { get }
}

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
