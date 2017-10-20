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
import UIKit

public protocol RSDPickerDataSource {
}

public enum RSDDatePickerMode : String {
    case time // Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
    
    case date // Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
    
    case dateAndTime // Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
}

public protocol RSDDatePickerDataSource : RSDPickerDataSource {
    
    var datePickerMode: RSDDatePickerMode { get }
    
    // specify min/max date range. default is nil. When min > max, the values are ignored.
    var minimumDate: Date? { get }
    var maximumDate: Date? { get }
    
    // display minutes wheel with interval. interval must be evenly divided into 60. default is 1. min is 1, max is 30
    var minuteInterval: Int? { get }
    
    // The date formatter for displaying the date in a text field
    var dateFormatter: DateFormatter { get }
}

public protocol RSDDateComponentPickerDataSource : RSDPickerDataSource {
    
    var calendar: Calendar { get }
    var calendarComponents: Set<Calendar.Component> { get }
    
    // Specify min/max year range if the year is included, otherwise these values are ignored.
    var minimumYear: Int? { get }
    var maximumYear: Int? { get }
    
    var dateComponentsFormatter: DateComponentsFormatter { get }
}

public protocol RSDChoicePickerDataSource : RSDPickerDataSource {
    
    // returns the number of 'columns' to display.
    var numberOfComponents: Int { get }
    
    // returns the # of rows in each component
    func numberOfRows(in component: Int) -> Int
    
    // returns the choice for this row/component. If this is returns `nil` then this is the "optional" choice.
    func choice(forRow row: Int, forComponent component: Int) -> RSDChoice?
    
    // returns the selected answer for a given row and componet
    func selectedAnswer(for selection: [Int : Int]) -> Any
}

public protocol RSDDecimalPickerDataSource : RSDPickerDataSource {
    
    // Returns the minimum number allowed.
    var minimum: Decimal { get }
    
    // Returns the maximum number allowed.
    var maximum: Decimal { get }
    
    // Returns the step interval to use. If `nil`, then the step interval will default to advance by 1.
    var stepInterval: Decimal? { get }
    
    // Returns the number formatter to use to format the displayed value and to parse the result.
    var numberFormatter: NumberFormatter { get }
}
