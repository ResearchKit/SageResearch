//
//  SurveyRuleNavigation.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

/// Convenience protocol for evaluating survey rules for a given `Question`.
/// - note: This protocol does not require conformance to `Question` or `RSDCohortAssignmentStep`
/// to allow for abstract subclassing and overrides.
/// - seealso: `AbstractQuestionStep`
public protocol SurveyRuleNavigation : RSDNavigationRule {  // RSDCohortAssignmentStep
    var identifier: String { get }
    var skipToIfNil: String? { get }
    var surveyRules: [RSDSurveyRule] { get }
}

extension SurveyRuleNavigation {

    /// Evaluate the survey rules for the given task result and return the next identifier.
    ///
    /// This method inspects all the survey rules and will return a value under the following
    /// conditions:
    ///
    ///   * If all the results are `nil` and `isPeeking` equals `false`, then it will return
    ///     the value of `skipToIfNil`
    ///   * If one and only one skip identifier is returned by the evaluated survey rules.
    ///
    /// - seealso: `AbstractQuestionStep` for an example implementation.
    ///
    /// - parameters:
    ///     - result:       The task result to evaluate.
    ///     - isPeeking:    Is this navigation rule being called on a result for a step that is navigating
    ///                     forward or is it a step navigator that is peeking at the next step to set up UI
    ///                     display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier for the step to skip to if the rules are `true`.
    public func evaluateSurveyRules(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        // Do not apply rules when the navigation is only peeking
        guard !isPeeking else { return nil }
        // If the result is nil then return the skipToNil value
        guard let finder = result,
            let answerResult = finder.findAnswerResult(with: identifier)
            else {
                return skipToIfNil
        }
        // evaluate the rules
        let skipTos = surveyRules.compactMap { $0.evaluateRule(with: answerResult) }
        return skipTos.count == 1 ? skipTos.first : nil
    }
    
    /// Evaluate the survey rules for the given task result and return the cohorts that should be
    /// added or removed based on the result.
    ///
    /// - note: `RSDSurveyNavigationStep` extends `RSDCohortAssignmentStep` but does not implement
    ///         the `cohortsToApply()` method because that will allow for additional customization
    ///         by the step that is implementing this protocol.
    ///
    /// - seealso: `RSDFormUIStepObject` for an example implementation.
    ///
    /// - parameter result: The task result to evaluate.
    /// - returns: The cohorts to add/remove or `nil` if no rules apply.
    public func evaluateCohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)? {
        var cohortsToAdd = Set<String>()
        var cohortsToRemove = Set<String>()
        let answerResult = result.findAnswerResult(with: identifier)
        surveyRules.forEach { rule in
            guard let cohorts = rule.evaluateCohorts(with: answerResult) else { return }
            cohortsToAdd.formUnion(cohorts.add)
            cohortsToRemove.formUnion(cohorts.remove)
        }
        return (cohortsToAdd.count > 0 || cohortsToRemove.count > 0) ? (cohortsToAdd, cohortsToRemove) : nil
    }
}
