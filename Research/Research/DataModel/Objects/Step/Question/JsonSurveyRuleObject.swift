//
//  JsonSurveyRuleObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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
