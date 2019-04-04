//
//  CSVDecoder.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// This csv decoder is narrowly designed to support decoding comma-delimited files where the format of the
/// string values are wrapped with "" marks and the file includes a single line table header of key names.
public final class CSVDecoder {
    
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    // MARK: - Decoding Values
    
    /// Decodes a top-level value of the given type from the given CSV representation.
    ///
    /// - note: It is assumed that the csv is formatted with a single header row with the keys for each column.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid CSV.
    /// - throws: An error if any value throws an error during decoding.
    public func decodeArray<T : Decodable>(_ type: T.Type, from data: Data) throws -> [T] {

        guard let str = String(data: data, encoding: .utf8)
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid CSV."))
        }
        
        let commas = CharacterSet(charactersIn: ",")
        let lines: [[String]] = str.components(separatedBy: .newlines).compactMap {
            let str = $0.trimmingCharacters(in: .whitespaces)
            guard str.count > 0 else { return nil }
            return str.components(separatedBy: commas)
        }
        
        guard lines.count > 1
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid CSV."))
        }
        
        let keyDecoder = _KeyDecoder()
        let keys = try lines[0].map {
            try keyDecoder.unbox($0, as: String.self)
        }
        let values: [T] = try lines[1...].compactMap { (items) -> T in
            let decoder = try _CSVTopLevelDecoder(keys: keys, items: items)
            return try T.init(from: decoder)
        }
        
        return values
    }
}

fileprivate struct _KeyDecoder: _StringDecoder {
    let codingPath: [CodingKey] = []
}

fileprivate class _CSVTopLevelDecoder : Decoder {

    public let codingPath: [CodingKey] = []
    fileprivate let keys: [String]
    fileprivate let items: [String]
    
    fileprivate init(keys: [String], items: [String]) throws {
        guard keys.count == items.count else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "\(keys.count) != \(items.count): The number of keys does not match the number of items for row starting with \(String(describing: items.first))"))
        }
        self.keys = keys
        self.items = items
    }

    public var userInfo: [CodingUserInfoKey : Any] = [:]

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let container = _CSVKeyedDecodingContainer<Key>(decoder: self)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode a CSV file as an array."))
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode a CSV file as a single value."))
    }
}

fileprivate class _CSVKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol, _StringDecoder {
    typealias Key = K

    public var codingPath: [CodingKey] {
        return _decoder.codingPath
    }

    fileprivate let _decoder: _CSVTopLevelDecoder

    fileprivate init(decoder: _CSVTopLevelDecoder) {
        self._decoder = decoder
    }

    public var allKeys: [Key] {
        return _decoder.keys.compactMap { Key(stringValue: $0) }
    }

    public func contains(_ key: Key) -> Bool {
        return _decoder.keys.contains(key.stringValue)
    }
    
    private func _stringValue(forKey key: Key) throws -> String? {
        guard let idx = _decoder.keys.firstIndex(of: key.stringValue), idx < _decoder.items.count else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        let str = _decoder.items[idx].trimmingCharacters(in: .whitespaces)
        return str.count > 0 ? str : nil
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return isNull(stringValue)
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        return try unbox(stringValue, as: type)
    }

    public func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        let singleValueContainer = _CSVStringDecoder(codingPath: [key], stringValue: stringValue, decoder: _decoder)
        return try singleValueContainer.decode(type)
    }

    public func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        return try unbox(stringValue, as: type)
    }

    public func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        guard let stringValue = try _stringValue(forKey: key), !isNull(stringValue) else {
            return nil
        }
        let singleValueContainer = _CSVStringDecoder(codingPath: [key], stringValue: stringValue, decoder: _decoder)
        return try singleValueContainer.decode(type)
    }

    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.typeMismatch(type, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription:"CSV format does not support nested containers."))
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch([String].self, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription:"CSV format does not support nested containers."))
    }

    public func superDecoder() throws -> Decoder {
        throw DecodingError.keyNotFound(AnyCodingKey(stringValue: "super")!, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription:"CSV format does not support using a super decoder."))
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        guard let stringValue = try _stringValue(forKey: key) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: _decoder.codingPath, debugDescription: "No value associated with key \(key.stringValue))."))
        }
        let singleValueContainer = _CSVStringDecoder(codingPath: [key], stringValue: stringValue, decoder: _decoder)
        return singleValueContainer
    }
}

fileprivate class _CSVStringDecoder : Decoder, _StringDecoder {
    fileprivate let codingPath: [CodingKey]
    fileprivate let stringValue: String
    fileprivate let _decoder: _CSVTopLevelDecoder
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return _decoder.userInfo
    }
    
    fileprivate init(codingPath: [CodingKey], stringValue: String, decoder: _CSVTopLevelDecoder) {
        self.codingPath = codingPath
        self.stringValue = stringValue
        self._decoder = decoder
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "\(stringValue) cannot be decoded as a dictionary."))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "\(stringValue) cannot be decoded as an array."))
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

extension _CSVStringDecoder : SingleValueDecodingContainer {
    
    public func decodeNil() -> Bool {
        return isNull(stringValue)
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        return try unbox(stringValue, as: type)
    }
    
    public func decode(_ type: String.Type) throws -> String {
        return try unbox(stringValue, as: type)
    }
    
    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(stringValue, as: type)
        return try type.init(from: self)
    }
}

fileprivate protocol _StringDecoder {
    var codingPath: [CodingKey] { get }
}

extension _StringDecoder {
    
    fileprivate func expectNonNull<T>(_ stringValue: String, as type: T.Type) throws {
        guard !isNull(stringValue) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
    
    fileprivate func isNull(_ stringValue: String) -> Bool {
        return stringValue == "null" || stringValue.count == 0
    }
    
    /// Returns the given value unboxed from a container.
    fileprivate func unbox(_ stringValue: String, as type: Bool.Type) throws -> Bool {
        try expectNonNull(stringValue, as: type)
        return (stringValue as NSString).boolValue
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Int.Type) throws -> Int {
        try expectNonNull(stringValue, as: type)
        return (stringValue as NSString).integerValue
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Int8.Type) throws -> Int8 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Int16.Type) throws -> Int16 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Int32.Type) throws -> Int32 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Int64.Type) throws -> Int64 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: UInt.Type) throws -> UInt {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(stringValue, as: type)
        return type.init((stringValue as NSString).integerValue)
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Float.Type) throws -> Float {
        try expectNonNull(stringValue, as: type)
        return (stringValue as NSString).floatValue
    }
    
    fileprivate func unbox(_ stringValue: String, as type: Double.Type) throws -> Double {
        try expectNonNull(stringValue, as: type)
        return (stringValue as NSString).doubleValue
    }
    
    fileprivate func unbox(_ stringValue: String, as type: String.Type) throws -> String {
        try expectNonNull(stringValue, as: type)
        
        let quote = Character("\"")
        guard stringValue.first == quote, stringValue.last == quote else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "String values within CSV should be wrapped in quotation marks."))
        }
        
        let value = String(stringValue.dropFirst().dropLast())
        return value
    }
}

