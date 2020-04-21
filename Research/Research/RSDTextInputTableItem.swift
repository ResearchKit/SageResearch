//
//  RSDTextInputTableItem.swift
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

/// `RSDTextInputTableItem` is used to represent a single row in a table that holds a text entry input field.
/// Typically, this would be used to represent a single `RSDInputField` value, but it can also be used to represent a
/// single component in a multiple-component field.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDTextInputTableItem : RSDInputFieldTableItem, TextInputItemState {
    
    /// The text field options for this input.
    open private(set) var textFieldOptions: RSDTextFieldOptions?
    
    public var keyboardOptions: KeyboardOptions {
        textFieldOptions ?? KeyboardOptionsObject()
    }
    
    public var inputPrompt: String? {
        inputField.inputPrompt
    }
    
    /// The placeholder text for this input.
    open private(set) var placeholder: String?
    
    /// The formatter used for dislaying answers and converting text to a number or date.
    open private(set) var formatter: Formatter?
    
    /// The picker data source for picking an answer using a custom keyboard.
    open private(set) var pickerSource: RSDPickerDataSource?
    
    /// The answer type for this component of the answer result.
    public let answerType: RSDAnswerResultType
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex: The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField: The RSDInputField representing this tableItem.
    ///     - uiHint: The UI hint for this row of the table.
    ///     - answerType: The answer type.
    ///     - textFieldOptions: The text field options.
    ///     - formatter: The formatter used for dislaying answers and converting text to a number or date.
    ///     - pickerSource: The picker data source for selecting answers.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, answerType: RSDAnswerResultType = .string, textFieldOptions: RSDTextFieldOptions? = nil, formatter: Formatter? = nil, pickerSource: RSDPickerDataSource? = nil, placeholder: String? = nil) {
        self.answerType = answerType
        self.formatter = formatter
        self.pickerSource = pickerSource
        self.placeholder = placeholder ?? inputField.placeholder
        
        // Set the text field options
        self.textFieldOptions = textFieldOptions ?? inputField.textFieldOptions ?? {
            switch answerType.baseType {
            case .decimal:
                return RSDTextFieldOptionsObject(keyboardType: .decimalPad)
            case .integer:
                return RSDTextFieldOptionsObject(keyboardType: .numberPad)
            case .date, .string:
                return RSDTextFieldOptionsObject(keyboardType: .default)
            case .boolean, .data, .codable:
                return nil
            }
            }()
        
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: uiHint)
    }
    
    /// The answer for this input field or component of a multiple component input field.
    open override var answer: Any? {
        return _answer
    }
    private var _answer: Any?
    
    /// The text string to display as the answer.
    open var answerText: String? {
        return answerText(for:_answer)
    }
    
    /// The text string to display for a given answer.
    open func answerText(for answer: Any?) -> String? {
        if let text = pickerSource?.textAnswer(from: answer) ?? formatter?.string(for: answer) {
            return text
        } else if let anyAnswer = answer, !(anyAnswer is NSNull) {
            return String(describing: anyAnswer)
        } else {
            return nil
        }
    }
    
    /// Set the new answer value. This will throw an error if the value isn't valid. Otherwise, it will
    /// set the answer.
    /// - parameter newValue: The new value for the answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    public final func setAnswer(_ newValue: Any?) throws {
        _answer = try validatedAnswer(newValue)
    }
    
    final func setPreviousAnswer(_ jsonValue: Any?) throws {
        // If setting a previous answer, then look to see if the answer can be converted from
        // json *before* validating to see if the answer is still a valid response.
        if let newValue = jsonValue as? JsonSerializable {
            let answer = try answerType.jsonDecode(from: newValue)
            _answer = try validatedAnswer(answer)
        }
        else {
            _answer = try validatedAnswer(jsonValue)
        }
    }
    
    /// Convert the input answer into a validated answer of a supported type, or throw an error if it fails validation.
    /// - parameter newValue: The new value for the answer.
    /// - returns: The converted answer.
    open func validatedAnswer(_ newValue: Any?) throws -> Any? {
        guard let newAnswer = newValue, !(newAnswer is NSNull) else {
            return nil
        }
        let answer = try convertAnswer(newAnswer)
        
        // Look for a range on the new value if it was converted from a text field
        if let _ = newValue as? String, (answer != nil) {
            switch answerType.baseType {
                
            case .date:
                if let date = answer as? Date, let range = inputField.range as? RSDDateRange {
                    if let minDate = range.minimumDate, date < minDate {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.lessThanMinimumDate(minDate, context)
                    }
                    if let maxDate = range.maximumDate, date > maxDate {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.greaterThanMaximumDate(maxDate, context)
                    }
                }
                
            case .string:
                if let string = answer as? String {
                    if let validator = self.textFieldOptions?.textValidator, let isValid = try? validator.isValid(string), !isValid {
                        let debugDescription = self.textFieldOptions?.invalidMessage ?? "Invalid regex"
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: debugDescription)
                        throw RSDInputFieldError.invalidRegex(self.textFieldOptions?.invalidMessage, context)
                    }
                    else if let maxLen = self.textFieldOptions?.maximumLength, maxLen > 0, string.count > maxLen {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Exceeds max length of \(maxLen)")
                        throw RSDInputFieldError.exceedsMaxLength(maxLen, context)
                    }
                }
                
            default:
                break
            }
        }
        
        return answer
    }
    
    /// Convert the input answer into a validated answer of a supported type, or throw an error if it fails validation.
    /// - parameter newValue: The new value for the answer.
    /// - returns: The converted answer.
    open func convertAnswer(_ newValue: Any) throws -> Any? {
        var answer = newValue
        
        // First check if this is an array and if so, if it needs to have the first value pulled from it.
        if let array = answer as? [Any] {
            if answerType.sequenceType == .array {
                return array
            } else if array.count == 0 {
                return nil
            } else if array.count == 1 {
                answer = array.first!
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Array Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        
        if answerType.baseType == .string {
            return (answer as? String) ?? formatter?.string(for: answer) ?? "\(answer)"
        }
        else if let string = answer as? String {
            if let formatter = self.formatter {
                var obj: AnyObject?
                var err: NSString?
                formatter.getObjectValue(&obj, for: string, errorDescription: &err)
                if err != nil {
                    let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: (err! as String))
                    throw RSDInputFieldError.invalidFormatter(formatter, context)
                } else {
                    return obj
                }
            } else if answerType.baseType == .boolean {
                return NSNumber(value: (string as NSString).boolValue)
            } else if answerType.baseType == .integer {
                return NSNumber(value: (string as NSString).integerValue)
            } else if answerType.baseType == .decimal {
                return NSNumber(value: (string as NSString).doubleValue)
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "String Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let date = answer as? Date {
            if answerType.baseType == .date {
                return date
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Date Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let num = (answer as? NSNumber) ?? (answer as? JsonNumber)?.jsonNumber()  {
            switch answerType.baseType  {
            case .boolean:
                return num.boolValue
            case .integer, .decimal:
                return num
            default:
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Number Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        } else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "\(answer) is not supported for \(inputField.identifier)")
            throw RSDInputFieldError.invalidType(context)
        }
    }
}
