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


extension RSDMultipleComponentInputField {
    
    // returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return self.choices.count
    }
    
    // returns the # of rows in each component
    public func numberOfRows(in component: Int) -> Int {
        guard component < self.choices.count else { return 0 }
        return self.choices[component].count
    }
    
    // returns the choice for this row/component
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < self.choices.count, row < self.choices[component].count else { return nil }
        return self.choices[component][row]
    }
    
    // returns the selected choices
    public func selectedAnswer(for selection: [Int : Int]) -> Any {
        var selectedChoices: [Any] = []
        for ii in 0..<Int(self.choices.count) {
            guard let row = selection[ii], row < self.choices[ii].count
                else {
                    return NSNull()
            }
            selectedChoices.append(self.choices[ii][row].value)
        }
        return selectedChoices
    }
}

extension RSDChoiceOptions {
    
    // returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return 1
    }
    
    // returns the # of rows in each component
    public func numberOfRows(in component: Int) -> Int {
        return self.choices.count
    }
    
    // returns the choice for this row/component
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < 1, row < self.choices.count else { return nil }
        return self.choices[row]
    }
    
    // returns the selected choice
    public func selectedAnswer(for selection: [Int : Int]) -> Any {
        guard let row = selection[0], let choice = self.choice(forRow: row, forComponent: 0) else { return NSNull() }
        return choice.value
    }
    
    public var hasImages: Bool {
        for choice in choices {
            if choice.hasIcon {
                return true
            }
        }
        return false
    }
}

public struct RSDChoiceOptionsObject : RSDChoiceOptions {
    public let choices: [RSDChoice]
    public let isOptional: Bool
}

public struct RSDDecimalPickerDataSourceObject : RSDDecimalPickerDataSource {
    public let minimum: Decimal
    public let maximum: Decimal
    public let stepInterval: Decimal?
    public let numberFormatter: NumberFormatter
}

public struct RSDMeasurementPickerDataSourceObject : RSDChoicePickerDataSource {
    public let dataType: RSDFormDataType
    public let unit: String?
    public let formatter: Formatter?
    
    // returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        fatalError("Not yet implemented")
    }
    
    // returns the # of rows in each component
    public func numberOfRows(in component: Int) -> Int {
        fatalError("Not yet implemented")
    }
    
    // returns the choice for this row/component
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        fatalError("Not yet implemented")
    }
    
    // returns the selected choice
    public func selectedAnswer(for selection: [Int : Int]) -> Any {
        fatalError("Not yet implemented")
    }
}

public struct RSDDatePickerDataSourceObject : RSDDatePickerDataSource {
    public let datePickerMode: RSDDatePickerMode
    public let minimumDate: Date?
    public let maximumDate: Date?
    public let minuteInterval: Int?
    public let dateFormatter: DateFormatter
}

public struct RSDDateComponentPickerDataSourceObject : RSDDateComponentPickerDataSource {
    public let calendar: Calendar
    public let calendarComponents: Set<Calendar.Component>
    public let minimumYear: Int?
    public let maximumYear: Int?
    public let dateComponentsFormatter: DateComponentsFormatter
}

extension NSCalendar.Unit {
    
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

extension RSDDateRange {
    
    public var calendarComponents: Set<Calendar.Component> {
        guard let components = dateCoder?.calendarComponents else {
            return [.year, .month, .day, .hour, .minute]
        }
        return components
    }
    
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


