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

/// `RSDFormStepDataSourceObject` is a concrete implementation of the `RSDFormStepDataSource` protocol.
open class RSDFormStepDataSourceObject : RSDFormStepDataSource {
    
    /// The delegate associated with this data source.
    open weak var delegate: RSDFormStepDataSourceDelegate?

    /// The step associated with this data source.
    public let step: RSDStep

    /// The UI hints supported by this data source.
    public let supportedHints: Set<RSDFormUIHint>

    /// The current task path.
    public private(set) var taskPath: RSDTaskPath

    /// The table sections for this data source.
    open private(set) var sections: [RSDTableSection]

    /// The initial result when the data source was first displayed.
    open private(set) var initialResults: [String : RSDResult]

    /// Initialize a new `RSDFormStepDataSourceObject`.
    /// - parameters:
    ///     - step:       The RSDStep for this data source.
    ///     - taskPath:   The current task path for this data source.
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
    
    /// The collection result associated with this data source. The default implementation is to search the `taskPath`
    /// for a matching result and if that fails to return a new instance of `RSDCollectionResultObject`.
    ///
    /// - returns: The appropriate collection result.
    open func collectionResult() -> RSDCollectionResult {
        if let collectionResult = taskPath.result.stepHistory.rsd_last(where: { $0.identifier == step.identifier }) as? RSDCollectionResult {
            return collectionResult
        }
        else {
            return RSDCollectionResultObject(identifier: step.identifier)
        }
    }
    
    /// Instantiate the appropriate answer result for the given item group.
    /// - parameter itemGroup: The item group for which to create a result.
    /// - returns: The answer result (if any).
    open func instantiateAnswerResult(for itemGroup: RSDInputFieldTableItemGroup) -> RSDAnswerResult? {
        var answerResult = RSDAnswerResultObject(identifier: itemGroup.identifier, answerType: itemGroup.answerType)
        answerResult.value = itemGroup.answer
        return answerResult
    }
    
    /// What is the preferred ui hint for this input field that is supported by this table? By default,
    /// this will look for the uiHint from the inputField to be included in the supported hints and if
    /// not, will return the preferred ui hint for the data type.
    ///
    /// - parameter inputField  The inputField to check.
    /// - returns: The ui hint to return.
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
    
    /// Does this ui hint require an exclusive section? This sets up a section with one and only one ItemGroup
    /// for certain ui hints.
    ///
    /// - parameter uiHint: The ui hint to test.
    /// - returns: `true` if the ui hint type requires it's own table section.
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
    
    /// Instantiate the appropriate item group for this input field.
    /// - parameters:
    ///     - inputField: The input field to convert to an item group.
    ///     - beginningRowIndex: The beginning row index for this item group.
    /// - returns: The instantiated item group.
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
    
    /// Convenience method for looking at the previous results in the task path and setting the answer based on that result.
    /// - returns: A dictionary of results mapped to the result identifier.
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
    
    /// Convenience method for building the sections of the table from the input fields.
    /// - returns: The sections for the table.
    private func populateSections() {
        guard let uiStep = step as? RSDUIStep else { return }

        var sectionBuilders: [RSDTableSectionBuilder] = []
        for item in inputFields() {
            
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
            let needExclusiveSection = requiresExclusiveSection(for: itemGroup)

            // if we don't need an exclusive section and we have an existing section and it's not exclusive ('singleFormItem'),
            // then add this item to that existing section, otherwise create a new one
            if !needExclusiveSection, let lastSection = sectionBuilders.last, !lastSection.singleFormItem {
                lastSection.title = nil
                lastSection.itemGroups.append(itemGroup)
            }
            else {
                let section = RSDTableSectionBuilder(sectionIndex: sectionBuilders.count, singleFormItem: needExclusiveSection)
                section.itemGroups.append(itemGroup)
                section.title = item.prompt
                sectionBuilders.append(section)
            }
        }
        self.sections = sectionBuilders.map { $0.tableSection }
        
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
    
    /// Convenience method for returning the input fields.
    /// - returns: The input fields for the form step.
    private func inputFields() -> [RSDInputField] {
        guard let formStep = self.step as? RSDFormUIStep else { return [] }
        return formStep.inputFields
    }
}

/// Used in refactored code to allow developers to build their own implementation of the table section.
fileprivate class RSDTableSectionBuilder {
    var itemGroups: [RSDTableItemGroup] = []
    let index: Int
    let singleFormItem: Bool
    var title: String?
    
    init(sectionIndex: Int, singleFormItem: Bool = true) {
        self.index = sectionIndex
        self.singleFormItem = singleFormItem
    }
    
    var tableSection: RSDTableSection {
        let section = RSDTableSection(sectionIndex: index, itemGroups: itemGroups)
        section.title = title
        return section
    }
}
