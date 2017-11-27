//
//  RSDFormStepDataSourceObject.swift
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

open class RSDFormStepDataSourceObject : RSDFormStepDataSource {
    
    public let step: RSDStep
    public let supportedHints: Set<RSDFormUIHint>
    public private(set) var taskPath: RSDTaskPath
    open private(set) var sections: [RSDTableSection]
    open private(set) var initialResults: [String : RSDResult]

    open var delegate: RSDFormStepDataSourceDelegate?
    
    /**
     Initialize a new RSDFormStepDataSourceObject.
     
     @param  step       The RSDStep for this data source.
     @param  taskPath   The current task path for this data source.
     */
    public init(step: RSDStep, taskPath: RSDTaskPath, supportedHints: Set<RSDFormUIHint>? = nil, sections: [RSDTableSection]? = nil, initialResults: [String : RSDResult]? = nil) {
        
        self.step = step
        self.taskPath = taskPath
        self.supportedHints = supportedHints ?? RSDFormUIHint.allStandardHints
        self.sections = sections ?? []
        self.initialResults = initialResults ?? [:]
        
        // If the sections and/or initial results are undefined then set them
        if sections == nil {
            populateSections()
        }
        if initialResults == nil {
            populateInitialResults()
        }
    }
    
    open func collectionResult() -> RSDCollectionResult {
        if let collectionResult = taskPath.result.stepHistory.rsd_last(where: { $0.identifier == step.identifier }) as? RSDCollectionResult {
            return collectionResult
        }
        else {
            return RSDCollectionResultObject(identifier: step.identifier)
        }
    }
    
    open func instantiateAnswerResult(for itemGroup: RSDInputFieldTableItemGroup) -> RSDAnswerResult? {
        var answerResult = RSDAnswerResultObject(identifier: itemGroup.identifier, answerType: itemGroup.answerType)
        answerResult.value = itemGroup.answer
        return answerResult
    }
    
    /**
     What is the preferred ui hint for this input field that is supported by this table? By default, this will look for the uiHint from the inputField to be included in the supported hints and if not, will return the preferred ui hint for the data type.
     
     @param inputField  The inputField to check.
     @return            The ui hint to return.
     */
    open func preferredUIHint(for inputField: RSDInputField) -> RSDFormUIHint {
        if let uiHint = inputField.uiHint, supportedHints.contains(uiHint) {
            return uiHint
        }
        let standardType: RSDFormUIHint?
        if let choiceInput = inputField as? RSDChoiceInputField, choiceInput.hasImages {
            standardType = supportedHints.contains(.slider) ? .slider : nil
        } else {
            standardType = inputField.dataType.validStandardUIHints.first(where:{ supportedHints.contains($0) })
        }
        return standardType ?? .textfield
    }
    
    /**
     Does this ui hint require an exclusive section? This sets up a section with one and only one ItemGroup for certain ui hints.
     @param uiHint      The ui hint to test.
     @return            `true` if the ui hint type requires it's own table section.
     */
    open func requiresExclusiveSection(for itemGroup: RSDTableItemGroup) -> Bool {
        guard let input = itemGroup as? RSDInputFieldTableItemGroup else { return true }
        let inputField = input.inputField
        let uiHint = input.uiHint
        if inputField.dataType.listSelectionHints.contains(uiHint) {
            return true
        }
        switch uiHint {
        case .picker, .textfield, .toggle, .checkbox, .radioButton:
            return false
        default:
            return true
        }
    }
    
