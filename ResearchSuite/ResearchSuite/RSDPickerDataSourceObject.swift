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
extension RSDMultipleComponentInputField {
    
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
}

extension RSDChoicePickerDataSource {
    
    /// Returns the selected answer for the given selected rows of a picker view.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        let choices = selectedRows.enumerated().rsd_mapAndFilter { (component, selectedRow) -> Any? in
            return self.choice(forRow: selectedRow, forComponent: component)?.value
        }
        return choices.count == self.numberOfComponents ? (choices.count == 1 ? choices.first : choices) : nil
    }
    
    /// Returns the selected rows that match the given selected answer.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard selectedAnswer != nil else { return nil }
        let answers:[Any] = (selectedAnswer! as? [Any]) ?? [selectedAnswer!]
        guard answers.count == self.numberOfComponents else { return nil }
        
        // Filter through and look for the current answer
        var selected: [Int] = []
        for (component, value) in answers.enumerated() {
            let numRows = self.numberOfRows(in: component)
            var found: Bool = false
            for row in 0..<numRows {
                if let choice = self.choice(forRow: row, forComponent: component),
                    RSDObjectEquality(choice.value, value) {
                    selected.append(row)
                    found = true
                }
            }
            // Exit early with nil if a selected row is not found
            if !found { return nil }
        }
        
        return selected
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

/// A concrete implementation of `RSDChoicePickerDataSource` for a measurement.
/// TODO: Implement syoung 11/28/2017
public struct RSDMeasurementPickerDataSourceObject : RSDChoicePickerDataSource {
    public let dataType: RSDFormDataType
    public let unit: String?
    public let formatter: Formatter?
    
    // Returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        fatalError("Not yet implemented")
    }
    
    // Returns the # of rows in each component.
    public func numberOfRows(in component: Int) -> Int {
        fatalError("Not yet implemented")
    }
    
    // Returns the choice for this row/component.
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        fatalError("Not yet implemented")
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

/// A simple struct that can be used to implement the `RSDDateComponentPickerDataSource` protocol.
public struct RSDDateComponentPickerDataSourceObject : RSDDateComponentPickerDataSource {
    /// The calendar to use for the date components.
    public let calendar: Calendar

    /// The components to include in the picker.
    public let calendarComponents: Set<Calendar.Component>

    /// The minimum year if the year is included, otherwise this value is ignored.
    public let minimumYear: Int?

    /// The maximum year if the year is included, otherwise this value is ignored.
    public let maximumYear: Int?

    /// The date components formatter for displaying the date components in a text field or label.
    public let dateComponentsFormatter: DateComponentsFormatter
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(calendar: Calendar, calendarComponents: Set<Calendar.Component>, minimumYear: Int?, maximumYear: Int?, dateComponentsFormatter: DateComponentsFormatter) {
        self.calendar = calendar
        self.calendarComponents = calendarComponents
        self.minimumYear = minimumYear
        self.maximumYear = maximumYear
        self.dateComponentsFormatter = dateComponentsFormatter
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
    public func dataSource() -> (RSDPickerDataSource, Formatter)  {
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
            let calendar = Calendar(identifier: .gregorian)
            let minYear: Int? = (self.minimumDate == nil) ? nil : calendar.component(.year, from: self.minimumDate!)
            let maxYear: Int? = (self.maximumDate == nil) ? nil : calendar.component(.year, from: self.maximumDate!)
            let formatter = DateComponentsFormatter()
            formatter.calendar = calendar
            formatter.allowedUnits = NSCalendar.Unit(calendarComponents: components)
            let pickerSource = RSDDateComponentPickerDataSourceObject(calendar: calendar, calendarComponents: components, minimumYear: minYear, maximumYear: maxYear, dateComponentsFormatter: formatter)
            return (pickerSource, formatter)
        }
    }
}
