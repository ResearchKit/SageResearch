//
//  RSDFormStepDataSourceObject.swift
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

/// `RSDFormStepDataSourceObject` is a concrete implementation of the `RSDTableDataSource` protocol that is
/// designed to be used to supply the data source for a form step.
open class RSDFormStepDataSourceObject : RSDTableDataSource {
    
    /// The delegate associated with this data source.
    open weak var delegate: RSDTableDataSourceDelegate?

    /// The step associated with this data source.
    public let step: RSDStep

    /// The UI hints supported by this data source.
    public let supportedHints: Set<RSDFormUIHint>

    /// The current task path.
    public private(set) var taskPath: RSDTaskPath!

    /// The table sections for this data source.
    open private(set) var sections: [RSDTableSection] = []
    
    /// The table item groups displayed in this table.
    open private(set) var itemGroups: [RSDTableItemGroup] = []

    /// The initial result when the data source was first displayed.
    open private(set) var initialResult: RSDCollectionResult?

    /// Initialize a new `RSDFormStepDataSourceObject`.
    /// - parameters:
    ///     - step:             The RSDStep for this data source.
    ///     - taskPath:         The current task path for this data source.
    ///     - supportedHints:   The supported UI hints for this data source.
    public init(step: RSDStep, taskPath: RSDTaskPath, supportedHints: Set<RSDFormUIHint>? = nil) {
        
        self.step = step
        self.taskPath = taskPath
        self.supportedHints = supportedHints ?? RSDFormUIHint.allStandardHints
        
        // Set the initial result if available.
        if let result = initialResult {
            self.initialResult = result
        }
        else if let previousResult = taskPath.previousResults?.rsd_last(where: { $0.identifier == step.identifier }) {
            if let collectionResult = (previousResult as? RSDCollectionResult) {
                self.initialResult = collectionResult
            } else {
                var collectionResult = self.instantiateCollectionResult()
                collectionResult.startDate = previousResult.startDate
                collectionResult.endDate = previousResult.endDate
                collectionResult.appendInputResults(with: previousResult)
                self.initialResult = collectionResult
            }
        }
        
        // Populate the sections and initial results.
        let (sections, groups) = self.bulidSections()
        self.sections = sections
        self.itemGroups = groups
        populateInitialResults()
    }
    
    /// The collection result associated with this data source. The default implementation is to search the `taskPath`
    /// for a matching result and if that fails to return a new instance created using `instantiateCollectionResult()`.
    ///
    /// - returns: The appropriate collection result.
    open func collectionResult() -> RSDCollectionResult {
        if let collectionResult = taskPath.result.stepHistory.rsd_last(where: { $0.identifier == step.identifier }) as? RSDCollectionResult {
            return collectionResult
        }
        else {
            return instantiateCollectionResult()
        }
    }
    
    /// Instantiate a collection result of the appropriate object type for this data source.
    /// The default implementation returns a new instance of `RSDCollectionResultObject`.
    ///
    /// - returns: The appropriate collection result.
    open func instantiateCollectionResult() -> RSDCollectionResult {
        return RSDCollectionResultObject(identifier: step.identifier)
    }
    
    /// Instantiate the appropriate answer result for the given item group.
    /// - parameter itemGroup: The item group for which to create a result.
    /// - returns: The answer result (if any).
    open func instantiateAnswerResult(for itemGroup: RSDInputFieldTableItemGroup) -> RSDAnswerResult? {
        var answerResult = RSDAnswerResultObject(identifier: itemGroup.identifier, answerType: itemGroup.answerType)
        answerResult.value = itemGroup.answer
        return answerResult
    }
    
    // MARK: RSDTableDataSource implementation
    
    /// Retrieve the `RSDTableItemGroup` with a specific `RSDInputField` identifier.
    /// - parameter identifier: The identifier of the `RSDInputField` assigned to the item group.
    /// - returns: The requested `RSDTableItemGroup`, or nil if it cannot be found.
    open func itemGroup(with identifier: String) -> RSDTableItemGroup? {
        return itemGroups.first(where: {
            ($0 as? RSDInputFieldTableItemGroup)?.inputField.identifier == identifier
        })
    }
    
    func isMatching(_ itemGroup: RSDTableItemGroup, at indexPath: IndexPath) -> Bool {
        return itemGroup.sectionIndex == indexPath.section &&
            (itemGroup.beginningRowIndex ... itemGroup.beginningRowIndex + (itemGroup.items.count - 1) ~= indexPath.row)
    }
    
