//
//  AnswerResultObject.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

public final class AnswerResultObject : AnswerResult, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case type, identifier, jsonAnswerType = "answerType", jsonValue = "value", questionText, startDate, endDate
    }
    public private(set) var type: RSDResultType = .answer
    
    public let identifier: String
    public let jsonAnswerType: AnswerType?
    public var jsonValue: JsonElement?
    public var questionText: String?
    
    public var startDate: Date = Date()
    public var endDate: Date = Date()
    
    public var value: Any? {
        return jsonValue?.jsonObject()
    }
    
    public init(identifier: String, value: JsonElement, questionText: String? = nil) {
        self.identifier = identifier
        self.jsonAnswerType = value.answerType
        self.jsonValue = value
        self.questionText = questionText
    }
    
    public init(identifier: String, answerType: AnswerType?, value: JsonElement? = nil, questionText: String? = nil) {
        self.identifier = identifier
        self.jsonAnswerType = answerType
        self.jsonValue = value
        self.questionText = questionText
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return AnswerResultObject(identifier: identifier, answerType: jsonAnswerType, value: jsonValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decode(RSDResultType.self, forKey: .type)
        self.questionText = try container.decodeIfPresent(String.self, forKey: .questionText)
        if container.contains(.jsonAnswerType) {
            let nestedDecoder = try container.superDecoder(forKey: .jsonAnswerType)
            let jsonAnswerType = try decoder.factory.decodeAnswerType(from: nestedDecoder)
            if container.contains(.jsonValue) {
                let jsonValueDecoder = try container.superDecoder(forKey: .jsonValue)
                self.jsonValue = try jsonAnswerType.decodeValue(from: jsonValueDecoder)
            }
            else {
                self.jsonValue = nil
            }
            self.jsonAnswerType = jsonAnswerType
        }
        else {
            self.jsonValue = try container.decodeIfPresent(JsonElement.self, forKey: .jsonValue)
            self.jsonAnswerType = nil
        }
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate) ?? Date()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(self.questionText, forKey: .questionText)
        try container.encodeIfPresent(self.startDate, forKey: .startDate)
        try container.encodeIfPresent(self.endDate, forKey: .endDate)
        if let encodable = self.jsonAnswerType {
            let nestedEncoder = container.superEncoder(forKey: .jsonAnswerType)
            try encodable.encode(to: nestedEncoder)
        }
        let jsonVal = try self.encodingValue()
        try container.encodeIfPresent(jsonVal, forKey: .jsonValue)
    }
}

extension AnswerResultObject : RSDAnswerResult {
    public var answerType: RSDAnswerResultType {
        (self.jsonAnswerType as? AnswerResultTypeConvertible)?.answerResultType() ?? .codable
    }
}

extension AnswerResultObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func answerResultExamples() -> [AnswerResultObject] {
        let typeAndValue = AnswerTypeExamples.examplesWithValues()
        let date = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        return typeAndValue.enumerated().map { (index, object) -> AnswerResultObject in
            let result = AnswerResultObject(identifier: "question\(index+1)", answerType: object.0, value: object.1)
            result.startDate = date
            result.endDate = date
            return result
        }
    }
    
    static func examples() -> [Encodable] {
        return answerResultExamples()
    }
}

