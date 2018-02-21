//
//  RSDSurveyRule.swift
//  ResearchSuite
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

/// List of rules creating the survey rule items.
public enum RSDSurveyRuleOperator: String, Codable, RSDEnumSet {
    
    /// Survey rule for checking if the skip identifier should apply if the answer was skipped
    /// in which case the result answer value will be `nil`
    case skip               = "de"

    /// The answer value is equal to the `matchingAnswer`.
    case equal              = "eq"
    
    /// The answer value is *not* equal to the `matchingAnswer`.
    case notEqual           = "ne"
    
    /// The answer value is less than the `matchingAnswer`.
    case lessThan           = "lt"
    
    /// The answer value is greater than the `matchingAnswer`.
    case greaterThan        = "gt"
    
    /// The answer value is less than or equal to the `matchingAnswer`.
    case lessThanEqual      = "le"
    
    /// The answer value is greater than or equal to the `matchingAnswer`.
    case greaterThanEqual   = "ge"
    
    /// The answer value is "other than" the `matchingAnswer`. This is intended for use where the answer
    /// type is an array and the comparison is for the case where the array is evaluated as the elements
    /// are *not* included. For example, if the `matchingAnswer` is `[0,3]` and the result answer is
    /// `[2,4]` then this will evaluate to `true` and return the `skipIdentifier` because neither `2` nor
    /// `4` are in the set defined by the `matchingAnswer`.
    case otherThan          = "ot"
    
    /// List of all the operators.
    public static var all: Set<RSDSurveyRuleOperator> {
        return [.skip, .equal, .notEqual, .lessThan, .greaterThan, .lessThanEqual, .greaterThanEqual, .otherThan]
    }
}

extension RSDSurveyRuleOperator : RSDDocumentableEnum {
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

/// `RSDComparable` can be used to compare a stored result to a matching value.
public protocol RSDComparable {
    
    /// Expected answer for the rule. If `nil`, then the operator must be .skip or this will return a nil
    /// value.
    var matchingAnswer: Any? { get }
}

/// `RSDDecimalComparable` can be used to compare a stored result to a matching value where the values
/// are decimals.
public protocol RSDDecimalComparable : RSDComparable {
    
    /// The accuracy to use for comparing two decimal values.
    var accuracy: Decimal? { get }
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

extension RSDComparable {
    
    /// Is the choice value equal to the given result?
    /// - parameter result: A result to test for equality.
    /// - returns: `true` if the values are equal.
    public func isEqualToResult(_ result: RSDResult?) -> Bool {
        let op: RSDSurveyRuleOperator = (self.matchingAnswer == nil) ? .skip : .equal
        return isMatching(to: result, op: op)
    }
    
    func isMatching(to result: RSDResult?, op: RSDSurveyRuleOperator) -> Bool {
        
        // If this is the skip operation then the values aren't equal *unless* it's nil
        guard let answerResult = result as? RSDAnswerResult, let value = answerResult.value
            else {
                return op == .skip ? true : false
        }
        if op == .skip {
            return false
        }
        
        guard let predicate = rulePredicate(with: answerResult.answerType, op: op),
            let cValue = convertValue(for: value, with: answerResult.answerType)
            else {
                return false
        }
        
        if predicate.evaluate(with: cValue) {
            return true
        } else {
            return false
        }
    }
    
    func rulePredicate(with answerType: RSDAnswerResultType, op: RSDSurveyRuleOperator) -> NSPredicate? {

        // Exit early if operator or value are unsupported
        guard let answerValue = convertValue(for: matchingAnswer, with: answerType) else { return nil }
        let isArray = (answerType.sequenceType == .array)
        let isDecimal = (answerType.baseType == .decimal)

        switch(op) {
        case .skip:
            return NSPredicate(format: "SELF = NULL")
        case .equal:
            if isArray {
                return NSPredicate(format: "ANY %@ IN SELF", answerValue)
            } else if isDecimal, let num = answerValue as? NSNumber {
                let decimal = num.decimalValue
                let epsilon = (self as? RSDDecimalComparable)?.accuracy ?? Decimal(0.00001)
                let min = decimal - epsilon
                let max = decimal + epsilon
                return NSPredicate(format: "SELF >= %@ AND SELF <= %@", min as NSNumber, max as NSNumber)
            } else {
                return NSPredicate(format: "SELF == %@", answerValue)
            }
        case .notEqual:
            return NSPredicate(format: "SELF <> %@", answerValue)
        case .otherThan:
            if isArray {
                return NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "ANY %@ IN SELF", answerValue))
            } else {
                return NSPredicate(format: "SELF <> %@", answerValue)
            }
        case .greaterThan:
            return NSPredicate(format: "SELF > %@", answerValue)
        case .greaterThanEqual:
            return NSPredicate(format: "SELF >= %@", answerValue)
        case .lessThan:
            return NSPredicate(format: "SELF < %@", answerValue)
        case .lessThanEqual:
            return NSPredicate(format: "SELF <= %@", answerValue)
        }
    }
    
    func convertValue(for value: Any?, with answerType: RSDAnswerResultType) -> CVarArg? {

        // Exit early if the answer is nil
        guard let answerValue = value else { return nil }

        // If this is a sequence type then need to convert the value into an NSArray
        // of CVarArg values.
        if let sequenceType = answerType.sequenceType {
            guard sequenceType == .array else {
                assertionFailure("Unsupported sequenceType: \(sequenceType)")
                return nil
            }
            let array = value as? [Any] ?? [answerValue]
            let baseType = RSDAnswerResultType(baseType: answerType.baseType)
            let ret = array.rsd_mapAndFilter { self.convertValue(for: $0, with: baseType) }
            return ret.count == array.count ? ret : nil
        }

        // Otherwise, look at the base type
        switch answerType.baseType {
        case .string:
            return "\(answerValue)" as NSString
        case .date:
            if let date = answerValue as? NSDate {
                return date
            } else if let dateString = answerValue as? String,
                let date = RSDFactory.shared.decodeDate(from: dateString) {
                return date as NSDate
            } else {
                assertionFailure("Failed to convert \(answerValue) to a date.")
                return nil
            }
        case .data:
            assertionFailure("data base type is unsupported")
            return nil
        default:
            return (answerValue as? NSNumber) ?? (answerValue as? RSDJSONNumber)?.jsonNumber()
        }
    }
}


