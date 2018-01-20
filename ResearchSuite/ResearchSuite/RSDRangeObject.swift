//
//  RSDRangeObject.swift
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

/// `RSDDateRangeObject` is a concrete implementation of a `RSDDateRange` that defines the range of values appropriate
/// for a `date` data type.
public struct RSDDateRangeObject : RSDDateRange, Codable {
    
    /// The minimum allowed date. When the value of this property is `nil`, then the `allowPast`
    /// property is checked for `nil`, otherwise `allowPast` is ignored.
    public let minDate: Date?
    
    /// The maximum allowed date. When the value of this property is `nil`, then the `allowFuture`
    /// property is checked for `nil`, otherwise `allowFuture` is ignored.
    public let maxDate: Date?
    
    /// Whether or not the UI should allow future dates. If `nil` or if `minDate` is defined then this value
    /// is ignored. Default is `true`.
    public let allowFuture: Bool?
    
    /// Whether or not the UI should allow past dates. If `nil` or if `maxDate` is defined then this value
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

/// `RSDNumberRangeObject` extends the properties of an `RSDInputField` for a `decimal` or `integer` data type.
public struct RSDNumberRangeObject : RSDNumberRange, Codable {
    
    /// The minimum allowed number. When the value of this property is `nil`, there is no minimum.
    public let minimumValue: Decimal?
    
    /// The maximum allowed number. When the value of this property is `nil`, there is no maximum.
    public let maximumValue: Decimal?
    
    /// A step interval to be used for a slider or picker.
    public let stepInterval: Decimal?
    
    /// A unit label associated with this property. The unit should *not* be localized. Instead, this
    /// value is used to determine the unit for measurements converted to the unit expected by the researcher.
    ///
    /// For example, if a measurement of distance is displayed and/or returned by the user in feet, but the
    /// researcher expects the returned value in meters then the unit here would be "m" and the formatter
    /// would be a `LengthFormatter` that uses the current locale with a `unitStyle` of `.long`.
    public let unit: String?
    
    /// `Formatter` that is appropriate to the data type. If `nil`, the format will be determined by the UI.
    /// This is the formatter used to display a previously entered answer to the user or to convert an answer
    /// entered in a text field into the appropriate value type.
    ///
    /// - note: Currently, the `Codable` protocol only supports instantiating a `NumberFormatter` with a
    ///         "maximumDigits" key that contains the number of decimal places to display.
    public let formatter: Formatter?
    
    /// Default initializer for a `Decimal` range. This is used to initialize the range for a `Decimal` type.
    ///
    /// - parameters:
    ///     - minimumDecimal: The minimum allowed number.
    ///     - maximumDecimal: The maximum allowed number.
    ///     - stepInterval: A step interval to be used for a slider or picker.  Default = `nil`.
    ///     - unit: A unit label associated with this property.  Default = `nil`.
    ///     - formatter: `NumberFormatter` that is appropriate to the data type. Default = `nil`.
    public init(minimumDecimal: Decimal?, maximumDecimal: Decimal?, stepInterval: Decimal? = nil, unit: String? = nil, formatter: Formatter? = nil) {
        self.minimumValue = minimumDecimal
        self.maximumValue = maximumDecimal
        self.stepInterval = stepInterval
        self.unit = unit
        self.formatter = formatter
    }
    
