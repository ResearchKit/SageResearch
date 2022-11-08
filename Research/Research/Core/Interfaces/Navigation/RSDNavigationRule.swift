//
//  RSDNavigationRule.swift
//  Research
//

import Foundation

/// Define the navigation rule as a protocol to allow for protocol-oriented extension (multiple
/// inheritance). Currently defined usage is to allow the `RSDConditionalStepNavigator` to check if a
/// step has a navigation rule and apply as necessary.
public protocol RSDNavigationRule {
    
    /// Identifier for the next step to navigate to based on the current task result and the conditional
    /// rule associated with this task.
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - isPeeking:        Is this navigation rule being called on a result for a step that is navigating
    ///                         forward or is it a step navigator that is peeking at the next step to set up UI
    ///                         display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step.
    func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String?
}

/// A navigation skip rule applies to this step to allow the step to be skipped.
public protocol RSDNavigationSkipRule {
    
    /// Should this step be skipped based on the current task result and the conditional rule associated
    /// with this task?
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - isPeeking:        Is this navigation rule being called on a result for a step that is navigating
    ///                         forward or is it a step navigator that is peeking at the next step to set up UI
    ///                         display? If peeking at the next step then this parameter will be `true`.
    /// - returns: `true` if the step should be skipped, otherwise `no`.
    func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool
}

/// A navigation back rule applies to this step to block backward navigation.
public protocol RSDNavigationBackRule {
    
    /// Should this step show a back button to allow backward navigation?
    ///
    /// - parameters:
    ///     - result:           The current task result.
    /// - returns: `true` if the backward navigation is allowed, otherwise `no`.
    func allowsBackNavigation(with result: RSDTaskResult?) -> Bool
}
