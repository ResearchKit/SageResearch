//
//  RSDAnswerResultType.swift
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

///
/// `RSDAnswerResultType` is a `Codable` struct that can be used to describe how to encode and decode an `RSDAnswerResult`.
/// It carries information about the type of the value and how to encode it. This struct serves a different purpose from
/// the `RSDFormDataType` because it only carries information required to store a result and *not* additional information
/// about presentation style.
///
/// - seealso: `RSDAnswerResult` and `RSDFormDataType`
///
public struct RSDAnswerResultType : Codable {
    
    /// The base type of the answer result. This is used to indicate what the type is of the
    /// value being stored. The value stored in the `RSDAnswerResult` should be convertable
    /// to one of these base types.
    public enum BaseType : String, Codable {
        /// Bool
        case boolean
        /// Data
        case data
        /// Date
        case date
        /// Double
        case decimal
        /// Int
        case integer
        /// String
        case string
        /// TimeInterval
        case timeInterval
    }
    
    /// The sequence type of the answer result. This is used to represent a multiple-choice
    /// answer array or a key/value dictionary.
    public enum SequenceType : String, Codable {
        /// Array
        case array
        /// Dictionary
        case dictionary
    }
    
    /// The base type for the answer.
    public let baseType: BaseType
    
    /// The sequence type (if any) for the answer.
    public private(set) var sequenceType: SequenceType?
    
    /// The date format that should be used to encode the answer.
    public private(set) var dateFormat: String?
    
    /// The unit (if any) to store with the answer for localized measurement conversion.
    public private(set) var unit: String?
    
    /// The sequence separator to use when storing a multiple component answer as a string.
    ///
    /// For example, blood pressure might be represented using an array with two fields
    /// but is stored as a single string value of "120/90". In this case, "/" would be the
    /// separator.
    public private(set) var sequenceSeparator: String?
    
    /// Static type for a `RSDAnswerResultType` with a `Bool` base type.
    public static let boolean = RSDAnswerResultType(baseType: .boolean)
    
    /// Static type for a `RSDAnswerResultType` with a `Data` base type.
    public static let data = RSDAnswerResultType(baseType: .data)
    
    /// Static type for a `RSDAnswerResultType` with a `Date` base type.
    public static let date = RSDAnswerResultType(baseType: .date)
    
    /// Static type for a `RSDAnswerResultType` with a `Double` or `Decimal` base type.
    public static let decimal = RSDAnswerResultType(baseType: .decimal)
    
    /// Static type for a `RSDAnswerResultType` with an `Int` base type.
    public static let integer = RSDAnswerResultType(baseType: .integer)
    
    /// Static type for a `RSDAnswerResultType` with a `String` base type.
    public static let string = RSDAnswerResultType(baseType: .string)
    
    /// Static type for a `RSDAnswerResultType` with a `TimeInterval` base type.
    public static let timeInterval = RSDAnswerResultType(baseType: .timeInterval)
    
    /// The initializer for the `RSDAnswerResultType`.
    ///
    /// - parameters:
    ///     - baseType: The base type for the answer. Required.
    ///     - sequenceType: The sequence type (if any) for the answer. Default is `nil`.
    ///     - dateFormat: The date format that should be used to encode the answer. Default is `nil`.
    ///     - unit: The unit (if any) to store with the answer for localized measurement conversion. Default is `nil`.
    ///     - sequenceSeparator: The sequence separator to use when storing a multiple component answer as a string. Default is `nil`.
    public init(baseType: BaseType, sequenceType: SequenceType? = nil, dateFormat: String? = nil, unit: String? = nil, sequenceSeparator: String? = nil) {
        self.baseType = baseType
        self.sequenceType = sequenceType
        self.dateFormat = dateFormat
        self.unit = unit
        self.sequenceSeparator = sequenceSeparator
    }
}

// MARK: Value Decoding
extension RSDAnswerResultType : RSDJSONValueDecoder {
    
