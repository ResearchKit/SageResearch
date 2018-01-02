//
//  RSDPickerDataSourceObject.swift
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

/// Extension of the `RSDMultipleComponentInputField` protocol to implement the `RSDChoicePickerDataSource` protocol.
extension RSDMultipleComponentOptions {
    
    /// Returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return self.choices.count
    }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    public func numberOfRows(in component: Int) -> Int {
        guard component < self.choices.count else { return 0 }
        return self.choices[component].count
    }
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < self.choices.count, row < self.choices[component].count else { return nil }
        return self.choices[component][row]
    }
}

extension RSDMultipleComponentInputField {
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        let choices = selectedRows.enumerated().rsd_mapAndFilter { (component, selectedRow) -> Any? in
            return self.choice(forRow: selectedRow, forComponent: component)?.value
        }
        guard choices.count == self.numberOfComponents
            else {
                return nil
        }
        return choices
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard selectedAnswer != nil else { return nil }
        let answers:[Any] = (selectedAnswer! as? [Any]) ?? [selectedAnswer!]
        guard answers.count == self.numberOfComponents else { return nil }
        
        // Filter through and look for the current answer
        let selected: [Int] = answers.enumerated().rsd_mapAndFilter { (component, value) -> Int? in
            return choices[component].index(where: { RSDObjectEquality($0.value, value) })
        }
        
        return selected.count == self.numberOfComponents ? selected : nil
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let array = selectedRows(from: selectedAnswer) else { return nil }
        let strings = array.enumerated().rsd_mapAndFilter { choice(forRow: $0.element, forComponent: $0.offset)?.text }
        let separator = self.separator ?? " "
        return strings.joined(separator: separator)
    }
}

/// Extension of the `RSDChoiceOptions` protocol to implement the `RSDChoicePickerDataSource` protocol.
extension RSDChoiceOptions {
    
    /// Returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return 1
    }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    public func numberOfRows(in component: Int) -> Int {
        return self.choices.count
    }
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < 1, row < self.choices.count else { return nil }
        return self.choices[row]
    }
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        guard selectedRows.count == 1, let row = selectedRows.first else { return nil }
        return self.choice(forRow: row, forComponent: 0)?.value
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard let index = self.choices.index(where: { RSDObjectEquality($0.value, selectedAnswer) }) else { return nil }
        return [index]
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let array = selectedRows(from: selectedAnswer), let row = array.first else { return nil }
        return choices[row].text
    }
}

/// A simple struct that can be used to implement the `RSDChoiceOptions` protocol.
public struct RSDChoiceOptionsObject : RSDChoiceOptions {
    
    /// A list of choices for the input field.
    public let choices: [RSDChoice]
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    public let isOptional: Bool
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(choices: [RSDChoice], isOptional: Bool) {
        self.choices = choices
        self.isOptional = isOptional
    }
}

/// A simple struct that can be used to implement the `RSDNumberPickerDataSource` protocol.
public struct RSDNumberPickerDataSourceObject : RSDNumberPickerDataSource {
    
    /// Returns the minimum number allowed.
    public let minimum: Decimal
    
    /// Returns the maximum number allowed.
    public let maximum: Decimal

    /// Returns the step interval to use. If `nil`, then the step interval will default to advance by 1.
    public let stepInterval: Decimal?

    /// Returns the number formatter to use to format the displayed value and to parse the result.
    public let numberFormatter: NumberFormatter
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(minimum: Decimal, maximum: Decimal, stepInterval: Decimal?, numberFormatter: NumberFormatter) {
        self.minimum = minimum
        self.maximum = maximum
        self.stepInterval = stepInterval
        self.numberFormatter = numberFormatter
    }
}

extension RSDNumberPickerDataSource {
    
    /// Returns the decimal number answer for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func numberAnswer(from selectedAnswer: Any?) -> Decimal? {
        // Check that the answer is a number in range
        let number: Decimal
        if let decimal = selectedAnswer as? Decimal {
            number = decimal
        } else if let num = (selectedAnswer as? NSNumber) ?? (selectedAnswer as? RSDJSONNumber)?.jsonNumber() {
            number = Decimal(num.doubleValue)
        } else {
            return nil
        }
        guard number <= maximum, number >= minimum else {
            return nil
        }
        return number
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let number = numberAnswer(from: selectedAnswer) else { return nil }
        return numberFormatter.string(from: number as NSNumber)
    }
}

/// `RSDImperialMeasurementPickerDataSource` is a generic protocol for converting imperial (multiple component)
/// units from and to imperial units.
public protocol RSDImperialMeasurementPickerDataSource : RSDMultipleComponentOptions {
    associatedtype UnitType : Dimension
    
    // The imperial unit converter.
    var converter: RSDUnitConverter.ImperialConverter<UnitType> { get }
    
    // The bounds of the larger unit. This is the range of numbers (integers) to display for the
    // the picker.  For example, a heigh measurement is from 1 ft to 8 ft, so the bounds would be (1, 8).
    var largeUnitBounds: (lower: Int, upper: Int) { get }
}

