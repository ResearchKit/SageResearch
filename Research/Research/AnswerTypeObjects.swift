//
//  AnswerTypeObjects.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

public struct AnswerTypeType : RSDFactoryTypeRepresentable, Codable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(jsonType: JsonType) {
        self.rawValue = jsonType.rawValue
    }
    
    static public let measurement: AnswerTypeType = "measurement"
    static public let dateTime: AnswerTypeType = "date-time"
    static public let string: AnswerTypeType = AnswerTypeType(jsonType: .string)
    static public let number: AnswerTypeType = AnswerTypeType(jsonType: .number)
    static public let integer: AnswerTypeType = AnswerTypeType(jsonType: .integer)
    static public let boolean: AnswerTypeType = AnswerTypeType(jsonType: .boolean)
    static public let array: AnswerTypeType = AnswerTypeType(jsonType: .array)
    static public let object: AnswerTypeType = AnswerTypeType(jsonType: .object)
    static public let null: AnswerTypeType = AnswerTypeType(jsonType: .null)
}

extension AnswerTypeType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

public protocol RSDBaseAnswerType : AnswerType {
    static var defaultJsonType: JsonType { get }
}

extension RSDBaseAnswerType {
    public var baseType: JsonType {
        return type(of: self).defaultJsonType
    }
}

extension JsonType {
    public var answerType : AnswerType {
        switch self {
        case .boolean:
            return AnswerTypeBoolean()
        case .string:
            return AnswerTypeString()
        case .number:
            return AnswerTypeNumber()
        case .integer:
            return AnswerTypeInteger()
        case .null:
            return AnswerTypeNull()
        case .array:
            return AnswerTypeArray()
        case .object:
            return AnswerTypeObject()
        }
    }
}

public struct AnswerTypeObject : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .object
    public private(set) var type: AnswerTypeType = .object
    public init() {
    }
}

public struct AnswerTypeString : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .string
    public private(set) var type: AnswerTypeType = .string
    public init() {
    }
}

public struct AnswerTypeBoolean : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .boolean
    public private(set) var type: AnswerTypeType = .boolean
    public init() {
    }
}

public struct AnswerTypeInteger : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .integer
    public private(set) var type: AnswerTypeType = .integer
    public init() {
    }
}

public struct AnswerTypeNumber : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .number
    public private(set) var type: AnswerTypeType = .number
    public init() {
    }
}

public struct AnswerTypeNull : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .null
    public private(set) var type: AnswerTypeType = .null
    public init() {
    }
}

public struct AnswerTypeArray : AnswerType, Codable, Hashable {
    public private(set) var type: AnswerTypeType = .array
    public let baseType: JsonType
    public let sequenceSeparator: String?
    public init(baseType: JsonType = .string, sequenceSeparator: String? = nil) {
        self.baseType = baseType
        self.sequenceSeparator = sequenceSeparator
    }
}

public struct AnswerTypeDateTime : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .string
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case type, _codingFormat = "codingFormat"
    }

    public private(set) var type: AnswerTypeType = .dateTime
    
    public var codingFormat: String {
        _codingFormat ?? rsd_ISO8601TimestampFormatter.dateFormat
    }
    private let _codingFormat: String?
    
    public init(codingFormat: String? = nil) {
        self._codingFormat = codingFormat
    }
}

public struct AnswerTypeMeasurement : RSDBaseAnswerType, Codable, Hashable {
    public static let defaultJsonType: JsonType = .number
    public private(set) var type: AnswerTypeType = .measurement
    public let unit: String?
    
    public init(unit: String? = nil) {
        self.unit = unit
    }
}

protocol AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)]
}

struct AnswerTypeExamples {
    
    static func examplesWithValues() -> [(AnswerType, JsonElement)] {
        documentableTypes.flatMap { $0.exampleTypeAndValues() }
    }
    
    static let documentableTypes: [AnswerTypeDocumentable.Type] = [
        AnswerTypeBoolean.self,
        AnswerTypeInteger.self,
        AnswerTypeNumber.self,
        AnswerTypeNull.self,
        AnswerTypeObject.self,
        AnswerTypeString.self,
        AnswerTypeArray.self,
        AnswerTypeDateTime.self,
        AnswerTypeMeasurement.self,
    ]
}

extension AnswerTypeObject : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeObject(), .object(["foo":"ba"]))]
    }
}

extension AnswerTypeString : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeString(), .string("foo"))]
    }
}

extension AnswerTypeBoolean : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeBoolean(), .boolean(true))]
    }
}

extension AnswerTypeInteger : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeInteger(), .integer(42))]
    }
}

extension AnswerTypeNumber : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeNumber(), .number(3.14))]
    }
}

extension AnswerTypeNull : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeNull(), .null)]
    }
}

extension AnswerTypeArray : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [
            (AnswerTypeArray(baseType: .number), .array([3.2, 5.1])),
            (AnswerTypeArray(baseType: .integer), .array([1, 5])),
            (AnswerTypeArray(baseType: .string), .array(["foo", "ba", "lalala"])),
        ]
    }
}

extension AnswerTypeDateTime : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [
            (AnswerTypeDateTime(codingFormat: "yyyy-MM"), .string("2020-04")),
            (AnswerTypeDateTime(codingFormat: "HH:mm"), .string("08:30")),
            (AnswerTypeDateTime(), .string("2017-10-16T22:28:09.000-07:00")),
        ]
    }
}

extension AnswerTypeMeasurement : AnswerTypeDocumentable {
    static func exampleTypeAndValues() -> [(AnswerType, JsonElement)] {
        [(AnswerTypeMeasurement(unit: "cm"), .number(4.2))]
    }
}

// MARK: Deprecated AnswerResultType conversion

protocol AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType?
}

extension AnswerTypeObject : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return .codable
    }
}

extension AnswerTypeString : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return .string
    }
}

extension AnswerTypeBoolean : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return .boolean
    }
}

extension AnswerTypeInteger : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return .integer
    }
}

extension AnswerTypeNumber : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return .decimal
    }
}

extension AnswerTypeNull : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        return nil
    }
}

extension AnswerTypeArray : AnswerResultTypeConvertible {
    func baseResultType() -> RSDAnswerResultType.BaseType {
        switch baseType {
        case .boolean:
            return .boolean
        case .integer:
            return .integer
        case .number:
            return .decimal
        case .object:
            return .codable
        default:
            return .string
        }
    }
    
    func answerResultType() -> RSDAnswerResultType? {
        return RSDAnswerResultType(baseType: baseResultType(), sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: sequenceSeparator)
    }
}

extension AnswerTypeDateTime : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: codingFormat)
    }
}

extension AnswerTypeMeasurement : AnswerResultTypeConvertible {
    func answerResultType() -> RSDAnswerResultType? {
        RSDAnswerResultType(baseType: .decimal, sequenceType: nil, formDataType: nil, dateFormat: nil, unit: unit, sequenceSeparator: nil)
    }
}
