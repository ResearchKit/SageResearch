//
//  RSDCohortNavigationStep.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

/// A cohort navigation step is a step that carries information about navigation rules to apply either
/// before or after displaying this step based on the currently applied cohorts.
public protocol RSDCohortNavigationStep : RSDStep {
    
    /// The navigation cohort rules to apply *before* displaying the step.
    var beforeCohortRules : [RSDCohortNavigationRule]? { get }
    
    /// The navigation cohort rules to apply *after* displaying the step.
    var afterCohortRules : [RSDCohortNavigationRule]? { get }
}

/// `RSDCohortAssignmentStep` evaluates a task result and returns the cohorts to apply for a given
/// result.
public protocol RSDCohortAssignmentStep : RSDStep {
    
    /// Evaluate the task result and return the set of cohorts to add and remove.
    /// - parameter result: The task result to evaluate.
    /// - returns: The cohorts to add/remove or `nil` if no rules apply.
    func cohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)?
}

/// List of the rules to apply when navigating based on the currently applied cohorts.
public enum RSDCohortRuleOperator : String, Codable, CaseIterable {
    /// Require all the cohorts to match.
    case all
    /// Require any of the cohorts to match.
    case any
}

/// A cohort navigation rule is used by the `RSDCohortTrackingRule` to determine whether to skip a step,
/// and if so where to skip to, based on the currently applied cohorts.
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
