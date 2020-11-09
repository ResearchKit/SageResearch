//
//  RSDNumberInputTableItem.swift
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
import Formatters

/// An table item for entering a number value.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
public final class RSDNumberInputTableItem : RSDTextInputTableItem {
    
    fileprivate var numberRange: RSDNumberRange?
    fileprivate var unit: Unit?
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex:     The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:   The RSDInputField representing this tableItem.
    ///     - uiHint:       The UI hint for this row of the table.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var formatter: Formatter?
        var pickerSource: RSDPickerDataSource? = inputField.pickerSource
        var range: RSDNumberRange? = (inputField.range as? RSDNumberRange)
        var unitString: String? = range?.unit
        var textFieldOptions: RSDTextFieldOptions? = nil
        
        // special-case the .year and .duration data types to set up range and picker
        if inputField.dataType.baseType == .year, let dateRange = inputField.range as? RSDDateRange {
            let calendar = Calendar(identifier: .iso8601)
            let min: Int? = (dateRange.minimumDate != nil) ? calendar.component(.year, from: dateRange.minimumDate!) : nil
            let max: Int? = (dateRange.maximumDate != nil) ? calendar.component(.year, from: dateRange.maximumDate!) : nil
            if min != nil || max != nil {
                range = RSDNumberRangeObject(minimumInt: min, maximumInt: max)
            }
        } else if inputField.dataType.baseType == .duration, (range == nil) {
            let durationRange = (inputField.range as? RSDDurationRange) ?? RSDDurationRangeObject()
            let baseUnit = durationRange.baseUnit
            unitString = baseUnit.symbol
            self.unit = baseUnit
            if pickerSource == nil {
                pickerSource = RSDDurationPickerDataSourceObject(range: durationRange)
            }
            formatter = (durationRange as? RSDRangeWithFormatter)?.formatter ??
                UnitDuration.defaultFormatter(for: durationRange.durationUnits, baseUnit: baseUnit)
            range = RSDNumberRangeObject(minimumDouble: durationRange.minimumDuration.valueConverted(to: baseUnit),
                                         maximumDouble: durationRange.maximumDuration?.valueConverted(to: baseUnit))
            
            // Set the text field options
            textFieldOptions = inputField.textFieldOptions ?? RSDTextFieldOptionsObject(keyboardType: .default)
        }
        
        // get the answer type
        let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: nil, formDataType: inputField.dataType, dateFormat: nil, unit: unitString)
        
        // set up the formatter
        let numberFormatter: (RSDNumberFormatterProtocol & Formatter)
        if inputField.dataType.baseType == .fraction {
            // If this is a fraction type then always default to the fraction formatter
            // as the number protocol formatter, and use the range number formatter as the
            // fraction formatter's number formatter.
            let fractionFormatter = RSDFractionFormatter()
            if let rangeFormatter = (inputField.range as? RSDRangeWithFormatter)?.formatter as? NumberFormatter {
                fractionFormatter.numberFormatter = rangeFormatter
            }
            numberFormatter = fractionFormatter
        } else {
            // Otherwise, set the number formatter based on whether or not the range formatter is a number formatter.
            let digits = (baseType == .decimal) ? 3 : 0
            formatter = formatter ?? (inputField.range as? RSDRangeWithFormatter)?.formatter
            numberFormatter = (formatter as? (RSDNumberFormatterProtocol & Formatter)) ?? NumberFormatter.defaultNumberFormatter(with: digits)
            if inputField.dataType.baseType == .year {
                (numberFormatter as? NumberFormatter)?.groupingSeparator = ""
            }
        }
        formatter = formatter ?? numberFormatter
        self.numberRange = range
        
        // set up the picker source
        if pickerSource == nil, let range = range, let min = range.minimumValue, let max = range.maximumValue {
            pickerSource = RSDNumberPickerDataSourceObject(minimum: min, maximum: max, stepInterval: range.stepInterval, numberFormatter: numberFormatter)
        }

        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, textFieldOptions: textFieldOptions, formatter: formatter, pickerSource: pickerSource)
    }
    
    /// Override to check if the returned value is a Measurement and return the double value if it is.
    override public func convertAnswer(_ newValue: Any) throws -> Any? {
        let answer = try super.convertAnswer(newValue)
        guard let measurement = answer as? Measurement else { return answer }
        if let baseUnit = self.unit as? UnitDuration, let dm = answer as? Measurement<UnitDuration> {
            return dm.valueConverted(to: baseUnit)
        }
        return measurement.value
    }
    
    /// Override to check the range of the value
    override public func validatedAnswer(_ newValue: Any?) throws -> Any? {
        guard let answer = try super.validatedAnswer(newValue) else {
            return nil
        }
    
        if let number = (answer as? NSNumber) ?? (answer as? JsonNumber)?.jsonNumber(), let range = numberRange {
            let decimal = number.decimalValue
            if let min = range.minimumValue, decimal < min {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Value entered is outside allowed range.")
                throw RSDInputFieldError.lessThanMinimumValue(min, context)
            }
            if let max = range.maximumValue, decimal > max {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, debugDescription: "Value entered is outside allowed range.")
                throw RSDInputFieldError.greaterThanMaximumValue(max, context)
            }
        }
        
        return answer
    }
}

