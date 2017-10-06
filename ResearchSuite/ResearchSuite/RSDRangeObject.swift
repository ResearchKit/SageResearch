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

public struct RSDDateRangeObject : RSDDateRange {
    
    public private(set) var minDate: Date?
    public private(set) var maxDate: Date?
    public private(set) var allowFuture: Bool?
    public private(set) var allowPast: Bool?
    public private(set) var dateCoder: RSDDateCoder?
    
    public var calendarComponents: Set<Calendar.Component> {
        guard let components = dateCoder?.calendarComponents else {
            return [.year, .month, .day, .hour, .minute]
        }
        return components
    }
    
    public init(minimumDate: Date?, maximumDate: Date?, allowFuture: Bool? = nil, allowPast: Bool? = nil, dateCoder: RSDDateCoder? = nil) {
        self.minDate = minimumDate
        self.maxDate = maximumDate
        self.allowFuture = allowFuture
        self.allowPast = allowPast
        self.dateCoder = dateCoder
    }
    
    private enum CodingKeys : String, CodingKey {
        case minDate = "minimumDate", maxDate = "maximumDate", allowFuture, allowPast, codingFormat
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
            if let obj = minDate { try container.encode(obj, forKey: .minDate) }
            if let obj = maxDate { try container.encode(obj, forKey: .maxDate) }
        }
        if let obj = allowPast { try container.encode(obj, forKey: .allowPast) }
        if let obj = allowFuture { try container.encode(obj, forKey: .allowFuture) }
    }
}

public struct RSDIntegerRangeObject : RSDIntegerRange {
    
    public private(set) var minimumValue: Int?
    public private(set) var maximumValue: Int?
    public private(set) var stepInterval: Int?
    public private(set) var unit: String?
    
    public init(minimumValue: Int?, maximumValue: Int?, stepInterval: Int? = nil, unit: String? = nil) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepInterval = stepInterval
        self.unit = unit
    }
}

public struct RSDDecimalRangeObject : RSDDecimalRange {
    
    public private(set) var minimumValue: Double?
    public private(set) var maximumValue: Double?
    public private(set) var stepInterval: Double?
    public private(set) var unit: String?
    public private(set) var numberFormatter: NumberFormatter?
    
    public init(minimumValue: Double?, maximumValue: Double?, stepInterval: Double? = nil, unit: String? = nil, numberFormatter: NumberFormatter? = nil) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepInterval = stepInterval
        self.unit = unit
        self.numberFormatter = numberFormatter
    }
    
    private enum CodingKeys : String, CodingKey {
        case minimumValue, maximumValue, stepInterval, unit, maximumDigits
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.minimumValue = try container.decodeIfPresent(Double.self, forKey: .minimumValue)
        self.maximumValue = try container.decodeIfPresent(Double.self, forKey: .maximumValue)
        self.stepInterval = try container.decodeIfPresent(Double.self, forKey: .stepInterval)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        if let digits = try container.decodeIfPresent(Int.self, forKey: .maximumDigits) {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = digits
            self.numberFormatter = formatter
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let obj = self.minimumValue { try container.encode(obj, forKey: .minimumValue) }
        if let obj = self.maximumValue { try container.encode(obj, forKey: .maximumValue) }
        if let obj = self.stepInterval { try container.encode(obj, forKey: .stepInterval) }
        if let obj = self.unit { try container.encode(obj, forKey: .unit) }
        if let digits = self.numberFormatter?.maximumFractionDigits {
            try container.encode(digits, forKey: .maximumDigits)
        }
    }
}
