//
//  RSDDurationPickerDataSourceObject.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

/// `RSDDurationPickerDataSourceObject` is a concrete implementation of a `RSDMultipleComponentChoiceOptions`
/// that can be used to select a duration using duration units for each component of the duration.
public struct RSDDurationPickerDataSourceObject : RSDMultipleComponentPickerDataSource {
    
    /// A list of choices for the input field.
    public var choices: [[RSDChoice]] {
        return componentChoices
    }
    
    /// The unit that the answer should use to represent the selection.
    let baseUnit: UnitDuration
    
    /// The mapping of the unit representing each column in the picker.
    let componentUnits: [UnitDuration]
    
    /// The arrays of Int objects for each column of the duration represented by
    /// by this picker.
    let componentChoices: [[RSDChoiceObject<Int>]]
    
    /// The formatter for displaying the duration.
    let formatter: DateComponentsFormatter
    
    /// The separator is not used with the height picker.
    public let separator: String?
    
    /// The default answer associated with this option set.
    public let defaultAnswer: Any?
    
    /// Default initializer.
    /// - parameter range: The duration range to use to instantiate this picker source.
    public init?(range: RSDDurationRange) {
        guard let maxUnit = range.durationUnits.max(),
            let minUnit = range.durationUnits.min()
            else {
                return nil
        }

        let componentUnits = range.durationUnits.sorted(by: >)
        self.componentChoices = componentUnits.map { (unit) -> [RSDChoiceObject<Int>] in
            
            let indexBy = (unit == minUnit) ? (range.stepInterval ?? 1) : 1
            let maxValue: Int = {
                if (unit == maxUnit) {
                    return range.maximumDuration?.component(of: unit) ?? unit.maxTimeValue()
                } else {
                    return unit.maxTimeValue() - indexBy
                }
            }()
            
            let range = Array(stride(from: 0, to: maxValue + indexBy, by: indexBy))
            return range.map { try! RSDChoiceObject<Int>(value: $0, text: String(format: "%02d", $0)) }
        }
        
        let dateComponentsFormatter = range.dateComponentsFormatter()
        
        self.componentUnits = componentUnits
        self.formatter = dateComponentsFormatter
        self.baseUnit = range.baseUnit
        self.separator = (dateComponentsFormatter.unitsStyle == .positional) ? ":" : nil
        self.defaultAnswer = range.minimumDuration.value
    }
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        let value: Double = selectedRows.enumerated().reduce(0) { (input, arg) -> Double in
            let (component, index) = arg
            let unit = self.componentUnits[component]
            let choiceValue = self.componentChoices[component][index].answerValue as! Int
            let measurement = Measurement(value: Double(choiceValue), unit: unit)
            return input + measurement.valueConverted(to: baseUnit)
        }
        return value
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard let duration = duration(for: selectedAnswer) else { return nil }
        return componentUnits.enumerated().map { (idx, unit) -> Int in
            let value = duration.component(of: unit)
            return self.componentChoices[idx].firstIndex(where: { ($0.answerValue as! Int) == value }) ?? 0
        }
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let duration = duration(for: selectedAnswer) else { return nil }
        return formatter.string(from: duration.timeInterval)
    }
    
    /// The duration measurement (if any) for the given answer.
    /// - parameter answer: The object to convert to a duration measurement.
    /// - returns: The duration measurement (if any).
    public func duration(for answer: Any?) -> Measurement<UnitDuration>? {
        if let duration = answer as? Measurement<UnitDuration> {
            return duration
        }
        else if let num = (answer as? JsonNumber)?.jsonNumber() {
            return Measurement<UnitDuration>(value: num.doubleValue, unit: baseUnit)
        }
        else {
            return nil
        }
    }
}

extension RSDDurationRange {
    
    /// Convenience method for getting the base unit associated with this range.
    public var baseUnit: UnitDuration {
        return self.minimumDuration.unit
    }
    
    /// Convenience method for getting the date components formatter for this range.
    public func dateComponentsFormatter() -> DateComponentsFormatter {
        return ((self as? RSDRangeWithFormatter)?.formatter as? DateComponentsFormatter) ?? UnitDuration.defaultFormatter(for: self.durationUnits, baseUnit: self.baseUnit)
    }
}
