//
//  RSDAnswerResultObject.swift
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

/// `RSDAnswerResultObject` is a concrete implementation of a result that can be described using a single value.
@available(*, deprecated, message: "Use `AnswerResultObject` instead")
public struct RSDAnswerResultObject : RSDAnswerResult, Codable {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, type, startDate, endDate, answerType, value, questionText
    }

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
    
    /// The question text for the form step (if applicable).
    public var questionText: String? = nil
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - answerType: The answer type of the answer result.
    public init(identifier: String, answerType: RSDAnswerResultType, value: Any? = nil) {
        self.identifier = identifier
        self.answerType = answerType
        self.type = .answer
        self.value = value
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
        self.questionText = try container.decodeIfPresent(String.self, forKey: .questionText)
        
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
        try container.encodeIfPresent(self.questionText, forKey: .questionText)
        
        try container.encode(answerType, forKey: .answerType)
        if let obj = value {
            let nestedEncoder = container.superEncoder(forKey: .value)
            try answerType.encode(obj, to: nestedEncoder)
        }
    }
}