extension RSDImperialMeasurementPickerDataSource {
    
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
            let tuple = converter.toImperialValue(from: selectedAnswer!)
            else {
                return nil
        }
        return [Int(tuple.largeValue) - largeUnitBounds.lower, Int(tuple.smallValue)]
    }
}

/// `RSDUSHeightPickerDataSource` is a custom height picker for use when the `Locale` is `US_en`.
public struct RSDUSHeightPickerDataSource : RSDImperialMeasurementPickerDataSource {
    
    // The imperial unit converter.
    public let converter: RSDUnitConverter.ImperialConverter<UnitLength>
    
    /// The separator is hardcoded to a space.
    public let separator: String? = " "
    
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

/// `RSDUSInfantMassPickerDataSource` is a custom weight picker for use when the `Locale` is `US_en`
/// and the mass is for an infant in "lb, oz".
public struct RSDUSInfantMassPickerDataSource : RSDImperialMeasurementPickerDataSource {
    
    // The imperial unit converter.
    public let converter: RSDUnitConverter.ImperialConverter<UnitMass>
    
    /// The separator is equal to ", ".
    public let separator: String? = ", "
    
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

/// A simple struct that can be used to implement the `RSDDatePickerDataSource` protocol.
public struct RSDDatePickerDataSourceObject : RSDDatePickerDataSource {
    
    /// The type of UI picker to display for dates and times.
    public let datePickerMode: RSDDatePickerMode

    /// Specify the minimum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    public let minimumDate: Date?

    /// Specify the maximum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    public let maximumDate: Date?

    /// The minute interval to display in a picker wheel or list of choices. The interval must be evenly divided into 60.
    /// For example, `5` is valid but `7` is not. Default is `1`, minimum is `1`, maximum is `30`.
    public let minuteInterval: Int?

    /// The date formatter for displaying the date in a text field or label.
    public let dateFormatter: DateFormatter
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(datePickerMode: RSDDatePickerMode, minimumDate: Date?, maximumDate: Date?, minuteInterval: Int?, dateFormatter: DateFormatter) {
        self.datePickerMode = datePickerMode
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.minuteInterval = minuteInterval
        self.dateFormatter = dateFormatter
    }
}

extension RSDDatePickerDataSource {
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let date = selectedAnswer as? Date else { return nil }
        return dateFormatter.string(from: date)
    }
}

extension NSCalendar.Unit {
    
    /// Convenience initializer for converting from a `Calendar.Component` set to an `NSCalendar.Unit`
    public init(calendarComponents: Set<Calendar.Component>) {
        self = calendarComponents.reduce(NSCalendar.Unit(rawValue: 0), { (input, component) -> NSCalendar.Unit in
            switch component {
            case .era:
                return input.union(.era)
            case .year:
                return input.union(.year)
            case .month:
                return input.union(.month)
            case .day:
                return input.union(.day)
            case .hour:
                return input.union(.hour)
            case .minute:
                return input.union(.minute)
            case .second:
                return input.union(.second)
            case .nanosecond:
                return input.union(.nanosecond)
            case .weekday:
                return input.union(.weekday)
            case .weekdayOrdinal:
                return input.union(.weekdayOrdinal)
            case .quarter:
                return input.union(.quarter)
            case .weekOfMonth:
                return input.union(.weekOfMonth)
            case .weekOfYear:
                return input.union(.weekOfYear)
            case .yearForWeekOfYear:
                return input.union(.yearForWeekOfYear)
            case .timeZone:
                return input.union(.timeZone)
            case .calendar:
                return input.union(.calendar)
            }
        })
    }
}

/// Extension of `RSDDateRange` for setting up calendar components and a data source.
extension RSDDateRange {
    
    /// The calendar components to include for this date range.
    public var calendarComponents: Set<Calendar.Component> {
        guard let components = dateCoder?.calendarComponents else {
            return [.year, .month, .day, .hour, .minute]
        }
        return components
    }
    
    /// Get the picker data source and formatter for this date range.
    /// - returns: Tuple for the picker data source and formatter.
    public func dataSource() -> (RSDPickerDataSource?, Formatter)  {
        let dateComponents : Set<Calendar.Component> = [.year, .month, .day]
        let timeComponents : Set<Calendar.Component> = [.hour, .minute]
        let dateAndTimeComponents = dateComponents.union(timeComponents)
        let components = calendarComponents
        
        if components == dateAndTimeComponents {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .dateAndTime, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter)
            return (pickerSource, formatter)
        }
        else if components == dateComponents {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .date, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter)
            return (pickerSource, formatter)
        }
        else if components == timeComponents {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .time, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter)
            return (pickerSource, formatter)
        }
        else {
            let formatter = DateComponentsFormatter()
            formatter.calendar = Locale.current.calendar
            formatter.allowedUnits = NSCalendar.Unit(calendarComponents: components)
            return (nil, formatter)
        }
    }
}
