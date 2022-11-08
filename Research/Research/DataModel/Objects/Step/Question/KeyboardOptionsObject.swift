//
//  KeyboardOptionsObject.swift
//  Research
//

import Foundation
import JsonModel

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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
