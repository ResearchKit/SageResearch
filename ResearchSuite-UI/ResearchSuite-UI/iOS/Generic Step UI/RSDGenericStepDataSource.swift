//
//  RSDGenericStepDataSource.swift
//  ResearchSuite-UI
//
//  Created by Josh Bruhin on 6/5/17.
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

import UIKit

/**
 RSDGenericStepDataSource: the internal model for RSDGenericStepViewController. It provides the UITableViewDataSource,
 manages and stores answers provided thru user input, and provides an RSDResult with those anwers upon request.
 
 It also provides several convenience methods for saving or selecting answers, checking if all answers are valid,
 and retrieving specific model objects that may be needed by the ViewController.
 
 The tableView data source is comprised of 3 objects:
 
 1) RSDGenericStepTableSection - An object representing a section in the tableView. It has one or more RSDGenericStepTableItemGroups.
 
 2) RSDGenericStepTableItemGroup - An object representing a specific question supplied by RSDStep in the form of RSDFormItem.
 An RSDInputField can have multiple answer options, such as a boolean question or text choice
 question. Or, it can have just one answer option, in the case of alpha/numeric questions.
 
 Upon init(), the ItemGroup will create one or more RSDGenericStepTableItem representing the answer
 options for the RSDInputField. The ItemGroup is responsible for storing/computing the answers
 for its RSDInputField.
 
 3) RSDGenericStepTableItem - An object representing a specific answer option from the ItemGroup (RSDInputField), such as a Yes or No
 choice in a boolean question or a string or number that's entered thru a text field. There will be
 one TableItem for each indexPath in the tableView.
 */

public protocol RSDGenericStepDataSourceDelegate {
    func answersDidChange()
}

open class RSDGenericStepDataSource: NSObject {
    
    open var delegate: RSDGenericStepDataSourceDelegate?
    open var sections: Array<RSDGenericStepTableSection> = Array()
    open var step: RSDStep?
    
    /**
     Initialize a new RSDGenericStepDataSource.
     @param  step       The RSDStep
     @param  result     The previous ORKResult, if any
     */
    public init(step: RSDStep?, result: ORKResult?) {
        super.init()
        self.step = step
        populate()
        if result != nil {
            updateAnswers(from: result!)
        }
    }
    
    func updateAnswers(from result: ORKResult) {
        
        guard let taskResult = result as? ORKTaskResult else { return }
        
        // find the existing result for this step, if any
        if let stepResult = taskResult.result(forIdentifier: step!.identifier) as? ORKStepResult,
            let stepResults = stepResult.results as? [ORKQuestionResult] {
            
            // for each form item result, save the existing answer to our model
            for result in stepResults {
                let answer = result.answer ?? NSNull()
                if let group = itemGroup(with: result.identifier) {
                    group.answer = answer as AnyObject
                }
            }
        }
    }
    
    
    public func updateDefaults(_ defaults: NSMutableDictionary) {
        
        // TODO: Josh Bruhin, 6/12/17 - implement. this may require access to a HealthKit source.
        
        for section in sections {
            section.itemGroups.forEach({
                if let newAnswer = defaults[$0.inputField.identifier] {
                    $0.defaultAnswer = newAnswer as AnyObject
                }
            })
        }
        
        // notify our delegate that the result changed
        if let delegate = delegate {
            delegate.answersDidChange()
        }
    }
    
    /**
     Determine if all answers are valid. Also checks the case where answers are required but one has not been provided.
     @return    A Bool indicating if all answers are valid
     */
    open func allAnswersValid() -> Bool {
        for section in sections {
            for itemGroup in section.itemGroups {
                if !itemGroup.isAnswerValid {
                    return false
                }
            }
        }
        return true
    }
    
    /**
     Retrieve the 'RSDGenericStepTableItemGroup' with a specific RSDInputField identifier.
     @param   identifier   The identifier of the RSDInputField assigned to the ItemGroup
     @return               The requested RSDGenericStepTableItemGroup, or nil if it cannot be found
     */
    open func itemGroup(with identifier: String) -> RSDGenericStepTableItemGroup? {
        for section in sections {
            for itemGroup in section.itemGroups {
                if itemGroup.inputField.identifier == identifier {
                    return itemGroup
                }
            }
        }
        return nil
    }
    
