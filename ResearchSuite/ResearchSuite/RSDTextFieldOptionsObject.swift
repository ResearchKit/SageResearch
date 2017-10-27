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


public struct RSDTextFieldOptionsObject : RSDTextFieldOptions, Codable {

    public var validationRegex: String?
    public var invalidMessage: String?
    
    public var validationRegularExpression: NSRegularExpression? {
        return nil  // This struct does not support custom regex
    }
    
    private let _maximumLength: Int?
    public var maximumLength: Int {
        return _maximumLength ?? 0
    }
    
    private let _autocapitalizationType: UITextAutocapitalizationType?
    public var autocapitalizationType: UITextAutocapitalizationType {
        return _autocapitalizationType ?? .none
    }
    
    public let _autocorrectionType: UITextAutocorrectionType?
    public var autocorrectionType: UITextAutocorrectionType {
        return _autocorrectionType ?? .no
    }
    
    public let _spellCheckingType: UITextSpellCheckingType?
    public var spellCheckingType: UITextSpellCheckingType {
        return _spellCheckingType ?? .no
    }
    
    private let _keyboardType: UIKeyboardType?
    public var keyboardType: UIKeyboardType {
        return _keyboardType ?? .default
    }
    
    private let _isSecureTextEntry: Bool?
    public var isSecureTextEntry: Bool {
        return _isSecureTextEntry ?? false
    }
    
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
    
    public init(keyboardType: UIKeyboardType = .default, autocapitalizationType: UITextAutocapitalizationType = .none, isSecureTextEntry: Bool = false, maximumLength: Int = 0, spellCheckingType: UITextSpellCheckingType = .no, autocorrectionType: UITextAutocorrectionType = .no) {
        self._maximumLength = maximumLength
        self._autocapitalizationType = autocapitalizationType
        self._keyboardType = keyboardType
        self._isSecureTextEntry = isSecureTextEntry
        self._spellCheckingType = spellCheckingType
        self._autocorrectionType = autocorrectionType
    }
}

fileprivate let _RSDTextAutocapitalizationType : [String] = [   "none",
                                                                "words",
                                                                "sentences",
                                                                "allCharacters"]

extension UITextAutocapitalizationType {
    
    /**
     Initializer that uses an `identifier` string.
     
     @param identifier    The identifier to convert
     @return              An `UITextAutocapitalizationType`. Default = `.none`
     */
    public init(identifier: String) {
        guard let idx = _RSDTextAutocapitalizationType.index(of: identifier),
            let type = UITextAutocapitalizationType(rawValue: Int(idx))
            else {
                self = .none
                return
        }
        self = type
    }
    
    /**
     String identifier for this enum value.
     */
    public var identifier: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextAutocapitalizationType.count else {
            return _RSDTextAutocapitalizationType[0]
        }
        return _RSDTextAutocapitalizationType[idx]
    }
}

extension UITextAutocapitalizationType : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(identifier: identifier)
    }
}

extension UITextAutocapitalizationType : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.identifier)
    }
}

fileprivate let _RSDTextAutocorrectionType : [String] = [   "default",
                                                                "no",
                                                                "yes"]

extension UITextAutocorrectionType {
    
    /**
     Initializer that uses an `identifier` string.
     
     @param identifier    The identifier to convert
     @return              An `UITextAutocapitalizationType`. Default = `.none`
     */
    public init(identifier: String) {
        guard let idx = _RSDTextAutocorrectionType.index(of: identifier),
            let type = UITextAutocorrectionType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /**
     String identifier for this enum value.
     */
    public var identifier: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextAutocorrectionType.count else {
            return _RSDTextAutocorrectionType[0]
        }
        return _RSDTextAutocorrectionType[idx]
    }
}

extension UITextAutocorrectionType : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(identifier: identifier)
    }
}

extension UITextAutocorrectionType : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.identifier)
    }
}

fileprivate let _RSDTextSpellCheckingType : [String] = [   "default",
                                                            "no",
                                                            "yes"]

extension UITextSpellCheckingType {
    
    /**
     Initializer that uses an `identifier` string.
     
     @param identifier    The identifier to convert
     @return              An `UITextAutocapitalizationType`. Default = `.none`
     */
    public init(identifier: String) {
        guard let idx = _RSDTextSpellCheckingType.index(of: identifier),
            let type = UITextSpellCheckingType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /**
     String identifier for this enum value.
     */
    public var identifier: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDTextSpellCheckingType.count else {
            return _RSDTextSpellCheckingType[0]
        }
        return _RSDTextSpellCheckingType[idx]
    }
}

extension UITextSpellCheckingType : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(identifier: identifier)
    }
}

extension UITextSpellCheckingType : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.identifier)
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

extension UIKeyboardType {
    
    /**
     Initializer that uses an `identifier` string.
     
     @param identifier    The identifier to convert
     @return              An `UIKeyboardType`. Default = `.default`
     */
    public init(identifier: String) {
        guard let idx = _RSDKeyboardType.index(of: identifier),
            let type = UIKeyboardType(rawValue: Int(idx))
            else {
                self = .default
                return
        }
        self = type
    }
    
    /**
     String identifier for this enum value.
     */
    public var identifier: String {
        let idx = self.rawValue
        guard idx >= 0 && idx < _RSDKeyboardType.count else {
            return _RSDKeyboardType[0]
        }
        return _RSDKeyboardType[idx]
    }
}

extension UIKeyboardType : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.init(identifier: identifier)
    }
}

extension UIKeyboardType : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.identifier)
    }
}

