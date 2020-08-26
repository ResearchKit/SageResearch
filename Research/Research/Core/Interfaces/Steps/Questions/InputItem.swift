//
//  InputItem.swift
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

public protocol InputItemBuilder {
    var answerType: AnswerType { get }
    func buildInputItem(for question: Question) -> InputItem
}

public protocol InputItem : InputItemBuilder {
    var identifier: String? { get }
    var inputUIHint: RSDFormUIHint { get }
    var fieldLabel: String? { get }
    var placeholder: String? { get }
    var isOptional: Bool { get }
    var isExclusive: Bool { get }
}

public extension InputItem {
    func buildInputItem(for question: Question) -> InputItem { self }
}

public protocol ChoiceInputItem : InputItem, RSDChoice {
    func jsonElement(selected: Bool) -> JsonElement?
}

public extension ChoiceInputItem {
    var placeholder: String? { nil }
    var isOptional: Bool { true }
}

public protocol SkipCheckboxInputItem : ChoiceInputItem {
    var matchingValue : JsonElement? { get }
}

public extension SkipCheckboxInputItem {
    /// A JSON encodable object to return as the value when this choice is selected. A `null` value
    /// indicates that the user has selected to skip the question or "prefers not to answer".
    var answerValue: Codable? { matchingValue ?? JsonElement.null }
    var identifier: String? { nil }
    var detail: String? { nil }
    var imageData: RSDImageData? { nil }
    var isExclusive: Bool { true }
    var answerType: AnswerType { AnswerTypeNull() }
    var inputUIHint: RSDFormUIHint { .checkbox }
    
    func jsonElement(selected: Bool) -> JsonElement? {
        selected ? (matchingValue ?? JsonElement.null) : nil
    }
    
    func isEqualToResult(_ result: RSDResult?) -> Bool {
        guard let answerResult = result as? AnswerResult else { return false }
        let answer = answerResult.jsonValue ?? JsonElement.null
        let matching = self.matchingValue ?? JsonElement.null
        return answer == matching
    }
}

public protocol CheckboxInputItem : ChoiceInputItem, RSDComparable {
}

public extension CheckboxInputItem {
    var inputUIHint: RSDFormUIHint { .checkbox }
    var isExclusive: Bool { false }
    var answerType: AnswerType { AnswerTypeBoolean() }
    var imageData: RSDImageData? { nil }
    var answerValue: Codable? { true }
    var matchingAnswer: Any? { true }
    
    func jsonElement(selected: Bool) -> JsonElement? {
        .boolean(selected)
    }
}

public protocol KeyboardTextInputItem : InputItem {

    /**
     * Options for displaying a text field. This is only applicable for certain types of UI hints
     * and data types. If not applicable, it will be ignored.
     */
    var keyboardOptions: KeyboardOptions { get }

    /**
     * This can be used to return a class used to format and/or validate the text input.
     */
    func buildTextValidator() -> TextInputValidator
    
    /**
     * For certain types of input items, there may be a picker associated with it.
     */
    func buildPickerSource() -> RSDPickerDataSource?
}

public protocol TextInputValidator {
    func answerText(for answer: Any?) -> String?
    func validateInput(text: String?) throws -> Any?
    func validateInput(answer: Any?) throws -> Any?
}

public protocol DoubleTextInputItem : KeyboardTextInputItem {
    var formatOptions: DoubleFormatOptions? { get }
}

public extension DoubleTextInputItem {
    var answerType: AnswerType { AnswerTypeNumber() }
    var keyboardOptions: KeyboardOptions { KeyboardOptionsObject.decimalEntryOptions }
    
    func buildTextValidator() -> TextInputValidator {
        formatOptions ?? DoubleFormatOptions()
    }
    
    func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: min,
                                               maximum: max,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public protocol IntegerTextInputItem : KeyboardTextInputItem {
    var formatOptions: IntegerFormatOptions? { get }
}

public extension IntegerTextInputItem {
    var answerType: AnswerType { AnswerTypeInteger() }
    
    func buildTextValidator() -> TextInputValidator {
        formatOptions ?? IntegerFormatOptions()
    }
    
    func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: min,
                                               maximum: max,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public protocol YearTextInputItem : KeyboardTextInputItem {
    var formatOptions: YearFormatOptions? { get }
}

public extension YearTextInputItem {
    var answerType: AnswerType { AnswerTypeInteger() }
    
    var keyboardOptions: KeyboardOptions { KeyboardOptionsObject.integerEntryOptions }
    
    func buildTextValidator() -> TextInputValidator {
        formatOptions ?? YearFormatOptions()
    }
    
    func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: max,
                                               maximum: min,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public protocol ChoicePickerInputItem : KeyboardTextInputItem, RSDChoiceOptions {
    var jsonChoices: [JsonChoice] { get }
}

public extension ChoicePickerInputItem {
    var choices: [RSDChoice] { jsonChoices }
    var keyboardOptions: KeyboardOptions { KeyboardOptionsObject() }
    func buildTextValidator() -> TextInputValidator { PassThruValidator() }
    func buildPickerSource() -> RSDPickerDataSource? { self }
}

public protocol DateTimeInputItem : KeyboardTextInputItem {
    var pickerMode: RSDDatePickerMode { get }
    var formatOptions: RSDDateRangeObject? { get }
}

public extension DateTimeInputItem {
    
    var keyboardOptions: KeyboardOptions {
        KeyboardOptionsObject.dateTimeEntryOptions
    }

    var answerType: AnswerType {
        let codingFormat = formatOptions?.dateCoder?.inputFormatter.dateFormat ?? pickerMode.defaultCodingFormat
        return AnswerTypeDateTime(codingFormat: codingFormat)
    }
    
    
    func buildTextValidator() -> TextInputValidator {
        DateTimeValidator(pickerMode: pickerMode, range: formatOptions)
    }
    
    func buildPickerSource() -> RSDPickerDataSource? {
        formatOptions.map { $0.dataSource().0 } ?? nil
    }
}
