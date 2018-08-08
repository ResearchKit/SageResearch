//
//  Codable+Utilities.swift
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

extension Dictionary {
    
    /// Use this dictionary to decode the given object type.
    public func rsd_decode<T>(_ type: T.Type, bundle: Bundle? = nil) throws -> T where T : Decodable {
        let decoder = RSDFactory.shared.createJSONDecoder(bundle: bundle)
        let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
        let decodable = try decoder.decode(type, from: jsonData)
        return decodable
    }
}

extension Array {
    
    /// Use this array to decode an array of objects of the given type.
    public func rsd_decode<T>(_ type: Array<T>.Type, bundle: Bundle? = nil) throws -> Array<T> where T : Decodable {
        let decoder = RSDFactory.shared.createJSONDecoder(bundle: bundle)
        let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
        let decodable = try decoder.decode(type, from: jsonData)
        return decodable
    }
}

extension RSDFactoryEncoder {
    
    /// Serialize a dictionary. This is a work-around for not being able to
    /// directly encode a generic dictionary.
    func rsd_encode(_ value: Dictionary<String, Any>) throws -> Data {
        let dictionary = value.mapKeys { "\($0)" }
        let anyDictionary = AnyCodableDictionary(dictionary)
        let data = try self.encode(anyDictionary)
        return data
    }
    
    /// Serialize an array. This is a work-around for not being able to
    /// directly encode a generic dictionary.
    func rsd_encode(_ value: Array<Any>) throws -> Data {
        let anyArray = AnyCodableArray(value)
        let data = try self.encode(anyArray)
        return data
    }
}

/// `CodingKey` for converting a decoding container to a dictionary where any key in the
/// dictionary is accessible.
public struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

/// Wrapper for any codable array.
public struct AnyCodableArray : Codable {
    let array : [Any]
    
    public init(_ array : [Any]) {
        self.array = array
    }
    
    public init(from decoder: Decoder) throws {
        var genericContainer = try decoder.unkeyedContainer()
        self.array = try genericContainer.rsd_decode(Array<Any>.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        try (self.array as NSArray).encode(to: encoder)
    }
}

/// Wrapper for any codable dictionary.
public struct AnyCodableDictionary : Codable {
    public let dictionary : [String : Any]
    
    public init(_ dictionary : [String : Any]) {
        self.dictionary = dictionary
    }
    
    public init(from decoder: Decoder) throws {
        let genericContainer = try decoder.container(keyedBy: AnyCodingKey.self)
        self.dictionary = try genericContainer.rsd_decode(Dictionary<String, Any>.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        try (self.dictionary as NSDictionary).encode(to: encoder)
    }
}

/// Extension of the keyed decoding container for decoding to any dictionary. These methods are defined internally
/// to avoid possible namespace clashes.
extension KeyedDecodingContainer {
    
    /// Decode `Dictionary<String, Any>` for the given key.
    func rsd_decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        return try container.rsd_decode(type)
    }
    
    /// Decode `Dictionary<String, Any>` for the given key if the dictionary is present for that key.
    func rsd_decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        return try rsd_decode(type, forKey: key)
    }
    
    /// Decode `Array<Any>` for the given key.
    func rsd_decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.rsd_decode(type)
    }
    
    /// Decode `Array<Any>` for the given key if the array is present for that key.
    func rsd_decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        return try rsd_decode(type, forKey: key)
    }
    
    /// Decode this container as a `Dictionary<String, Any>`.
    func rsd_decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()
        
        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            }
            else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            }
            else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            }
            else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            }
            else if let nestedDictionary = try? decode(AnyCodableDictionary.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary.dictionary
            }
            else if let nestedArray = try? decode(AnyCodableArray.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray.array
            }
        }
        return dictionary
    }
}

/// Extension of the unkeyed decoding container for decoding to any array. These methods are defined internally
/// to avoid possible namespace clashes.
extension UnkeyedDecodingContainer {
    
    /// For the elements in the unkeyed contain, decode all the elements.
    mutating func rsd_decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedArray = try? decode(AnyCodableArray.self) {
                array.append(nestedArray.array)
            } else {
                let nestedDictionary = try decode(AnyCodableDictionary.self)
                array.append(nestedDictionary.dictionary)
            }
        }
        return array
    }
}
