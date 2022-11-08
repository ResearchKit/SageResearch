//
//  RSDSectionStep.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel


/// `RSDSectionStep` is used to define a logical subgrouping of steps such as a section in a longer survey
/// or an active step that includes an instruction step, countdown step, and activity step.
public protocol RSDSectionStep: RSDStep, RSDTask, RSDStepNavigator {
    
    /// A list of the steps used to define this subgrouping of steps.
    var steps: [RSDStep] { get }
}

extension RSDSectionStep {
    
    /// Task info is `nil` for a section step.
    @available(*,deprecated, message: "Will be deleted in a future version.")
    public var taskInfo: RSDTaskInfoStep? {
        return nil
    }
    
    /// Schema info is `nil` for a section step.
    public var schemaInfo: RSDSchemaInfo? {
        return nil
    }
    
    /// The step navigator is `self` for a section step.
    public var stepNavigator: RSDStepNavigator {
        return self
    }
    
    /// A section step returns a task result for both the step result and the task result
    /// This method will throw an assert if the implementation of the section step does not
    /// return a `RSDTaskResult` as its type.
    public func instantiateTaskResult() -> RSDTaskResult {
        let result = self.instantiateStepResult()
        guard let taskResult = result as? RSDTaskResult else {
            assertionFailure("Expected that a section step will return a result that conforms to RSDTaskResult protocol.")
            return BranchNodeResultObject(identifier: identifier)
        }
        return taskResult
    }
}

