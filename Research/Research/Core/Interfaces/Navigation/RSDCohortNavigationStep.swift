//
//  RSDCohortNavigationStep.swift
//  Research
//

import Foundation

/// A cohort navigation step is a step that carries information about navigation rules to apply either
/// before or after displaying this step based on the currently applied cohorts.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDCohortNavigationStep : RSDStep {
    
    /// The navigation cohort rules to apply *before* displaying the step.
    var beforeCohortRules : [RSDCohortNavigationRule]? { get }
    
    /// The navigation cohort rules to apply *after* displaying the step.
    var afterCohortRules : [RSDCohortNavigationRule]? { get }
}

/// `RSDCohortAssignmentStep` evaluates a task result and returns the cohorts to apply for a given
/// result.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDCohortAssignmentStep : RSDStep {
    
    /// Evaluate the task result and return the set of cohorts to add and remove.
    /// - parameter result: The task result to evaluate.
    /// - returns: The cohorts to add/remove or `nil` if no rules apply.
    func cohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)?
}

/// List of the rules to apply when navigating based on the currently applied cohorts.
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDCohortRuleOperator : String, Codable, CaseIterable {
    /// Require all the cohorts to match.
    case all
    /// Require any of the cohorts to match.
    case any
}

/// A cohort navigation rule is used by the `RSDCohortTrackingRule` to determine whether to skip a step,
/// and if so where to skip to, based on the currently applied cohorts.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDCohortNavigationRule {
    
    /// The list of cohorts that are tested for this navigation rule.
    var requiredCohorts : Set<String> { get }
    
    /// What type of operator to apply. If `nil`, then `.all` is assumed.
    var cohortOperator : RSDCohortRuleOperator? { get }
    
    /// Optional skip identifier for this rule.
    ///
    /// If this rule is applied *after* displaying the step, then this will be used as the identifier to
    /// skip to. If `nil` then the skip to identifier will be assumed to be `RSDIdentifier.exit`.
    ///
    /// If this rule is applied *before* displaying the step, then this is the identifier to skip to. If
    /// `nil` then just this step will be skipped.
    var skipToIdentifier : String? { get }
}
