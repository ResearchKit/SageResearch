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
    static public let dateTime: AnswerTypeType = "dateTime"
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

public struct AnswerTypeObject : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .object
    public private(set) var type: AnswerTypeType = .object
    public init() {
    }
}

public struct AnswerTypeString : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .string
    public private(set) var type: AnswerTypeType = .string
    public init() {
    }
}

public struct AnswerTypeBoolean : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .boolean
    public private(set) var type: AnswerTypeType = .boolean
    public init() {
    }
}

public struct AnswerTypeInteger : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .integer
    public private(set) var type: AnswerTypeType = .integer
    public init() {
    }
}

public struct AnswerTypeNumber : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .number
    public private(set) var type: AnswerTypeType = .number
    public init() {
    }
}

public struct AnswerTypeNull : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .null
    public private(set) var type: AnswerTypeType = .null
    public init() {
    }
}

public struct AnswerTypeArray : AnswerType, Codable {
    public private(set) var type: AnswerTypeType = .array
    public let baseType: JsonType
    public let sequenceSeparator: String?
    public init(baseType: JsonType = .string, sequenceSeparator: String? = nil) {
        self.baseType = baseType
        self.sequenceSeparator = sequenceSeparator
    }
}

public struct AnswerTypeDateTime : RSDBaseAnswerType, Codable {
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

public struct AnswerTypeMeasurement : RSDBaseAnswerType, Codable {
    public static let defaultJsonType: JsonType = .number
    public private(set) var type: AnswerTypeType = .measurement
    public let unit: String?
    
    public init(unit: String? = nil) {
        self.unit = unit
    }
}

