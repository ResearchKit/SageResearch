//
//  RSDSurveyRuleOperator.swift
//  Research
//

import Foundation
import JsonModel

/// List of rules creating the survey rule items.
public enum RSDSurveyRuleOperator: String, Codable, StringEnumSet {
    
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
    
    /// The rule should always evaluate to true.
    case always
}

extension RSDSurveyRuleOperator : DocumentableStringEnum {
}
