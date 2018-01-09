//
//  RSDChoicePickerTableItemGroup.swift
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


/// `RSDChoicePickerTableItemGroup` subclasses `RSDInputFieldTableItemGroup` to implement a single or multiple choice
/// question where the choices are presented as a list.
open class RSDChoicePickerTableItemGroup : RSDInputFieldTableItemGroup {
    
    /// Does the item group allow for multiple choices or is it single selection?
    public let singleSelection: Bool
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    ///     - choicePicker: The choice picker data source.
    ///     - answerType: The answer type.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, choicePicker: RSDChoicePickerDataSource, answerType: RSDAnswerResultType? = nil) {
        
        // Set the items
        var items: [RSDTableItem]?
        var singleSelection: Bool = true
        if inputField.dataType.listSelectionHints.contains(uiHint),
            let choicePicker = choicePicker as? RSDChoiceOptions {
            if case .collection(let collectionType, _) = inputField.dataType, collectionType == .multipleChoice {
                singleSelection = false
            }
            items = choicePicker.choices.enumerated().map { (index, choice) -> RSDTableItem in
                RSDChoiceTableItem(rowIndex: beginningRowIndex + index, inputField: inputField, uiHint: uiHint, choice: choice)
            }
        }
        self.singleSelection = singleSelection
        
        // Setup the answer type if nil
        let aType: RSDAnswerResultType = answerType ?? {
            let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
            let sequenceType: RSDAnswerResultType.SequenceType? = singleSelection ? nil : .array
            let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
            let unit: String? = (inputField.range as? RSDNumberRange)?.unit
            return RSDAnswerResultType(baseType: baseType, sequenceType: sequenceType, formDataType:inputField.dataType, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: nil)
            }()
        
        // If this is being used as a picker source, then setup the picker
        if items == nil {
            items = [RSDTextInputTableItem(rowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: aType)]
        }
        
        super.init(beginningRowIndex: beginningRowIndex, items: items!, inputField: inputField, uiHint: uiHint, answerType: aType)
    }
    
    // Override to set the selected items from the result.
    override open func setAnswer(from result: RSDResult) throws {
        try super.setAnswer(from: result)
        
        // Set all the previously selected items as selected
        guard let selectableItems = self.items as? [RSDChoiceTableItem] else { return }
        for input in selectableItems {
            input.selected = input.choice.isEqualToResult(result)
        }
    }
    
    /// Select or de-select an item (answer) at a specific indexPath. This is used for text choice and boolean answers.
    /// - parameters:
    ///     - selected:   A `Bool` indicating if the item should be selected.
    ///     - indexPath:  The IndexPath of the item.
    open func select(_ item: RSDChoiceTableItem, indexPath: IndexPath) throws {
        guard let selectableItems = self.items as? [RSDChoiceTableItem] else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: nil, answerResult: answerType, debugDescription: "This input field does not support selection.")
            throw RSDInputFieldError.invalidType(context)
        }
        
        // To get the index of our item, add our `beginningRowIndex` to `indexPath.row`.
        let deselectOthers = singleSelection || item.choice.isExclusive
        let index =  indexPath.row - beginningRowIndex
        let selected = !item.selected
        
        // If we selected an item and this is a single-selection group, then we iterate
        // our other items and de-select them.
        var answers: [Any] = []
        for (ii, input) in selectableItems.enumerated() {
            if deselectOthers || (ii == index) || input.choice.isExclusive || (input.choice.value == nil) {
                input.selected = (ii == index) && selected
            }
            if input.selected, let value = input.choice.value {
                answers.append(value)
            }
        }
        
        // Set the answer array
        if singleSelection {
            try setAnswer(answers.first)
        } else {
            try setAnswer(answers)
        }
    }
}

/// An item group for entering a boolean data type.
final class RSDBooleanTableItemGroup : RSDChoicePickerTableItemGroup {
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The first row of the item group.
    ///     - inputField: The input field associated with this item group.
    ///     - uiHint: The UI hint.
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        let choicePicker: RSDChoicePickerDataSource
        if let picker = inputField as? RSDChoicePickerDataSource {
            choicePicker = picker
        } else {
            let choiceYes = try! RSDChoiceObject<Bool>(value: true, text: Localization.buttonYes(), iconName: nil, detail: nil, isExclusive: true)
            let choiceNo = try! RSDChoiceObject<Bool>(value: false, text: Localization.buttonNo(), iconName: nil, detail: nil, isExclusive: true)
            choicePicker = RSDChoiceOptionsObject(choices: [choiceYes, choiceNo], isOptional: inputField.isOptional)
        }
        let answerType = RSDAnswerResultType(baseType: .boolean, sequenceType: nil, formDataType: inputField.dataType)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, choicePicker: choicePicker, answerType: answerType)
    }
}
