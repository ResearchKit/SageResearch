//
//  RSDInputField.swift
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

/**
 `RSDInputField` is used to describe a form input and includes the data type and a possible hint to how the UI should be displayed.
 */
public protocol RSDInputField {
    
    /**
     A short string that uniquely identifies the form item within the step. The identifier is reproduced in the results of a step result in the step history of a task result.
     */
    var identifier: String { get }
    
    /**
     A localized string that displays a short text offering a hint to the user of the data to be entered for this field.
     */
    var prompt: String? { get }
    
    /**
     A localized string that displays placeholder information for the input field.
     
     You can display placeholder text in a text field or text area to help users understand how to answer the item's question.
     */
    var placeholderText: String? { get }
    
    /**
     A Boolean value indicating whether the user can skip the input field without providing an answer.
     */
    var optional: Bool { get }
    
    /**
     The data type for this input field. The data type can have an associated ui hint.
     */
    var dataType: RSDFormDataType { get }
    
    /**
     A UI hint for how the study would prefer that the input field is displayed to the user.
     */
    var uiHint: RSDFormUIHint? { get }
    
    /**
     Validate the input field to check for any configuration that should throw an error.
     */
    func validate() throws
    
    /**
     Validation run on the result.
     */
    func validateResult(_ result: RSDAnswerResult) throws -> Bool
}

/**
 `RSDTextFieldOptions` extends the properties of an `RSDFieldInput` for a text field data type.
 */
public protocol RSDTextFieldOptions : RSDInputField {
    
    /**
     The regex used to validate user's input. If set to nil, no validation will be performed.
     Dictionary key = "validationRegex"
     
     @note If the "validationRegex" is defined, then the `invalidMessage` should also be defined.
     */
    var validationRegex: String? { get }
    
    /**
     The text presented to the user when invalid input is received.
     */
    var invalidMessage: String? { get }
    
    /**
     The maximum length of the text users can enter. When the value of this property is 0, there is no maximum.
     */
    var maximumLength: Int { get }
    
    /**
     Auto-capitalization type for the text field.
     */
    var autocapitalizationType: UITextAutocapitalizationType { get }
    
    /**
     Keyboard type for the text field.
     */
    var keyboardType: UIKeyboardType { get }
}

/**
 `RSDDateRange` extends the properties of an `RSDFieldInput` for an timestamp or date data type.
 */
public protocol RSDDateRange : RSDInputField {
    
    /**
     The minimum allowed date. When the value of this property is `nil`, there is no minimum.
     */
    var minimum: Date? { get }
    
    /**
     The maximum allowed date. When the value of this property is `nil`, there is no maximum.
     */
    var maximum: Date? { get }
    
    /**
     Whether or not the UI date picker should allow future dates.
     */
    var allowsFuture: Bool { get }
}

/**
 `RSDIntegerRange` extends the properties of an `RSDFieldInput` for an integer data type.
 */
public protocol RSDIntegerRange : RSDInputField {
    
    /**
     The minimum allowed number. When the value of this property is `nil`, there is no minimum.
     */
    var minimum: Int? { get }
    
    /**
     The maximum allowed number. When the value of this property is `nil`, there is no maximum.
     */
    var maximum: Int? { get }
    
    /**
     A unit label associated with this property.
     */
    var unitLabel: String? { get }
    
    /**
     A step interval to be used for a slider or picker.
     */
    var stepInterval: Int { get }
}

/**
 `RSDDecimalRange` extends the properties of an `RSDFieldInput` for a decimal or time interval data type.
 */
public protocol RSDDecimalRange : RSDInputField {
    
    /**
     The minimum allowed number. When the value of this property is `nil`, there is no minimum.
     */
    var minimum: Double? { get }
    
    /**
     The maximum allowed number. When the value of this property is `nil`, there is no maximum.
     */
    var maximum: Double? { get }
    
    /**
     A unit label associated with this property. This property is currently not supported for
     `ORKContinuousScaleAnswerFormat` or `ORKScaleAnswerFormat`.
     */
    var unitLabel: String? { get }
    
    /**
     A step interval to be used for a slider or picker.
     */
    var stepInterval: Double { get }
}