    /**
     Retrieve the 'RSDGenericStepTableItemGroup' for a specific IndexPath.
     @param   indexPath   The IndexPath that represents the ItemGroup in the tableView
     @return              The requested RSDGenericStepTableItemGroup, or nil if it cannot be found
     */
    open func itemGroup(at indexPath: IndexPath) -> RSDGenericStepTableItemGroup? {
        let section = sections[indexPath.section]
        for itemGroup in section.itemGroups {
            if itemGroup.beginningRowIndex ... itemGroup.beginningRowIndex + (itemGroup.items.count - 1) ~= indexPath.row {
                return itemGroup
            }
        }
        return nil
    }
    
    /**
     Retrieve the 'RSDGenericStepTableItem' for a specific IndexPath.
     @param   indexPath   The IndexPath that represents the TableItem in the tableView
     @return              The requested RSDGenericStepTableItem, or nil if it cannot be found
     */
    open func tableItem(at indexPath: IndexPath) -> RSDGenericStepTableItem? {
        if let itemGroup = itemGroup(at: indexPath) {
            let index = indexPath.row - itemGroup.beginningRowIndex
            return itemGroup.items[index]
        }
        return nil
    }
    
    /**
     Save an answer for a specific IndexPath.
     @param   answer      The object to be save as the answer
     @param   indexPath   The IndexPath that represents the TableItemGroup in the tableView
     */
    open func saveAnswer(_ answer: AnyObject, at indexPath: IndexPath) {
        
        let itemGroup = self.itemGroup(at: indexPath)
        itemGroup?.answer = answer
        
        // inform delegate that answers have changed
        if let delegate = delegate {
            delegate.answersDidChange()
        }
    }
    
    /**
     Select or deselect the answer option for a specific IndexPath.
     @param   indexPath   The IndexPath that represents the TableItemGroup in the tableView
     */
    open func selectAnswer(selected: Bool, at indexPath: IndexPath) {
        
        let itemGroup = self.itemGroup(at: indexPath)
        itemGroup?.select(selected, indexPath: indexPath)
        
        // inform delegate that answers have changed
        if let delegate = delegate {
            delegate.answersDidChange()
        }
    }
    
    /**
     Retrieve the current ORKStepResult.
     @return    An ORKStepResult object with the current answers for all of its RSDInputFields
     */
    open func results(parentResult: ORKStepResult) -> ORKStepResult {
        
        guard let inputFields = inputFieldsWithAnswerFormat() else { return parentResult }
        
        // "Now" is the end time of the result, which is either actually now,
        // or the last time we were in the responder chain.
        
        let now = parentResult.endDate
        
        for inputField: RSDInputField in inputFields {
            
            var answer = NSNull()
            var answerDate = now
            var systemCalendar = Calendar.current
            var systemTimeZone = NSTimeZone.system
            
            if let itemGroup = itemGroup(with: inputField.identifier) {
                
                answer = itemGroup.answer
                
                // check that answer is not NSNull
                // Skipped forms report a "null" value for every item -- by skipping, the user has explicitly said they don't want
                // to report any values from this form.
                if !(answer is NSNull) {
                    answerDate = itemGroup.answerDate ?? now
                    systemCalendar = itemGroup.calendar
                    systemTimeZone = itemGroup.timezone
                }
            }
            
            guard let result = inputField.answerFormat?.result(withIdentifier: inputField.identifier, answer: answer) else {
                continue
            }
            
            let impliedAnswerFormat = inputField.answerFormat?.implied()
            
            if let dateAnswerFormat = impliedAnswerFormat as? ORKDateAnswerFormat,
                let dateQuestionResult = result as? ORKDateQuestionResult,
                let _ = dateQuestionResult.dateAnswer {
                
                let usedCalendar = dateAnswerFormat.calendar ?? systemCalendar
                dateQuestionResult.calendar = usedCalendar
                dateQuestionResult.timeZone = systemTimeZone
                
            }
            else if let numericAnswerFormat = impliedAnswerFormat as? ORKNumericAnswerFormat,
                let numericQuestionFormat = result as? ORKNumericQuestionResult,
                numericQuestionFormat.unit == nil {
                
                numericQuestionFormat.unit = numericAnswerFormat.unit
            }
            
            result.startDate = answerDate
            result.endDate = answerDate
            
            parentResult.addResult(result)
        }
        
        return parentResult
    }
    
    fileprivate func inputFieldsWithAnswerFormat() -> Array<RSDInputField>? {
        return self.inputFields()?.filter { $0.answerFormat != nil }
    }
    
    fileprivate func inputFields() -> [RSDInputField]? {
        guard let formStep = self.step as? RSDFormStepProtocol else { return nil }
        return formStep.inputFields
    }
    
