//
//  RSDPickerDataSource.swift
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


/// `RSDPickerDataSource` includes information that can be used to build a picker UI element.
public protocol RSDPickerDataSource {
}

/// `RSDDatePickerMode` describes the type of UI picker to display for dates and times.
/// - seealso: `RSDDatePickerDataSource`
public enum RSDDatePickerMode : String {
    
    /// Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
    case time
    
    /// Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
    case date
    
    /// Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting
    /// (e.g. Wed Nov 15 | 6 | 53 | PM)
    case dateAndTime
}

/// A data source for selecting a date.
public protocol RSDDatePickerDataSource : RSDPickerDataSource {
    
    /// The type of UI picker to display for dates and times.
    var datePickerMode: RSDDatePickerMode { get }
    
    /// Specify the minimum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    var minimumDate: Date? { get }
    
    /// Specify the maximum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    var maximumDate: Date? { get }
    
    /// The minute interval to display in a picker wheel or list of choices. The interval must be evenly divided into 60.
    /// For example, `5` is valid but `7` is not. Default is `1`, minimum is `1`, maximum is `30`.
    var minuteInterval: Int? { get }
    
    /// The date formatter for displaying the date in a text field or label
    var dateFormatter: DateFormatter { get }
}

/// A picker data source for selecting date components.
public protocol RSDDateComponentPickerDataSource : RSDPickerDataSource {
    
    /// The calendar to use for the date components.
    var calendar: Calendar { get }
    
    /// The components to include in the picker.
    var calendarComponents: Set<Calendar.Component> { get }
    
    /// The minimum year if the year is included, otherwise this value is ignored.
    var minimumYear: Int? { get }
    
    /// The maximum year if the year is included, otherwise this value is ignored.
    var maximumYear: Int? { get }
    
    /// The date components formatter for displaying the date components in a text field or label.
    var dateComponentsFormatter: DateComponentsFormatter { get }
}

/// A picker data source for selecting choices.
public protocol RSDChoicePickerDataSource : RSDPickerDataSource {
    
    /// Returns the number of 'columns' to display.
    var numberOfComponents: Int { get }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    func numberOfRows(in component: Int) -> Int
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    func choice(forRow row: Int, forComponent component: Int) -> RSDChoice?
}

/// A picker data source for picking a number.
public protocol RSDNumberPickerDataSource : RSDPickerDataSource {
    
    /// Returns the minimum number allowed.
    var minimum: Decimal { get }
    
    /// Returns the maximum number allowed.
    var maximum: Decimal { get }
    
    /// Returns the step interval to use. If `nil`, then the step interval will default to advance by 1.
    var stepInterval: Decimal? { get }
    
    /// Returns the number formatter to use to format the displayed value and to parse the result.
    var numberFormatter: NumberFormatter { get }
}
