//
//  RSDStep.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// `RSDStep` is the base protocol for the steps that can compose a task for presentation using a
/// controller appropriate to the device and application. Each `RSDStep` object represents one logical
/// piece of data entry, information, or activity in a larger task.
///
/// Implementations included in this SDK include:
/// 1. `RSDSectionStep` is used to define a logical subgroup of steps.
/// 2. `RSDUIStep` is used to define a display step.
/// 3. `RSDTaskInfoStep` is used to combine tasks into a single flow. For example, if the researcher wishes
///     to ask for survey responses before an activity.
///
/// A step can be a question, an active test, or a simple instruction. An `RSDStep` subclass is usually
/// paired with an `RSDStepController` that controls the actions of the step.
///
public protocol RSDStep {
    
    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in
    /// the results  of a step history.
    ///
    /// In some cases, it can be useful to link the step identifier to a unique identifier in a database;
    /// in other cases, it can make sense to make the identifier human readable.
    var identifier: String { get }
    
    /// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to
    /// customize the UI.
    var stepType: RSDStepType { get }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: A result for this step.
    func instantiateStepResult() -> ResultData
    
    /// Validate the step to check for any configuration that should throw an error.
    /// - throws: An error if validation fails.
    func validate() throws
}

/// `RSDCopyStep` is a step that supports creating a copy of itself that has specified properties mutated
/// to return a new instance and/or includes mutated properties.
public protocol RSDCopyStep : RSDStep, RSDCopyWithIdentifier {

    /// Copy the step to a new instance with the given identifier and user info.
    /// - parameters:
    ///     - identifier: The new identifier.
    ///     - decoder: A decoder that can be used to decode properties on this step.
    func copy(with identifier: String, decoder: Decoder?) throws -> Self
}

extension Array where Element == RSDStep {
    public func deepCopy() -> [RSDStep] {
        self.map { (step) -> RSDStep in
            (step as? RSDCopyStep)?.copy(with: step.identifier) ?? step
        }
    }
}
