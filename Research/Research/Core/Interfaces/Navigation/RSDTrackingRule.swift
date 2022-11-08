//
//  RSDTrackingRule.swift
//  Research
//

import Foundation


/// A tracking rule is used to track changes that are applied during a task that should be saved at the
/// end of the the overall task. By definition, these rules can mutate and should be handled using
/// pointers rather than using structs.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTrackingRule : AnyObject {
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// If *only* this step should be skipped, then return `RSDIdentifier.nextStep`. If the section should
    /// be skipped then return `RSDIdentifier.nextSection`.
    ///
    /// - parameters:
    ///     - step:      The step about to be displayed.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step to display.
    func skipToStepIdentifier(before step: RSDStep, with result: RSDTaskResult?, isPeeking: Bool) -> String?
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// - parameters:
    ///     - step:      The step that just finished.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step.
    func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?, isPeeking: Bool) -> String?
}