    /// Retrieve the 'RSDTableItemGroup' for a specific IndexPath.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The requested `RSDTableItemGroup`, or nil if it cannot be found.
    open func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        return itemGroups.first(where: { isMatching($0, at: indexPath) })
    }
    
    /// Save an answer for a specific IndexPath.
    /// - parameters:
    ///     - answer:      The object to be save as the answer.
    ///     - indexPath:   The `IndexPath` that represents the `RSDTableItem` in the table view.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    open func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        guard let itemGroup = self.itemGroup(at: indexPath) as? RSDInputFieldTableItemGroup else {
            return
        }
        
        if let tableItem = self.tableItem(at: indexPath) as? RSDTextInputTableItem {
            // If this is a text input table item then store the answer on the table item instead of on the group.
            try tableItem.setAnswer(answer)
        } else {
            try itemGroup.setAnswer(answer)
        }
        _answerDidChange(for: itemGroup, at: indexPath)
    }
    
    /// Select or deselect the answer option for a specific IndexPath.
    /// - parameter indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - returns:
    ///     - isSelected: The new selection state of the selected item.
    ///     - reloadSection: `true` if the section needs to be reloaded b/c other answers have changed,
    ///                      otherwise returns `false`.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    open func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard let choiceItem = item as? RSDChoiceTableItem,
            let itemGroup = self.itemGroup(at: indexPath) as? RSDChoicePickerTableItemGroup else {
            return (false, false)
        }
        
        let ret = try itemGroup.select(choiceItem, indexPath: indexPath)
        _answerDidChange(for: itemGroup, at: indexPath)
        return ret
    }
    
    private func _answerDidChange(for itemGroup: RSDInputFieldTableItemGroup, at indexPath: IndexPath) {
        
        // Update the answers
        var stepResult = self.collectionResult()
        if let result = self.instantiateAnswerResult(for: itemGroup) {
            stepResult.appendInputResults(with: result)
        } else {
            stepResult.removeInputResult(with: itemGroup.identifier)
        }
        self.taskPath.appendStepHistory(with: stepResult)
        
        // inform delegate that answers have changed
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
    }
    
    /// Determine if all answers are valid. Also checks the case where answers are required but one has not been provided.
    /// - returns: A `Bool` indicating if all answers are valid.
    open func allAnswersValid() -> Bool {
        return itemGroups.reduce(true, { $0 && $1.isAnswerValid })
    }
    

    // MARK: Build table - These methods are called during initialization, but they are *not*
    // defined as class methods b/c there is a lot of interdependancy on the methods used to
    // update results during use.
    
    /// Convenience method for building the sections of the table from the input fields.
    /// - returns: The sections for the table.
    open func bulidSections() -> ([RSDTableSection], [RSDTableItemGroup]) {
        guard let uiStep = step as? RSDUIStep else { return ([], []) }
        
        var sectionBuilders: [RSDTableSectionBuilder] = []
        let inputFields = (step as? RSDFormUIStep)?.inputFields ?? []
        for item in inputFields {
            
            // Get the next row index
            let rowIndex: Int = {
                if let lastSection = sectionBuilders.last, !lastSection.singleFormItem {
                    return lastSection.tableSection.rowCount()
                } else {
                    return 0
                }
            }()
            
            // Call open method to get the appropriate item group
            let itemGroup = instantiateTableItemGroup(for: item, beginningRowIndex: rowIndex)
            let needExclusiveSection = (itemGroup as? RSDInputFieldTableItemGroup)?.requiresExclusiveSection ?? false
            
            // If we don't need an exclusive section and we have an existing section and it's not exclusive
            // ('singleFormItem'), then add this item to that existing section, otherwise create a new one.
            if !needExclusiveSection, let lastSection = sectionBuilders.last, !lastSection.singleFormItem {
                lastSection.appendGroup(itemGroup)
            }
            else {
                let section = RSDTableSectionBuilder(sectionIndex: sectionBuilders.count, singleFormItem: needExclusiveSection)
                section.appendGroup(itemGroup)
                if let choiceGroup = itemGroup as? RSDChoicePickerTableItemGroup, choiceGroup.items.count > 1 {
                    section.title = item.inputPrompt
                    section.subtitle = item.inputPromptDetail
                }
                sectionBuilders.append(section)
            }
        }
        
        var sections = sectionBuilders.map { $0.tableSection }
        let itemGroups = sectionBuilders.map { $0.itemGroups }.flatMap{$0}
        
        // add image below and footnote
        var items: [RSDTableItem] = []
        if let imageTheme = (step as? RSDThemedUIStep)?.imageTheme, imageTheme.placementType == .iconAfter {
            items.append(RSDImageTableItem(rowIndex: items.count, imageTheme: imageTheme))
        }
        if let footnote = uiStep.footnote {
            items.append(RSDTextTableItem(rowIndex: items.count, text: footnote))
        }
        if items.count > 0 {
            let sectionIndex = sections.count
            let section = RSDTableSection(identifier: "\(sectionIndex)", sectionIndex: sectionIndex, tableItems: items)
            sections.append(section)
        }
        
        return (sections, itemGroups)
    }
    
    /// Instantiate the appropriate item group for this input field.
    /// - parameters:
    ///     - inputField: The input field to convert to an item group.
    ///     - beginningRowIndex: The beginning row index for this item group.
    /// - returns: The instantiated item group.
    open func instantiateTableItemGroup(for inputField: RSDInputField, beginningRowIndex: Int) -> RSDTableItemGroup {
        let uiHint = preferredUIHint(for: inputField)
        
        if case .measurement(_,_) = inputField.dataType {
            return RSDHumanMeasurementTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
        }
        else if let pickerSource = inputField.pickerSource as? RSDChoiceOptions {
            return RSDChoicePickerTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: uiHint, choicePicker: pickerSource)
        }
        else if let pickerSource = inputField.pickerSource as? RSDMultipleComponentPickerDataSource {
            return RSDMultipleComponentTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint, pickerSource: pickerSource)
        } else {
            switch inputField.dataType.baseType {
            case .boolean:
                return RSDBooleanTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .string:
                return RSDTextFieldTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .date:
                return RSDDateTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            case .decimal, .integer, .year, .fraction, .duration:
                return RSDNumberTableItemGroup(beginningRowIndex: beginningRowIndex, inputField: inputField, uiHint: uiHint)
            }
        }
    }
    
    /// What is the preferred ui hint for this input field that is supported by this table? By default,
    /// this will look for the uiHint from the inputField to be included in the supported hints and if
    /// not, will return the preferred ui hint for the data type.
    ///
    /// - parameter inputField  The inputField to check.
    /// - returns: The ui hint to return.
    open func preferredUIHint(for inputField: RSDInputField) -> RSDFormUIHint {
        if let uiHint = inputField.inputUIHint, supportedHints.contains(uiHint) {
            return uiHint
        }
        let standardType: RSDFormUIHint?
        if let choiceInput = inputField.pickerSource as? RSDChoiceOptions, choiceInput.hasImages {
            standardType = supportedHints.contains(.slider) ? .slider : nil
        } else {
            standardType = inputField.dataType.validStandardUIHints.first(where:{ supportedHints.contains($0) })
        }
        return standardType ?? .textfield
    }
    
    /// Convenience method for looking at the previous results in the task path and setting the answer
    /// based on that result. Get the collection result for this step and populate that result with the
    /// initial results that are valid from this form.
    ///
    /// - note: This is **not** handled universally by the `RSDTaskController` for all steps because it
    /// is possible that a different implementation should not include populating the current result with
    /// a previous result. For example, a form should be populated with previous answers, but an active
    /// test should not.
    open func populateInitialResults() {
        guard let results = self.initialResult?.inputResults, results.count > 0 else { return }
        
        var stepResult = self.collectionResult()
        var hasChanges: Bool = false
        
        for result in results {
            if let itemGroup = itemGroup(with: result.identifier) as? RSDInputFieldTableItemGroup {
                do {
                    try itemGroup.setAnswer(from: result)
                    if let result = self.instantiateAnswerResult(for: itemGroup) {
                        stepResult.appendInputResults(with: result)
                        hasChanges = true
                    }
                } catch let err {
                    // ignore error but do not save the result
                    debugPrint("Failed to restore answer from result. \(err)")
                }
            }
        }
        
        if hasChanges {
            self.taskPath.appendStepHistory(with: stepResult)
        }
    }
}

/// Used in refactored code to allow developers to build their own implementation of the table section.
fileprivate class RSDTableSectionBuilder {
    private(set) var itemGroups: [RSDTableItemGroup] = []
    let index: Int
    let singleFormItem: Bool
    var title: String?
    var subtitle: String?
    
    init(sectionIndex: Int, singleFormItem: Bool = true) {
        self.index = sectionIndex
        self.singleFormItem = singleFormItem
    }
    
    func appendGroup(_ itemGroup: RSDTableItemGroup) {
        itemGroup.sectionIndex = index
        itemGroups.append(itemGroup)
    }
    
    var tableSection: RSDTableSection {
        let tableItems = itemGroups.map{$0.items}.flatMap{$0}
        let section = RSDTableSection(identifier: "\(index)", sectionIndex: index, tableItems: tableItems)
        section.title = title
        section.subtitle = subtitle
        return section
    }
}
