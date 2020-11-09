//
//  RSDUSMeasurementPickerDataSource.swift
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
import Formatters

/// `RSDUSMeasurementPickerDataSource` is a generic protocol for converting US Customary
/// units (multiple component) to metric units.
public protocol RSDUSMeasurementPickerDataSource : RSDMultipleComponentPickerDataSource {
    associatedtype UnitType : Dimension
    
    // The US Customary unit converter.
    var converter: RSDUnitConverter.USCustomaryUnitConverter<UnitType> { get }
    
    // The bounds of the larger unit. This is the range of numbers (integers) to display for the
    // the picker.  For example, a height measurement is from 1 ft to 8 ft, so the bounds would be (1, 8).
    var largeUnitBounds: (lower: Int, upper: Int) { get }
}

extension RSDUSMeasurementPickerDataSource {
    
    /// US measurement pickers do not have a default answer.
    public var defaultAnswer: Any? {
        return nil
    }
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        guard selectedRows.count == choices.count else { return nil }
        // Generic measurements cannot be cast to a Codable object. Therefore, do not use the
        // measurement from the converter directly. Instead, this must be returned as the Double value.
        let measurement = converter.measurement(fromLargeValue: Double(selectedRows[0] + largeUnitBounds.lower),
                                                smallValue: Double(selectedRows[1]))
        return measurement.value
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard selectedAnswer != nil,
            let tuple = converter.toTupleValue(from: selectedAnswer!)
            else {
                return nil
        }
        return [Int(tuple.largeValue) - largeUnitBounds.lower, Int(tuple.smallValue)]
    }
}


/// `RSDUSHeightPickerDataSourceObject` is a custom height picker for use when the `Locale`
/// uses US Customary units (not metric system).
public struct RSDUSHeightPickerDataSourceObject : RSDUSMeasurementPickerDataSource {
    
    /// The separator is not used with the height picker.
    public let separator: String? = nil
    
    // The US Customary unit converter.
    public let converter: RSDUnitConverter.USCustomaryUnitConverter<UnitLength>
    
    /// The unit bounds for the source.
    public let largeUnitBounds: (lower: Int, upper: Int) = (1, 8)
    
    /// The formatter to use for converting the value inches and feet.
    public let formatter: RSDLengthFormatter
    
    /// The choices are hardcoded for a range from 1' to 8' 11".
    public let choices: [[RSDChoice]] = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        let feet = Array(1...8)
        let inches = Array(0...11)
        return [ feet.map { try! RSDChoiceObject(value: $0, text: formatter.string(fromValue: Double($0), unit: .foot))},
                 inches.map { try! RSDChoiceObject(value: $0, text: formatter.string(fromValue: Double($0), unit: .inch))} ]
    }()
    
    /// Default initializer.
    /// - parameter formatter: The length formatter to use for converting to and from text.
    public init(formatter: RSDLengthFormatter? = nil) {
        let formatter = formatter ?? RSDLengthFormatter(forChildUse: false)
        var converter = RSDUnitConverter.feetAndInches
        converter.baseUnit = formatter.toStringUnit
        self.converter = converter
        self.formatter = formatter
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        return formatter.string(for:selectedAnswer)
    }
}

extension RSDLengthFormatter {
    
    /// Convenience initializer for initializing a length formatter for the appropriate
    /// range of human measurement.
    public convenience init(forChildUse: Bool, unitSymbol: String? = nil) {
        self.init()
        
        self.isForPersonHeightUse = true
        self.isForChildHeightUse = forChildUse
        self.toStringUnit = UnitLength(fromSymbol: unitSymbol ?? "cm") ?? .centimeters
        self.unitStyle = .short
        
        // When converting from the value entered by the participant, then the
        // locale is used to determine the preferred units.
        if Locale.current.usesMetricSystem {
            self.fromStringUnit = .centimeters
        } else {
            self.fromStringUnit = .inches
            if !forChildUse {
                self.numberFormatter.maximumFractionDigits = 0
            }
        }
    }
}


/// `RSDUSInfantMassPickerDataSource` is a custom weight picker for use when the `Locale`
/// uses US Customary units (not metric system) and the mass is for an infant in "lb, oz".
public struct RSDUSInfantMassPickerDataSourceObject : RSDUSMeasurementPickerDataSource {
    
    /// The separator is not used with the mass picker.
    public let separator: String? = nil
    
    // The US Customary unit converter.
    public let converter: RSDUnitConverter.USCustomaryUnitConverter<UnitMass>
    
    /// The unit bounds for the source.
    public let largeUnitBounds: (lower: Int, upper: Int) = (1, 20)
    
    /// The formatter to use for converting the value inches and feet.
    public let formatter: RSDMassFormatter
    
    /// The mass choices are hard coded from 1 lb to 20 lb, 15 oz.
    public let choices : [[RSDChoice]] = {
        let formatter = MassFormatter()
        formatter.unitStyle = .medium
        let pounds = Array(1...20)
        let ounces = Array(0...15)
        return [ pounds.map { try! RSDChoiceObject(value: $0, text: formatter.string(fromValue: Double($0), unit: .pound))},
                 ounces.map { try! RSDChoiceObject(value: $0, text: formatter.string(fromValue: Double($0), unit: .ounce))} ]
    }()
    
    /// Default initializer.
    /// - parameter formatter: The mass formatter to use for converting to and from text.
    public init(formatter: RSDMassFormatter? = nil) {
        let formatter = formatter ?? RSDMassFormatter(forInfantUse: true)
        var converter = RSDUnitConverter.poundAndOunces
        converter.baseUnit = formatter.toStringUnit
        self.converter = converter
        self.formatter = formatter
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        return formatter.string(for:selectedAnswer)
    }
}

extension RSDMassFormatter {
    
    /// Convenience initializer for initializing a mass formatter for the appropriate
    /// range of human measurement.
    public convenience init(forInfantUse: Bool, unitSymbol: String? = nil) {
        self.init()
        
        self.isForPersonMassUse = true
        self.isForInfantMassUse = forInfantUse
        self.toStringUnit = UnitMass(fromSymbol: unitSymbol ?? "kg") ?? .kilograms
        self.unitStyle = .medium
        
        // When converting from the value entered by the participant, then the
        // locale is used to determine the preferred units.
        if Locale.current.usesMetricSystem {
            self.fromStringUnit = .kilograms
        } else {
            self.fromStringUnit = .pounds
            if forInfantUse {
                self.numberFormatter.maximumFractionDigits = 0
            }
        }
    }
}
