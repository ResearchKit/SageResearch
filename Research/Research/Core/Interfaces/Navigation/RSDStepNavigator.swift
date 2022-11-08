//
//  RSDStepNavigator.swift
//  Research
//

import Foundation

/// `RSDStepNavigator` is used by the `RSDTaskController` to determine the order of presentation of the steps
/// in a task. The navigator should include navigation that is based on the input model and the results rather
/// that depending upon the available real estate.
///
/// - seealso: `RSDTask`, `RSDTaskController`, and `RSDConditionalStepNavigator`
public protocol RSDStepNavigator {
    
    /// Returns the step associated with a given identifier.
    /// - parameter identifier:  The identifier for the step.
    /// - returns: The step with this identifier or nil if not found.
    func step(with identifier: String) -> RSDStep?
    
    /// Should the task exit early from the entire task?
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should exit.
    func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool
    
    /// Is there a step after the current step with the given result.
    ///
    /// - note: the result may not include a result for the current step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a next button.
    func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool
    
    /// Given the current task result, is there a step after the current step?
    ///
    /// This method is checked when first displaying a step to determine if the UI should display
    /// this as the last step. By default, the UI defined in ResearchUI will change the text
    /// on the continue button from "Next" to "Done", unless customized.
    ///
    /// - note: the task result may or may not include a result for the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a next button.
    func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool
    
    /// Given the current task result, is there a step before the current step?
    ///
    /// This method is checked when first displaying a step to determine if the UI should display
    /// this as the first step. By default, the UI defined in ResearchUI will hide the "Back"
    /// button if there is no step before the given step.
    ///
    /// - note: the task result may or may not include a result for the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a back button.
    func step(after step: RSDStep?, with result: inout RSDTaskResult) -> (step: RSDStep?, direction: RSDStepDirection)
    
    /// Return the step to go to before the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: The previous step or nil if the task does not support backward navigation or this is the first step.
    func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep?
    
    /// Return the progress through the task for a given step with the current result.
    ///
    /// - parameters:
    ///     - step:         The current step.
    ///     - result:       The current result set for this task.
    /// - returns:
    ///     - current:      The current progress. This indicates progress within the task.
    ///     - total:        The total number of steps.
    ///     - isEstimated:  Whether or not the progress is an estimate (if the task has variable navigation).
    func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)?
}

/// An extension of the step navigator to allow inserting a section into the work-flow
/// of this step navigator.
///
/// When using a step navigator that was developed by a third-party, it can be desirable to insert into
/// that task flow steps related to the timing of the task. For example, a tapping task may also include
/// asking about medication or a 12 minute run may prompt a clinic participant to put on their Fitbit
/// before running. These additional questions or instructions need to be inserted into the task flow at a
/// logical point **after** showing one or more initial screens.
public protocol RSDCopyStepNavigator : RSDStepNavigator {
    
    /// Return a copy of the step navigator that includes the desired section inserted in a position that
    /// is appropriate to this navigator.
    /// - parameter section: The section step to insert.
    /// - returns: A copy of this navigator with the inserted section.
    func copyAndInsert(_ section: RSDSectionStep) -> Self
    
    /// Return a copy of the step navigator that includes the desired subtask inserted in a position that
    /// is appropriate to this navigator.
    /// - parameter subtask: The task info step to insert.
    /// - returns: A copy of this navigator with the inserted section.
    func copyAndInsert(_ subtask: RSDTaskInfoStep) -> Self
    
    /// Return a copy of the step navigator that removes the steps with the given identifiers.
    /// - parameter stepIdentifiers: The identifiers for the steps to remove.
    /// - returns: A copy of this navigator without the given steps.
    func copyAndRemove(_ stepIdentifiers: [String]) -> Self
}
