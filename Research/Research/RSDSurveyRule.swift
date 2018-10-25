//
//  RSDSurveyRule.swift
//  Research
//
//  Copyright © 2016-2018 Sage Bionetworks. All rights reserved.
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

/// `RSDSurveyRule` defines an evaluation rule and returns a step identifier if appropriate.
public protocol RSDSurveyRule {
    
    /// For a given result (if any), what is the step that the survey should go to next?
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The identifier to skip to if the result evaluates to `true`.
    func evaluateRule(with result: RSDResult?) -> String?
    
    /// For a given result (if any), what are the cohorts to add or remove?
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The cohorts to add and remove.
    func evaluateCohorts(with result: RSDResult?) -> (add: Set<String>, remove: Set<String>)?
}

/// `RSDComparableSurveyRule` is a survey rule that matches an expected result to the answer and vends a skip
/// identifier if the match is evaluated to `true`.
public protocol RSDComparableSurveyRule : RSDSurveyRule, RSDComparable {
    
    /// Optional skip identifier for this rule. If available, this will be used as the skip identifier,
    /// otherwise the `skipToIdentifier` will be assumed to be `RSDIdentifier.exit` **unless** the
    /// `cohort` is not `nil`.
    var skipToIdentifier: String? { get }
    
    /// Optional cohort to assign if the rule matches. If non-nil, then the `evaluateRule()` function
    /// will return the `skipToIdentifier` and will *not* assume exit if the skipToIdentifier is `nil`.
    var cohort: String? { get }
    
    /// The rule operator to apply. If `nil`, `.equal` will be assumed unless the `matchingAnswer`
    /// is also `nil`, in which case `.skip` will be assumed.
    var ruleOperator: RSDSurveyRuleOperator? { get }
}

extension RSDComparableSurveyRule {
    
    fileprivate var _ruleOperator: RSDSurveyRuleOperator {
        return self.ruleOperator ?? ((self.matchingAnswer == nil) ? .skip : .equal)
    }

    /// For a given result (if any), what is the step that the survey should go to next?
    ///
    /// For the `RSDComparableSurveyRule`, this will evaluate the result using the `ruleOperator`
    /// and the `matchingAnswer` and return the `skipIdentifier` if the rule evaluates to `true`.
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The identifier to skip to if the result evaluates to `true`.
    public func evaluateRule(with result: RSDResult?) -> String? {
        guard cohort == nil || skipToIdentifier != nil else { return nil }
        
        let skipTo: String = skipToIdentifier ?? RSDIdentifier.exit.rawValue
        return isMatching(to: result, op: _ruleOperator) ? skipTo : nil
    }
    
    /// For a given result (if any), what is the step that the survey should go to next?
    ///
    /// For the `RSDComparableSurveyRule`, this will evaluate the result using the `ruleOperator`
    /// and the `matchingAnswer` and return the `cohort` to add if the rule evaluates to `true`
    /// or the `cohort` to remove if the rule evaluates to `false`.
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The cohorts to add and remove.
    public func evaluateCohorts(with result: RSDResult?) -> (add: Set<String>, remove: Set<String>)? {
        guard let cohort = self.cohort else { return nil }
        return isMatching(to: result, op: _ruleOperator) ? ([cohort], []) : ([], [cohort])
    }
}

