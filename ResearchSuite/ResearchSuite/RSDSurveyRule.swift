//
//  RSDSurveyRule.swift
//  ResearchSuite
//
//  Copyright © 2016-2017 Sage Bionetworks. All rights reserved.
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

/**
 The `RSDSurveyRule` defines an evaluation rule and returns a step identifier if appropriate.
 */
public protocol RSDSurveyRule {
    
    /**
     For a given result (if any), what is the step that the survey should go to next?
     */
    func evaluateRule(with result: RSDResult?) -> String?
}

/**
 List of rules creating the survey rule items.
 */
public enum RSDSurveyRuleOperator: String, Codable {
    case skip               = "de"
    case equal              = "eq"
    case notEqual           = "ne"
    case lessThan           = "lt"
    case greaterThan        = "gt"
    case lessThanEqual      = "le"
    case greaterThanEqual   = "ge"
    case otherThan          = "ot"
}

/**
 `RSDComparableSurveyRule` is a survey rule that matches an expected result to the answer and vends a skip identifier if the match is evaluated to `true`.
 */
public protocol RSDComparableSurveyRule : RSDSurveyRule {
    
    /**
     Optional skip identifier for this rule. If available, this will be used as the skip identifier, otherwise
     the skipIdentifier will be assumed to be `RSDIdentifier.exit`
     */
    var skipIdentifier: String? { get }
    
    /**
     Expected answer for the rule. If nil, then the operator must be .skip or this will return a nil value.
     */
    var matchingAnswer: Any? { get }
    
    /**
     The rule operator to apply. If nil, `.equal` will be assumed unless the `expectedAnswer` is also nil,
     in which case skip will be assumed.
     */
    var ruleOperator: RSDSurveyRuleOperator? { get }
}

extension RSDComparableSurveyRule {
    
    public func isValidRule() -> Bool {
        let value = self.matchingAnswer as? NSObject
        let op: RSDSurveyRuleOperator = self.ruleOperator ?? ((value == nil) ? .skip : .equal)
        return (value != nil) || (op == .skip)
    }
    
    public func evaluateRule(with result: RSDResult?) -> String? {
        
        // If this is the skip operation then the values aren't equal *unless* it's nil
        guard let answerResult = result as? RSDAnswerResult, let value = answerResult.value
            else {
                return ruleOperator == .skip ? skipIdentifier : nil
        }
        if ruleOperator == .skip {
            return nil
        }
        
        guard let predicate = rulePredicate(with: answerResult.answerType),
            let cValue = convertValue(for: value, with: answerResult.answerType)
            else {
                return nil
        }
        
        if predicate.evaluate(with: cValue) {
            return skipIdentifier ?? RSDIdentifier.exit.rawValue
        } else {
            return nil
        }
    }
    
    func rulePredicate(with answerType: RSDAnswerResultType) -> NSPredicate? {

        // Exit early if operator or value are unsupported
        guard let answerValue = convertValue(for: matchingAnswer, with: answerType) else { return nil }
        let op = ruleOperator ?? .equal
        let isArray = answerType.sequenceType == .array

        switch(op) {
        case .skip:
            return NSPredicate(format: "SELF = NULL")
        case .equal:
            if isArray {
                return NSPredicate(format: "ANY %@ IN SELF", answerValue)
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
            return (answerValue as? NSDate) ?? ((answerValue as? NSString)?.dateValue as NSDate?)
        case .data:
            assertionFailure("data base type is unsupported")
            return nil
        default:
            return (answerValue as? NSNumber) ?? (answerValue as? RSDJSONNumber)?.jsonNumber()
        }
    }
}
