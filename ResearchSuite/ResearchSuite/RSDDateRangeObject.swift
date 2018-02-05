//
//  RSDDateRangeObject.swift
//  ResearchSuite
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

/// `RSDDateRangeObject` is a concrete implementation of a `RSDDateRange` that defines the range of values appropriate
/// for a `date` data type.
public struct RSDDateRangeObject : RSDDateRange, Codable {
    
    /// The minimum allowed date. When the value of this property is `nil`, then the `allowPast`
    /// property is checked for `nil`, otherwise `allowPast` is ignored.
    public let minDate: Date?
    
    /// The maximum allowed date. When the value of this property is `nil`, then the `allowFuture`
    /// property is checked for `nil`, otherwise `allowFuture` is ignored.
    public let maxDate: Date?
    
    /// Whether or not the UI should allow future dates. If `nil` or if `maxDate` is defined then this value
    /// is ignored. Default is `true`.
    public let allowFuture: Bool?
    
    /// Whether or not the UI should allow past dates. If `nil` or if `minDate` is defined then this value
    /// is ignored. Default is `true`.
    public let allowPast: Bool?
    
    /// The minute interval to allow for a time picker. A time picker will default to 1 minute if this
    /// is `nil` or if the number is outside the allowable range of 1 to 30 minutes.
    public let minuteInterval: Int?
    
    /// The date encoder to use for formatting the result. If `nil` then the result, `minDate`, and
    /// `maxDate` are assumed to be used for time and date with the default coding implementation.
    public let dateCoder: RSDDateCoder?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - minimumDate: The minimum allowed date.
    ///     - maximumDate: The maximum allowed date.
    ///     - allowFuture: Whether or not the UI should allow future dates.
    ///     - allowPast: Whether or not the UI should allow past dates.
    ///     - minuteInterval: The minute interval to allow for a time picker.
    ///     - dateCoder: The date encoder to use for formatting the result.
    public init(minimumDate: Date?, maximumDate: Date?, allowFuture: Bool? = nil, allowPast: Bool? = nil, minuteInterval: Int? = nil, dateCoder: RSDDateCoder? = nil) {
        self.minDate = minimumDate
        self.maxDate = maximumDate
        self.allowFuture = allowFuture
        self.allowPast = allowPast
        self.minuteInterval = minuteInterval
        self.dateCoder = dateCoder
    }
    
    private enum CodingKeys : String, CodingKey {
        case minDate = "minimumDate", maxDate = "maximumDate", allowFuture, allowPast, minuteInterval, codingFormat
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///
    /// Example where the minimum and maximum dates are set to specific values.
    /// ```
    ///    {
    ///     "minimumDate" : "2017-02-20",
    ///     "maximumDate" : "2017-03-20",
    ///     "codingFormat" : "yyyy-MM-dd"
    ///    }
    /// ```
    ///
    /// Example where the range does not allow future dates.
    /// ```
    ///     { "allowFuture" : "false" }
    /// ```
    ///
    /// Example where the range does not allow future dates.
    /// ```
    ///     { "allowPast" : "false" }
    /// ```
    ///
    /// Example where the time should include hours and minutes, but the minute interval is set to 15 minutes.
    /// ```
    ///     {
    ///      "minuteInterval" : 15,
    ///      "codingFormat" : "HH:mm"
    ///     }
    /// ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // If there is an encoding format, then the date should be decoded/encoded using a string of that format.
        var minDate: Date?
        var maxDate: Date?
        let dateCoder = try container.decodeIfPresent(RSDDateCoderObject.self, forKey: .codingFormat)
        if dateCoder != nil {
            if let dateStr = try container.decodeIfPresent(String.self, forKey: .minDate) {
                minDate = dateCoder!.date(from: dateStr)
            }
            if let dateStr = try container.decodeIfPresent(String.self, forKey: .maxDate) {
                maxDate = dateCoder!.date(from: dateStr)
            }
        }
        else {
            minDate = try container.decodeIfPresent(Date.self, forKey: .minDate)
            maxDate = try container.decodeIfPresent(Date.self, forKey: .maxDate)
        }
        
        self.dateCoder = dateCoder
        self.minDate = minDate
        self.maxDate = maxDate
        self.allowPast = try container.decodeIfPresent(Bool.self, forKey: .allowPast)
        self.allowFuture = try container.decodeIfPresent(Bool.self, forKey: .allowFuture)
        self.minuteInterval = try container.decodeIfPresent(Int.self, forKey: .minuteInterval)
    }
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let dateCoder = dateCoder {
            let nestedEncoder = container.superEncoder(forKey: .codingFormat)
            try dateCoder.encode(to: nestedEncoder)
            if let date = minDate {
                try container.encode(dateCoder.string(from: date), forKey: .minDate)
            }
            if let date = maxDate {
                try container.encode(dateCoder.string(from: date), forKey: .maxDate)
            }
        }
        else {
            try container.encodeIfPresent(minDate, forKey: .minDate)
            try container.encodeIfPresent(maxDate, forKey: .maxDate)
        }
        try container.encodeIfPresent(allowPast, forKey: .allowPast)
        try container.encodeIfPresent(allowFuture, forKey: .allowFuture)
        try container.encodeIfPresent(minuteInterval, forKey: .minuteInterval)
    }
}

extension RSDDateRangeObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.minDate, .maxDate, .allowFuture, .allowPast, .minuteInterval, .codingFormat]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .minDate:
                if idx != 0 { return false }
            case .maxDate:
                if idx != 1 { return false }
            case .allowFuture:
                if idx != 2 { return false }
            case .allowPast:
                if idx != 3 { return false }
            case .minuteInterval:
                if idx != 4 { return false }
            case .codingFormat:
                if idx != 5 { return false }
            }
        }
        return keys.count == 6
    }
    
    static func dateRangeExamples() -> [RSDDateRangeObject] {
        let minDate = rsd_ISO8601TimestampFormatter.date(from: "2017-10-16T00:00:00.000-07:00")!
        let maxDate = rsd_ISO8601TimestampFormatter.date(from: "2017-10-17T00:00:00.000-07:00")!
        let exampleA = RSDDateRangeObject(minimumDate: minDate, maximumDate: maxDate, allowFuture: nil, allowPast: false, minuteInterval: nil, dateCoder: RSDDateCoderObject(rawValue: "yyyy-MM-dd"))
        let exampleB = RSDDateRangeObject(minimumDate: nil, maximumDate: nil, allowFuture: nil, allowPast: false, minuteInterval: nil, dateCoder: nil)
        let exampleC = RSDDateRangeObject(minimumDate: nil, maximumDate: nil, allowFuture: false, allowPast: nil, minuteInterval: nil, dateCoder: nil)
        let exampleD = RSDDateRangeObject(minimumDate: nil, maximumDate: nil, allowFuture: nil, allowPast: nil, minuteInterval: 15, dateCoder: RSDDateCoderObject(rawValue: "HH:mm"))
        return [exampleA, exampleB, exampleC, exampleD]
    }
    
    static func examples() -> [Encodable] {
        return dateRangeExamples()
    }
}
