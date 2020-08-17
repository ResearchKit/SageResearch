//
//  RSDNumberRangeObject.swift
//  Research
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

/// `RSDNumberRangeObject` extends the properties of an `RSDInputField` for a `decimal` or `integer` data type.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public struct RSDNumberRangeObject : RSDNumberRange, RSDRangeWithFormatter, Codable {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case minimumValue, maximumValue, stepInterval, unit, formatter
    }
    
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
    public var formatter: Formatter?
    
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
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///
    /// ```
    ///     { "minimumValue" : 15,
    ///       "maximumValue" : 360,
    ///       "stepInterval" : 5,
    ///       "unit" : "cm",
    ///       "formatter" : {"maximumDigits" : 3 }
    ///    }
    /// ```
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
