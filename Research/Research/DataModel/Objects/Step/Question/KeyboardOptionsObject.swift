//
//  KeyboardOptionsObject.swift
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
import JsonModel

public struct KeyboardOptionsObject : KeyboardOptions, Codable, Equatable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case _isSecureTextEntry = "isSecureTextEntry"
        case _autocapitalizationType = "autocapitalizationType"
        case _autocorrectionType = "autocorrectionType"
        case _spellCheckingType = "spellCheckingType"
        case _keyboardType = "keyboardType"
    }
    
    public var isSecureTextEntry: Bool { _isSecureTextEntry ?? false }
    private var _isSecureTextEntry: Bool?
    
    public var autocapitalizationType: RSDTextAutocapitalizationType { _autocapitalizationType ?? .none }
    private var _autocapitalizationType: RSDTextAutocapitalizationType?
    
    public var autocorrectionType: RSDTextAutocorrectionType { _autocorrectionType ?? .no }
    private var _autocorrectionType: RSDTextAutocorrectionType?
    
    public var spellCheckingType: RSDTextSpellCheckingType { _spellCheckingType ?? .no }
    private var _spellCheckingType: RSDTextSpellCheckingType?
    
    public var keyboardType: RSDKeyboardType { _keyboardType ?? .default }
    private var _keyboardType: RSDKeyboardType?
    
    public init(isSecureTextEntry: Bool? = nil,
                autocapitalizationType: RSDTextAutocapitalizationType? = nil,
                autocorrectionType: RSDTextAutocorrectionType? = nil,
                spellCheckingType: RSDTextSpellCheckingType? = nil,
                keyboardType: RSDKeyboardType? = nil) {
        _isSecureTextEntry = isSecureTextEntry
        _autocapitalizationType = autocapitalizationType
        _autocorrectionType = autocorrectionType
        _spellCheckingType = spellCheckingType
        _keyboardType = keyboardType
    }
    
    public static let integerEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                  autocapitalizationType: RSDTextAutocapitalizationType.none,
                                                                 autocorrectionType: .no,
                                                                 spellCheckingType: .no,
                                                                 keyboardType: .numberPad)

    public static let decimalEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                  autocapitalizationType: RSDTextAutocapitalizationType.none,
                                                                  autocorrectionType: .no,
                                                                  spellCheckingType: .no,
                                                                  keyboardType: .decimalPad)
    
    public static let dateTimeEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                   autocapitalizationType: RSDTextAutocapitalizationType.none,
                                                                   autocorrectionType: .no,
                                                                   spellCheckingType: .no,
                                                                   keyboardType: .numbersAndPunctuation)
    
    public static let measurementEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                   autocapitalizationType: RSDTextAutocapitalizationType.none,
                                                                   autocorrectionType: .no,
                                                                   spellCheckingType: .no,
                                                                   keyboardType: .numbersAndPunctuation)
}

extension KeyboardOptionsObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case ._isSecureTextEntry:
            return .init(defaultValue: .boolean(false))
        case ._autocapitalizationType:
            return .init(propertyType: .reference(RSDTextAutocapitalizationType.documentableType()))
        case ._autocorrectionType:
            return .init(propertyType: .reference(RSDTextAutocorrectionType.documentableType()))
        case ._spellCheckingType:
            return .init(propertyType: .reference(RSDTextSpellCheckingType.documentableType()))
        case ._keyboardType:
            return .init(propertyType: .reference(RSDKeyboardType.documentableType()))
        }
    }
    
    public static func examples() -> [KeyboardOptionsObject] {
        [KeyboardOptionsObject(), .decimalEntryOptions]
    }
}