    /// Default initializer for an `Int` range. This is used to initialize the range for an `Int` type.
    ///
    /// - parameters:
    ///     - minimumInt: The minimum allowed number.
    ///     - maximumInt: The maximum allowed number.
    ///     - stepInterval: A step interval to be used for a slider or picker.  Default = `nil`.
    ///     - unit: A unit label associated with this property.  Default = `nil`.
    ///     - formatter: `NumberFormatter` that is appropriate to the data type. Default = `nil`.
    public init(minimumInt: Int?, maximumInt: Int?, stepInterval: Int? = nil, unit: String? = nil, formatter: Formatter? = nil) {
        self.minimumValue = (minimumInt == nil) ? nil : Decimal(integerLiteral: minimumInt!)
        self.maximumValue = (maximumInt == nil) ? nil : Decimal(integerLiteral: maximumInt!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(integerLiteral: stepInterval!)
        self.unit = unit
        self.formatter = formatter
    }

    /// Default initializer for an `Double` range. This is used to initialize the range for a `Double` type.
    ///
    /// - parameters:
    ///     - minimumDouble: The minimum allowed number.
    ///     - maximumDouble: The maximum allowed number.
    ///     - stepInterval: A step interval to be used for a slider or picker.  Default = `nil`.
    ///     - unit: A unit label associated with this property.  Default = `nil`.
    ///     - formatter: `NumberFormatter` that is appropriate to the data type. Default = `nil`.
    public init(minimumDouble: Double?, maximumDouble: Double?, stepInterval: Double? = nil, unit: String? = nil, formatter: Formatter? = nil) {
        self.minimumValue = (minimumDouble == nil) ? nil : Decimal(floatLiteral: minimumDouble!)
        self.maximumValue = (maximumDouble == nil) ? nil : Decimal(floatLiteral: maximumDouble!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(floatLiteral: stepInterval!)
        self.unit = unit
        self.formatter = formatter
    }
    
    private enum CodingKeys : String, CodingKey {
        case minimumValue, maximumValue, stepInterval, unit, formatter
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let minimumDouble = try container.decodeIfPresent(Double.self, forKey: .minimumValue)
        let maximumDouble = try container.decodeIfPresent(Double.self, forKey: .maximumValue)
        let stepInterval = try container.decodeIfPresent(Double.self, forKey: .stepInterval)
        self.minimumValue = (minimumDouble == nil) ? nil : Decimal(floatLiteral: minimumDouble!)
        self.maximumValue = (maximumDouble == nil) ? nil : Decimal(floatLiteral: maximumDouble!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(floatLiteral: stepInterval!)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        if container.contains(.formatter) {
            let nestedDecoder = try container.superDecoder(forKey: .formatter)
            self.formatter = try decoder.factory.decodeNumberFormatter(from: nestedDecoder)
        } else {
            self.formatter = nil
        }
    }
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let obj = (self.minimumValue as NSDecimalNumber?)?.doubleValue {
            try container.encode(obj, forKey: .minimumValue)
        }
        if let obj = (self.maximumValue as NSDecimalNumber?)?.doubleValue {
            try container.encode(obj, forKey: .maximumValue)
        }
        if let obj = (self.stepInterval as NSDecimalNumber?)?.doubleValue  {
            try container.encode(obj, forKey: .stepInterval)
        }
        try container.encodeIfPresent(self.unit, forKey: .unit)
        
        if let obj = self.formatter {
            let nestedEncoder = container.superEncoder(forKey: .formatter)
            guard let encodable = obj as? Encodable else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedEncoder.codingPath, debugDescription: "The object does not conform to the Encodable protocol"))
            }
            try encodable.encode(to: nestedEncoder)
        }
    }
}

extension RSDNumberRangeObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.minimumValue, .maximumValue, .stepInterval, .unit, .formatter]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .minimumValue:
                if idx != 0 { return false }
            case .maximumValue:
                if idx != 1 { return false }
            case .stepInterval:
                if idx != 2 { return false }
            case .unit:
                if idx != 3 { return false }
            case .formatter:
                if idx != 4 { return false }
            }
        }
        return keys.count == 5
    }
    
    static func numberRangeExamples() -> [RSDNumberRangeObject] {
        let exampleA = RSDNumberRangeObject(minimumDouble: 1.23, maximumDouble: 567.89, stepInterval: 0.01, unit: "m", formatter: NumberFormatter.defaultNumberFormatter(with: 2))
        let exampleB = RSDNumberRangeObject(minimumInt: -5, maximumInt: 10)
        return [exampleA, exampleB]
    }
    
    static func examples() -> [Encodable] {
        return numberRangeExamples()
    }
}
