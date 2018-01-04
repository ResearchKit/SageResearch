//
//  RSDMeasurementInputTableItem.swift
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

/// A custom implementation for inputing a person's height that can set up a picker for
/// setting the height of an adult. Typically, US participants will report an adult height
/// using ft and in, whereas a child or infant will be reported in inches. The placeholder
/// text for child or infant measurement range will be either "inches" or "centimeters",
/// depending upon the user's locale.
final class RSDHeightInputTableItem : RSDTextInputTableItem {
    
    /// The base unit is the unit of mass that the measurement should be converted to in order
    /// to save the result. Because the `Measurement` class has a generic `UnitType`, it cannot
    /// be easily converted to a `Codable` object so the results are stored as `.decimal` base
    /// type with the unit symbol also stored on the result.
    public let baseUnit: UnitLength
    
    /// Default initializer.
    /// - parameters:
    ///     - rowIndex:         The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:       The RSDInputField representing this tableItem.
    ///     - uiHint:           The UI hint for this row of the table.
    ///     - measurementSize:  The measurement range for the input field.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, measurementSize: RSDFormDataType.MeasurementRange) {
        
        // initial unit
        var unit = (inputField.range as? RSDNumberRange)?.unit
        
        // Setup the formatter.
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var placeholderText: String?
        if (formatter == nil) {
            let lengthFormatter = RSDLengthFormatter(forChildUse: (measurementSize != .adult), unitSymbol: unit)
            formatter = lengthFormatter
        }
        
        let lengthUnit: UnitLength
        if let lengthFormatter = formatter as? RSDLengthFormatter {
            // When converting from the value entered by the participant, then the
            // locale is used to determine the preferred units.
            lengthFormatter.unitStyle = .long
            if Locale.current.usesMetricSystem {
                placeholderText = lengthFormatter.unitString(fromValue: 250, unit: .centimeter)
            } else {
                placeholderText = lengthFormatter.unitString(fromValue: 60, unit: .inch)
            }
            lengthFormatter.unitStyle = .short
            
            lengthUnit = lengthFormatter.toStringUnit
        }
        else {
            lengthUnit = ((unit != nil) ? UnitLength(fromSymbol: unit!) : nil) ?? .centimeters
        }
        
        self.baseUnit = lengthUnit
        unit = lengthUnit.symbol
        
        // If the measurement size is for an adult and the locale is US
        // then use a picker with feet/inches.
        var pickerSource: RSDPickerDataSource? = (inputField as? RSDPickerDataSource)
        if pickerSource == nil, measurementSize == .adult, !Locale.current.usesMetricSystem {
            pickerSource = RSDUSHeightPickerDataSourceObject(formatter: formatter as? RSDLengthFormatter)
        }
        
        // Switch the hint type to a supported type.
        var hint: RSDFormUIHint = uiHint
        if uiHint != .popover {
            hint = (pickerSource == nil) ? .textfield : .picker
        }
        
        let answerType = RSDAnswerResultType(baseType: .decimal, sequenceType: nil, dateFormat: nil, unit: unit, sequenceSeparator: nil)
        
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: hint, answerType: answerType, textFieldOptions: nil, formatter: formatter, pickerSource: pickerSource, placeholderText: placeholderText)
    }
    
    /// Override the `convertAnswer()` function to convert the `Measurement` returned
    /// by the formatter into a decimal value in the `baseUnit`.
    override func convertAnswer(_ newValue: Any) throws -> Any? {
        let answer = try super.convertAnswer(newValue)
        guard let measurement = answer as? Measurement<UnitLength> else { return answer }
        return measurement.converted(to: baseUnit).value
    }
}


/// A custom implementation for inputing a person's mass (weight) that can set up a picker for
/// setting the weight of an infant. Typically, US participants know what their newborn baby's
/// weight is in lb and oz. Additionally, the placeholder text for an adult or child measurement
/// range will be either "pounds" or "kilograms", depending upon the participant's locale.
final class RSDMassInputTableItem : RSDTextInputTableItem {
    
    /// The base unit is the unit of mass that the measurement should be converted to in order
    /// to save the result. Because the `Measurement` class has a generic `UnitType`, it cannot
    /// be easily converted to a `Codable` object so the results are stored as `.decimal` base
    /// type with the unit symbol also stored on the result.
    public let baseUnit: UnitMass
    
    /// Default initializer.
    /// - parameters:
    ///     - rowIndex:         The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:       The RSDInputField representing this tableItem.
    ///     - uiHint:           The UI hint for this row of the table.
    ///     - measurementSize:  The measurement range for the input field.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, measurementSize: RSDFormDataType.MeasurementRange) {
        
        // initial unit
        var unit = (inputField.range as? RSDNumberRange)?.unit
        
        // Setup the formatter.
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var placeholderText: String?
        if (formatter == nil) {
            let massFormatter = RSDMassFormatter(forInfantUse: (measurementSize == .infant), unitSymbol: unit)
            formatter = massFormatter
        }
        
        let massUnit: UnitMass
        if let massFormatter = formatter as? RSDMassFormatter {
            // When converting from the value entered by the participant, then the
            // locale is used to determine the preferred units.
            massFormatter.unitStyle = .long
            if Locale.current.usesMetricSystem {
                placeholderText = massFormatter.unitString(fromValue: 60, unit: .kilogram)
            } else {
                placeholderText = massFormatter.unitString(fromValue: 140, unit: .pound)
            }
            massFormatter.unitStyle = .medium
            
            massUnit = massFormatter.toStringUnit
        }
        else {
            massUnit = ((unit != nil) ? UnitMass(fromSymbol: unit!) : nil) ?? .kilograms
        }
        
        self.baseUnit = massUnit
        unit = massUnit.symbol
        
        // If the measurement is for an infant and the locale is US
        // then use the infant mass picker.
        var pickerSource: RSDPickerDataSource? = (inputField as? RSDPickerDataSource)
        if pickerSource == nil, measurementSize == .infant, !Locale.current.usesMetricSystem {
            pickerSource = RSDUSInfantMassPickerDataSourceObject(formatter: formatter as? RSDMassFormatter)
        }
        
        // Switch the hint type to a supported type most appropriate to the units.
        var hint: RSDFormUIHint = uiHint
        if uiHint != .popover {
            hint = (pickerSource == nil) ? .textfield : .picker
        }
        
        let answerType = RSDAnswerResultType(baseType: .decimal, sequenceType: nil, dateFormat: nil, unit: unit, sequenceSeparator: nil)
        
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: hint, answerType: answerType, textFieldOptions: nil, formatter: formatter, pickerSource: pickerSource, placeholderText: placeholderText)
    }
    
    /// Override the `convertAnswer()` function to convert the `Measurement` returned
    /// by the formatter into a decimal value in the `baseUnit`.
    override func convertAnswer(_ newValue: Any) throws -> Any? {
        let answer = try super.convertAnswer(newValue)
        guard let measurement = answer as? Measurement<UnitMass> else { return answer }
        return measurement.converted(to: baseUnit).value
    }
}
