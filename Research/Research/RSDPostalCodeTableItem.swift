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
    public let characterCount = 3
    
    /// A list of known sparsely populated postal codes.
    ///
    /// Currently, the list of postal codes inclues the codes from the US 2010 census and is *only*
    /// checked for US zipcodes.
    public let sparselyPopulatedCodes: [String : [String]] =
        ["US" : [036,059,102,203,205,369,556,692,821,823,878,879,884,893].map { "\($0)"}]
    
    /// The country code for the participant. By default, this will return the region code for the
    /// participant's locale or "US" if the region code is unknown.
    public var countryCode: String! {
        get { return _countryCode ?? "US" }
        set { _countryCode = newValue }
    }
    private var _countryCode: String? = Locale.current.regionCode
    
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
        return deidentifyCode(code)
    }
    
    func deidentifyCode(_ code: String) -> String {
        guard code.count >= characterCount else { return code }
        
        // Determine where to start replacing the characters with "*" characters.
        var start = code.index(code.startIndex, offsetBy: characterCount)
        var repeatCount = code.count - characterCount
        let subcode = String(code[..<start])
        if let codes = sparselyPopulatedCodes[countryCode], codes.contains(subcode) {
            start = code.startIndex
            repeatCount = code.count
        }
        
        // Replace from `start`.
        var value = code
        let replacement = String(repeating: "*", count: repeatCount)
        value.replaceSubrange(start..., with: replacement)
        
        return value
    }
}
