//
//  QuestionTableItemGroup.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

open class QuestionTableItemGroup : RSDTableItemGroup {
    
    public let question: Question
    
    public let answerResult: AnswerResult
    
    open override var isAnswerValid: Bool {
        return question.isOptional || (answerResult.jsonValue != nil)
    }
    
    public init(beginningRowIndex: Int,
                question: Question,
                supportedHints: Set<RSDFormUIHint>?,
                initialValue: JsonElement?) {
        self.question = question
        self.answerResult = question.instantiateAnswerResult()
        self.answerResult.jsonValue = initialValue
        let items: [RSDTableItem] = question.buildInputItems().enumerated().compactMap { (idx, inputItem) -> RSDTableItem? in
            
            let initialAnswer: JsonElement? = {
                guard let jsonValue = initialValue, jsonValue != .null else { return .null }
                if case .object(let dictionary) = jsonValue {
                    let identifier = inputItem.identifier ?? question.identifier
                    return (dictionary[identifier] as? JsonValue).map { JsonElement($0) }
                }
                else {
                    return jsonValue
                }
            }()

            if let textItem = inputItem as? KeyboardTextInputItem {
                return TextInputItemTableItem(questionIdentifier: question.identifier,
                                              rowIndex: idx + beginningRowIndex,
                                              textItem: textItem,
                                              initialAnswer: initialAnswer,
                                              supportedHints: supportedHints)
            }
            else if let choiceItem = inputItem as? ChoiceInputItem {
                return ChoiceInputItemTableItem(questionIdentifier: question.identifier,
                                                rowIndex: idx + beginningRowIndex,
                                                choiceItem: choiceItem,
                                                initialAnswer: initialAnswer,
                                                supportedHints: supportedHints)
            }
            else {
                debugPrint("WARNING!!! Failed to create a table item for \(inputItem)")
                return nil
            }
        }
        super.init(beginningRowIndex: beginningRowIndex, items: items)
    }
    
    open func toggleSelection(at index: Int) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard let selectableItems = self.items as? [InputItemState] else {
            throw RSDValidationError.invalidType("Could not cast \(items) to [InputItemState]")
        }
        guard index < selectableItems.count else {
            throw RSDValidationError.unexpectedNullObject("Index \(index) out of range.")
        }
        let item = selectableItems[index]
        
        // To get the index of our item, add our `beginningRowIndex` to `indexPath.item`.
        let selected = !item.selected
        let deselectOthers = question.isSingleAnswer || item.inputItem.isExclusive ||
                (selectableItems.first(where: { $0.inputItem.isExclusive && $0.selected }) != nil)
        let reselectOthers = item.inputItem.isExclusive && !selected
        
        // Iterate through the inputs and update the selection state.
        for (ii, input) in selectableItems.enumerated() {
            if deselectOthers || (ii == index) || input.inputItem.isExclusive {
                input.selected = (ii == index) && selected
            }
            if reselectOthers && !input.inputItem.isExclusive && (ii != index) && (input.storedAnswer != nil) {
                input.selected = true
            }
        }
        
        // Set the answer array
        try updateAnswer()
        
        return (selected, deselectOthers || reselectOthers)
    }
    
    open func saveAnswer(_ answer: Any, at index: Int) throws {
        if let textItem = self.items[index] as? TextInputItemTableItem {
            let answer = try textItem.textValidator.validateInput(answer: answer)
            textItem.currentAnswer = jsonElement(for: answer, at: index)
        }
        else if let choiceItem = self.items[index] as? ChoiceInputItemTableItem {
            choiceItem.currentAnswer = jsonElement(for: answer, at: index)
        }
        else {
            throw RSDValidationError.invalidType("Could not convert answer for \(self.items[index]). Unknown cast.")
        }
        try updateAnswer()
    }
    
    open func jsonElement(for answer: Any?, at index: Int) -> JsonElement {
        (answer as? JsonElement) ?? JsonElement(answer as? JsonValue)
    }
    
    public final func updateAnswer() throws {
        answerResult.jsonValue = try buildAnswer()
    }
    
    open func buildAnswer() throws -> JsonElement {
        guard let selectableItems = self.items as? [InputItemState] else {
            throw RSDValidationError.invalidType("Could not cast \(items) to [InputItemState]")
        }
        if question.answerType is AnswerTypeArray {
            let arr = selectableItems.compactMap { item in
                item.currentAnswer.map { $0.jsonType != .null ? $0.jsonObject() : nil } ?? nil
            }
            return .array(arr)
        }
        else if question.isSingleAnswer {
            return selectableItems.first(where: { $0.selected })?.currentAnswer ?? .null
        }
        else {
            let dictionary = selectableItems.reduce(into: [String : JsonSerializable]()) { (hashtable, item) in
                guard let answer = item.currentAnswer, answer != .null else { return }
                hashtable[item.inputItem.identifier ?? item.identifier] = answer.jsonObject()
            }
            return .object(dictionary)
        }
    }
}
