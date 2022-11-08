//
//  RSDDatePickerDataSourceObject.swift
//  Research
//

import Foundation

/// A simple struct that can be used to implement the `RSDDatePickerDataSource` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
    
    /// The date that should be set initially.
    public let defaultDate: Date?
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(datePickerMode: RSDDatePickerMode, minimumDate: Date?, maximumDate: Date?, minuteInterval: Int?, dateFormatter: DateFormatter, defaultDate: Date?) {
        self.datePickerMode = datePickerMode
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.minuteInterval = minuteInterval
        self.dateFormatter = dateFormatter
        self.defaultDate = defaultDate
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDDatePickerDataSource {
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let date = selectedAnswer as? Date else { return nil }
        return dateFormatter.string(from: date)
    }
}


/// Extension of `RSDDateRange` for setting up calendar components and a data source.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .dateAndTime, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter, defaultDate: self.defaultDate)
            return (pickerSource, formatter)
        }
        else if components == dateComponents {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .date, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter, defaultDate: self.defaultDate)
            return (pickerSource, formatter)
        }
        else if components == timeComponents {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            let pickerSource = RSDDatePickerDataSourceObject(datePickerMode: .time, minimumDate: self.minimumDate, maximumDate: self.maximumDate, minuteInterval: self.minuteInterval, dateFormatter: formatter, defaultDate: self.defaultDate)
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
