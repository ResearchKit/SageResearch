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

public struct JsonSurveyRuleObject : RSDComparableSurveyRule, Codable, Hashable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case skipToIdentifier, matchingValue = "matchingAnswer", ruleOperator, cohort
    }
    
    /// Optional skip identifier for this rule. If available, this will be used as the skip
    /// identifier, otherwise the `skipToIdentifier` will be assumed to be `RSDIdentifier.exit`
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

// TODO: syoung 04/06/2020 Replace with JsonModel-Swift in next set of deprecations.
/// A `Codable` element that can be used to serialize any `JsonSerializable`.
public enum JsonElement : Codable, Hashable, RSDJSONValue {
    case string(String)
    case integer(Int)
    case number(RSDJSONNumber)
    case boolean(Bool)
    case null
    case array([Any])
    case object([String : Any])
    
    public func jsonObject() -> RSDJSONSerializable {
        switch self {
        case .null:
            return NSNull()
        case .boolean(let value):
            return value
        case .string(let value):
            return value
        case .integer(let value):
            return value
        case .number(let value):
            return value.jsonNumber() ?? NSNull()
        case .array(let value):
            return value.jsonObject()
        case .object(let value):
            return value.jsonObject()
        }
    }
    
    public var jsonType: JsonType {
        switch self {
        case .null:
            return .null
        case .boolean(_):
            return .boolean
        case .string(_):
            return .string
        case .integer(_):
            return .integer
        case .number(_):
            return .number
        case .array(_):
            return .array
        case .object(_):
            return .object
        }
    }
    
    public init(_ jsonValue: RSDJSONValue?) {
        let obj = jsonValue?.jsonObject()
        if obj == nil || obj is NSNull {
            self = .null
        }
        else if let value = obj as? String {
            self = .string(value)
        }
        else if let value = obj as? Bool {
            self = .boolean(value)
        }
        else if let value = obj as? Int {
            self = .integer(value)
        }
        else if let value = obj as? RSDJSONNumber {
            self = .number(value)
        }
        else if let value = obj as? [RSDJSONSerializable] {
            self = .array(value)
        }
        else if let value = obj as? [String : RSDJSONSerializable] {
            self = .object(value)
        }
        else {
            fatalError("Unsupported cast of \(String(describing: obj)). Cannot serialize this object.")
        }
    }
    
    public init(from decoder: Decoder) throws {
        if let _ = try? decoder.container(keyedBy: AnyCodingKey.self) {
            let value = try AnyCodableDictionary(from: decoder)
            self = .object(value.dictionary)
        }
        else if let _ = try? decoder.unkeyedContainer() {
            let value = try AnyCodableArray(from: decoder)
            self = .array(value.array)
        }
        else {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .null
            }
            else if let value = try? container.decode(Bool.self) {
                self = .boolean(value)
            }
            else if let value = try? container.decode(Int.self) {
                self = .integer(value)
            }
            else if let value = try? container.decode(Double.self) {
                self = .number(value)
            }
            else {
                let value = try container.decode(String.self)
                self = .string(value)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .null:
            try NSNull().encode(to: encoder)
        case .boolean(let value):
            try value.encode(to: encoder)
        case .string(let value):
            try value.encode(to: encoder)
        case .integer(let value):
            try value.encode(to: encoder)
        case .number(let value):
            try value.encode(to: encoder)
        case .array(let value):
            try AnyCodableArray(value).encode(to: encoder)
        case .object(let value):
            try AnyCodableDictionary(value).encode(to: encoder)
        }
    }
    
    public static func == (lhs: JsonElement, rhs: JsonElement) -> Bool {
        switch lhs {
        case .null:
            if case .null = rhs { return true } else { return false }
        case .boolean(let lv):
            if case .boolean(let rv) = rhs { return rv == lv } else { return false }
        case .string(let lv):
            if case .string(let rv) = rhs { return rv == lv } else { return false }
        case .integer(let lv):
            if case .integer(let rv) = rhs { return rv == lv } else { return false }
        case .number(let lv):
            if case .number(let rv) = rhs { return rv.jsonNumber() == lv.jsonNumber() } else { return false }
        case .array(let lv):
            if case .array(let rv) = rhs { return (lv as NSArray).isEqual(to: rv) } else { return false }
        case .object(let lv):
            if case .object(let rv) = rhs { return (lv as NSDictionary).isEqual(to: rv) } else { return false }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .null:
            "null".hash(into: &hasher)
        case .boolean(let value):
            "boolean".hash(into: &hasher)
            value.hash(into: &hasher)
        case .string(let value):
            "string".hash(into: &hasher)
            value.hash(into: &hasher)
        case .integer(let value):
            "integer".hash(into: &hasher)
            value.hash(into: &hasher)
        case .number(let value):
            "number".hash(into: &hasher)
            value.jsonNumber()?.hash(into: &hasher)
        case .array(let value):
            "array".hash(into: &hasher)
            (value as NSArray).hash(into: &hasher)
        case .object(let value):
            "object".hash(into: &hasher)
            (value as NSDictionary).hash(into: &hasher)
        }
    }
}

extension JsonElement {
    var answerType: AnswerType {
        switch self {
        case .null:
            return AnswerTypeNull()
        case .boolean(_):
            return AnswerTypeBoolean()
        case .string(_):
            return AnswerTypeString()
        case .integer(_):
            return AnswerTypeInteger()
        case .number(_):
            return AnswerTypeNumber()
        case .array(let arr):
            if arr is [Int] {
                return AnswerTypeArray(baseType: .integer)
            } else if arr is [NSNumber] || arr is [RSDJSONNumber] {
                return AnswerTypeArray(baseType: .number)
            } else if arr is [String] {
                return AnswerTypeArray(baseType: .string)
            } else {
                return AnswerTypeArray(baseType: .object)
            }
        case .object(_):
            return AnswerTypeObject()
        }
    }
}

extension Encodable {

    /// Return the `JsonElement` for this object using the serialization strategy for numbers and
    /// dates defined by `SerializationFactory.shared`.
    public func jsonElement(using factory: RSDFactory = RSDFactory.shared) throws -> JsonElement {
        let data = try factory.createJSONEncoder().encode(self)
        let json = try factory.createJSONDecoder().decode(JsonElement.self, from: data)
        return json
    }
}
