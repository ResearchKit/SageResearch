//
//  InputItemTableItem.swift
//  Research
//

import Foundation
import JsonModel

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol InputItemState : AnyObject {
    var identifier: String { get }
    var rowIndex: Int { get }
    var inputItem: InputItem { get }
    var currentAnswer: JsonElement? { get set }
    var storedAnswer: JsonElement? { get }
    var selected: Bool { get set }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
open class AbstractInputItemTableItem : RSDTableItem {
    public let inputItem: InputItem
    
    public init(questionIdentifier: String, rowIndex: Int, inputItem: InputItem, supportedHints: Set<RSDFormUIHint>?) {
        self.inputItem = inputItem
        let identifier = (rowIndex == 0) ? questionIdentifier : "\(questionIdentifier).\(rowIndex)"
        let hint = inputItem.inputUIHint.bestHint(from: supportedHints)
        super.init(identifier: identifier, rowIndex: rowIndex, reuseIdentifier: hint.rawValue)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
open class ChoiceInputItemTableItem : AbstractInputItemTableItem, InputItemState, ChoiceInputItemState {

    public var selected: Bool
    
    public var storedAnswer: JsonElement? { nil }
    
    public var currentAnswer: JsonElement? {
        get {
            choiceItem.jsonElement(selected: self.selected)
        }
        set(newValue) {
            self.selected = (newValue == choiceItem.jsonElement(selected: true))
        }
    }
    
    public var choiceItem: ChoiceInputItem {
        inputItem as! ChoiceInputItem
    }
    
    public var choice: RSDChoice { choiceItem }
    
    public init(questionIdentifier: String, rowIndex: Int, choiceItem: ChoiceInputItem, initialAnswer: JsonElement?, supportedHints: Set<RSDFormUIHint>?) {

        self.selected = initialAnswer.map { jsonValue in
            if case .array(let arr) = jsonValue {
                if let selectedValue = choiceItem.jsonElement(selected: true), selectedValue != .null {
                    return (arr as NSArray).contains(selectedValue.jsonObject())
                }
                else {
                    return arr.count == 0
                }
            }
            else {
                return jsonValue == choiceItem.jsonElement(selected: true)
            }
        } ?? false

        super.init(questionIdentifier: questionIdentifier, rowIndex: rowIndex, inputItem: choiceItem, supportedHints: supportedHints)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
open class TextInputItemTableItem : AbstractInputItemTableItem, InputItemState, TextInputItemState {
    public private(set) var storedAnswer: JsonElement?
    public var selected: Bool
    public let textValidator: TextInputValidator
    public let pickerSource: RSDPickerDataSource?
    
    public var textItem: KeyboardTextInputItem {
        inputItem as! KeyboardTextInputItem
    }
    
    public init(questionIdentifier: String,
                rowIndex: Int,
                textItem: KeyboardTextInputItem,
                initialAnswer: JsonElement?,
                supportedHints: Set<RSDFormUIHint>?) {
        let storedAnswer = (initialAnswer != .null) ? initialAnswer : nil
        self.storedAnswer = storedAnswer
        self.selected = (storedAnswer != nil)
        self.textValidator = textItem.buildTextValidator()
        self.pickerSource = textItem.buildPickerSource()
        super.init(questionIdentifier: questionIdentifier, rowIndex: rowIndex, inputItem: textItem, supportedHints: supportedHints)
    }
    
    public var currentAnswer: JsonElement? {
        get { selected ? (storedAnswer ?? .null) : nil }
        set(newValue) {
            storedAnswer = newValue
            selected = (newValue != nil)
        }
    }
    
    public var placeholder: String? {
        textItem.placeholder
    }
    
    public var uiHint: RSDFormUIHint {
        textItem.inputUIHint
    }
    
    public var answerText: String? {
        self.answerText(for: currentAnswer)
    }
    
    public var answer: Any? {
        currentAnswer.map { $0 == .null ? nil : $0 } ?? nil
    }
    
    public var keyboardOptions: KeyboardOptions {
        textItem.keyboardOptions
    }
    
    public var inputPrompt: String? {
        textItem.fieldLabel
    }
    
    public func answerText(for answer: Any?) -> String? {
        pickerSource.map { $0.textAnswer(from: answer) ?? "" } ?? textValidator.answerText(for: answer)
    }
}