    open func instantiateTableItemGroup(for inputField: RSDInputField, beginningRowIndex: Int) -> RSDTableItemGroup {
        let uiHint = preferredUIHint(for: inputField)
        
        if case .measurement(_,_) = inputField.dataType {
            return RSDMeasurementTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
        }
        else if let choiceInput = inputField as? RSDChoiceInputField {
            return RSDChoicePickerTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, choicePicker: choiceInput)
        }
        else if let componentInput = inputField as? RSDMultipleComponentInputField {
            return RSDMultipleComponentTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: componentInput, uiHint: uiHint)
        } else {
            switch inputField.dataType.baseType {
            case .boolean:
                return RSDBooleanTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .string:
                return RSDTextFieldTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .date:
                return RSDDateTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .decimal, .integer, .year:
                return RSDNumberTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            }
        }
    }
    
    /**
     Convenience method for looking at the previous results in the task path and setting the answer based on that result.
     @return    A dictionary of results mapped to the result identifier.
     */
    private func populateInitialResults() {
        guard let previousResult = self.taskPath.previousResults?.rsd_last(where: { $0.identifier == self.step.identifier }) else {
            return
        }
        let results: [RSDResult] = (previousResult as? RSDCollectionResult)?.inputResults ?? [previousResult]
        for result in results {
            if let itemGroup = itemGroup(with: result.identifier) as? RSDInputFieldTableItemGroup,
                let answerResult = result as? RSDAnswerResult,
                answerResult.answerType == itemGroup.answerType {
                
                do {
                    try itemGroup.setAnswer(answerResult.value)
                    initialResults[result.identifier] = result
                } catch {
                    // ignore error but do not save the result
                }
            }
        }
    }
    
    /**
     Convenience method for building the sections of the table from the input fields.
     @return    The sections for the table.
     */
    private func populateSections() {
        guard let uiStep = step as? RSDUIStep else { return }

        for item in inputFields() {
            
            // Get the next row index
            let rowIndex: Int = {
                if let lastSection = sections.last, !lastSection.singleFormItem {
                    return lastSection.rowCount()
                } else {
                    return 0
                }
            }()
            
            // Call open method to get the appropriate item group
            let itemGroup = instantiateTableItemGroup(for: item, beginningRowIndex: rowIndex)
            let needExclusiveSection = requiresExclusiveSection(for: itemGroup)

            // if we don't need an exclusive section and we have an existing section and it's not exclusive ('singleFormItem'),
            // then add this item to that existing section, otherwise create a new one
            if !needExclusiveSection, let lastSection = sections.last, !lastSection.singleFormItem {
                lastSection.title = nil
                lastSection.add(itemGroup: itemGroup)
            }
            else {
                let section = RSDTableSection(sectionIndex: sections.count, singleFormItem: needExclusiveSection)
                section.add(itemGroup: itemGroup)
                section.title = item.prompt
                sections.append(section)
            }
        }
        
        // add image below and footnote
        var items: [RSDTableItem] = []
        if let imageTheme = (uiStep as? RSDThemedUIStep)?.imageTheme, imageTheme.placementType == .iconAfter {
            items.append(RSDImageTableItem(rowIndex: items.count, imageTheme: imageTheme))
        }
        if let footnote = uiStep.footnote {
            items.append(RSDTextTableItem(rowIndex: items.count, text: footnote))
        }
        if items.count > 0 {
            let itemGroup = RSDTableItemGroup(items: items, beginningRowIndex: 0)
            let section = RSDTableSection(sectionIndex: sections.count, itemGroups: [itemGroup])
            sections.append(section)
        }
    }
    
    /**
     Convenience method for returning the input fields.
     @return    The input fields for the form step.
     */
    private func inputFields() -> [RSDInputField] {
        guard let formStep = self.step as? RSDFormUIStep else { return [] }
        return formStep.inputFields
    }
}


/**
 Defines a section in a table. A table is made up of sections, groups and items. For most group types, there is one cell per group. The exception would be where the ui hint is for a list where each value is displayed in a selectable list.
 */
public final class RSDTableSection {
    
    /**
     The list of items included in this section.
     */
    public private(set) var itemGroups: [RSDTableItemGroup] = []
    
    /**
     The table section index.
     */
    public let index: Int
    
    /**
     Indicates whether this section is exclusive to a single form item or can contain multiple form items.
     */
    fileprivate let singleFormItem: Bool

    /**
     The title for this section.
     */
    public var title: String?
    
