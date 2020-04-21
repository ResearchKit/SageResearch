//
//  RSDComparableSurveyRuleObject.swift
//  Research
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDComparableSurveyRuleObject` is a survey rule that matches an expected result to the answer and vends a skip
/// identifier if the match is evaluated to `true`.
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
