//
//  RSDTextFieldOptionsObject.swift
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

/// `RSDTextFieldOptionsObject` defines the options for a text field.
///
/// - seealso: `RSDInputField` and `RSDFormStepDataSource`
public struct RSDTextFieldOptionsObject : RSDTextFieldOptions, Codable {

    /// The regex used to validate user's input. If set to nil, no validation will be performed.
    ///
    /// - note: If the "validationRegex" is defined, then the `invalidMessage` should also be defined.
    public var validationRegex: String?
    
    /// The localizaed text presented to the user when invalid input is received.
    public var invalidMessage: String?
    
    /// This struct does not support custom regex
    public var validationRegularExpression: NSRegularExpression? {
        return nil
    }
    
    /// The maximum length of the text users can enter. When the value of this property is 0, there
    /// is no maximum.
    public var maximumLength: Int {
        return _maximumLength ?? 0
    }
    private let _maximumLength: Int?
    
    /// Auto-capitalization type for the text field.
    public var autocapitalizationType: UITextAutocapitalizationType {
        return _autocapitalizationType ?? .none
    }
    private let _autocapitalizationType: UITextAutocapitalizationType?

    /// Auto-correction type for the text field.
    public var autocorrectionType: UITextAutocorrectionType {
        return _autocorrectionType ?? .no
    }
    public let _autocorrectionType: UITextAutocorrectionType?
    
    /// Spell checking type for the text field.
    public var spellCheckingType: UITextSpellCheckingType {
        return _spellCheckingType ?? .no
    }
    public let _spellCheckingType: UITextSpellCheckingType?
    
    /// Keyboard type for the text field.
    public var keyboardType: UIKeyboardType {
        return _keyboardType ?? .default
    }
    private let _keyboardType: UIKeyboardType?
    
    /// Is the text field for password entry?
    public var isSecureTextEntry: Bool {
        return _isSecureTextEntry ?? false
    }
    private let _isSecureTextEntry: Bool?
    
    private enum CodingKeys : String, CodingKey {
        case validationRegex
        case invalidMessage
        case _maximumLength = "maximumLength"
        case _autocapitalizationType = "autocapitalizationType"
        case _keyboardType = "keyboardType"
        case _isSecureTextEntry = "isSecureTextEntry"
        case _autocorrectionType = "autocorrectionType"
        case _spellCheckingType = "spellCheckingType"
    }
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - keyboardType: Keyboard type for the text field.
    ///     - autocapitalizationType: Auto-capitalization type for the text field.
    ///     - isSecureTextEntry: Is the text field for password entry?
    ///     - spellCheckingType: Spell checking type for the text field.
    ///     - autocorrectionType: Auto-correction type for the text field.
    public init(keyboardType: UIKeyboardType = .default, autocapitalizationType: UITextAutocapitalizationType = .none, isSecureTextEntry: Bool = false, maximumLength: Int = 0, spellCheckingType: UITextSpellCheckingType = .no, autocorrectionType: UITextAutocorrectionType = .no) {
        self._maximumLength = maximumLength
        self._autocapitalizationType = autocapitalizationType
        self._keyboardType = keyboardType
        self._isSecureTextEntry = isSecureTextEntry
        self._spellCheckingType = spellCheckingType
        self._autocorrectionType = autocorrectionType
    }
}

extension RSDTextFieldOptionsObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.validationRegex, .invalidMessage, ._maximumLength, ._autocapitalizationType, ._keyboardType, ._autocorrectionType, ._spellCheckingType, ._isSecureTextEntry]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .validationRegex:
                if idx != 0 { return false }
            case .invalidMessage:
                if idx != 1 { return false }
            case ._maximumLength:
                if idx != 2 { return false }
            case ._autocapitalizationType:
                if idx != 3 { return false }
            case ._keyboardType:
                if idx != 4 { return false }
            case ._autocorrectionType:
                if idx != 5 { return false }
            case ._spellCheckingType:
                if idx != 6 { return false }
            case ._isSecureTextEntry:
                if idx != 7 { return false }
            }
        }
        return keys.count == 8
    }
    
    static func examples() -> [Encodable] {
        let exampleA = RSDTextFieldOptionsObject(keyboardType: .asciiCapable, autocapitalizationType: .allCharacters, isSecureTextEntry: true, maximumLength: 16, spellCheckingType: .no, autocorrectionType: .no)
        var exampleB = RSDTextFieldOptionsObject(keyboardType: .numberPad)
        exampleB.validationRegex = "^[0-9]*$"
        exampleB.invalidMessage = "This input field only allows entering numbers."
        return [exampleA, exampleB]
    }
}

fileprivate let _RSDTextAutocapitalizationType : [String] = [   "none",
                                                                "words",
                                                                "sentences",
                                                                "allCharacters"]

