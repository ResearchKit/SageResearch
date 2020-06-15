//
//  Question.swift
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

// TODO: syoung 04/02/2020 Add documentation for the Kotlin interfaces.


/// The protocol for the answer type of a question.
public protocol AnswerType : PolymorphicRepresentable, Encodable {
    var objectType: AnswerTypeType { get }
    static var defaultType: AnswerTypeType { get }
    
    var baseType: JsonType { get }
    
    /// Decode the JsonElement for this AnswerType from the given decoder.
    ///
    /// - parameter decoder: The nested decoder for this json element.
    /// - returns: The decoded value or `nil` if the value is not present.
    /// - throws: `DecodingError` if the encountered stored value cannot be decoded.
    func decodeValue(from decoder: Decoder) throws -> JsonElement
    
    /// Decode a `JsonElement` into the expected class type.
    ///
    /// - parameter jsonValue: The JSON value (from an array or dictionary) with the answer.
    /// - returns: The decoded value or `nil` if the value is not present.
    /// - throws: `DecodingError` if the encountered stored value cannot be decoded.
    func decodeAnswer(from jsonValue: JsonElement?) throws -> Any?
    
    /// Returns a `JsonElement` that is encoded for this answer type from the given value.
    ///
    /// - parameter value: The value to encode.
    /// - returns: The JSON serializable object for this encodable.
    func encodeAnswer(from value: Any?) throws -> JsonElement
}

public extension AnswerType {
    var typeName: String { objectType.rawValue }
}

public protocol Question : ResultNode {
    var isOptional: Bool { get }
    var isSingleAnswer: Bool { get }
    var answerType: AnswerType { get }
    func buildInputItems() -> [InputItem]
    func instantiateAnswerResult() -> AnswerResult
}

public extension Question {
    func instantiateResult() -> RSDResult {
        instantiateAnswerResult()
    }
}

public protocol QuestionStep : Question, RSDUIStep {
}

public extension QuestionStep {
    func instantiateAnswerResult() -> AnswerResult {
        instantiateStepResult() as? AnswerResult ??
            AnswerResultObject(identifier: self.identifier, answerType: self.answerType)
    }
}

public protocol SkipCheckboxQuestion : Question {
    var skipCheckbox: SkipCheckboxInputItem? { get }
}

public protocol SimpleQuestion : SkipCheckboxQuestion {
    var inputItem: InputItemBuilder { get }
}

extension SimpleQuestion {
    
    public var isSingleAnswer: Bool {
        true
    }
    
    public var answerType: AnswerType {
        inputItem.answerType
    }
    
    public func buildInputItems() -> [InputItem] {
        return [inputItem.buildInputItem(for: self), skipCheckbox].compactMap { $0 }
    }
}

public protocol MultipleInputQuestion : SkipCheckboxQuestion {
    var inputItems: [InputItemBuilder] { get }
    var sequenceSeparator: String?  { get }
}

extension MultipleInputQuestion {
    
    public var isSingleAnswer: Bool {
        false
    }
    
    public var answerType: AnswerType {
        AnswerTypeObject()
    }
    
    public func buildInputItems() -> [InputItem] {
        var all = inputItems.map { $0.buildInputItem(for: self) }
        skipCheckbox.map { all.append($0) }
        return all
    }
}

public protocol ChoiceQuestion : Question, RSDChoiceOptions {
    var baseType: JsonType { get }
    var inputUIHint: RSDFormUIHint { get }
    var jsonChoices: [JsonChoice] { get }
}

public extension ChoiceQuestion {
    
    var choices: [RSDChoice] { jsonChoices }
    
    var answerType: AnswerType {
        return isSingleAnswer ? baseType.answerType : AnswerTypeArray(baseType: baseType)
    }
    
    var defaultAnswer: Any? { nil }
    
    func buildInputItems()-> [InputItem] {
        jsonChoices.map {
            ChoiceItemWrapper(choice: $0,
                              answerType: baseType.answerType,
                              isSingleAnswer: isSingleAnswer,
                              uiHint: inputUIHint)
        }
    }
}

public struct ChoiceItemWrapper : ChoiceInputItem {
    public let choice: JsonChoice
    public let answerType: AnswerType
    public let isSingleAnswer: Bool
    public let inputUIHint: RSDFormUIHint
    
    public init(choice: JsonChoice, answerType: AnswerType, isSingleAnswer: Bool, uiHint: RSDFormUIHint) {
        self.choice = choice
        self.answerType = answerType
        self.isSingleAnswer = isSingleAnswer
        self.inputUIHint = uiHint
    }
    
    public var identifier: String? {
        answerValue.map { "\($0)" }
    }
    
    public var fieldLabel: String? {
        choice.text
    }
    
    public var answerValue: Codable? {
        choice.answerValue
    }
    
    public var text: String? {
        choice.text
    }
    
    public var detail: String? {
        choice.detail
    }
    
    public var isExclusive: Bool {
        choice.isExclusive
    }
    
    public var imageData: RSDImageData? {
        choice.imageData
    }
    
    public func isEqualToResult(_ result: RSDResult?) -> Bool {
        return choice.isEqualToResult(result)
    }
    
    public func jsonElement(selected: Bool) -> JsonElement? {
        selected ? (choice.matchingValue ?? .null) : nil
    }
}