    /**
     Returns the total count of all Items in this section.
     @return    The total number of RSDGenericStepTableItems in this section
     */
    public func rowCount() -> Int {
        return itemGroups.reduce(0, {$0 + $1.items.count})
    }
    
    public init(sectionIndex: Int, itemGroups: [RSDTableItemGroup]) {
        self.index = sectionIndex
        self.singleFormItem = (itemGroups.count == 1)
        self.itemGroups = itemGroups
    }
    
    fileprivate init(sectionIndex: Int, singleFormItem: Bool = true) {
        self.index = sectionIndex
        self.singleFormItem = singleFormItem
    }
    
    fileprivate func add(itemGroup: RSDTableItemGroup) {
        itemGroups.append(itemGroup)
    }
}


// MARK: RSDTableItemGroup

/**
 `RSDTableItemGroup` is a generic table item group object that can be used to display information in a tableview that does not have an associated input field.
 */
open class RSDTableItemGroup {
    
    /**
     The list of items (or rows) included in this group. A table group can be used to represent one or more rows.
     */
    public let items: [RSDTableItem]
    
    /**
     The row index for the first row in the group.
     */
    public let beginningRowIndex: Int
    
    /**
     A unique identifier that can be used to track the group.
     */
    public let uuid = UUID()
    
    /**
     Determine if the current answer is valid. Also checks the case where answer is required but one has not been provided.
     @return    A Bool indicating if answer is valid
     */
    public var isAnswerValid: Bool {
        return true
    }
    
    public init(items: [RSDTableItem], beginningRowIndex: Int) {
        self.items = items
        self.beginningRowIndex = beginningRowIndex
    }
}

/**
 `RSDInputFieldTableItemGroup` is used to represent a single input field.
 */
open class RSDInputFieldTableItemGroup : RSDTableItemGroup {
    
    public let inputField: RSDInputField
    public let uiHint: RSDFormUIHint
    public let answerType: RSDAnswerResultType
    public let defaultAnswer: Any
    public let textFieldOptions: RSDTextFieldOptions?
    
