//
//  RSDInputFieldTableItemGroup.swift
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

/// `RSDInputFieldTableItemGroup` is used to represent a single input field.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDInputFieldTableItemGroup : RSDTableItemGroup {
    
    /// The input field associated with this item group.
    public let inputField: RSDInputField
    
    /// The UI hint for displaying the component of the item group.
    public let uiHint: RSDFormUIHint
    
    /// The answer type for the input field result.
    public let answerType: RSDAnswerResultType
    
    /// Does this item group require an exclusive section?
    public let requiresExclusiveSection: Bool
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - items: The table items included in this item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    ///     - answerType: The answer type.
    public init(beginningRowIndex: Int, items: [RSDTableItem], inputField: RSDInputField, uiHint: RSDFormUIHint, answerType: RSDAnswerResultType, requiresExclusiveSection: Bool? = nil) {
        self.inputField = inputField
        self.uiHint = uiHint
        self.answerType = answerType
        self.requiresExclusiveSection = requiresExclusiveSection ?? (beginningRowIndex == 0 && items.count > 0)
        super.init(beginningRowIndex: beginningRowIndex, items: items)
    }
    
    /// Convenience initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - tableItem: A single table item that can be used to build an answer.
    public init(beginningRowIndex: Int, tableItem: RSDTextInputTableItem) {
        self.inputField = tableItem.inputField
        self.uiHint = tableItem.uiHint
        self.answerType = tableItem.answerType
        self.requiresExclusiveSection = false
        super.init(beginningRowIndex: beginningRowIndex, items: [tableItem])
    }
    
    /// Convenience property for accessing the identifier associated with the item group.
    public var identifier: String {
        return inputField.identifier
    }
    
    /// The answer for this item group. This is the answer stored to the `RSDAnswerResult`. The default
    /// implementation will return the privately stored answer if set and if not, will look to see if the
    /// first table item is recognized as a table item that stores an answer on it.
    open var answer: Any? {
        return _answer ?? (self.items.first as? RSDTextInputTableItem)?.answer
    }
    private var _answer: Any?
    
    /// Set the new answer value. This will throw an error if the value isn't valid. Otherwise, it will
    /// set the answer.
    /// - parameter newValue: The new value for the answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    open func setAnswer(_ newValue: Any?) throws {
        
        // Only validation at this level is on a single-input field. Otherwise, just set the answer and return
        guard self.items.count == 1, let textItem = self.items.first as? RSDTextInputTableItem
            else {
                _answer = newValue
                return
        }
        
        // If there is a single-input field then set the answer on that field
        try textItem.setAnswer(newValue)
    }
    
    /// Set the answer from a previous run to the given value.
    open func setPreviousAnswer(from jsonValue: Any?) throws {
        // Only validation at this level is on a single-input field. Otherwise, just set the
        // answer and return.
        guard self.items.count == 1, let textItem = self.items.first as? RSDTextInputTableItem
            else {
                _answer = jsonValue
                return
        }
        
        try textItem.setPreviousAnswer(jsonValue)
    }
    
    /// Set the default answer for the item group. The base class implementation does nothing.
    /// - returns: `true` if the answer was updated and `false` if the answer was unchanged.
    open func setDefaultAnswerIfValid() -> Bool {
        // At this level, only the "date" has a default value.
        guard self.items.count == 1,
            let textItem = self.items.first as? RSDTextInputTableItem,
            textItem.answer == nil,
            let defaultDate = (textItem.pickerSource as? RSDDatePickerDataSource)?.defaultDate
            else {
                return false
        }
        
        do {
            try textItem.setAnswer(defaultDate)
            return true
        }
        catch let err {
            debugPrint("Failed to set the default answer: \(err)")
            return false
        }
    }
    
    /// Set the new answer value from a previous result. This will throw an error if the result isn't valid.
    /// Otherwise, it will set the answer.
    /// - parameter result: The result that *may* have a previous answer.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    open func setAnswer(from result: RSDResult) throws {
        guard let answerResult = result as? RSDAnswerResult,
            answerResult.answerType == answerType
            else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Result answer type for \(result) not expected type.")
                throw RSDInputFieldError.invalidType(context)
        }
        try self.setAnswer(answerResult.value)
    }
    
    /// Determine if the current answer is valid. Also checks the case where answer is required but one has
    /// not been provided.
    /// - returns: A `Bool` indicating if answer is valid.
    open override var isAnswerValid: Bool {
        // if answer is NOT optional and it equals Null, then it's invalid
        return self.isOptional || !((self.answer == nil) || (self.answer is NSNull))
    }
    
    /// Whether or not the question is optional.
    open var isOptional: Bool {
        return self.items.reduce(self.inputField.isOptional) {
            $0 && (($1 as? RSDInputFieldTableItem)?.inputField.isOptional ?? true)
        }
    }
}

/// An item group for entering text.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
public final class RSDTextFieldTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        let tableItem = RSDTextInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
        super.init(beginningRowIndex: beginningRowIndex, tableItem: tableItem)
    }
}


/// An item group for entering a date.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
public final class RSDDateTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var pickerSource: RSDPickerDataSource? = inputField.pickerSource
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var dateFormatter: DateFormatter?
        
        if let dateRange = inputField.range as? RSDDateRange {
            let (src, fmt) = dateRange.dataSource()
            pickerSource = pickerSource ?? src
            formatter = formatter ?? fmt
            dateFormatter = dateRange.dateCoder?.resultFormatter
        }
        else {
            let dateFormatter = DateFormatter()
            var datePickerMode: RSDDatePickerMode = .dateAndTime
            
            if case .dateRange(let rangeType) = inputField.dataType {
                switch rangeType {
                case .timestamp:
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    datePickerMode = .dateAndTime
                case .dateOnly:
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    datePickerMode = .date
                case .timeOnly:
                    dateFormatter.dateStyle = .none
                    dateFormatter.timeStyle = .short
                    datePickerMode = .time
                }
            }
            else {
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
            }
            formatter = formatter ?? dateFormatter
            pickerSource = pickerSource ?? RSDDatePickerDataSourceObject(datePickerMode: datePickerMode, minimumDate: nil, maximumDate: nil, minuteInterval: nil, dateFormatter: dateFormatter, defaultDate: nil)
        }
        
        let answerType = RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: inputField.dataType, dateFormat: dateFormatter?.dateFormat, unit: nil, sequenceSeparator: nil)
        let tableItem = RSDTextInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, textFieldOptions: nil, formatter: formatter, pickerSource: pickerSource)
        
        super.init(beginningRowIndex: beginningRowIndex, tableItem: tableItem)
    }
}


/// An item group for entering a number value.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
public final class RSDNumberTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        let tableItem = RSDNumberInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
        super.init(beginningRowIndex: beginningRowIndex, tableItem: tableItem)
    }
}


/// An item group for entering data requiring a multiple component format.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
public final class RSDMultipleComponentTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, pickerSource: RSDMultipleComponentPickerDataSource) {
        
        let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
        let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
        let unit: String? = (inputField.range as? RSDNumberRange)?.unit
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: .array, formDataType: inputField.dataType, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: pickerSource.separator)
        let tableItem = RSDTextInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, textFieldOptions: nil, formatter: nil, pickerSource: pickerSource)
        
        super.init(beginningRowIndex: beginningRowIndex, tableItem: tableItem)
    }
}
