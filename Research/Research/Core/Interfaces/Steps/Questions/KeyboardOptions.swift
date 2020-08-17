//
//  KeyboardOptions.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

/// A set of options for the keyboard to use for test entry.
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

extension RSDTextAutocapitalizationType : DocumentableStringEnum {
}


/// `Codable` enum for the auto-correction type for an input text field.
/// - keywords: ["default", "no", yes"]
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

extension RSDTextAutocorrectionType : DocumentableStringEnum {
}


/// `Codable` enum for the spell checking type for an input text field.
/// - keywords: ["default", "no", yes"]
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

extension RSDTextSpellCheckingType : DocumentableStringEnum {
}


/// `Codable` enum for the keyboard type for an input text field.
/// - keywords: [ "default", "asciiCapable", "numbersAndPunctuation", "URL",
///               "numberPad", "phonePad", "namePhonePad", "emailAddress",
///               "decimalPad", "twitter", "webSearch", "asciiCapableNumberPad"]
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

extension RSDKeyboardType : DocumentableStringEnum {
}
