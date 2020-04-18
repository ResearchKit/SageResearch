//
//  JsonSurveyRuleObject.swift
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
import JsonModel

public struct JsonSurveyRuleObject : RSDComparableSurveyRule, Codable, Hashable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case skipToIdentifier, matchingValue = "matchingAnswer", ruleOperator, cohort
    }
    
    /// Optional skip identifier for this rule. If available, this will be used as the skip
    /// identifier; otherwise the `skipToIdentifier` will be assumed to be `RSDIdentifier.exit`.
    public let skipToIdentifier: String?
    
    /// Json-Codable matching answer.
    public let matchingValue: JsonElement?
    
    /// The rule operator to apply. If `nil`, `.equal` will be assumed unless the `expectedAnswer`
    /// is also nil, in which case `.skip` will be assumed.
    public let ruleOperator: RSDSurveyRuleOperator?
    
    /// Optional cohort to assign if the rule matches. If available, then an `RSDCohortRule` can be
    /// used to track the cohort to assign depending upon how this rule evaluates.
    public let cohort: String?
    
    /// Expected answer for the rule. If `nil`, then the operator must be .skip or this will return
    /// a nil value.
    public var matchingAnswer: Any? {
        guard let value = matchingValue, value != .null else { return nil }
        return value.jsonObject()
    }

    public init(skipToIdentifier: String?, matchingValue: JsonElement?, ruleOperator: RSDSurveyRuleOperator? = nil, cohort: String? = nil) {
        self.skipToIdentifier = skipToIdentifier
        self.cohort = cohort
        self.ruleOperator = ruleOperator
        self.matchingValue = matchingValue
    }
}

extension JsonSurveyRuleObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .skipToIdentifier:
            return .init(propertyType: .primitive(.string))
        case .matchingValue:
            return .init(propertyType: .any)
        case .ruleOperator:
            return .init(propertyType: .reference(RSDSurveyRuleOperator.documentableType()))
        case .cohort:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [JsonSurveyRuleObject] {
        [JsonSurveyRuleObject(skipToIdentifier: "foo", matchingValue: .boolean(true)),
         JsonSurveyRuleObject(skipToIdentifier: nil, matchingValue: .number(5.0), ruleOperator: .equal, cohort: "baloo")]
    }
}
