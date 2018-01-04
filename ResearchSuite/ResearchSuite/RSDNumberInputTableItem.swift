//
//  RSDNumberInputTableItem.swift
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

/// An table item for entering a number value.
final class RSDNumberInputTableItem : RSDTextInputTableItem {
    
    private var numberRange: RSDNumberRange?
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex:     The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:   The RSDInputField representing this tableItem.
    ///     - uiHint:       The UI hint for this row of the table.
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