    /// Decode a `RSDJSONValue` from the given decoder.
    ///
    /// - parameter decoder: The decoder that holds the value.
    /// - returns: The decoded value or `nil` if the value is not present.
    /// - throws: `DecodingError` if the encountered stored value cannot be decoded.
    public func decodeValue(from decoder:Decoder) throws -> RSDJSONValue? {
        // Look to see if the decoded value is nil and exit early if that is the case.
        if let nilContainer = try? decoder.singleValueContainer(), nilContainer.decodeNil() {
            return nil
        }
        
        if let sType = sequenceType {
            switch sType {
            case .array:
                do {
                    var values: [RSDJSONValue] = []
                    var container = try decoder.unkeyedContainer()
                    while !container.isAtEnd {
                        let value = try _decodeSingleValue(from: container.superDecoder())
                        values.append(value)
                    }
                    return values 
                } catch DecodingError.typeMismatch(let type, let context) {
                    // If attempting to get an array fails, then look to see if this is a single String value
                    if sType == .array, let separator = self.sequenceSeparator {
                        let container = try decoder.singleValueContainer()
                        let strings = try container.decode(String.self).components(separatedBy: separator)
                        return try strings.map { try _decodeStringValue(from: $0, decoder: decoder) }
                    }
                    else {
                        throw DecodingError.typeMismatch(type, context)
                    }
                }
                
            case .dictionary:
                var values: [String : RSDJSONValue] = [:]
                let container = try decoder.container(keyedBy: AnyCodingKey.self)
                for key in container.allKeys {
                    let nestedDecoder = try container.superDecoder(forKey: key)
                    let value = try _decodeSingleValue(from: nestedDecoder)
                    values[key.stringValue] = value
                }
                return values
            }
        }
        else {
            return try _decodeSingleValue(from: decoder)
        }
    }
    
    private func _decodeStringValue(from string: String, decoder: Decoder) throws -> RSDJSONValue {
        switch baseType {
        case .boolean:
            return (string as NSString).boolValue
            
        case .data:
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.typeMismatch(Data.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(string) is not a valid base64 encoded string."))
            }
            return data
            
        case .decimal:
            return (string as NSString).doubleValue
            
        case .integer:
            return (string as NSString).integerValue
            
        case .string:
            return string
            
        case .date:
            return try decoder.factory.decodeDate(from: string, dateFormat: self.dateFormat, codingPath: decoder.codingPath)
            
        case .timeInterval:
            return (string as NSString).doubleValue
            
        }
    }
    
    private func _decodeSingleValue(from decoder: Decoder) throws -> RSDJSONValue {
        let container = try decoder.singleValueContainer()
        switch baseType {
        case .boolean:
            return try container.decode(Bool.self)
            
        case .data:
            return try container.decode(Data.self)
            
        case .decimal:
            return try container.decode(Double.self)
            
        case .integer:
            return try container.decode(Int.self)
            
        case .string:
            return try container.decode(String.self)
            
        case .date:
            if let format = self.dateFormat {
                let string = try container.decode(String.self)
                return try decoder.factory.decodeDate(from: string, dateFormat: format, codingPath: decoder.codingPath)
            }
            else {
                return try container.decode(Date.self)
            }
            
        case .timeInterval:
            return try container.decode(TimeInterval.self)
            
        }
    }
    
    private func _decodeDate(from string: String, codingPath: [CodingKey]) throws -> Date {
        guard let date = decodeDate(from: string) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode \(string) as a Date.")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        return date
    }
    
