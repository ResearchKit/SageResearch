//
//  RSDTableItem.swift
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

/// `RSDTableItem` can be used to represent the type of the row to display.
open class RSDTableItem {
    
    /// The index of this item relative to all rows in the section in which this item resides.
    public let rowIndex: Int
    
    /// Initialize a new RSDTableItem.
    /// - parameter rowIndex: The index of this item relative to all rows in the section in which this item resides.
    public init(rowIndex: Int) {
        self.rowIndex = rowIndex
    }
}

/// `RSDTextTableItem` is used to represent a item row that has static text.
public final class RSDTextTableItem : RSDTableItem {
    
    /// The text to display.
    public let text: String
    
    /// Initialize a new `RSDTextTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - text:          The text to display.
    public init(rowIndex: Int, text: String) {
        self.text = text
        super.init(rowIndex: rowIndex)
    }
}

/// `RSDImageTableItem` is used to represent a item row that has a static image.
public final class RSDImageTableItem : RSDTableItem {
    
    /// The image to display.
    public let imageTheme: RSDImageThemeElement
    
    /// Initialize a new `RSDImageTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - imageTheme:    The image to display.
    public init(rowIndex: Int, imageTheme: RSDImageThemeElement) {
        self.imageTheme = imageTheme
        super.init(rowIndex: rowIndex)
    }
}

/// `RSDInputFieldTableItem` is an abstract base class implementation for representing an answer, or part of an
/// answer for a given `RSDInputField`.
open class RSDInputFieldTableItem : RSDTableItem {
    
    /// The RSDInputField representing this tableItem.
    public let inputField: RSDInputField
    
    /// The UI hint for displaying the component of the item group.
    public let uiHint: RSDFormUIHint
    
    /// The answer associated with this table item component. Base class returns `nil`.
    open var answer: Any? {
        return nil
    }
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:    The RSDInputField representing this tableItem.
    ///     - uiHint: The UI hint for this row of the table.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        self.inputField = inputField
        self.uiHint = uiHint
        super.init(rowIndex: rowIndex)
    }
}

/// `RSDChoiceTableItem` is used to represent a single row in a table where the user picks from a list of choices.
open class RSDChoiceTableItem : RSDInputFieldTableItem {
    
    /// The choice for a single or multiple choice input field.
    open private(set) var choice: RSDChoice
    
    /// The answer associated with this choice
    open override var answer: Any? {
        return selected ? choice.value : nil
    }
    
    /// Whether or not the choice is currently selected.
    public var selected: Bool = false
    
    /// Initialize a new RSDChoiceTableItem.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:    The RSDInputField representing this tableItem.
    ///     - uiHint:        The UI hint for this row of the table.
    ///     - choice:        The choice for a single or multiple choice input field.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, choice: RSDChoice) {
        self.choice = choice
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: uiHint)
    }
}

/// `RSDTextInputTableItem` is used to represent a single row in a table that holds a text entry input field.
/// Typically, this would be used to represent a single `RSDInputField` value, but it can also be used to represent a
/// single component in a multiple-component field.
open class RSDTextInputTableItem : RSDInputFieldTableItem {
    
