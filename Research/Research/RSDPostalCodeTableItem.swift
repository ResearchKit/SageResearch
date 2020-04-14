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

@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDPostalCodeTableItem : RSDTextInputTableItem {
    
    // TODO: syoung 10/07/2019 Replace this with a more clever form that asks for the user to
    // enter their country using the supported country codes or "Other" from the list and then
    // show/hide the postal code based on the answer to the region question.
    
    /// The country code for the participant. By default, this will return the region code for the
    /// participant's locale or "US" if the region code is unknown.
    public var countryCode: String! {
        get { return _countryCode ?? "US" }
        set { _countryCode = newValue }
    }
    private var _countryCode: String? = Locale.current.regionCode
    
    /// Postal range
    public var postalCodeRange: RSDPostalCodeRange! {
        get {
            if _postalCodeRange == nil {
                _postalCodeRange = InternalPostalCodeRange()
            }
            return _postalCodeRange!
        }
        set {
            _postalCodeRange = newValue
        }
    }
    private var _postalCodeRange: RSDPostalCodeRange?
    
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
        
        // Set the postal code range
        self.postalCodeRange = inputField.range as? RSDPostalCodeRange ?? InternalPostalCodeRange()
    }

    /// Override to replace the characters after the first 3 with "*".
    open override func convertAnswer(_ newValue: Any) throws -> Any? {
        guard let code = try super.convertAnswer(newValue) as? String else { return nil }
        return deidentifyCode(code)
    }
    
    func deidentifyCode(_ code: String) -> String {
        let range = self.postalCodeRange!
        // If the postal code is not a supported region then do not include the postal code.
        guard range.supportedRegions.contains(self.countryCode) else { return "" }
        
        let characterCount = range.savedCharacterCount(for: self.countryCode)
        guard code.count >= characterCount else { return code }
        
        // Determine where to start replacing the characters with "*" characters.
        var start = code.index(code.startIndex, offsetBy: characterCount)
        var repeatCount = code.count - characterCount
        let subcode = String(code[..<start])
        if let codes = range.sparselyPopulatedCodes(for: self.countryCode), codes.contains(subcode) {
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

/// Default postal code range.
struct InternalPostalCodeRange : RSDPostalCodeRange {
    
    private enum SupportedRegions: String, Codable, CaseIterable {
        case US, CA
    }
    
    var supportedRegions: [String] {
        return SupportedRegions.allCases.map { $0.rawValue }
    }
    
    func sparselyPopulatedCodes(for region: String) -> [String]? {
        guard let region = SupportedRegions(rawValue: region.uppercased()) else { return nil }
        switch region {
        case .US:
            return ["036","059","102","203","205","369","556","692","821","823","878","879","884","893"]
        default:
            return nil
        }
    }
    
    func savedCharacterCount(for region: String) -> Int {
        guard let region = SupportedRegions(rawValue: region.uppercased()) else { return 1 }
        switch region {
        case .US:
            return 3
        case .CA:
            return 1
        }
    }
    
    func maxCharacterCount(for region: String) -> Int? {
        guard let region = SupportedRegions(rawValue: region.uppercased()) else { return nil }
        switch region {
        case .US:
            return 5
        case .CA:
            return 6
        }
    }
}