    fileprivate func populate() {
        
        guard let items = inputFields(), items.count > 0 else {
            return
        }
        
        let singleSelectionTypes: [ORKQuestionType] = [.boolean, .singleChoice, .multipleChoice, .location]
        
        for item in items {
            
            // some form items need to be in their own section
            var needExclusiveSection = false
            
            if let answerFormat = item.answerFormat?.implied() {

                let multiCellChoice = singleSelectionTypes.contains(answerFormat.questionType) && !(answerFormat is ORKValuePickerAnswerFormat)
                let multiLineTextEntry = answerFormat.questionType == .text
                let scale = answerFormat.questionType == .scale

                needExclusiveSection =  multiCellChoice || multiLineTextEntry || scale
            }
            
            // if we don't need an exclusive section and we have an existing section and it's not exclusive ('singleFormItem'),
            // then add this item to that existing section, otherwise create a new one
            if !needExclusiveSection, let lastSection = sections.last, !lastSection.singleFormItem {
                lastSection.add(inputField: item)
            }
            else {
                let section = RSDGenericStepTableSection(sectionIndex: sections.count)
                section.add(inputField: item)
                section.title = item.text
                section.singleFormItem = needExclusiveSection
                sections.append(section)
            }
        }
    }
}


open class RSDGenericStepTableSection: NSObject {
    
    open var itemGroups: Array<RSDGenericStepTableItemGroup> = Array()
    
    private var _title: String?
    var title: String? {
        get { return _title }
        set (newValue) { _title = newValue?.uppercased(with: Locale.current) }
    }
    
    /**
     Indicates whether this section is exclusive to a single form item or can contain multiple form items.
    */
    public var singleFormItem = false
    
    
    let index: Int!
    
    public init(sectionIndex: Int) {
        self.index = sectionIndex
        super.init()
    }
    
    /**
     Add a new RSDInputField, which results in the creation and addition of a new RSDGenericStepTableItemGroup to the section.
     The ItemGroup essectially represents the input field and is reponsible for storing and providing answers for the input field
     when a ORKStepResult is requested.
     
     @param   inputField    The RSDInputField to add to the section
     */
    public func add(inputField: RSDInputField) {
        
        guard itemGroups.find({ $0.inputField.identifier == inputField.identifier }) == nil else {
            assertionFailure("Cannot add RSDInputField with duplicate identifier.")
            return
        }
        
        itemGroups.append(RSDGenericStepTableItemGroup(inputField: inputField, beginningRowIndex: itemCount()))
    }
    
    /**
     Returns the total count of all Items in this section.
     @return    The total number of RSDGenericStepTableItems in this section
     */
    public func itemCount() -> Int {
        return itemGroups.reduce(0, {$0 + $1.items.count})
    }
}


open class RSDGenericStepTableItemGroup: NSObject {
    
    let inputField: RSDInputField!
    
    var items: [RSDGenericStepTableItem]!
    var beginningRowIndex = 0
    
    var singleSelection: Bool = true
    
    var answerDate: Date?
    var calendar = Calendar.current
    var timezone = TimeZone.current
    
    var defaultAnswer: Any = NSNull() as Any
    private var _answer: Any?
    
    /**
     Save an answer for this ItemGroup. This is used only for those questions that have single answers,
     such as text and numeric answers, as opposed to booleans or text choice answers.
     */
    public var answer: Any! {
        get { return internalAnswer() }
        set { setInternalAnswer(newValue) }
    }
    
    /**
     Determine if the current answer is valid. Also checks the case where answer is required but one has not been provided.
     @return    A Bool indicating if answer is valid
     */
    public var isAnswerValid: Bool {
        
        // if answer is NOT optional and it equals Null, or is nil, then it's invalid
        if !inputField.isOptional, answer is NSNull || answer == nil {
            return false
        }
        
        return inputField.answerFormat?.implied().isAnswerValid(answer) ?? false
    }
    
    /**
     Initialize a new ItemGroup with an RSDInputField. Pass a beginningRowIndex since sections can have multiple ItemGroups.
     @param  inputField   The RSDInputField to add to the model
     @param  beginningRowIndex  The row index in the section at which this inputField begins
     */
    fileprivate init(inputField: RSDInputField, beginningRowIndex: Int) {
        
        self.inputField = inputField
        
        super.init()
        
        if let textChoiceAnswerFormat = inputField.answerFormat?.implied() as? ORKTextChoiceAnswerFormat {
            singleSelection = textChoiceAnswerFormat.style == .singleChoice
            self.items = textChoiceAnswerFormat.textChoices.enumerated().map { (index, _) -> RSDGenericStepTableItem in
                RSDGenericStepTableItem(inputField: inputField, choiceIndex: index, rowIndex: beginningRowIndex + index)
            }
        } else {
            let tableItem = RSDGenericStepTableItem(inputField: inputField, choiceIndex: 0, rowIndex: beginningRowIndex)
            self.items = [tableItem]
        }
        
    }
    
