//
//  RSDAnswerResultType.swift
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
import JsonModel

///
/// `RSDAnswerResultType` is a `Codable` struct that can be used to describe how to encode and decode an `RSDAnswerResult`.
/// It carries information about the type of the value and how to encode it. This struct serves a different purpose from
/// the `RSDFormDataType` because it only carries information required to store a result and *not* additional information
/// about presentation style.
///
/// - seealso: `RSDAnswerResult` and `RSDFormDataType`
///
@available(*, deprecated, message: "Use `AnswerType` instead")
public struct RSDAnswerResultType : Codable, Hashable, Equatable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case baseType, sequenceType, formDataType, dateFormat, dateLocaleIdentifier, unit, sequenceSeparator
    }
    
    /// Override equality to *not* include the original formDataType.
    public static func == (lhs: RSDAnswerResultType, rhs: RSDAnswerResultType) -> Bool {
        return lhs.baseType == rhs.baseType &&
            lhs.sequenceType == rhs.sequenceType &&
            lhs.dateFormat == rhs.dateFormat &&
            lhs.unit == rhs.unit &&
            lhs.sequenceSeparator == rhs.sequenceSeparator
    }
    
    /// Override the hash into to *not* include the original formDataType.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(baseType)
        if let hashV = self.sequenceType { hasher.combine(hashV) }
        if let hashV = self.dateFormat { hasher.combine(hashV) }
        if let hashV = self.unit { hasher.combine(hashV) }
        if let hashV = self.sequenceSeparator { hasher.combine(hashV) }
    }
    
    /// The base type of the answer result. This is used to indicate what the type is of the
    /// value being stored. The value stored in the `RSDAnswerResult` should be convertable
    /// to one of these base types.
    public enum BaseType : String, Codable, StringEnumSet {
        
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
        /// Codable
        case codable
    }
    
    /// The sequence type of the answer result. This is used to represent a multiple-choice
    /// answer array or a key/value dictionary.
    public enum SequenceType : String, Codable, StringEnumSet {
        
        /// Array
        case array
        
        /// Dictionary
        case dictionary
    }
    
    /// The base type for the answer.
    public let baseType: BaseType
    
    /// The sequence type (if any) for the answer.
    public let sequenceType: SequenceType?
    
    /// The original data type of the form input item.
    public var formDataType: RSDFormDataType?
    
    /// The date format that should be used to encode and decode the answer.
    public let dateFormat: String?
    
    /// The date formatter locale identifier that should be used to encode and decode the answer.
    /// If nil, the default Locale will be set to "en_US_POSIX".
    public var dateLocaleIdentifier: String?
    
    /// The unit (if any) to store with the answer for localized measurement conversion.
    public let unit: String?
    
    /// A conveniece property for accessing the formatter used to encode and decode a date.
    public var dateFormatter: DateFormatter? {
        guard let dateFormat = self.dateFormat else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: dateLocaleIdentifier ?? RSDAnswerResultType.defaultDateLocaleIdentifier)
        return formatter
    }
    
    private static let defaultDateLocaleIdentifier = "en_US_POSIX"
    
    /// The sequence separator to use when storing a multiple component answer as a string.
    ///
    /// For example, blood pressure might be represented using an array with two fields
    /// but is stored as a single string value of "120/90". In this case, "/" would be the
    /// separator.
    public private(set) var sequenceSeparator: String?
    
    /// The initializer for the `RSDAnswerResultType`.
    ///
    /// - parameters:
    ///     - baseType: The base type for the answer. Required.
    ///     - sequenceType: The sequence type (if any) for the answer. Default is `nil`.
    ///     - dateFormat: The date format that should be used to encode the answer. Default is `nil`.
    ///     - unit: The unit (if any) to store with the answer for localized measurement conversion. Default is `nil`.
    ///     - sequenceSeparator: The sequence separator to use when storing a multiple component answer as a string. Default is `nil`.
    public init(baseType: BaseType, sequenceType: SequenceType? = nil, formDataType: RSDFormDataType? = nil, dateFormat: String? = nil, unit: String? = nil, sequenceSeparator: String? = nil) {
        self.baseType = baseType
        self.sequenceType = sequenceType
        self.formDataType = formDataType
        self.dateFormat = dateFormat
        self.unit = unit
        self.sequenceSeparator = sequenceSeparator
    }
    
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
    
    /// Static type for a `RSDAnswerResultType` with a `Codable` base type.
    public static let codable = RSDAnswerResultType(baseType: .codable)

    public var description: String {
        return "\(baseType)|\(String(describing:sequenceType))|\(String(describing:dateFormat))|\(String(describing:unit))|\(String(describing:sequenceSeparator))"
    }
}

@available(*, deprecated, message: "Use `AnswerType` instead")
extension RSDAnswerResultType.BaseType {
    var jsonType: JsonType {
        switch self {
        case .boolean:
            return .boolean
        case .codable:
            return .object
        case .data:
            return .string
        case .date:
            return .string
        case .decimal:
            return .number
        case .integer:
            return .integer
        case .string:
            return .string
        }
    }
}

@available(*, deprecated, message: "Use `AnswerType` instead")
extension RSDAnswerResultType {
    var answerType: AnswerType {
        if let sequenceType = self.sequenceType {
            switch sequenceType {
            case .array:
                return AnswerTypeArray(baseType: self.baseType.jsonType, sequenceSeparator: self.sequenceSeparator)
            case .dictionary:
                return AnswerTypeObject()
            }
        }
        else if let unit = self.unit {
            return AnswerTypeMeasurement(unit: unit)
        }
        else if self.baseType == .date {
            return AnswerTypeDateTime(codingFormat: self.dateFormat)
        }
        else {
            return self.baseType.jsonType.answerType
        }
    }
}