extension UITextAutocapitalizationType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    /// Initializer that uses an `stringValue` string.
    ///
    /// - parameter stringLiteral: The stringValue to convert
    /// - returns: An `UITextAutocapitalizationType`. Default = `.none`
    public init(stringLiteral identifier: String) {
        guard let idx = _RSDTextAutocapitalizationType.index(of: identifier),
            let type = UITextAutocapitalizationType(rawValue: Int(idx))
            else {
                self = .none
                return
        }
        self = type
    }
    
    /// String value for this enum value.
    public var stringValue: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextAutocapitalizationType.count else {
            return _RSDTextAutocapitalizationType[0]
        }
        return _RSDTextAutocapitalizationType[idx]
    }
}

extension UITextAutocapitalizationType : Decodable {
    
    /// Initialize using a decoder.
    ///
    /// This method expects the `decoder` to contain either a single `String` value
    /// that maps to the `stringValue`.
    ///
    /// - parameter decoder: The decoder with the single value container.
    /// - throws: `DecodingError` if the container does not
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(stringLiteral: identifier)
    }
}

extension UITextAutocapitalizationType : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}

extension UITextAutocapitalizationType : RSDDocumentableEnum {
    static func allCodingKeys() -> [String] {
        return _RSDTextAutocapitalizationType
    }
}

fileprivate let _RSDTextAutocorrectionType : [String] = [   "default",
                                                                "no",
                                                                "yes"]

extension UITextAutocorrectionType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    /// Initializer that uses an `stringValue` string.
    ///
    /// - parameter stringLiteral: The stringValue to convert
    /// - returns: An `UITextAutocapitalizationType`. Default = `.none`
    public init(stringLiteral identifier: String) {
        guard let idx = _RSDTextAutocorrectionType.index(of: identifier),
            let type = UITextAutocorrectionType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /// String value for this enum value.
    public var stringValue: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextAutocorrectionType.count else {
            return _RSDTextAutocorrectionType[0]
        }
        return _RSDTextAutocorrectionType[idx]
    }
}

extension UITextAutocorrectionType : Decodable {
    
    /// Initialize using a decoder.
    ///
    /// This method expects the `decoder` to contain either a single `String` value
    /// that maps to the `stringValue`.
    ///
    /// - parameter decoder: The decoder with the single value container.
    /// - throws: `DecodingError` if the container does not
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(stringLiteral: identifier)
    }
}

extension UITextAutocorrectionType : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}

extension UITextAutocorrectionType : RSDDocumentableEnum {
    static func allCodingKeys() -> [String] {
        return _RSDTextAutocorrectionType
    }
}

fileprivate let _RSDTextSpellCheckingType : [String] = [   "default",
                                                            "no",
                                                            "yes"]

extension UITextSpellCheckingType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    /// Initializer that uses an `stringValue` string.
    ///
    /// - parameter stringLiteral: The stringValue to convert
    /// - returns: An `UITextAutocapitalizationType`. Default = `.none`
    public init(stringLiteral identifier: String) {
        guard let idx = _RSDTextSpellCheckingType.index(of: identifier),
            let type = UITextSpellCheckingType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /// String value for this enum value.
    public var stringValue: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextSpellCheckingType.count else {
            return _RSDTextSpellCheckingType[0]
        }
        return _RSDTextSpellCheckingType[idx]
    }
}

extension UITextSpellCheckingType : Decodable {
    
    /// Initialize using a decoder.
    ///
    /// This method expects the `decoder` to contain either a single `String` value
    /// that maps to the `stringValue`.
    ///
    /// - parameter decoder: The decoder with the single value container.
    /// - throws: `DecodingError` if the container does not
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(stringLiteral: identifier)
    }
}

extension UITextSpellCheckingType : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}

extension UITextSpellCheckingType : RSDDocumentableEnum {
    static func allCodingKeys() -> [String] {
        return _RSDTextSpellCheckingType
    }
}

fileprivate let _RSDKeyboardType : [String] = [ "default",
                                                "asciiCapable",
                                                "numbersAndPunctuation",
                                                "URL",
                                                "numberPad",
                                                "phonePad",
                                                "namePhonePad",
                                                "emailAddress",
                                                "decimalPad",
                                                "twitter",
                                                "webSearch",
                                                "asciiCapableNumberPad"]

extension UIKeyboardType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    /// Initializer that uses an `stringValue` string.
    ///
    /// - parameter stringLiteral: The stringValue to convert
    /// - returns: An `UIKeyboardType`. Default = `.default`
    public init(stringLiteral identifier: String) {
        guard let idx = _RSDKeyboardType.index(of: identifier),
            let type = UIKeyboardType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /// String value for this enum value.
    public var stringValue: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDKeyboardType.count else {
            return _RSDKeyboardType[0]
        }
        return _RSDKeyboardType[idx]
    }
}

extension UIKeyboardType : Decodable {
    
    /// Initialize using a decoder.
    ///
    /// This method expects the `decoder` to contain either a single `String` value
    /// that maps to the `stringValue`.
    ///
    /// - parameter decoder: The decoder with the single value container.
    /// - throws: `DecodingError` if the container does not
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(stringLiteral: identifier)
    }
}

extension UIKeyboardType : Encodable {
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}

extension UIKeyboardType : RSDDocumentableEnum {
    static func allCodingKeys() -> [String] {
        return _RSDKeyboardType
    }
}

