//
//  RSDTextFieldOptionsObject.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
    public var maximumLength: Int
    
    /// Auto-capitalization type for the text field.
    public var autocapitalizationType: RSDTextAutocapitalizationType

    /// Auto-correction type for the text field.
    public var autocorrectionType: RSDTextAutocorrectionType
    
    /// Spell checking type for the text field.
    public var spellCheckingType: RSDTextSpellCheckingType
    
    /// Keyboard type for the text field.
    public var keyboardType: RSDKeyboardType
    
    /// Is the text field for password entry?
    public var isSecureTextEntry: Bool
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
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
    public init(keyboardType: RSDKeyboardType = .default, autocapitalizationType: RSDTextAutocapitalizationType = .none, isSecureTextEntry: Bool = false, maximumLength: Int = 0, spellCheckingType: RSDTextSpellCheckingType = .no, autocorrectionType: RSDTextAutocorrectionType = .no) {
        self.maximumLength = maximumLength
        self.autocapitalizationType = autocapitalizationType
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        self.spellCheckingType = spellCheckingType
        self.autocorrectionType = autocorrectionType
    }
    
    /// Initialize from a `Decoder`. The decoder uses string value keywords for all the `Int` base enums defined by this
    /// struct where the keywords listed in the table below.
    ///
    /// | Property                 | Keywords                                                           |
    /// |--------------------------|:------------------------------------------------------------------:|
    /// | `keyboardType`           | [ "default", "asciiCapable", "numbersAndPunctuation", "URL",
    ///                                "numberPad", "phonePad", "namePhonePad", "emailAddress",
    ///                                "decimalPad", "twitter", "webSearch", "asciiCapableNumberPad"]   |
    /// | `autocapitalizationType` | ["none", "words", "sentences", "allCharacters"]                    |
    /// | `spellCheckingType`      | ["default", "no", "yes"]                                           |
    /// | `autocorrectionType`     | ["default", "no", "yes"]                                           |
    ///
    /// - example:
    ///
    ///     ```
    ///            let json = """
    ///                {
    ///                "textValidator" : "[A:C]",
    ///                "invalidMessage" : "You know me",
    ///                "maximumLength" : 10,
    ///                "autocapitalizationType" : "words",
    ///                "keyboardType" : "asciiCapable",
    ///                "isSecureTextEntry" : true
    ///                }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let defaultValues = RSDTextFieldOptionsObject()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.invalidMessage = try container.decodeIfPresent(String.self, forKey: .invalidMessage)
        self.maximumLength = try container.decodeIfPresent(Int.self, forKey: .maximumLength) ?? defaultValues.maximumLength
        self.autocapitalizationType = try container.decodeIfPresent(RSDTextAutocapitalizationType.self, forKey: .autocapitalizationType) ?? defaultValues.autocapitalizationType
        self.keyboardType = try container.decodeIfPresent(RSDKeyboardType.self, forKey: .keyboardType) ?? defaultValues.keyboardType
        self.isSecureTextEntry = try container.decodeIfPresent(Bool.self, forKey: .isSecureTextEntry) ?? false
        self.spellCheckingType = try container.decodeIfPresent(RSDTextSpellCheckingType.self, forKey: .spellCheckingType) ?? defaultValues.spellCheckingType
        self.autocorrectionType = try container.decodeIfPresent(RSDTextAutocorrectionType.self, forKey: .autocorrectionType) ?? defaultValues.autocorrectionType
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
        return CodingKeys.allCases
    }
    
    static func examples() -> [Encodable] {
        let exampleA = RSDTextFieldOptionsObject(keyboardType: .asciiCapable, autocapitalizationType: .allCharacters, isSecureTextEntry: true, maximumLength: 16, spellCheckingType: .no, autocorrectionType: .no)
        var exampleB = RSDTextFieldOptionsObject(keyboardType: .numberPad)
        exampleB.textValidator = try! RSDRegExValidatorObject(regExPattern: "^[0-9]*$")
        exampleB.invalidMessage = "This input field only allows entering numbers."
        return [exampleA, exampleB]
    }
}

/// `Codable` enum for the auto-capitalization type for an input text field.
/// - keywords: ["none", "words", "sentences", "allCharacters"]
public enum RSDTextAutocapitalizationType : String, Codable, RSDStringEnumSet {
    case none, words, sentences, allCharacters
    
    public static var all: Set<RSDTextAutocapitalizationType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocapitalizationType] {
        return [.none, .words, .sentences, .allCharacters]
    }

    /// Return the `UITextAutocapitalizationType` that maps to this enum.
    #if os(iOS) || os(tvOS)
    public func textAutocapitalizationType() -> UITextAutocapitalizationType {
        guard let idx = RSDTextAutocapitalizationType.orderedSet.index(of: self),
            let type = UITextAutocapitalizationType(rawValue: Int(idx))
            else {
                return .none
        }
        return type
    }
    #endif
}

extension RSDTextAutocapitalizationType : RSDDocumentableStringEnum {
}

/// `Codable` enum for the auto-capitalization type for an input text field.
/// - keywords: ["default", "no", yes"]
public enum RSDTextAutocorrectionType : String, Codable, RSDStringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextAutocorrectionType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocorrectionType] {
        return [.default, .no, .yes]
    }

    /// Return the `UITextAutocorrectionType` that maps to this enum.
    #if os(iOS) || os(tvOS)
    public func textAutocorrectionType() -> UITextAutocorrectionType {
        guard let idx = RSDTextAutocorrectionType.orderedSet.index(of: self),
            let type = UITextAutocorrectionType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
    #endif
}

extension RSDTextAutocorrectionType : RSDDocumentableStringEnum {
}

/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: ["default", "no", yes"]
public enum RSDTextSpellCheckingType  : String, Codable, RSDStringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextSpellCheckingType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextSpellCheckingType] {
        return [.default, .no, .yes]
    }

    /// Return the `UITextSpellCheckingType` that maps to this enum.
    #if os(iOS) || os(tvOS)
    public func textSpellCheckingType() -> UITextSpellCheckingType {
        guard let idx = RSDTextSpellCheckingType.orderedSet.index(of: self),
            let type = UITextSpellCheckingType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
    #endif
}

extension RSDTextSpellCheckingType : RSDDocumentableStringEnum {
}

/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: [ "default", "asciiCapable", "numbersAndPunctuation", "URL",
///               "numberPad", "phonePad", "namePhonePad", "emailAddress",
///               "decimalPad", "twitter", "webSearch", "asciiCapableNumberPad"]
public enum RSDKeyboardType  : String, Codable, RSDStringEnumSet {
    case `default`, asciiCapable, numbersAndPunctuation, URL, numberPad, phonePad, namePhonePad, emailAddress, decimalPad, twitter, webSearch, asciiCapableNumberPad
    
    public static var all: Set<RSDKeyboardType> {
        return Set(orderedSet)
    }

    static var orderedSet: [RSDKeyboardType] {
        return [.default, .asciiCapable, .numbersAndPunctuation, .URL, .numberPad, .phonePad, .namePhonePad, .emailAddress, .decimalPad, .twitter, .webSearch, .asciiCapableNumberPad]
    }

    /// Return the `UIKeyboardType` that maps to this enum.
    #if os(iOS) || os(tvOS)
    public func keyboardType() -> UIKeyboardType {
        guard let idx = RSDKeyboardType.orderedSet.index(of: self),
            let type = UIKeyboardType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
    #endif
}

extension RSDKeyboardType : RSDDocumentableStringEnum {
}