    open fileprivate(set) var numberRange: RSDNumberRange?
    open private(set) var formatter: Formatter?
    open private(set) var pickerSource: RSDPickerDataSource?
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, answerType: RSDAnswerResultType, defaultAnswer: Any? = nil, textFieldOptions: RSDTextFieldOptions? = nil, items: [RSDTableItem]? = nil, formatter: Formatter? = nil, pickerSource: RSDPickerDataSource? = nil) {
        self.inputField = inputField
        self.uiHint = uiHint
        self.answerType = answerType
        self.pickerSource = pickerSource
        self.formatter = formatter
        self.defaultAnswer = defaultAnswer ?? NSNull()
        
        // Set the text field options
        self.textFieldOptions = textFieldOptions ?? inputField.textFieldOptions ?? {
            switch answerType.baseType {
            case .decimal:
                return RSDTextFieldOptionsObject(keyboardType: .decimalPad)
            case .integer, .timeInterval:
                return RSDTextFieldOptionsObject(keyboardType: .numberPad)
            case .date, .string:
                return RSDTextFieldOptionsObject(keyboardType: .default)
            case .boolean, .data:
                return nil
            }
        }()
        
        super.init(items: items ?? [RSDInputFieldTableItem(rowIndex: beginningRowIndex, inputField: inputField)], beginningRowIndex: beginningRowIndex)
    }

    /**
     Convenience property for accessing the identifier associated with the item group.
     */
    public var identifier: String {
        return inputField.identifier
    }
    
    /**
     Save an answer for this ItemGroup. This is used only for those questions that have single answers,
     such as text and numeric answers, as opposed to booleans or text choice answers.
     */
    public var answer: Any {
        return _answer ?? defaultAnswer
    }
    fileprivate var _answer: Any?
    
    /**
     The text string to display as the answer.
     */
    public var answerText: String? {
        return (_answer as? String) ?? formatter?.string(for: _answer)
    }
    
    /**
     Set the new answer value. This will throw an error if the value isn't valid. Otherwise, it will set the answer.
     @param newValue    The new value for the answer.
     @return            `true` if the answer was changed, otherwise false.
     */
    public func setAnswer(_ newValue: Any?) throws {
        _answer = try validatedAnswer(newValue)
    }
    
    /**
     Determine if the current answer is valid. Also checks the case where answer is required but one has not been provided.
     @return    A Bool indicating if answer is valid
     */
    open override var isAnswerValid: Bool {
        // if answer is NOT optional and it equals Null, then it's invalid
        return inputField.isOptional || !(answer is NSNull)
    }
    
    /**
     Convert the input answer into a validated answer of a supported type, or throw an error if it fails validation.
     
     @param newValue    The new value for the answer.
     
     @return            The converted answer.
     */
    open func validatedAnswer(_ newValue: Any?) throws -> Any? {
        guard let newAnswer = newValue, !(newAnswer is NSNull) else {
            return nil
        }
        let answer = try convertAnswer(newAnswer)
        
        // Look for a range on the new value if it was converted from a text field
        if let _ = newValue as? String, (answer != nil) {
            switch answerType.baseType {
            case .integer, .decimal, .timeInterval:
                if let number = (answer as? NSNumber) ?? (answer as? RSDJSONNumber)?.jsonNumber(), let range = numberRange {
                    let decimal = number.decimalValue
                    if let min = range.minimumValue, decimal < min {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.lessThanMinimumValue(min, context)
                    }
                    if let max = range.maximumValue, decimal > max {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.greaterThanMaximumValue(max, context)
                    }
                }
                
            case .date:
                if let date = answer as? Date, let range = inputField.range as? RSDDateRange {
                    if let minDate = range.minimumDate, date < minDate {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.lessThanMinimumDate(minDate, context)
                    }
                    if let maxDate = range.maximumDate, date > maxDate {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Value entered is outside allowed range.")
                        throw RSDInputFieldError.greaterThanMaximumDate(maxDate, context)
                    }
                }
                
            case .string:
                if let string = answer as? String {
                    if let validator = self.textFieldOptions?.textValidator, let isValid = try? validator.isValid(string), !isValid {
                        let debugDescription = self.textFieldOptions?.invalidMessage ?? "Invalid regex"
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: debugDescription)
                        throw RSDInputFieldError.invalidRegex(self.textFieldOptions?.invalidMessage, context)
                    }
                    else if let maxLen = self.textFieldOptions?.maximumLength, string.count > maxLen {
                        let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Exceeds max length of \(maxLen)")
                        throw RSDInputFieldError.exceedsMaxLength(maxLen, context)
                    }
                }
                
            default:
                break
            }
        }
        
        return answer
    }
    
    /**
     Convert the input answer into a validated answer of a supported type, or throw an error if it fails validation.
     
     @param newValue    The new value for the answer.
     
     @return            The converted answer.
     */
    open func convertAnswer(_ newValue: Any) throws -> Any? {
        var answer = newValue
        
        // First check if this is an array and if so, if it needs to have the first value pulled from it.
        if let array = answer as? [Any] {
            if answerType.sequenceType == .array {
                return array
            } else if array.count == 0 {
                return nil
            } else if array.count == 1 {
                answer = array.first!
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Array Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        
        if answerType.baseType == .string {
            return (answer as? String) ?? formatter?.string(for: answer) ?? "\(answer)"
        }
        else if let string = answer as? String {
            if let formatter = self.formatter {
                var obj: AnyObject?
                var err: NSString?
                formatter.getObjectValue(&obj, for: string, errorDescription: &err)
                if err != nil {
                    let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: (err as String!))
                    throw RSDInputFieldError.invalidFormatter(formatter, context)
                } else {
                    return obj
                }
            } else if answerType.baseType == .boolean {
                return NSNumber(value: (string as NSString).boolValue)
            } else if answerType.baseType == .integer {
                return NSNumber(value: (string as NSString).integerValue)
            } else if answerType.baseType == .decimal || answerType.baseType == .timeInterval {
                return NSNumber(value: (string as NSString).doubleValue)
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "String Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let date = answer as? Date {
            if answerType.baseType == .date {
                return date
            } else {
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Date Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        }
        else if let num = (answer as? NSNumber) ?? (answer as? RSDJSONNumber)?.jsonNumber()  {
            switch answerType.baseType  {
            case .boolean:
                return num.boolValue
            case .integer, .decimal, .timeInterval:
                return num
            default:
                let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "Number Type \(answer) is not supported for \(inputField.identifier)")
                throw RSDInputFieldError.invalidType(context)
            }
        } else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: answer, answerResult: answerType, debugDescription: "\(answer) is not supported for \(inputField.identifier)")
            throw RSDInputFieldError.invalidType(context)
        }
    }
}

