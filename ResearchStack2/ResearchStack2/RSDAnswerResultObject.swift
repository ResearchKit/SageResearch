//
//  RSDAnswerResultObject.swift
//  ResearchStack2
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

/// `RSDAnswerResultObject` is a concrete implementation of a result that can be described using a single value.
public struct RSDAnswerResultObject : RSDAnswerResult, Codable {

    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let type: RSDResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// The answer type of the answer result. This includes coding information required to encode and
    /// decode the value. The value is expected to conform to one of the coding types supported by the answer type.
    public let answerType: RSDAnswerResultType
    
    /// The answer for the result.
    public var value: Any?
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - answerType: The answer type of the answer result.
    public init(identifier: String, answerType: RSDAnswerResultType) {
        self.identifier = identifier
        self.answerType = answerType
        self.type = .answer
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, startDate, endDate, answerType, value
    }
    
    /// Initialize from a `Decoder`.
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.type = try container.decode(RSDResultType.self, forKey: .type)
        
        let answerType = try container.decode(RSDAnswerResultType.self, forKey: .answerType)
        self.answerType = answerType
        if container.contains(.value) {
            let nestedDecoder = try container.superDecoder(forKey: .value)
            self.value = try answerType.decodeValue(from: nestedDecoder)
        }
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(type, forKey: .type)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        
        try container.encode(answerType, forKey: .answerType)
        if let obj = value {
            let nestedEncoder = container.superEncoder(forKey: .value)
            try answerType.encode(obj, to: nestedEncoder)
        }
    }
}

extension RSDAnswerResultObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .type, .startDate, .endDate, .answerType, .value]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .type:
                if idx != 1 { return false }
            case .startDate:
                if idx != 2 { return false }
            case .endDate:
                if idx != 3 { return false }
            case .answerType:
                if idx != 4 { return false }
            case .value:
                if idx != 5 { return false }
            }
        }
        return keys.count == 6
    }
    
    static func answerResultExamples() -> [RSDAnswerResultObject] {
        let typeAndValue = RSDAnswerResultType.examplesWithValues()
        let date = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        return typeAndValue.enumerated().map { (index, object) -> RSDAnswerResultObject in
            var result = RSDAnswerResultObject(identifier: "question\(index+1)", answerType: object.answerType)
            result.startDate = date
            result.endDate = date
            result.value = object.value
            return result
        }
    }
    
    static func examples() -> [Encodable] {
        return answerResultExamples()
    }
}