    /**
     Select or de-select an item (answer) at a specific indexPath. This is used for text choice and boolean answers.
     @param  selected   A bool indicating if item should be selected
     @param  indexPath  The IndexPath of the item
     */
    fileprivate func select(_ selected: Bool, indexPath: IndexPath) {
        
        // to get index of our item, add our beginningRowIndex to indexPath.row
        let index = beginningRowIndex + indexPath.row
        if items.count > index {
            items[index].selected = selected
        }
        
        // if we selected an item and this is a single-selection group, then we iterate
        // our other items and de-select them
        if singleSelection {
            for (ii, item) in items.enumerated() {
                item.selected = (ii == index)
            }
        }
    }
    
    fileprivate func internalAnswer() -> Any {
        
        guard let answerFormat = items.first?.inputField?.answerFormat else {
            return _answer ?? defaultAnswer
        }
        
        switch answerFormat {
        case is ORKBooleanAnswerFormat:
            return answerForBoolean()
            
        case is ORKMultipleValuePickerAnswerFormat,
             is ORKTextChoiceAnswerFormat:
            return answerForTextChoice()
            
        default:
            return _answer ?? defaultAnswer
        }
    }
    
    fileprivate func setInternalAnswer(_ answer: Any) {
        
        guard let answerFormat = items.first?.inputField?.answerFormat else {
            return
        }

        switch answerFormat {
        case is ORKBooleanAnswerFormat:
            
            // iterate our items and find the item with a value equal to our answer,
            // then select that item
            
            let formattedAnswer = answer as? NSNumber
            for item in items {
                if (item.choice?.value as? NSNumber)?.boolValue == formattedAnswer?.boolValue {
                    item.selected = true
                }
            }
            
        case is ORKTextChoiceAnswerFormat:
            
            // iterate our items and find the items with a value that is contained in our
            // answer, which should be an array, then select those items
            
            if let arrayAnswer = answer as? Array<AnyObject> {
                for item in items {
                    item.selected = (item.choice?.value != nil) && arrayAnswer.contains(where: { (value) -> Bool in
                        return item.choice!.value === value
                    })
                }
            }
            
        case is ORKMultipleValuePickerAnswerFormat:
            
            // TODO: Josh Bruhin, 6/12/17 - implement this answer format.
            fatalError("setInternalAnswer for ORKMultipleValuePickerAnswerFormat not implemented")
            
        default:
            _answer = answer
        }
    }
    
    private func answerForTextChoice() -> AnyObject {
        let array = self.items.mapAndFilter { $0.selected ? $0.choice?.value : nil }
        return array.count > 0 ? array as AnyObject : NSNull() as AnyObject
    }
    
    private func answerForBoolean() -> AnyObject {
        for item in items {
            if item.selected {
                if let value = item.choice?.value as? NSNumber {
                    return NSDecimalNumber(value: value.boolValue)
                }
            }
        }
        return NSNull() as AnyObject
    }
}

open class RSDGenericStepTableItem: NSObject {
    
    // the same inputField assigned to the group that this item belongs to
    var inputField: RSDInputField?
    var answerFormat: ORKAnswerFormat?
    var choice: ORKTextChoice?
    
    var choiceIndex = 0
    var rowIndex = 0
    
    var selected: Bool = false
    
    /**
     Initialize a new RSDGenericStepTableItem
     @param   inputField      The RSDInputField representing this tableItem.
     @param   choiceIndex   The index of this item relative to all the choices in this ItemGroup
     @param   rowIndex      The index of this item relative to all rows in the section in which this item resides
     */
    fileprivate init(inputField: RSDInputField!, choiceIndex: Int, rowIndex: Int) {
        super.init()
        commonInit(inputField: inputField)
        self.choiceIndex = choiceIndex
        self.rowIndex = rowIndex
        if let textChoiceFormat = textChoiceAnswerFormat() {
            choice = textChoiceFormat.textChoices[choiceIndex]
        }
    }
    
    func commonInit(inputField: RSDInputField!) {
        self.inputField = inputField
        self.answerFormat = inputField.answerFormat?.implied()
    }
    
    func textChoiceAnswerFormat() -> ORKTextChoiceAnswerFormat? {
        guard let textChoiceFormat = self.answerFormat as? ORKTextChoiceAnswerFormat else { return nil }
        return textChoiceFormat
    }
}

