//
//  RSDStringLiteralOptionSet.swift
//  Research
//

import Foundation

/// `RSDStringLiteralOptionSet` extends `OptionSet` to allow mapping any OptionSet that uses a `BinaryInteger`
/// as its `RawValue` to a set of string keys.
///
/// - seealso: `RSDActiveUICommand` for example usage.
public protocol RSDStringLiteralOptionSet : OptionSet, Codable {
    
    /// A mapping of an option to a string value. This is used to allow `Codable` protocol
    /// conformance using human-readable strings rather than `Binary` flags.
    static var stringMapping: [String : RawValue] { get }
    
    /// A convenience method for mapping a `rawValue` to a `String`.
    ///
    /// - parameters:
    ///     - rawValue: The raw value for this command.
    ///     - forKey: The string representation.
    static func set(rawValue: RawValue, forKey: String)
}

extension RSDStringLiteralOptionSet {
    
    /// Initialize a option step value using both the binary raw value and
    /// the coding key to use when coding the value.
    /// - parameters:
    ///     - rawValue: The raw value for this command.
    ///     - codingKey: The string representation.
    public init(_ rawValue: RawValue, codingKey: String) {
        self.init(rawValue: rawValue)
        
        // Add to the mapped options
        type(of: self).set(rawValue: rawValue, forKey: codingKey)
    }
}

extension RSDStringLiteralOptionSet where Self.RawValue : BinaryInteger {
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read
    /// is corrupted or otherwise invalid.
    ///
    /// - parameters:
    ///     - decoder: The decoder to read data from.
    ///     - stringMapping: The mapping of coding strings to the associated raw value.
    public init(from decoder: Decoder, stringMapping: [String : RawValue]) throws {
        var container = try decoder.unkeyedContainer()
        var rawValue: RawValue = 0
        while !container.isAtEnd {
            let option = try container.decode(String.self)
            guard let value = stringMapping[option] else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot map '\(option)' String key to a value for this set. stringMapping = \(stringMapping)")
                throw DecodingError.valueNotFound(RawValue.self, context)
            }
            rawValue |= value
        }
        self.init(rawValue: rawValue)
    }
    
    /// Method for encoding the value back into an array of strings.
    /// - parameter encoder: The encoder to encode this value to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for (key, value) in type(of: self).stringMapping {
            if (value & self.rawValue) == value {
                try container.encode(key)
            }
        }
    }
}