final class RSDTextFieldTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: RSDAnswerResultType(baseType: .string))
    }
}

final class RSDBooleanTableItemGroup : RSDChoicePickerTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        let choicePicker: RSDChoicePickerDataSource
        if let picker = inputField as? RSDChoicePickerDataSource {
            choicePicker = picker
        } else {
            // TODO: syoung 10/20/2017 Implement Boolean formatter
            let choiceYes = try! RSDChoiceObject<Bool>(value: true, text: nil, iconName: nil, detail: nil, isExclusive: true)
            let choiceNo = try! RSDChoiceObject<Bool>(value: false, text: nil, iconName: nil, detail: nil, isExclusive: true)
            choicePicker = RSDChoiceOptionsObject(choices: [choiceYes, choiceNo], isOptional: inputField.isOptional)
        }
        let answerType = RSDAnswerResultType(baseType: .boolean)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, choicePicker: choicePicker, answerType: answerType)
    }
}

open class RSDChoicePickerTableItemGroup : RSDInputFieldTableItemGroup {

    public let singleSelection: Bool
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, choicePicker: RSDChoicePickerDataSource, answerType: RSDAnswerResultType? = nil,  defaultAnswer: Any? = nil, textFieldOptions: RSDTextFieldOptions? = nil, formatter: Formatter? = nil) {
        
        // Set the items
        var items: [RSDTableItem]?
        var singleSelection: Bool = true
        if inputField.dataType.listSelectionHints.contains(uiHint),
            let choicePicker = choicePicker as? RSDChoiceOptions {
            if case .collection(let collectionType, _) = inputField.dataType, collectionType == .multipleChoice {
                singleSelection = false
            }
            items = choicePicker.choices.enumerated().map { (index, choice) -> RSDTableItem in
                RSDChoiceTableItem(rowIndex: beginningRowIndex + index, inputField: inputField, choice: choice, choiceIndex: index)
            }
        }
        self.singleSelection = singleSelection
        
        // Setup the answer type if nil
        let aType: RSDAnswerResultType = answerType ?? {
            let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
            let sequenceType: RSDAnswerResultType.SequenceType? = singleSelection ? nil : .array
            let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
            let unit: String? = (inputField.range as? RSDNumberRange)?.unit
            return RSDAnswerResultType(baseType: baseType, sequenceType: sequenceType, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: nil)
        }()
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: aType, defaultAnswer: defaultAnswer, textFieldOptions: textFieldOptions, items: items, formatter: formatter, pickerSource: choicePicker)
    }

    /**
     Select or de-select an item (answer) at a specific indexPath. This is used for text choice and boolean answers.
     @param  selected   A bool indicating if item should be selected
     @param  indexPath  The IndexPath of the item
     */
    open func select(_ item: RSDChoiceTableItem, indexPath: IndexPath) throws {
        guard let selectableItems = self.items as? [RSDChoiceTableItem] else {
            let context = RSDInputFieldError.Context(identifier: inputField.identifier, value: nil, answerResult: answerType, debugDescription: "This input field does not support selection.")
            throw RSDInputFieldError.invalidType(context)
        }
        
        // to get index of our item, add our beginningRowIndex to indexPath.row
        let deselectOthers = singleSelection || item.choice.isExclusive
        let index =  indexPath.row - beginningRowIndex
        let selected = !item.selected
        
        // if we selected an item and this is a single-selection group, then we iterate
        // our other items and de-select them
        var answers: [Any] = []        
        for (ii, input) in selectableItems.enumerated() {
            if deselectOthers || (ii == index) || input.choice.isExclusive || (input.choice.value == nil) {
                input.selected = (ii == index) && selected
            }
            if input.selected, let value = input.choice.value {
                answers.append(value)
            }
        }
        
        // Set the answer array bypassing validation
        if singleSelection {
            _answer = answers.first
        } else {
            _answer = answers
        }
    }
}