    public func decodeDate(from string: String) -> Date? {
        guard let format = self.dateFormat else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

// MARK: Value Encoding
extension RSDAnswerResultType : RSDJSONValueEncoder {
    
    /// A convenience property for getting the measurement `Unit` from the `unit` string.
    public var measurementUnit: Unit? {
        guard let symbol = self.unit else { return nil }
        return Unit(symbol: symbol)
    }
    
    /// Encode a value to the given encoder.
    ///
    /// - parameters:
    ///     - value: The value to encode.
    ///     - encoder: The encoder to mutate.
    /// - throws: `EncodingError` if the value cannot be encoded.
    public func encode(_ value: Any?, to encoder: Encoder) throws {
        guard let obj = value else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }
        
        if let sType = self.sequenceType {
            switch sType {
            case .array:
                guard let array = obj as? [Any] else {
                    throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(obj) is not expected type. Expecting an Array."))
                }

                if let separator = self.sequenceSeparator {
                    let strings = try array.map { (object) -> String in
                        guard let string = try _encodableString(object, encoder: encoder) else {
                            throw EncodingError.invalidValue(object, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(object) cannot be converted to a \(self.baseType) encoded value."))
                        }
                        return string
                    }
                    let encodable = strings.joined(separator: separator)
                    try encodable.encode(to: encoder)
                }
                else {
                    var nestedContainer = encoder.unkeyedContainer()
                    for object in array {
                        guard let encodable = try _encodableValue(object, encoder: encoder) else {
                            throw EncodingError.invalidValue(object, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(object) cannot be converted to a \(self.baseType) encoded value."))
                        }
                        let nestedEncoder = nestedContainer.superEncoder()
                        try encodable.encode(to: nestedEncoder)
                    }
                }
                
                
            case .dictionary:
                guard let dictionary = obj as? NSDictionary else {
                    throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(obj) is not expected type. Expecting a Dictionary."))
                }
                
                var nestedContainer = encoder.container(keyedBy: AnyCodingKey.self)
                for (key, object) in dictionary {
                    guard let encodable = try _encodableValue(object, encoder: encoder) else {
                        throw EncodingError.invalidValue(object, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(object) cannot be converted to a \(self.baseType) encoded value."))
                    }
                    let nestedEncoder = nestedContainer.superEncoder(forKey: AnyCodingKey(stringValue: "\(key)")!)
                    try encodable.encode(to: nestedEncoder)
                }
            }
        }
        else {
            guard let encodable = try _encodableValue(obj, encoder: encoder) else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "\(obj) cannot be converted to a \(baseType) encoded value."))
            }
            try encodable.encode(to: encoder)
        }
    }
    
    private func _encodableString(_ value: Any, encoder: Encoder) throws -> String? {
        guard let encodable = try _encodableValue(value, encoder: encoder) else {
            return nil
        }
        if let date = encodable as? Date {
            return encoder.factory.encodedDate(from: date, codingPath: encoder.codingPath)
        }
        else {
            return "\(encodable)"
        }
    }
    
    private func _encodableValue(_ value: Any, encoder: Encoder) throws -> Encodable? {
        if let num = value as? NSNumber {
            switch baseType {
            case .boolean:
                return num.boolValue
            case .decimal, .timeInterval:
                return num.doubleValue
            case .integer:
                return num.intValue
            case .string:
                return "\(num)"
            default:
                return nil
            }
        }
        else if let measurement = value as? Measurement {
            if let mUnit = self.measurementUnit, measurement.unit != mUnit {
                guard (measurement as NSMeasurement).canBeConverted(to: mUnit) else {
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Measurement \(value) cannot be converted to \(mUnit.symbol) unit."))
                }
                return try _encodableValue(NSNumber(value: (measurement as NSMeasurement).converting(to: mUnit).value), encoder: encoder)
            } else {
                return try _encodableValue(NSNumber(value: measurement.value), encoder: encoder)
            }
        }
        else if let string = value as? NSString {
            switch baseType {
            case .boolean:
                return string.boolValue
            case .integer:
                return string.integerValue
            case .decimal:
                return string.doubleValue
            default:
                return string as String
            }
        }
        else if let date = value as? Date {
            guard baseType == .date || baseType == .string else {
                return nil
            }
            if let format = dateFormat {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                return formatter.string(from: date)
            } else if baseType == .string {
                return RSDClassTypeMap.shared.timestampFormatter.string(from: date)
            } else {
                return date
            }
        }
        else {
            switch baseType {
            case .data:
                return (value as? Data)
            case .boolean, .decimal, .integer, .timeInterval:
                return (value as? RSDJSONNumber)
            case .string:
                return "\(value)"
            default:
                return nil
            }
        }
    }
}

// MARK: Equatable and Hashable
extension RSDAnswerResultType : Hashable, Equatable {
    
    public var description: String {
        return "\(baseType)|\(String(describing:sequenceType))|\(String(describing:dateFormat))|\(String(describing:unit))|\(String(describing:sequenceSeparator))"
    }
    
    public var hashValue: Int {
        return description.hashValue
    }
    
    public static func ==(lhs: RSDAnswerResultType, rhs: RSDAnswerResultType) -> Bool {
        return lhs.description == rhs.description
    }
}
