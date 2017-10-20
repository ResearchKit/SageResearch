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

public struct RSDDateRangeObject : RSDDateRange, Codable {
    
    public let minDate: Date?
    public let maxDate: Date?
    public let allowFuture: Bool?
    public let allowPast: Bool?
    public let minuteInterval: Int?
    public let dateCoder: RSDDateCoder?
    
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

public struct RSDDecimalRangeObject : RSDDecimalRange, Codable {
    
    public let minimumValue: Decimal?
    public let maximumValue: Decimal?
    public let stepInterval: Decimal?
    public let unit: String?
    public let formatter: Formatter?
    
    public init(minimumDecimal: Decimal?, maximumDecimal: Decimal?, stepInterval: Decimal? = nil, unit: String? = nil, numberFormatter: NumberFormatter? = nil) {
        self.minimumValue = minimumDecimal
        self.maximumValue = maximumDecimal
        self.stepInterval = stepInterval
        self.unit = unit
        self.formatter = numberFormatter
    }
    
    public init(minimumInt: Int?, maximumInt: Int?, stepInterval: Int? = nil, unit: String? = nil, numberFormatter: NumberFormatter? = nil) {
        self.minimumValue = (minimumInt == nil) ? nil : Decimal(integerLiteral: minimumInt!)
        self.maximumValue = (maximumInt == nil) ? nil : Decimal(integerLiteral: maximumInt!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(integerLiteral: stepInterval!)
        self.unit = unit
        self.formatter = numberFormatter
    }

    public init(minimumDouble: Double?, maximumDouble: Double?, stepInterval: Double? = nil, unit: String? = nil, numberFormatter: NumberFormatter? = nil) {
        self.minimumValue = (minimumDouble == nil) ? nil : Decimal(floatLiteral: minimumDouble!)
        self.maximumValue = (maximumDouble == nil) ? nil : Decimal(floatLiteral: maximumDouble!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(floatLiteral: stepInterval!)
        self.unit = unit
        self.formatter = numberFormatter
    }
    
    private enum CodingKeys : String, CodingKey {
        case minimumValue, maximumValue, stepInterval, unit, maximumDigits
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let minimumDouble = try container.decodeIfPresent(Double.self, forKey: .minimumValue)
        let maximumDouble = try container.decodeIfPresent(Double.self, forKey: .maximumValue)
        let stepInterval = try container.decodeIfPresent(Double.self, forKey: .stepInterval)
        self.minimumValue = (minimumDouble == nil) ? nil : Decimal(floatLiteral: minimumDouble!)
        self.maximumValue = (maximumDouble == nil) ? nil : Decimal(floatLiteral: maximumDouble!)
        self.stepInterval = (stepInterval == nil) ? nil : Decimal(floatLiteral: stepInterval!)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        if let digits = try container.decodeIfPresent(Int.self, forKey: .maximumDigits) {
            self.formatter = RSDDecimalRangeObject.defaultNumberFormatter(with: digits)
        } else {
            self.formatter = nil
        }
    }
    
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
        if let digits = (self.formatter as? NumberFormatter)?.maximumFractionDigits {
            try container.encode(digits, forKey: .maximumDigits)
        }
    }
    
    static func defaultNumberFormatter(with maximumFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.generatesDecimalNumbers = true
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter
    }
    
}
