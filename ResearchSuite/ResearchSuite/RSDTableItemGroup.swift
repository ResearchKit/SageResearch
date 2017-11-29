//
//  RSDTableItemGroup.swift
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

/// `RSDTableItemGroup` is a generic table item group object that can be used to display information in a tableview
/// that does not have an associated input field.
open class RSDTableItemGroup {
    
    /// The list of items (or rows) included in this group. A table group can be used to represent one or more rows.
    public let items: [RSDTableItem]
    
    /// The row index for the first row in the group.
    public let beginningRowIndex: Int
    
    /// A unique identifier that can be used to track the group.
    public let uuid = UUID()
    
    /// Determine if the current answer is valid. Also checks the case where answer is required but one has not
    /// been provided.
    public var isAnswerValid: Bool {
        return true
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - items: The list of items (or rows) included in this group.
    ///     - beginningRowIndex: The row index for the first row in the group.
    public init(items: [RSDTableItem], beginningRowIndex: Int) {
        self.items = items
        self.beginningRowIndex = beginningRowIndex
    }
}

/// `RSDInputFieldTableItemGroup` is used to represent a single input field.
open class RSDInputFieldTableItemGroup : RSDTableItemGroup {
    
    /// The input field associated with this item group.
    public let inputField: RSDInputField
    
    /// The UI hint for displaying the item group.
    public let uiHint: RSDFormUIHint
    
    /// The answer type for the input field result.
    public let answerType: RSDAnswerResultType
    
    /// The default answer for the input field result.
    public let defaultAnswer: Any
    
    /// The text field options for this input.
    public let textFieldOptions: RSDTextFieldOptions?
    
    /// The formatter used for dislaying answers and converting text to a number or date.
    open private(set) var formatter: Formatter?
    
    /// The picker data source for selecting answers.
    open private(set) var pickerSource: RSDPickerDataSource?
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    ///     - answerType: The answer type.
    ///     - defaultAnswer: The default answer.
    ///     - textFieldOptions: The text field options.
    ///     - items: The table items included in this item group.
    ///     - formatter: The formatter used for dislaying answers and converting text to a number or date.
    ///     - pickerSource: The picker data source for selecting answers.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, answerType: RSDAnswerResultType, defaultAnswer: Any? = nil, textFieldOptions: RSDTextFieldOptions? = nil, items: [RSDTableItem]? = nil, formatter: Formatter? = nil, pickerSource: RSDPickerDataSource? = nil) {
        self.inputField = inputField
        self.uiHint = uiHint
        self.answerType = answerType
        self.pickerSource = pickerSource
        self.formatter = formatter
        self.defaultAnswer = defaultAnswer ?? NSNull()
        
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
        
        super.init(items: items ?? [RSDInputFieldTableItem(rowIndex: beginningRowIndex, inputField: inputField)], beginningRowIndex: beginningRowIndex)
    }
    
    /// Convenience property for accessing the identifier associated with the item group.
    public var identifier: String {
        return inputField.identifier
    }
    
    /// Save an answer for this ItemGroup. This is used only for those questions that have single answers,
    // such as text and numeric answers, as opposed to booleans or text choice answers.
    open var answer: Any {
        return _answer ?? defaultAnswer
    }
    fileprivate var _answer: Any?
    
    /// The text string to display as the answer.
    open var answerText: String? {
        return (_answer as? String) ?? formatter?.string(for: _answer)
    }
    
