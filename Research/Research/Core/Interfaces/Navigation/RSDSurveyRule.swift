//
//  RSDSurveyRule.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// `RSDSurveyRule` defines an evaluation rule and returns a step identifier if appropriate.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDSurveyRule {
    
    /// For a given result (if any), what is the step that the survey should go to next?
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The identifier to skip to if the result evaluates to `true`.
    func evaluateRule(with result: ResultData?) -> String?
    
    /// For a given result (if any), what are the cohorts to add or remove?
    ///
    /// - parameter results: The result to evaluate.
    /// - returns: The cohorts to add and remove.
    func evaluateCohorts(with result: ResultData?) -> (add: Set<String>, remove: Set<String>)?
}

/// `RSDComparableSurveyRule` is a survey rule that matches an expected result to the answer and vends a skip
/// identifier if the match is evaluated to `true`.
@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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
    public func evaluateRule(with result: ResultData?) -> String? {
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
    public func evaluateCohorts(with result: ResultData?) -> (add: Set<String>, remove: Set<String>)? {
        guard let cohort = self.cohort else { return nil }
        return isMatching(to: result, op: _ruleOperator) ? ([cohort], []) : ([], [cohort])
    }
}

