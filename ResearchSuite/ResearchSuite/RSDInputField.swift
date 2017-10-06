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
     Options for displaying a text field. This is only applicable for certain types of UI hints and data types.
     */
    var textFieldOptions: RSDTextFieldOptions? { get }
    
    /**
     A range used by dates and numbers for setting up a picker wheel, slider or providing text field input validation.
     */
    var range: RSDRange? { get }
    
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
 `RSDChoice` is used to describe a choice item for use with a multiple choice or multiple component input field.
 */
public protocol RSDChoice : Codable {
    
    /**
     A JSON encodable object to return as the value when this choice is selected.
     */
    var value: Codable { get }
    
    /**
     Localized text string to display for the choice.
     */
    var text: String? { get }
    
    /**
     Additional detail text.
     */
    var detail: String? { get }
    
    /**
     For a multiple choice option, is this choice mutually exclusive? For example, "none of the above".
     */
    var isExclusive: Bool { get }
    
    /**
     Whether or not this choice has an image associated with it that should be returned by the fetch icon method.
     */
    var hasIcon: Bool { get }
    
    /**
     An icon image that can be used for displaying the choice.
     
     @param size        The size of the image to return.
     @param callback    The callback with the image, run on the main thread.
     */
    func fetchIcon(for size: CGSize, callback: @escaping ((UIImage?) -> Void))
}

/**
 `RSDChoiceOptions` extends the properties of an `RSDFieldInput` with information required to create a choice selection input field.
 */
public protocol RSDChoiceInputField : RSDInputField {
    
    /**
     A list of choices for input field.
     */
    var choices : [RSDChoice] { get }
    
    /**
     Does the choice selection allow entering a custom value
     */
    var allowOther : Bool { get }
}

/**
 `RSDMultipleComponentOptions` extends the properties of an `RSDFieldInput` with information required to create a multiple component input field.
 */
public protocol RSDMultipleComponentInputField : RSDInputField {
        
    /**
     A list of choices for input fields that make up the multiple component option set.
     */
    var choices : [[RSDChoice]] { get }
    
    /**
     If this is a multiple component input field, the UI can optionally define a separator.
     */
    var separator: String? { get }
}

public protocol RSDRange : Codable {
}

/**
 `RSDDateRange` extends the properties of an `RSDFieldInput` for a `date` data type.
 */
public protocol RSDDateRange : RSDRange {
    
    /**
     The minimum allowed date. When the value of this property is `nil`, there is no minimum.
     */
    var minDate: Date? { get }
    
    /**
     The maximum allowed date. When the value of this property is `nil`, there is no maximum.
     */
    var maxDate: Date? { get }
    
    /**
     Whether or not the UI should allow future dates. If `nil` or `minDate` is defined then this value is ignored.
     */
    var allowFuture: Bool? { get }
    
    /**
     Whether or not the UI should allow past dates. If `nil` or `maxDate` is defined then this value is ignored.
     */
    var allowPast: Bool? { get }
    
    /**
     Calendar components that are relevant for this input field.
     */
    var calendarComponents: Set<Calendar.Component> { get }
    
    /**
     The date encoder to use for formatting the result. If `nil` then the result, `minDate`, and `maxDate` are assumed to be used for time and date with the default encoding/decoding implementation.
     */
    var dateCoder: RSDDateCoder? { get }
}

extension RSDDateRange {
    
    /**
     The minimum allowed date. This is calculated by using either the `minDate` (if non-nil) or today's date if `allowPast` is non-nil and `false`.
     */
    public var minimumDate: Date? {
        return minDate ?? ((allowPast ?? true) ? nil : Date())
    }
    
    /**
     The maximum allowed date. This is calculated by using either the `maxDate` (if non-nil) or today's date if `allowFuture` is non-nil and `false`.
     */
    public var maximumDate: Date? {
        return maxDate ?? ((allowFuture ?? true) ? nil : Date())
    }
}

/**
 `RSDIntegerRange` extends the properties of an `RSDFieldInput` for a `integer` data type.
 */
public protocol RSDIntegerRange : RSDRange {
    
    /**
     The minimum allowed number. When the value of this property is `nil`, there is no minimum.
     */
    var minimumValue: Int? { get }
    
    /**
     The maximum allowed number. When the value of this property is `nil`, there is no maximum.
     */
    var maximumValue: Int? { get }
    
    /**
     A step interval to be used for a slider or picker.
     */
    var stepInterval: Int? { get }
    
    /**
     A unit label associated with this property.
     */
    var unit: String? { get }
}

/**
 `RSDDecimalRange` extends the properties of an `RSDFieldInput` for a `decimal` data type.
 */
public protocol RSDDecimalRange : RSDRange {
    
    /**
     The minimum allowed number. When the value of this property is `nil`, there is no minimum.
     */
    var minimumValue: Double? { get }
    
    /**
     The maximum allowed number. When the value of this property is `nil`, there is no maximum.
     */
    var maximumValue: Double? { get }
    
    /**
     A step interval to be used for a slider or picker.
     */
    var stepInterval: Double? { get }
    
    /**
     A unit label associated with this property.
     */
    var unit: String? { get }
    
    /**
     Optional number formatter to use for formatting the displayed value.
     */
    var numberFormatter: NumberFormatter? { get }
}

/**
 `RSDTextFieldOptions` defines the options for a text field ui hint.
 */
public protocol RSDTextFieldOptions : Codable {
    
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
    
    /**
     Is the text field for password entry?
     */
    var isSecureTextEntry: Bool { get }
}