    /// Set the new answer value. This will throw an error if the value isn't valid. Otherwise, it will
    /// set the answer.
    /// - parameter newValue: The new value for the answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    public final func setAnswer(_ newValue: Any?) throws {
        _answer = try validatedAnswer(newValue)
    }
    
    /// Set the new answer value from a previous result. This will throw an error if the result isn't valid.
    /// Otherwise, it will set the answer.
    /// - parameter result: The result that *may have a previous answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    open func setAnswer(from result: RSDResult) throws {
        guard let answerResult = result as? RSDAnswerResult,
            answerResult.answerType == answerType
            else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Result answer type for \(result) not expected type.")
                throw RSDInputFieldError.invalidType(context)
        }
        try self.setAnswer(answerResult.value)
    }
    
    /// Determine if the current answer is valid. Also checks the case where answer is required but one has
    /// not been provided.
    /// - returns: A Bool indicating if answer is valid
    open override var isAnswerValid: Bool {
        // if answer is NOT optional and it equals Null, then it's invalid
        return inputField.isOptional || !(answer is NSNull)
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

/// `RSDChoicePickerTableItemGroup` subclasses `RSDInputFieldTableItemGroup` to implement a single or multiple choice
/// question where the choices are presented as a list.
open class RSDChoicePickerTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Does the item group allow for multiple choices or is it single selection?
    public let singleSelection: Bool
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    ///     - choicePicker: The choice picker data source.
    ///     - answerType: The answer type.
    ///     - defaultAnswer: The default answer.
    ///     - textFieldOptions: The text field options.
    ///     - formatter: The formatter used for dislaying answers and converting text to a number or date.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, choicePicker: RSDChoicePickerDataSource, answerType: RSDAnswerResultType? = nil,  defaultAnswer: Any? = nil, textFieldOptions: RSDTextFieldOptions? = nil, formatter: Formatter? = nil) {
        
        // Set the items
        var items: [RSDTableItem]?
        var singleSelection: Bool = true
        if inputField.dataType.listSelectionHints.contains(uiHint),
            let choicePicker = choicePicker as? RSDChoiceOptions {
            if case .collection(let collectionType, _) = inputField.dataType, collectionType == .multipleChoice {
                singleSelection = false
            }
            items = choicePicker.choices.enumerated().map { (index, choice) -> RSDTableItem in
                RSDChoiceTableItem(rowIndex: beginningRowIndex + index, inputField: inputField, choice: choice)
            }
        }
        self.singleSelection = singleSelection
        
        // Setup the answer type if nil
        let aType: RSDAnswerResultType = answerType ?? {
            let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
            let sequenceType: RSDAnswerResultType.SequenceType? = singleSelection ? nil : .array
            let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
            let unit: String? = (inputField.range as? RSDNumberRange)?.unit
            return RSDAnswerResultType(baseType: baseType, sequenceType: sequenceType, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: nil)
            }()
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: aType, defaultAnswer: defaultAnswer, textFieldOptions: textFieldOptions, items: items, formatter: formatter, pickerSource: choicePicker)
    }
    
    override open func setAnswer(from result: RSDResult) throws {
        try super.setAnswer(from: result)
        
        // Set all the previously selected items as selected
        guard let selectableItems = self.items as? [RSDChoiceTableItem] else { return }
        for input in selectableItems {
            input.selected = input.choice.isEqualToResult(result)
        }
    }
    
    /// Select or de-select an item (answer) at a specific indexPath. This is used for text choice and boolean answers.
    /// - parameters:
    ///     - selected:   A bool indicating if item should be selected
    ///     - indexPath:  The IndexPath of the item
    open func select(_ item: RSDChoiceTableItem, indexPath: IndexPath) throws {
        guard let selectableItems = self.items as? [RSDChoiceTableItem] else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: nil, answerResult: answerType, debugDescription: "This input field does not support selection.")
            throw RSDInputFieldError.invalidType(context)
        }
        
        // to get index of our item, add our beginningRowIndex to indexPath.row
        let deselectOthers = singleSelection || item.choice.isExclusive
        let index =  indexPath.row - beginningRowIndex
        let selected = !item.selected
        
        // if we selected an item and this is a single-selection group, then we iterate
        // our other items and de-select them
        var answers: [Any] = []
        for (ii, input) in selectableItems.enumerated() {
            if deselectOthers || (ii == index) || input.choice.isExclusive || (input.choice.value == nil) {
                input.selected = (ii == index) && selected
            }
            if input.selected, let value = input.choice.value {
                answers.append(value)
            }
        }
        
        // Set the answer array bypassing validation
        if singleSelection {
            _answer = answers.first
        } else {
            _answer = answers
        }
    }
}

