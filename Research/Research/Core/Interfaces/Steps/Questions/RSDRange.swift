//
//  RSDRange.swift
//  Research
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

/// `RSDRangeWithFormatter` is an optional extension of the range that can be used to extend the range
/// to include a formatter appropriate to the UI. For example, this could be used to describe a number
/// range that displays currency.
public protocol RSDRangeWithFormatter : RSDRange {
    
    /// A formatter that is appropriate to the data type. If `nil`, the format will be determined by the UI.
    /// This is the formatter used to display a previously entered answer to the user or to convert an answer
    /// entered in a text field into the appropriate value type.
    ///
    /// - seealso: `RSDAnswerResultType.BaseType` and `RSDFormStepDataSource`
    var formatter: Formatter? { get set }
}

/// `RSDDateRange` defines the range of values appropriate for a `date` data type.
public protocol RSDDateRange : RSDRange {
    
    /// The minimum allowed date. When the value of this property is `nil`, then the `allowPast`
    /// property is checked for `nil`, otherwise `allowPast` is ignored.
    var minDate: Date? { get }
    
    /// The maximum allowed date. When the value of this property is `nil`, then the `allowFuture`
    /// property is checked for `nil`, otherwise `allowFuture` is ignored.
    var maxDate: Date? { get }
    
    /// Whether or not the UI should allow future dates. If `nil` or if `minDate` is defined then this value
    /// is ignored. Default is `true`.
    var shouldAllowFuture: Bool? { get }
    
    /// Whether or not the UI should allow past dates. If `nil` or if `maxDate` is defined then this value
    /// is ignored. Default is `true`.
    var shouldAllowPast: Bool? { get }
    
    /// The minute interval to allow for a time picker. A time picker will default to 1 minute if this
    /// is `nil` or if the number is outside the allowable range of 1 to 30 minutes.
    var minuteInterval: Int? { get }
    
    /// The date encoder to use for formatting the result. If `nil` then the result, `minDate`, and
    /// `maxDate` are assumed to be used for time and date with the default coding implementation.
    var dateCoder: RSDDateCoder? { get }
    
    /// The date that should be set initially.
    var defaultDate: Date? { get }
}

extension RSDDateRange {
    
    /// The minimum allowed date. This is calculated by using either the `minDate` (if non-nil) or today's
    /// date if `allowPast` is non-nil and `false`. If both `minDate` and `allowPast` are `nil` then this
    /// property will return `nil`.
    public var minimumDate: Date? {
        return minDate ?? ((shouldAllowPast ?? true) ? nil : Date())
    }
    
    /// The maximum allowed date. This is calculated by using either the `maxDate` (if non-nil) or today's
    /// date if `allowFuture` is non-nil and `false`. If both `maxDate` and `allowFuture` are `nil` then this
    /// property will return `nil`.
    public var maximumDate: Date? {
        return maxDate ?? ((shouldAllowFuture ?? true) ? nil : Date())
    }
}

/// `RSDNumberRange` extends the properties of an `RSDInputField` for a `decimal` or `integer` data type.
public protocol RSDNumberRange : RSDRange {
    
    /// The minimum allowed number. When the value of this property is `nil`, there is no minimum.
    var minimumValue: Decimal? { get }
    
    /// The maximum allowed number. When the value of this property is `nil`, there is no maximum.
    var maximumValue: Decimal? { get }
    
    /// A step interval to be used for a slider or picker.
    var stepInterval: Decimal? { get }
    
    /// A unit label associated with this property. The unit should *not* be localized. Instead, this
    /// value is used to determine the unit for measurements converted to the unit expected by the researcher.
    ///
    /// For example, if a measurement of distance is displayed and/or returned by the user in feet, but the
    /// researcher expects the returned value in meters then the unit here would be "m" and the formatter
    /// would be a `LengthFormatter` that uses the current locale with a `unitStyle` of `.long`.
    var unit: String? { get }
}

public protocol RSDDurationRange : RSDRange {
    
    /// The minimum allowed duration. The minimum duration should use the `UnitDuration` of the
    /// base unit that is used to represent the answer.
    /// - seealso: `RSDAnswerResultType.unit`
    var minimumDuration: Measurement<UnitDuration> { get }
    
    /// The maximum allowed duration. When the value of this property is `nil`, there is no maximum.
    var maximumDuration: Measurement<UnitDuration>? { get }
    
    /// A step interval to be used for a slider or picker in the smallest units represented.
    var stepInterval: Int? { get }
    
    /// The duration units that should be included in the formatter and picker used for setting up a
    /// `.duration` data type.
    var durationUnits: Set<UnitDuration> { get }
}

public protocol RSDPostalCodeRange : RSDRange {
    
    /// A list of the supported regions for this question. This should include all the regions that
    /// are supported by this survey question. The question is expected to be phrased in a way that
    /// is generic to the regions that are supported. For example, use "postal code" rather than
    /// zipcode if including a region outside of "US".
    var supportedRegions: [String] { get }
    
    /// A list of known sparsely populated postal codes for a given region. If nil, it is assumed
    /// that there are no sparsely populated postal codes for the given country.
    func sparselyPopulatedCodes(for region: String) -> [String]?
    
    /// The number of characters to include in the answer. All characters beyond this are expected
    /// to be blanked out. The exception to this is the sparselyPopulatedCodes, where the entire
    /// string is *not* saved.
    func savedCharacterCount(for region: String) -> Int
    
    /// A maximum character count allowed for a given region. For example, a zipcode is 5 characters
    /// long whereas a Canadian postal code is 6 characters. If nil, no maximum is assumed.
    func maxCharacterCount(for region: String) -> Int?
}
