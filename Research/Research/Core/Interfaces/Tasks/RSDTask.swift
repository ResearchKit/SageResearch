//
//  RSDTask.swift
//  Research
//

import Foundation
import MobilePassiveData

/// `RSDTask` is the interface for running a task. It includes information about how to calculate progress,
/// validation, and the order of display for the steps.
///
/// - seealso: `RSDTaskController` and `RSDTaskInfoStep`
public protocol RSDTask {
    
    /// A short string that uniquely identifies the task.
    var identifier: String { get }
    
    /// Additional information about the result schema.
    var schemaInfo: RSDSchemaInfo? { get }
    
    /// The step navigator for this task.
    var stepNavigator: RSDStepNavigator { get }
    
    /// A list of asynchronous actions to run on the task.
    var asyncActions: [AsyncActionConfiguration]? { get }
    
    /// Instantiate a task result that is appropriate for this task.
    ///
    /// - returns: A task result for this task.
    func instantiateTaskResult() -> RSDTaskResult

    /// Validate the task to check for any model configuration that should throw an error.
    /// - throws: An error appropriate to the failed validation.
    func validate() throws
}

extension RSDTask {
    
    /// Filter the `asyncActions` and return only those actions to start with this step. This will return the
    /// configurations where the `startStepIdentifier` matches the current step as well as configurations
    /// where the `startStepIdentifier` is `nil` if and only if `isFirstStep` equals `true`.
    ///
    /// - parameters:
    ///     - step:         The step that is about to be displayed.
    ///     - isFirstStep:  `true` if this is the first step in the task, otherwise `false`.
    /// - returns: The array of async actions to start.
    public func asyncActionsToStart(at step: RSDStep, isFirstStep: Bool) -> [AsyncActionConfiguration] {
        guard let actions = self.asyncActions else { return [] }
        return actions.filter {
            ($0.startStepIdentifier == step.identifier) || ($0.startStepIdentifier == nil && isFirstStep)
        }
    }
}

