//
//  RSDSchedule.swift
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

public protocol RSDScheduleTime {
    
    /// The time of the day as a string with the format "HH:mm:ss" or "HH:mm".
    var timeOfDayString: String? { get }
    
    /// The original time zone for the time of day.
    var timeZone: TimeZone { get }
}

/// The `RSDSchedule` protocol can be used to describe a local notification schedule. This provides a
/// shared interface for getting and setting the time of day and for setting up notifications.
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
