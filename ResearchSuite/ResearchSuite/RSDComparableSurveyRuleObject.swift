//
//  RSDComparableSurveyRuleObject.swift
//  ResearchSuite
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


public struct RSDComparableSurveyRuleObject<T : Codable> : RSDComparableSurveyRule, Decodable {
    public typealias Value = T
    
    public let skipToIdentifier: String?
    public let ruleOperator: RSDSurveyRuleOperator?
    public let matchingValue: Value?
    
    public var matchingAnswer: Any? {
        return matchingValue
    }
    
    public init(skipToIdentifier: String?, matchingValue: Value?, ruleOperator: RSDSurveyRuleOperator?) {
        self.skipToIdentifier = skipToIdentifier
        self.matchingValue = matchingValue
        self.ruleOperator = ruleOperator
    }
    
    private enum CodingKeys: String, CodingKey {
        case skipToIdentifier, matchingValue = "matchingAnswer", ruleOperator
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let skipToIdentifier = try container.decodeIfPresent(String.self, forKey: .skipToIdentifier)
        let matchingValue = try container.decodeIfPresent(Value.self, forKey: .matchingValue)
        let ruleOperator = try container.decodeIfPresent(RSDSurveyRuleOperator.self, forKey: .ruleOperator)
        if (skipToIdentifier == nil) && (matchingValue == nil) && (ruleOperator == nil) {
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
    }
}
