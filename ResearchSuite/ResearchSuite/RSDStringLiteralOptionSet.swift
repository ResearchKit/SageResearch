//
//  RSDStringLiteralOptionSet.swift
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

/**
 Extend `OptionSet` to allow mapping any OptionSet that uses a `BinaryInteger` as its `RawValue` to a set of string keys. See the implementation for `RSDActiveUICommand` for example usage.
 */
public protocol RSDStringLiteralOptionSet : OptionSet, Codable {
    
    static var stringMapping: [String : RawValue] { get }
    
    static func set(rawValue: RawValue, forKey: String)
}

extension RSDStringLiteralOptionSet {
    
    public init(_ rawValue: RawValue, codingKey: String) {
        self.init(rawValue: rawValue)
        
        // Add to the mapped options
        type(of: self).set(rawValue: rawValue, forKey: codingKey)
    }
    
    public init(_ unionSet: Self, codingKey: String) {
        let rawValue = unionSet.rawValue
        self.init(rawValue: rawValue)
        
        type(of: self).set(rawValue: rawValue, forKey: codingKey)
    }
}

extension RSDStringLiteralOptionSet where Self.RawValue : BinaryInteger {

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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for (key, value) in type(of: self).stringMapping {
            if (value & self.rawValue) == value {
                try container.encode(key)
            }
        }
    }
}
