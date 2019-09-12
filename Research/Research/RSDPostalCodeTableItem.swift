//
//  RSDPostalCodeTableItem.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

open class RSDPostalCodeTableItem : RSDTextInputTableItem {
    
    /// The number of characters after which to replace the rest with "*" characters.
    let characterCount = 3
    
    public init(rowIndex: Int, inputField: RSDInputField) {
        
        // If the text field options are not defined then set them
        let textFieldOptions = inputField.textFieldOptions ??
            RSDTextFieldOptionsObject(keyboardType: .asciiCapable,
                                      autocapitalizationType: .allCharacters,
                                      isSecureTextEntry: false,
                                      maximumLength: 0,
                                      spellCheckingType: .no,
                                      autocorrectionType: .no)

        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: .textfield, answerType: .string, textFieldOptions: textFieldOptions, formatter: nil, pickerSource: nil, placeholder: nil)
    }

    /// Override to replace the characters after the first 3 with "*".
    open override func convertAnswer(_ newValue: Any) throws -> Any? {
        guard let code = try super.convertAnswer(newValue) as? String else { return nil }
        guard code.count > characterCount else { return code }
        
        var value = code
        let start = value.index(value.startIndex, offsetBy: characterCount)
        let replacement = String(repeating: "*", count: value.count - characterCount)
        value.replaceSubrange(start..., with: replacement)

        return value
    }
}
