//
//  ORKQuestionResult+Research.swift
//  RK1Translator
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

extension RSDAnswerResult {
    
    func orkResult() -> ORKResult {
        if let result = self as? ORKResult {
            return result
        }
        
        if let sequenceType = self.answerType.sequenceType {
            if sequenceType == .array {
                if self.answerType.sequenceSeparator != nil {
                    return ORKMultipleComponentQuestionResult(from: self)
                }
                else {
                    return ORKChoiceQuestionResult(from: self)
                }
            }
            else {
                return ORKQuestionResult(identifier: self.identifier)
            }
        }
        else {
            switch self.answerType.baseType {
            case .boolean:
                return ORKBooleanQuestionResult(from: self)
            case .decimal, .integer:
                return ORKNumericQuestionResult(from: self)
            case .string:
                return ORKTextQuestionResult(from: self)
            case .date:
                if self.answerType.dateFormat == RSDDateCoderObject.timeOfDay.rawValue {
                    return ORKTimeOfDayQuestionResult(from: self)
                }
                else {
                    return ORKDateQuestionResult(from: self)
                }
            default:
                return ORKQuestionResult(identifier: self.identifier)
            }
        }
    }
}

/// The `ORKQuestionResult` extends the shared implementation of `RSDAnswerResult`.
extension ORKQuestionResult { // : RSDAnswerResult
    
    /// Returns `.answer` type.
    public var type: RSDResultType {
        return .answer
    }
    
    /// Returns the `answer` property.
    public var value: Any? {
        get {
            return self.answer
        }
        set(newValue) {
            self.answer = newValue
        }
    }
    
    /// Encodes the result as an `RSDAnswerResultObject`
    public func encode(to encoder: Encoder) throws {
        guard let result = self as? RSDAnswerResult else {
            let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Question result does not support `RSDAnswerResult` and cannot be encoded.")
            throw EncodingError.invalidValue(self, context)
        }
        var answerResult = RSDAnswerResultObject(identifier: identifier, answerType: result.answerType)
        answerResult.startDate = startDate
        answerResult.endDate = endDate
        answerResult.value = result.value
        try answerResult.encode(to: encoder)
    }
}

extension ORKBooleanQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.booleanAnswer = (result.value as? NSNumber) ?? (result.value as? RSDJSONNumber)?.jsonNumber()
    }
    
    /// Returns `.boolean`
    public var answerType: RSDAnswerResultType {
        return .boolean
    }
}

extension ORKChoiceQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.answer = result.value
        self.questionType = .multipleChoice
    }
    
    /// Returns a new instance of an answer result with a sequence type of `.array`
    /// and a base type of `.string`.
    public var answerType: RSDAnswerResultType {
        return RSDAnswerResultType(baseType: .string, sequenceType: .array)
    }
}

extension ORKDateQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.answer = result.value
        if result.answerType.dateFormat == RSDDateCoderObject.dateOnly.rawValue {
            self.questionType = .date
        }
        else {
            self.questionType = .dateAndTime
        }
    }
    
    /// Returns `.date` or a new instance with a date-only format if this is a date-only result.
    public var answerType: RSDAnswerResultType {
        if self.questionType == ORKQuestionType.date {
            return RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: RSDDateCoderObject.dateOnly.rawValue)
        }
        else {
            return .date
        }
    }
}

extension ORKMultipleComponentQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.answer = result.value
        self.separator = result.answerType.sequenceSeparator
    }
    
    /// Returns a new instance of an answer result with a sequence type of `.array`,
    /// a base type of `.string`, and a separator.
    public var answerType: RSDAnswerResultType {
        return RSDAnswerResultType(baseType: .string, sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: separator)
    }
}

extension ORKNumericQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.numericAnswer = (result.value as? NSNumber) ?? (result.value as? RSDJSONNumber)?.jsonNumber()
        self.questionType = (result.answerType.baseType == .integer) ? .integer : .decimal
        self.unit = result.answerType.unit
    }
    
    /// Returns a new instance of an answer result with a base type of `.decimal` and a unit.
    public var answerType: RSDAnswerResultType {
        switch self.questionType {
        case .integer:
             return RSDAnswerResultType(baseType: .integer, sequenceType: nil, formDataType: nil, dateFormat: nil, unit: unit)
        default:
            return RSDAnswerResultType(baseType: .decimal, sequenceType: nil, formDataType: nil, dateFormat: nil, unit: unit)
        }
    }
}

extension ORKScaleQuestionResult : RSDAnswerResult {
    
    public var answerType: RSDAnswerResultType {
        switch self.questionType {
        case .integer:
            return .integer
        default:
            return .decimal
        }
    }
}

extension ORKTextQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.answer = result.value
    }
    
    /// Returns `.string`
    public var answerType: RSDAnswerResultType {
        return .string
    }
}

extension ORKTimeIntervalQuestionResult : RSDAnswerResult {
    
    /// Returns `.decimal`
    public var answerType: RSDAnswerResultType {
        return .decimal
    }
}

extension ORKTimeOfDayQuestionResult : RSDAnswerResult {
    
    convenience init(from result: RSDAnswerResult) {
        self.init(identifier: result.identifier)
        self.startDate = result.startDate
        self.endDate = result.endDate
        self.answer = result.value
    }
    
    /// Returns `.date` with a date format coding of "HH:mm"
    public var answerType: RSDAnswerResultType {
        return RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: RSDDateCoderObject.timeOfDay.rawValue)
    }
}
