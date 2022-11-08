//
//  QuestionTableItemGroup.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Will be deleted in a future version.")
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
