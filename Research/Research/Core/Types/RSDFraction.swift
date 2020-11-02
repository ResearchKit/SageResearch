//
//  RSDFraction.swift
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
import JsonModel
import Formatters

extension RSDFraction : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        let fraction = RSDFraction.fraction(from: value)
        self.init(numerator: fraction.numerator, denominator: fraction.denominator)
    }
    
    fileprivate static func fraction(from value: String) -> RSDFraction {
        let formatter = RSDFractionFormatter()
        guard let number = formatter.number(from: value) else {
            return RSDFraction(numerator: 1, denominator: 0)
        }
        return number.fractionalValue()
    }
    
    /// String representation of the fractional value
    public var stringValue: String {
        if self.denominator == 0 {
            return (self.numerator == 0) ? "NaN" : ((self.numerator > 0) ? "inf" : "-inf")
        } else if self.denominator == 1 {
            return "\(self.numerator)"
        } else {
            return "\(self.numerator)/\(self.denominator)"
        }
    }
}

extension RSDFraction : ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        let fraction = RSDFraction.fraction(from: value)
        self.init(numerator: fraction.numerator, denominator: fraction.denominator)
    }
    
    fileprivate static func fraction(from value: Double) -> RSDFraction {
        if value == Double.infinity {
            return RSDFraction(numerator: 1, denominator: 0)
        }
        else if value == -1 * Double.infinity {
            return RSDFraction(numerator: -1, denominator: 0)
        }
        let number = NSNumber(value: value)
        return number.fractionalValue()
    }
    
    /// Double value for the fraction
    public var doubleValue: Double {
        guard self.denominator != 0
            else {
                return (self.numerator == 0) ? Double.nan : ((self.numerator > 0) ? Double.infinity : -1 * Double.infinity)
        }
        return Double(self.numerator) / Double(self.denominator)
    }
}

extension RSDFraction : Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(numerator)
        hasher.combine(denominator)
    }

    public static func ==(lhs: RSDFraction, rhs: RSDFraction) -> Bool {
        return lhs.numerator == rhs.numerator && lhs.denominator == rhs.denominator
    }
}

extension RSDFraction : Decodable {
    
    /// The fraction can be decoded from either a string in the form `numerator / denominator`
    /// or from a number.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self.init(floatLiteral: value)
        } else if let value = try? container.decode(Int.self) {
            self.init(numerator: value, denominator: 1)
        } else {
            let value = try container.decode(String.self)
            self.init(stringLiteral: value)
        }
    }
}

extension RSDFraction : Encodable {
    
    /// The fraction is encoded as a double value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.doubleValue)
    }
}

extension RSDFraction : JsonNumber {

    public func jsonNumber() -> NSNumber? {
        return Decimal(self.doubleValue) as NSNumber
    }
}

extension RSDFraction : JsonValue {
    
    public func jsonObject() -> JsonSerializable {
        return self.jsonNumber() ?? NSNull()
    }
}

extension RSDFraction : CustomStringConvertible {
    
    public var description: String {
        return stringValue
    }
}

