//
//  RSDRange.swift
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

/// `RSDRange` defines range constraints that are appropriate for a given data type.
public protocol RSDRange {
}

/// `RSDRangeWithFormatter` is an optional extention of the range that can be used to extend the range
/// to include a formatter.
public protocol RSDRangeWithFormatter : RSDRange {
    
    /// A formatter that is appropriate to the data type. If `nil`, the format will be determined by the UI.
    var formatter: Formatter? { get }
}

/// `RSDDateRange` defines the range values appropriate for a `date` data type.
public protocol RSDDateRange : RSDRange {
    
    /// The minimum allowed date. When the value of this property is `nil`, then the `allowPast` property
    /// is used to optionally set the minimum date to now.
    var minDate: Date? { get }
    
    /// The maximum allowed date. When the value of this property is `nil`, then the `allowFuture`
    /// property is used to optionally set the maximum date to now.
    var maxDate: Date? { get }
    
    /// Whether or not the UI should allow future dates. If `nil` or `minDate` is defined then this value
    /// is ignored. Default is `true`.
    var allowFuture: Bool? { get }
    
    /// Whether or not the UI should allow past dates. If `nil` or `maxDate` is defined then this value
    /// is ignored. Default is `true`.
    var allowPast: Bool? { get }
    
    /// The minute interval to allow for a time picker. A time picker will default to 1 minute if this
    /// is `nil` or if the number is outside the allowable range of 1 to 30 minutes.
    var minuteInterval: Int? { get }
    
    /// Calendar components that are relevant for this input field.
    var calendarComponents: Set<Calendar.Component> { get }
    
    /// The date encoder to use for formatting the result. If `nil` then the result, `minDate`, and
    /// `maxDate` are assumed to be used for time and date with the default coding implementation.
    var dateCoder: RSDDateCoder? { get }
}

extension RSDDateRange {
    
    /// The minimum allowed date. This is calculated by using either the `minDate` (if non-nil) or today's
    /// date if `allowPast` is non-nil and `false`.
    public var minimumDate: Date? {
        return minDate ?? ((allowPast ?? true) ? nil : Date())
    }
    
    /// The maximum allowed date. This is calculated by using either the `maxDate` (if non-nil) or today's
    /// date if `allowFuture` is non-nil and `false`.
    public var maximumDate: Date? {
        return maxDate ?? ((allowFuture ?? true) ? nil : Date())
    }
}

/// `RSDNumberRange` extends the properties of an `RSDFieldInput` for a `decimal` or `integer` data type.
public protocol RSDNumberRange : RSDRange {
    
    /// The minimum allowed number. When the value of this property is `nil`, there is no minimum.
    var minimumValue: Decimal? { get }
    
    /// The maximum allowed number. When the value of this property is `nil`, there is no maximum.
    var maximumValue: Decimal? { get }
    
    /// A step interval to be used for a slider or picker.
    var stepInterval: Decimal? { get }
    
    /// A unit label associated with this property.
    var unit: String? { get }
}
