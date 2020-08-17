//
//  RSDComparable.swift
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
import JsonModel


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

extension RSDComparable {
    
    /// Is the choice value equal to the given result?
    /// - parameter result: A result to test for equality.
    /// - returns: `true` if the values are equal.
    public func isEqualToResult(_ result: RSDResult?) -> Bool {
        let op: RSDSurveyRuleOperator = (self.matchingAnswer == nil) ? .skip : .equal
        return isMatching(to: result, op: op)
    }
    
    func isMatching(to result: RSDResult?, op: RSDSurveyRuleOperator) -> Bool {
        
        // If this is an `.always` operator, it should evaluate as a match.
        if op == .always {
            return true
        }
        
        if let answerResult = result as? AnswerResult {
            return isMatching(to: answerResult.jsonValue?.jsonObject(),
                              answerType: answerResult.jsonAnswerType ?? AnswerTypeString(),
                              op: op)
        }
        else if let answerResult = result as? RSDAnswerResult {
            return isMatching(to: answerResult.value, answerType: answerResult.answerType.answerType, op: op)
        }
        else {
            return op == .skip ? true : false
        }
    }
    
    func isMatching(to value: Any?, answerType: AnswerType, op: RSDSurveyRuleOperator) -> Bool {
        
        // If this is the skip operation then the values aren't equal *unless* it's nil
        guard let value = value, !(value is NSNull)
            else {
                return op == .skip ? true : false
        }
        if op == .skip {
            return false
        }
        
        guard let predicate = rulePredicate(with: answerType, op: op),
            let cValue = convertValue(for: value, with: answerType)
            else {
                return false
        }
        
        if predicate.evaluate(with: cValue) {
            return true
        } else {
            return false
        }
    }
    
    func rulePredicate(with answerType: AnswerType, op: RSDSurveyRuleOperator) -> NSPredicate? {
        
        // Exit early if operator or value are unsupported
        guard let answerValue = convertValue(for: matchingAnswer, with: answerType) else { return nil }
        let isArray = (answerType is AnswerTypeArray)
        let isDecimal = (answerType.baseType == .number)
        
        switch(op) {
        case .skip:
            return NSPredicate(format: "SELF = NULL")
        case .always:
            return NSPredicate(value: true)
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
    
    func convertValue(for value: Any?, with answerType: AnswerType) -> CVarArg? {
        
        // Exit early if the answer is nil
        guard let answerValue = value, !(answerValue is NSNull) else { return nil }

        // If this is a sequence type then need to convert the value into an NSArray
        // of CVarArg values.
        if let _ = answerType as? AnswerTypeArray {
            let obj = (answerValue as? JsonElement)?.jsonObject() ?? value
            let array: [Any] = obj as? [Any] ?? [answerValue]
            let baseType = answerType.baseType.answerType
            let ret = array.compactMap { self.convertValue(for: $0, with: baseType) }
            return ret.count == array.count ? ret : nil
        }
        else if let _ = answerType as? AnswerTypeDateTime {
            if let date = answerValue as? NSDate {
                return date
            } else if let dateString = answerValue as? String,
                let date = RSDFactory.shared.decodeDate(from: dateString) {
                return date as NSDate
            } else {
                assertionFailure("Failed to convert \(answerValue) to a date.")
                return nil
            }
        }
        else {
            // Otherwise, look at the base type
            switch answerType.baseType {
            case .string:
                if let comparableValue = answerValue as? CustomStringConvertible {
                    return comparableValue.description
                }
                else {
                    return "\(answerValue)" as NSString
                }
            default:
                return (answerValue as? NSNumber) ?? (answerValue as? JsonNumber)?.jsonNumber()
            }
        }
    }
}
