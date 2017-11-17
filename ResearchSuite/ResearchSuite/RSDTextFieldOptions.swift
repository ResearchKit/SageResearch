//
//  RSDTextFieldOptions.swift
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

/// `RSDTextFieldOptions` defines the options for a text field.
///
/// - seealso: `RSDInputField` and `RSDFormStepDataSource`
public protocol RSDTextFieldOptions {
    
    /// The regex used to validate user's input. If set to nil, no validation will be performed.
    ///
    /// - note: If the "validationRegex" is defined, then the `invalidMessage` should also be defined.
    var validationRegex: String? { get }
    
    /// A localized custom regular expression that can be used to validate a string. If this is `nil`,
    /// then the regular expression with be created from the `validationRegex`.
    ///
    /// - note: If the "validationRegex" is defined, then the `invalidMessage` should also be defined.
    var validationRegularExpression: NSRegularExpression? { get }
    
    /// The text presented to the user when invalid input is received.
    var invalidMessage: String? { get }
    
    /// The maximum length of the text users can enter. When the value of this property is 0, there
    /// is no maximum.
    var maximumLength: Int { get }
    
    /// Auto-capitalization type for the text field.
    var autocapitalizationType: UITextAutocapitalizationType { get }
    
    /// Auto-correction type for the text field.
    var autocorrectionType: UITextAutocorrectionType { get }
    
    /// Spell checking type for the text field.
    var spellCheckingType: UITextSpellCheckingType { get }
    
    /// Keyboard type for the text field.
    var keyboardType: UIKeyboardType { get }
    
    /// Is the text field for password entry?
    var isSecureTextEntry: Bool { get }
}

extension RSDTextFieldOptions {
    
    /// Method for evaluating a string against the `validationRegex` for a match.
    /// - paramater string: The string to evaluate.
    /// - returns: The number of matches found.
    public func regExMatches(_ string: String) throws -> Int? {
        guard let expression = try _regEx() else { return nil }
        return expression.numberOfMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
    }
    
    private func _regEx() throws -> NSRegularExpression? {
        if let regEx = validationRegularExpression {
            return regEx
        } else if let pattern = self.validationRegex {
            return try NSRegularExpression(pattern: pattern, options: [])
        } else {
            return nil
        }
    }
}