    /// The text field options for this input.
    open private(set) var textFieldOptions: RSDTextFieldOptions?
    
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
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, answerType: RSDAnswerResultType = .string, textFieldOptions: RSDTextFieldOptions? = nil, formatter: Formatter? = nil, pickerSource: RSDPickerDataSource? = nil) {
        self.answerType = answerType
        self.formatter = formatter
        self.pickerSource = pickerSource
        
        // Set the text field options
        self.textFieldOptions = textFieldOptions ?? inputField.textFieldOptions ?? {
            switch answerType.baseType {
            case .decimal:
                return RSDTextFieldOptionsObject(keyboardType: .decimalPad)
            case .integer, .timeInterval:
                return RSDTextFieldOptionsObject(keyboardType: .numberPad)
            case .date, .string:
                return RSDTextFieldOptionsObject(keyboardType: .default)
            case .boolean, .data:
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
        return (answer as? String) ?? formatter?.string(for: answer)
    }
    
    /// Set the new answer value. This will throw an error if the value isn't valid. Otherwise, it will
    /// set the answer.
    /// - parameter newValue: The new value for the answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    public final func setAnswer(_ newValue: Any?) throws {
        _answer = try validatedAnswer(newValue)
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
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.lessThanMinimumDate(minDate, context)
                    }
                    if let maxDate = range.maximumDate, date > maxDate {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.greaterThanMaximumDate(maxDate, context)
                    }
                }
                
            case .string:
                if let string = answer as? String {
                    if let validator = self.textFieldOptions?.textValidator, let isValid = try? validator.isValid(string), !isValid {
                        let debugDescription = self.textFieldOptions?.invalidMessage ?? "Invalid regex"
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: debugDescription)
                        throw RSDInputFieldError.invalidRegex(self.textFieldOptions?.invalidMessage, context)
                    }
                    else if let maxLen = self.textFieldOptions?.maximumLength, maxLen > 0, string.count > maxLen {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Exceeds max length of \(maxLen)")
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
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Array Type \(answer) is not supported for \(inputField.identifier)")
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
                    let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: (err as String!))
                    throw RSDInputFieldError.invalidFormatter(formatter, context)
                } else {
                    return obj
                }
            } else if answerType.baseType == .boolean {
                return NSNumber(value: (string as NSString).boolValue)
            } else if answerType.baseType == .integer {
                return NSNumber(value: (string as NSString).integerValue)
            } else if answerType.baseType == .decimal || answerType.baseType == .timeInterval {
                return NSNumber(value: (string as NSString).doubleValue)
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "String Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let date = answer as? Date {
            if answerType.baseType == .date {
                return date
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Date Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let num = (answer as? NSNumber) ?? (answer as? RSDJSONNumber)?.jsonNumber()  {
            switch answerType.baseType  {
            case .boolean:
                return num.boolValue
            case .integer, .decimal, .timeInterval:
                return num
            default:
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Number Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        } else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "\(answer) is not supported for \(inputField.identifier)")
            throw RSDInputFieldError.invalidType(context)
        }
    }
}

/// An table item for entering a number value.
final class RSDNumberInputTableItem : RSDTextInputTableItem {
    
    private var numberRange: RSDNumberRange?
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:    The RSDInputField representing this tableItem.
    ///     - uiHint: The UI hint for this row of the table.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var pickerSource: RSDPickerDataSource? = inputField as? RSDPickerDataSource
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var range: RSDNumberRange? = (inputField.range as? RSDNumberRange)
        
        if inputField.dataType.baseType == .year, let dateRange = inputField.range as? RSDDateRange {
            let calendar = Calendar(identifier: .gregorian)
            let min: Int? = (dateRange.minimumDate != nil) ? calendar.component(.year, from: dateRange.minimumDate!) : nil
            let max: Int? = (dateRange.maximumDate != nil) ? calendar.component(.year, from: dateRange.maximumDate!) : nil
            if min != nil || max != nil {
                range = RSDNumberRangeObject(minimumInt: min, maximumInt: max)
            }
        }
        
        let baseType: RSDAnswerResultType.BaseType = (inputField.dataType.baseType == .decimal) ? .decimal : .integer
        let digits = (baseType == .decimal) ? 3 : 0
        let numberFormatter = (formatter as? NumberFormatter) ?? NumberFormatter.defaultNumberFormatter(with: digits)
        if inputField.dataType.baseType == .year {
            numberFormatter.groupingSeparator = ""
        }
        formatter = formatter ?? numberFormatter
        
        if pickerSource == nil, let range = range, let min = range.minimumValue, let max = range.maximumValue {
            pickerSource = RSDNumberPickerDataSourceObject(minimum: min, maximum: max, stepInterval: range.stepInterval, numberFormatter: numberFormatter)
        }
        
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: nil, dateFormat: nil, unit: range?.unit, sequenceSeparator: nil)
        
        self.numberRange = range
        
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, textFieldOptions: nil, formatter: formatter, pickerSource: pickerSource)
    }
    
    /// Convert the input answer into a validated answer of a supported type, or throw an error if it fails validation.
    /// - parameter newValue: The new value for the answer.
    /// - returns: The converted answer.
    override func validatedAnswer(_ newValue: Any?) throws -> Any? {
        guard let answer = try super.validatedAnswer(newValue) else {
            return nil
        }
        
        // Look for a range on the new value if it was converted from a text field
        if let _ = newValue as? String {
            switch answerType.baseType {
            case .integer, .decimal, .timeInterval:
                if let number = (answer as? NSNumber) ?? (answer as? RSDJSONNumber)?.jsonNumber(), let range = numberRange {
                    let decimal = number.decimalValue
                    if let min = range.minimumValue, decimal < min {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.lessThanMinimumValue(min, context)
                    }
                    if let max = range.maximumValue, decimal > max {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.greaterThanMaximumValue(max, context)
                    }
                }
                
            default:
                break
            }
        }
        
        return answer
    }
}