final class RSDDateTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var pickerSource: RSDPickerDataSource? = inputField as? RSDPickerDataSource
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var dateFormatter: DateFormatter?
        
        if let dateRange = inputField.range as? RSDDateRange {
            let (src, fmt) = dateRange.dataSource()
            pickerSource = pickerSource ?? src
            formatter = formatter ?? fmt
            dateFormatter = dateRange.dateCoder?.resultFormatter
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            formatter = formatter ?? dateFormatter
            pickerSource = pickerSource ?? RSDDatePickerDataSourceObject(datePickerMode: .dateAndTime, minimumDate: nil, maximumDate: nil, minuteInterval: nil, dateFormatter: dateFormatter)
        }
        
        let answerType = RSDAnswerResultType(baseType: .date, sequenceType: nil, dateFormat: dateFormatter?.dateFormat, unit: nil, sequenceSeparator: nil)
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
    }
}

final class RSDNumberTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var pickerSource: RSDPickerDataSource? = inputField as? RSDPickerDataSource
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        var range: RSDNumberRange? = (inputField.range as? RSDNumberRange)
        
        if inputField.dataType.baseType == .year, let dateRange = inputField.range as? RSDDateRange {
            let calendar = Calendar(identifier: .gregorian)
            let min: Int? = (dateRange.minimumDate != nil) ? calendar.component(.year, from: dateRange.minimumDate!) : nil
            let max: Int? = (dateRange.maximumDate != nil) ? calendar.component(.year, from: dateRange.maximumDate!) : nil
            if min != nil || max != nil {
                range = RSDNumberRangeObject(minimumInt: min, maximumInt: max)
            }
        }

        let baseType: RSDAnswerResultType.BaseType = (inputField.dataType.baseType == .decimal) ? .decimal : .integer
        let digits = (baseType == .decimal) ? 3 : 0
        let numberFormatter = (formatter as? NumberFormatter) ?? NumberFormatter.defaultNumberFormatter(with: digits)
        if inputField.dataType.baseType == .year {
            numberFormatter.groupingSeparator = ""
        }
        formatter = formatter ?? numberFormatter

        
        if pickerSource == nil, let range = range, let min = range.minimumValue, let max = range.maximumValue {
            pickerSource = RSDDecimalPickerDataSourceObject(minimum: min, maximum: max, stepInterval: range.stepInterval, numberFormatter: numberFormatter)
        }

        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: nil, dateFormat: nil, unit: range?.unit, sequenceSeparator: nil)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
        self.numberRange = range
    }
}

final class RSDMultipleComponentTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDMultipleComponentInputField, uiHint: RSDFormUIHint) {
        
        let baseType: RSDAnswerResultType.BaseType = inputField.dataType.defaultAnswerResultBaseType()
        let dateFormatter: DateFormatter? = (inputField.range as? RSDDateRange)?.dateCoder?.resultFormatter
        let unit: String? = (inputField.range as? RSDNumberRange)?.unit
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: .array, dateFormat: dateFormatter?.dateFormat, unit: unit, sequenceSeparator: inputField.separator)
        
        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: nil, pickerSource: inputField)
    }
}

final class RSDMeasurementTableItemGroup : RSDInputFieldTableItemGroup {
    
