//
//  InputItemTableItem.swift
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

public protocol InputItemState : class {
    var identifier: String { get }
    var rowIndex: Int { get }
    var inputItem: InputItem { get }
    var currentAnswer: JsonElement? { get set }
    var storedAnswer: JsonElement? { get }
    var selected: Bool { get set }
}

open class AbstractInputItemTableItem : RSDTableItem {
    public let inputItem: InputItem
    
    public init(questionIdentifier: String, rowIndex: Int, inputItem: InputItem, supportedHints: Set<RSDFormUIHint>?) {
        self.inputItem = inputItem
        let identifier = (rowIndex == 0) ? questionIdentifier : "\(questionIdentifier).\(rowIndex)"
        let hint = inputItem.inputUIHint.bestHint(from: supportedHints)
        super.init(identifier: identifier, rowIndex: rowIndex, reuseIdentifier: hint.rawValue)
    }
}

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
