//
//  RSDSchedule.swift
//  Research
//

import Foundation

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDScheduleTime {
    
    /// The time of the day as a string with the format "HH:mm:ss" or "HH:mm".
    var timeOfDayString: String? { get }
    
    /// The original time zone for the time of day.
    var timeZone: TimeZone { get }
}

/// The `RSDSchedule` protocol can be used to describe a local notification schedule. This provides a
/// shared interface for getting and setting the time of day and for setting up notifications.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDSchedule : RSDScheduleTime {
    
    /// The time of the day as a string with the format "HH:mm".
    var timeOfDayString: String? { get set }
    
    /// Get an array of the date components to use to set up notification triggers. This will return a
    /// `DateComponents` for each notification trigger that would be added to set notifications.
    ///
    /// - note: The date components will *not* include the participant's current timezone.
    /// - returns: The date components to use to set up a trigger for each scheduling instance.
    func notificationTriggers() -> [DateComponents]
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDScheduleTime {
    
    /// The time of the day for the schedule. This method will return a `Date` object on the same day as the
    /// the input time but with the time set to the time described by the `timeOfDayString`. If the time of
    /// day string is `nil` then this will also return nil.
    ///
    /// - parameter date: The date for which to set the time.
    public func timeOfDay(on date:Date) -> Date? {
        guard let timeComponents = self.timeComponents else { return nil }
        var calendar = Calendar.iso8601
        calendar.timeZone = self.timeZone
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components)
    }
    
    /// The time components using the ISO8601 calendar.
    public var timeComponents: DateComponents? {
        guard let todString = timeOfDayString,
            let tod = RSDDateCoderObject.hourAndMinutesOnly.inputFormatter.date(from: todString) ??
                RSDDateCoderObject.timeOfDay.inputFormatter.date(from: todString)
            else {
                return nil
        }
        return Calendar.iso8601.dateComponents([.hour, .minute], from: tod)
    }
    
    /// Return the localized time text string using the given style.
    public func localizedTime(with timeStyle: DateFormatter.Style = .short) -> String? {
        guard let time = self.timeOfDay(on: Date()) else { return nil }
        return DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: timeStyle)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDSchedule {

    /// Set the time by converting from Any.
    mutating public func setTime(from value: Any?) {
        if let dateValue = value as? Date {
            self.setTimeOfDay(from: dateValue)
        } else if let dateComponents = value as? DateComponents {
            self.setTimeComponents(from: dateComponents)
        } else {
            self.timeOfDayString = value as? String
        }
    }
    
    mutating func setTimeOfDay(from date: Date?) {
        guard let tod = date else {
            self.timeOfDayString = nil
            return
        }
        self.timeOfDayString = RSDDateCoderObject.hourAndMinutesOnly.inputFormatter.string(from: tod)
    }
    
    mutating func setTimeComponents(from dateComponents: DateComponents?) {
        guard let tod = dateComponents, let hour = tod.hour, let minute = tod.minute else {
            self.timeOfDayString = nil
            return
        }
        self.timeOfDayString = String(format: "%02d:%02d", hour, minute)
    }
}