    public init(beginningRowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint) {
        
        var formatter: Formatter? = (inputField.range as? RSDRangeWithFormatter)?.formatter
        let baseType: RSDAnswerResultType.BaseType = .decimal
        var unit: String?
        var sequenceType: RSDAnswerResultType.SequenceType?
        var sequenceSeparator: String?
        
        if case .measurement(let measurementType, _) = inputField.dataType {
            switch measurementType {
            case .height:
                let lengthFormatter = LengthFormatter()
                lengthFormatter.isForPersonHeightUse = true
                formatter = formatter ?? lengthFormatter
                unit = unit ?? "cm"
                
            case .weight:
                let massFormatter = MassFormatter()
                massFormatter.isForPersonMassUse = true
                formatter = formatter ?? massFormatter
                unit = unit ?? "kg"
                
            case .bloodPressure:
                sequenceType = .array
                sequenceSeparator = "/"
            }
        } else {
            fatalError("Cannot instantiate a measurement type item group without a base data type")
        }
        
        let answerType = RSDAnswerResultType(baseType: baseType, sequenceType: sequenceType, dateFormat: nil, unit: unit, sequenceSeparator: sequenceSeparator)
        let pickerSource: RSDPickerDataSource = (inputField as? RSDPickerDataSource) ?? RSDMeasurementPickerDataSourceObject(dataType: inputField.dataType, unit: unit, formatter: formatter)

        super.init(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, answerType: answerType, defaultAnswer: nil, textFieldOptions: nil, items: nil, formatter: formatter, pickerSource: pickerSource)
        
    }
}


// MARK: RSDTableItem

/**
 `RSDTableItem` can be used to represent the type of the row to display.
 */
open class RSDTableItem {
    
    public let rowIndex: Int
    
    /**
     Initialize a new RSDTableItem.
     
     @param   rowIndex      The index of this item relative to all rows in the section in which this item resides
     */
    public init(rowIndex: Int) {
        self.rowIndex = rowIndex
    }
}

/**
 `RSDInputFieldTableItem` is a base class implementation of an input field which defaults to using a text field. Depending upon the supported UI implementations, the `textFieldOptions` may be ignored.
 */
open class RSDInputFieldTableItem : RSDTableItem {
    
    public let inputField: RSDInputField

    /**
     Initialize a new RSDInputFieldTableItem.
     
     @param   rowIndex      The index of this item relative to all rows in the section in which this item resides
     @param   inputField    The RSDInputField representing this tableItem.
     */
    public init(rowIndex: Int, inputField: RSDInputField) {
        self.inputField = inputField
        super.init(rowIndex: rowIndex)
    }
}

/**
 `RSDChoiceTableItem` is used to represent a single row in a table where the user picks from a list of choices.
 */
open class RSDChoiceTableItem : RSDInputFieldTableItem {
    
    // Applicable where this table item represents one choice for a single or multiple choice input field
    open private(set) var choice: RSDChoice
    public let choiceIndex: Int
    public var selected: Bool = false
    
    /**
     Initialize a new RSDChoiceTableItem.
     
     @param   rowIndex      The index of this item relative to all rows in the section in which this item resides
     @param   inputField    The RSDInputField representing this tableItem.
     @param   choiceIndex   The index of this item relative to all the choices in this ItemGroup
     */
    public init(rowIndex: Int, inputField: RSDInputField, choice: RSDChoice, choiceIndex: Int) {
        self.choiceIndex = choiceIndex
        self.choice = choice
        super.init(rowIndex: rowIndex, inputField: inputField)
    }
}

public class RSDTextTableItem : RSDTableItem {
    
    public let text: String
    
    public init(rowIndex: Int, text: String) {
        self.text = text
        super.init(rowIndex: rowIndex)
    }
}

public class RSDImageTableItem : RSDTableItem {
    public let imageTheme: RSDImageThemeElement
    
    public var identifier: String {
        return "image.\(imageTheme.placementType?.rawValue ?? "above")"
    }
    
    public init(rowIndex: Int, imageTheme: RSDImageThemeElement) {
        self.imageTheme = imageTheme
        super.init(rowIndex: rowIndex)
    }
}
