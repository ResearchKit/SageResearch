//
//  RSDInputField.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDInputField` is used to describe a form input and includes the data type and a possible hint to how
/// the UI should be displayed. The Research framework uses `RSDFormUIStep` to represent questions to
/// ask the user. Each question must have at least one associated input field. An input field is validated
/// when its owning step is validated.
///
/// - seealso: `RSDFormUIStep`
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public protocol RSDInputField {
    
    /// A short string that uniquely identifies the input field within the step. The identifier is
    /// reproduced in the results of a step result in the step history of a task result.
    var identifier: String { get }
    
    /// A localized string that displays a short text offering a hint to the user of the data to be entered
    /// for this field.
    var inputPrompt: String? { get }
    
    /// Additional detail about this input field.
    var inputPromptDetail: String? { get }
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    var isOptional: Bool { get }
    
    /// The data type for this input field. The data type can have an associated ui hint.
    var dataType: RSDFormDataType { get }
    
    /// A UI hint for how the study would prefer that the input field is displayed to the user.
    var inputUIHint: RSDFormUIHint? { get }
    
    /// Validate the input field to check for any configuration that should throw an error.
    func validate() throws
    
    /// MARK: Extended protocol for an input field that can be used to enter input using a text field.
    
    /// A localized string that displays placeholder information for the input field.
    ///
    /// You can display placeholder text in a text field or text area to help users understand how to answer
    /// the item's question.
    var placeholder: String? { get }
    
    /// Options for displaying a text field. This is only applicable for certain types of UI hints and data
    /// types. If not applicable, it will be ignored.
    var textFieldOptions: RSDTextFieldOptions? { get }
    
    /// A range used by dates and numbers for setting up a picker wheel, slider, or providing text field
    /// input validation. If not applicable, it will be ignored.
    var range: RSDRange? { get }
    
    /// A formatter that is appropriate to the data type. If `nil`, the format will be determined by the UI.
    /// This is the formatter used to display a previously entered answer to the user or to convert an
    /// answer entered in a text field into the appropriate value type.
    ///
    /// - seealso: `RSDAnswerResultType.BaseType` and `RSDFormStepDataSource`
    var formatter: Formatter? { get }
    
    /// Optional picker source for a picker or multiple selection input field.
    var pickerSource: RSDPickerDataSource? { get }
}

/// `RSDPopoverInputField` wraps the input field in a form step. This allows the data source used to display
/// the input field to show a form step in a modal view controller.
@available(*, deprecated)
public protocol RSDPopoverInputField : RSDInputField, RSDFormUIStep {
}

/// `RSDDetailInputField` is an input field that can be presented as a step using the given transition style.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public protocol RSDDetailInputField : RSDInputField, RSDUIStep {
    
    /// The transition style for showing the detail input.
    var transitionStyle: RSDTransitionStyle? { get }
}

/// Extend the input field to a mutable type.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public protocol RSDMutableInputField : class, RSDInputField {
    
    /// Extend to allow setting.
    var inputPrompt: String? { get set }
    
    /// Extend to allow setting.
    var inputPromptDetail: String? { get set }
    
    /// Extend to allow setting.
    var placeholder: String? { get set }
}

/// Extend the input field to allow copying the field with a new identifier.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public protocol RSDCopyInputField : RSDInputField {
    
    /// Return a copy of the input field with a new identifier.
    func copy(with identifier: String) -> Self
}
