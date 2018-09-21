//
//  RSDPopoverInputFieldObject.swift
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

/// `RSDPopoverInputFieldObject` is a wrapper for a form step that allows it to conform to the input field
/// protocol. This is intended to allow a model that shows summary information about the input field in a
/// main view controller and using a modal presentation style to actually input the fields.
@available(*, deprecated)
open class RSDPopoverInputFieldObject : RSDFormUIStepObject, RSDPopoverInputField, RSDCopyInputField {
    
    /// A localized string that displays a short text offering a hint to the user of the data to be entered
    /// for this field. This is displayed at the parent level before showing the modal view controller that
    /// is used for inputing the answer.
    public var inputPrompt: String?
    
    /// Additional detail about this input field. This is displayed at the parent level before showing the
    /// modal view controller that is used for inputing the answer.
    public var inputPromptDetail: String?
    
    /// Placeholder text to display in the table cell or button that is displayed prior to entering an
    /// answer. This is displayed at the parent level before showing the modal view controller that is used
    /// for inputing the answer.
    public var placeholder: String?
    
    override open func validate() throws {
        try super.validate()
        if self.inputFields.count != 1 {
            throw RSDValidationError.invalidType("A popover input field only supports wrapping a single input field")
        }
    }
    
    // MARK: Wrapped input field properties.
    
    /// Returns the wrapped input field `isOptional`.
    open var isOptional: Bool {
        return self.inputFields.first!.isOptional
    }
    
    /// Returns the wrapped input field `dataType`.
    open var dataType: RSDFormDataType {
        return self.inputFields.first!.dataType
    }
    
    /// Returns `.popover`.
    open var inputUIHint: RSDFormUIHint? {
        return .popover
    }
    
    /// Returns `nil`.
    open var textFieldOptions: RSDTextFieldOptions? {
        return nil
    }
    
    /// Returns `nil`.
    open var range: RSDRange? {
        return nil
    }
    
    /// Returns the wrapped input field `formatter`.
    public var formatter: Formatter? {
        return self.inputFields.first!.formatter
    }
    
    /// Returns `nil`.
    public var pickerSource: RSDPickerDataSource? {
        return nil
    }
    
    public init(inputField: RSDInputField) {
        super.init(identifier: inputField.identifier, inputFields: [inputField])
        _movePrompts()
    }
    
    public required init(identifier: String, type: RSDStepType?) {
        super.init(identifier: identifier, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        _movePrompts()
    }
    
    private func _movePrompts() {
        // Copy the prompts and placeholder to this level.
        guard let inputField = self.inputFields.first else { return }
        self.inputPrompt = inputField.inputPrompt
        self.inputPromptDetail = inputField.inputPromptDetail
        self.placeholder = inputField.placeholder
        // If the field is a mutable class then set the prompts at that level to nil.
        guard let mutableField = inputField as? RSDMutableInputField else { return }
        mutableField.inputPrompt = nil
        mutableField.inputPromptDetail = nil
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case prompt, promptDetail, placeholder
    }
    
    open override func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDPopoverInputFieldObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.inputPrompt = self.inputPrompt
        subclassCopy.inputPromptDetail = self.inputPromptDetail
        subclassCopy.placeholder = self.placeholder
    }
}
