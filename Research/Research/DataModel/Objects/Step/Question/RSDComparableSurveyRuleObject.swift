//
//  RSDComparableSurveyRuleObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDComparableSurveyRuleObject` is a survey rule that matches an expected result to the answer and vends a skip
/// identifier if the match is evaluated to `true`.
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDComparableSurveyRuleObject<T : Codable> : RSDComparableSurveyRule, Codable {
    public typealias Value = T
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case skipToIdentifier, matchingValue = "matchingAnswer", ruleOperator, cohort
    }
    
    /// Optional skip identifier for this rule. If available, this will be used as the skip identifier,
    /// otherwise the `skipToIdentifier` will be assumed to be `RSDIdentifier.exit`
    public let skipToIdentifier: String?
    
    /// Optional cohort to assign if the rule matches. If available, then an `RSDCohortRule` can be used to track
    /// the cohort to assign depending upon how this rule evaluates.
    public let cohort: String?
    
    /// The rule operator to apply. If `nil`, `.equal` will be assumed unless the `expectedAnswer` is also nil,
    /// in which case `.skip` will be assumed.
    public let ruleOperator: RSDSurveyRuleOperator?
    
    /// Expected answer for the rule. If `nil`, then the operator must be .skip or this will return a nil value.
    public var matchingAnswer: Any? {
        return matchingValue
    }
    
    // Value-typed matching answer.
    public let matchingValue: Value?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - skipToIdentifier: Skip identifier for this rule.
    ///     - matchingValue: Value-typed matching answer.
    ///     - ruleOperator: The rule operator to apply.
    ///     - cohort: The cohort to assign for this rule if it matches.
    public init(skipToIdentifier: String?, matchingValue: Value?, ruleOperator: RSDSurveyRuleOperator?, cohort: String? = nil) {
        self.skipToIdentifier = skipToIdentifier
        self.matchingValue = matchingValue
        self.ruleOperator = ruleOperator
        self.cohort = cohort
    }
    
    /// Initialize from a `Decoder`. This method will decode the values and also check that the combination of
    /// inputs is valid.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError` if there is a decoding error.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let skipToIdentifier = try container.decodeIfPresent(String.self, forKey: .skipToIdentifier)
        let matchingValue = try container.decodeIfPresent(Value.self, forKey: .matchingValue)
        let ruleOperator = try container.decodeIfPresent(RSDSurveyRuleOperator.self, forKey: .ruleOperator)
        let cohort = try container.decodeIfPresent(String.self, forKey: .cohort)
        if (skipToIdentifier == nil) && (matchingValue == nil) && (ruleOperator == nil) && (cohort == nil) {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "All the values are nil. While each value in the comparable rule is optional, a comparable rule that does not include *any* values is invalid.")
            throw DecodingError.valueNotFound(Value.self, context)
        }
        else if (matchingValue == nil) && (ruleOperator != .skip) {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The expected answer is nil and the rule operator is not skip. This is an invalid combination.")
            throw DecodingError.valueNotFound(Value.self, context)
        }
        self.skipToIdentifier = skipToIdentifier
        self.matchingValue = matchingValue
        self.ruleOperator = ruleOperator
        self.cohort = cohort
    }
}
