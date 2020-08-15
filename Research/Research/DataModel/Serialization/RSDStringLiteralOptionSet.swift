//
//  RSDStringLiteralOptionSet.swift
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
