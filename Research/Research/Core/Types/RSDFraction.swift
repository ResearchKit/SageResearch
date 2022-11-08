//
//  RSDFraction.swift
//  Research
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

