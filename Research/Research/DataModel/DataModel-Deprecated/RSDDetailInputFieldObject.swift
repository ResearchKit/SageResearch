//
//  RSDDetailInputFieldObject.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
open class RSDDetailInputFieldObject : RSDFormUIStepObject, RSDDetailInputField {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case transitionStyle
        case inputPrompt = "prompt"
        case inputPromptDetail = "promptDetail"
        case placeholder
        case inputUIHint = "uiHint"
    }
    
    /// The transition style for showing the detail editing view.
    open var transitionStyle: RSDTransitionStyle?
    
    /// The prompt to display for the detail. This is the element displayed in the parent view controller
    /// as button text or above the cell if using a placeholder/formatter style of UI/UX.
    open var inputPrompt: String?
    
    /// The prompt detail is additional text displayed in the parent view controller.
    open var inputPromptDetail: String?
    
    /// The placeholder text to display for a `nil` input field (before the detail has been added).
    open var placeholder: String?
    
    /// The UI hint for displaying the cell (button, link, discloserArrow, etc.).
    open var inputUIHint: RSDFormUIHint?
    
    /// Override to allow decoding of subclass variables.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transitionStyle = try container.decodeIfPresent(RSDTransitionStyle.self, forKey: .transitionStyle) ?? self.transitionStyle
        self.inputPrompt = try container.decodeIfPresent(String.self, forKey: .inputPrompt) ?? self.inputPrompt
        self.inputPromptDetail = try container.decodeIfPresent(String.self, forKey: .inputPromptDetail) ?? self.inputPromptDetail
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? self.placeholder
        self.inputUIHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .inputUIHint) ?? self.inputUIHint
    }
    
    
    // MARK: Wrapper for `RSDInputField`
    
    /// Whether or not the detail is optional is determined by whether or not all the input fields are
    /// optional.
    open var isOptional: Bool {
        return self.inputFields.reduce(true, { $0 && $1.isOptional })
    }
    
    /// Returns the data type from the first input field (if only one) or `.detail(.codable)` if more than one
    /// input field.
    open var dataType: RSDFormDataType {
        if self.inputFields.count == 1 {
            return self.inputFields.first!.dataType
        }
        else {
            return .detail(.codable)
        }
    }
    
    /// Returns the test options from the first input field (if only one) or `nil` if more than one field.
    open var textFieldOptions: RSDTextFieldOptions? {
        if self.inputFields.count == 1 {
            return self.inputFields.first!.textFieldOptions
        }
        else {
            return nil
        }
    }
    
    /// Returns the range from the first input field (if only one) or `nil` if more than one field.
    open var range: RSDRange? {
        if self.inputFields.count == 1 {
            return self.inputFields.first!.range
        }
        else {
            return nil
        }
    }
    
    /// Returns the formatter from the first input field (if only one) or `nil` if more than one field.
    open var formatter: Formatter? {
        if self.inputFields.count == 1 {
            return self.inputFields.first!.formatter
        }
        else {
            return nil
        }
    }
    
    /// Returns the picker source from the first input field (if only one) or `nil` if more than one field.
    open var pickerSource: RSDPickerDataSource? {
        if self.inputFields.count == 1 {
            return self.inputFields.first!.pickerSource
        }
        else {
            return nil
        }
    }
}
