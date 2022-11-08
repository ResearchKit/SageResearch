//
//  KeyboardOptions.swift
//  Research
//

import Foundation
import JsonModel

/// A set of options for the keyboard to use for test entry.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol KeyboardOptions {
    
    /// Is the text field for password entry?
    var isSecureTextEntry: Bool { get }
    
    /// Auto-capitalization type for the text field.
    var autocapitalizationType: RSDTextAutocapitalizationType { get }
    
    /// Auto-correction type for the text field.
    var autocorrectionType: RSDTextAutocorrectionType { get }
    
    /// Spell checking type for the text field.
    var spellCheckingType: RSDTextSpellCheckingType { get }
    
    /// Keyboard type for the text field.
    var keyboardType: RSDKeyboardType { get }
}

/// `Codable` enum for the auto-capitalization type for an input text field.
/// - keywords: ["none", "words", "sentences", "allCharacters"]
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDTextAutocapitalizationType : String, Codable, StringEnumSet {
    case none, words, sentences, allCharacters
    
    public static var all: Set<RSDTextAutocapitalizationType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocapitalizationType] {
        return [.none, .words, .sentences, .allCharacters]
    }

    public func rawIntValue() -> Int? {
        return RSDTextAutocapitalizationType.orderedSet.firstIndex(of: self)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTextAutocapitalizationType : DocumentableStringEnum {
}


/// `Codable` enum for the auto-correction type for an input text field.
/// - keywords: ["default", "no", yes"]
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDTextAutocorrectionType : String, Codable, StringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextAutocorrectionType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextAutocorrectionType] {
        return [.default, .no, .yes]
    }
    
    public func rawIntValue() -> Int? {
        return RSDTextAutocorrectionType.orderedSet.firstIndex(of: self)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTextAutocorrectionType : DocumentableStringEnum {
}


/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: ["default", "no", yes"]
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDTextSpellCheckingType  : String, Codable, StringEnumSet {
    case `default`, no, yes
    
    public static var all: Set<RSDTextSpellCheckingType> {
        return Set(orderedSet)
    }
    
    static var orderedSet: [RSDTextSpellCheckingType] {
        return [.default, .no, .yes]
    }

    public func rawIntValue() -> Int? {
        return RSDTextSpellCheckingType.orderedSet.firstIndex(of: self)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTextSpellCheckingType : DocumentableStringEnum {
}


/// `Codable` enum for the keyboard type for an input text field.
/// - keywords: [ "default", "asciiCapable", "numbersAndPunctuation", "URL",
///               "numberPad", "phonePad", "namePhonePad", "emailAddress",
///               "decimalPad", "twitter", "webSearch", "asciiCapableNumberPad"]
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDKeyboardType  : String, Codable, StringEnumSet {
    case `default`, asciiCapable, numbersAndPunctuation, URL, numberPad, phonePad, namePhonePad, emailAddress, decimalPad, twitter, webSearch, asciiCapableNumberPad
    
    public static var all: Set<RSDKeyboardType> {
        return Set(orderedSet)
    }

    static var orderedSet: [RSDKeyboardType] {
        return [.default, .asciiCapable, .numbersAndPunctuation, .URL, .numberPad, .phonePad, .namePhonePad, .emailAddress, .decimalPad, .twitter, .webSearch, .asciiCapableNumberPad]
    }

    public func rawIntValue() -> Int? {
        return RSDKeyboardType.orderedSet.firstIndex(of: self)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDKeyboardType : DocumentableStringEnum {
}
