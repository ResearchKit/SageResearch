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

    /// A text validator that can be used to validate a string.
    public var textValidator: RSDTextValidator?
    
    /// The text presented to the user when invalid input is received.
    public var invalidMessage: String?
    
    /// The maximum length of the text users can enter. When the value of this property is 0, there
    /// is no maximum.
    public var maximumLength: Int = 0
    
    /// Auto-capitalization type for the text field.
    public var autocapitalizationType: UITextAutocapitalizationType = .none

    /// Auto-correction type for the text field.
    public var autocorrectionType: UITextAutocorrectionType = .no
    
    /// Spell checking type for the text field.
    public var spellCheckingType: UITextSpellCheckingType = .no
    
    /// Keyboard type for the text field.
    public var keyboardType: UIKeyboardType = .default
    
    /// Is the text field for password entry?
    public var isSecureTextEntry: Bool = false
    
    private enum CodingKeys : String, CodingKey {
        case textValidator, invalidMessage, maximumLength, isSecureTextEntry, autocapitalizationType, autocorrectionType, spellCheckingType, keyboardType
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
        self.maximumLength = maximumLength
        self.autocapitalizationType = autocapitalizationType
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        self.spellCheckingType = spellCheckingType
        self.autocorrectionType = autocorrectionType
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.invalidMessage = try container.decodeIfPresent(String.self, forKey: .invalidMessage)
        self.maximumLength = try container.decodeIfPresent(Int.self, forKey: .maximumLength) ?? 0
        self.autocapitalizationType = try container.decodeIfPresent(UITextAutocapitalizationType.self, forKey: .autocapitalizationType) ?? .none
        self.keyboardType = try container.decodeIfPresent(UIKeyboardType.self, forKey: .keyboardType) ?? .default
        self.isSecureTextEntry = try container.decodeIfPresent(Bool.self, forKey: .isSecureTextEntry) ?? false
        self.spellCheckingType = try container.decodeIfPresent(UITextSpellCheckingType.self, forKey: .spellCheckingType) ?? .no
        self.autocorrectionType = try container.decodeIfPresent(UITextAutocorrectionType.self, forKey: .autocorrectionType) ?? .no
        if container.contains(.textValidator) {
            let nestedDecoder = try container.superDecoder(forKey: .textValidator)
            self.textValidator = try decoder.factory.decodeTextValidator(from: nestedDecoder)
        }
    }
    
    /// Encode the result to the given encoder. This will encode the text options as a dictionary.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(invalidMessage, forKey: .invalidMessage)
        try container.encode(maximumLength, forKey: .maximumLength)
        try container.encode(autocapitalizationType, forKey: .autocapitalizationType)
        try container.encode(keyboardType, forKey: .keyboardType)
        try container.encode(isSecureTextEntry, forKey: .isSecureTextEntry)
        try container.encode(spellCheckingType, forKey: .spellCheckingType)
        try container.encode(autocorrectionType, forKey: .autocorrectionType)
        if let obj = self.textValidator {
            let nestedEncoder = container.superEncoder(forKey: .textValidator)
            guard let encodable = obj as? Encodable else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedEncoder.codingPath, debugDescription: "The reg ex validator does not conform to the Encodable protocol"))
            }
            try encodable.encode(to: nestedEncoder)
        }
    }
}

extension RSDTextFieldOptionsObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.textValidator, .invalidMessage, .maximumLength, .isSecureTextEntry, .autocapitalizationType, .autocorrectionType, .spellCheckingType, .keyboardType]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .textValidator:
                if idx != 0 { return false }
            case .invalidMessage:
                if idx != 1 { return false }
            case .maximumLength:
                if idx != 2 { return false }
            case .isSecureTextEntry:
                if idx != 3 { return false }
            case .autocapitalizationType:
                if idx != 4 { return false }
            case .autocorrectionType:
                if idx != 5 { return false }
            case .spellCheckingType:
                if idx != 6 { return false }
            case .keyboardType:
                if idx != 7 { return false }
            }
        }
        return keys.count == 8
    }
    
    static func examples() -> [Encodable] {
        let exampleA = RSDTextFieldOptionsObject(keyboardType: .asciiCapable, autocapitalizationType: .allCharacters, isSecureTextEntry: true, maximumLength: 16, spellCheckingType: .no, autocorrectionType: .no)
        var exampleB = RSDTextFieldOptionsObject(keyboardType: .numberPad)
        exampleB.textValidator = try! RSDRegExValidatorObject(regExPattern: "^[0-9]*$")
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