/// An item group for entering text.
final class RSDTextFieldTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: RSDAnswerResultType(baseType: .string))
    }
}

/// An item group for entering a boolean data type.
final class RSDBooleanTableItemGroup : RSDChoicePickerTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        let choicePicker: RSDChoicePickerDataSource
        if let picker = inputField as? RSDChoicePickerDataSource {
            choicePicker = picker
        } else {
            // TODO: syoung 10/20/2017 Implement Boolean formatter
            let choiceYes = try! RSDChoiceObject<Bool>(value: true, text: nil, iconName: nil, detail: nil, isExclusive: true)
            let choiceNo = try! RSDChoiceObject<Bool>(value: false, text: nil, iconName: nil, detail: nil, isExclusive: true)
            choicePicker = RSDChoiceOptionsObject(choices: [choiceYes, choiceNo], isOptional: inputField.isOptional)
        }
        let answerType = RSDAnswerResultType(baseType: .boolean)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, choicePicker: choicePicker, answerType: answerType)
    }
}

/// An item group for entering a date.
final class RSDDateTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var pickerSource: RSDPickerDataSource? = inputField as? RSDPickerDataSource
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var dateFormatter: DateFormatter?
        
        if let dateRange = inputField.range as? RSDDateRange {
            let (src, fmt) = dateRange.dataSource()
            pickerSource = pickerSource ?? src
            formatter = formatter ?? fmt
            dateFormatter = dateRange.dateCoder?.resultFormatter
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            formatter = formatter ?? dateFormatter
            pickerSource = pickerSource ?? RSDDatePickerDataSourceObject(datePickerMode: .dateAndTime, minimumDate: nil, maximumDate: nil, minuteInterval: nil, dateFormatter: dateFormatter)
        }
        
        let answerType = RSDAnswerResultType(baseType: .date, sequenceType: nil, dateFormat: dateFormatter?.dateFormat, unit: nil, sequenceSeparator: nil)
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
    }
}

/// An item group for entering a number value.
final class RSDNumberTableItemGroup : RSDInputFieldTableItemGroup {
    
    var numberRange: RSDNumberRange?
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
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
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
        self.numberRange = range
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

/// An item group for entering data requiring a multiple component format.
final class RSDMultipleComponentTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDMultipleComponentInputField, uiHint: RSDFormUIHint) {
        
        let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
        let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
        let unit: String? = (inputField.range as? RSDNumberRange)?.unit
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: .array, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: inputField.separator)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: nil, pickerSource: inputField)
    }
}

/// An item group for entering data that is a human-measurement in localized units appropriate to the
/// size-range of the human (adult, child, infant).
final class RSDMeasurementTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        let baseType: RSDAnswerResultType.BaseType = .decimal
        var unit: String?
        var sequenceType: RSDAnswerResultType.SequenceType?
        var sequenceSeparator: String?
        
        if case .measurement(let measurementType, _) = inputField.dataType {
            switch measurementType {
            case .height:
                let lengthFormatter = LengthFormatter()
                lengthFormatter.isForPersonHeightUse = true
                formatter = formatter ?? lengthFormatter
                unit = unit ?? "cm"
                
            case .weight:
                let massFormatter = MassFormatter()
                massFormatter.isForPersonMassUse = true
                formatter = formatter ?? massFormatter
                unit = unit ?? "kg"
                
            case .bloodPressure:
                sequenceType = .array
                sequenceSeparator = "/"
            }
        } else {
            fatalError("Cannot instantiate a measurement type item group without a base data type")
        }
        
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: sequenceType, dateFormat: nil, unit: unit, sequenceSeparator: sequenceSeparator)
        let pickerSource: RSDPickerDataSource = (inputField as? RSDPickerDataSource) ?? RSDMeasurementPickerDataSourceObject(dataType: inputField.dataType, unit: unit, formatter: formatter)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
        
    }
}
