//
//  RSDTrackedSelectionDataSource.swift
//  ResearchStack2
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

/// `RSDTrackedSelectionDataSource` is a concrete implementation of the `RSDTableDataSource` protocol
/// that is designed to be used with a `RSDTrackedItemsStep`.
open class RSDTrackedSelectionDataSource : RSDTableDataSource {

    /// The delegate associated with this data source.
    open weak var delegate: RSDTableDataSourceDelegate?
    
    /// The step associated with this data source.
    public let step: RSDStep
    
    /// The current task path.
    public let taskPath: RSDTaskPath
    
    /// The table sections for this data source.
    public let sections: [RSDTableSection]
    
    /// The list of item groups.
    public let itemGroups: [RSDChoicePickerTableItemGroup]
    
    /// The initial result when the data source was first displayed.
    public let initialResult: RSDTrackedItemsResult?
    
    /// Initialize a new `RSDFormStepDataSourceObject`.
    /// - parameters:
    ///     - step:             The RSDTrackedSelectionStep for this data source.
    ///     - taskPath:         The current task path for this data source.
    public init(step: RSDTrackedItemsStep, taskPath: RSDTaskPath) {
        self.step = step
        self.taskPath = taskPath
        
        // Look for an initial result in either the taskPath or on self.
        var initialResult: RSDTrackedItemsResult?
        if let result = step.result {
            initialResult = result
        }
        else if let previousResult = taskPath.previousResults?.rsd_last(where: { $0.identifier == step.identifier }) as? RSDTrackedItemsResult {
            initialResult = previousResult
        }
        self.initialResult = initialResult
        
        // build the sections and groups
        let (sections, groups) = type(of: self).buildSections(step: step, initialResult: initialResult)
        self.sections = sections
        self.itemGroups = groups
    }
    
    open class func buildSections(step: RSDTrackedItemsStep, initialResult: RSDTrackedItemsResult?) -> ([RSDTableSection], [RSDChoicePickerTableItemGroup]) {

        let sectionItems = step.sections ?? []
        let dataType: RSDFormDataType = .collection(.multipleChoice, .string)
        var trackedItems = step.items
        var trackedAnswers = initialResult?.selectedAnswers ?? []
        var tableSections: [RSDTableSection] = []
        var itemGroups: [RSDChoicePickerTableItemGroup] = []
        
        func appendSection(choices: [RSDTrackedItem], section: RSDTrackedSection?) {
            let identifier = section?.identifier ?? step.identifier
            let idx = tableSections.count
            let field = RSDChoiceInputFieldObject(identifier: identifier, choices: choices, dataType: dataType, uiHint: .list)
            // group
            let group = RSDChoicePickerTableItemGroup(beginningRowIndex: 0, inputField: field, uiHint: .list, choicePicker: field)
            group.sectionIndex = idx
            itemGroups.append(group)
            // table section
            let tableSection = RSDTableSection(sectionIndex: idx, tableItems: group.items)
            tableSection.title = (section?.text ?? section?.identifier) ?? (
                idx > 0 ? Localization.localizedString("OTHER_SECTION_TITLE") : nil
            )
            tableSection.subtitle = section?.detail
            tableSections.append(tableSection)
            // selection state
            let choiceIdentifiers = choices.map { $0.identifier }
            let answers = trackedAnswers.remove(where: { choiceIdentifiers.contains($0.identifier) }).map { $0.identifier }
            let selectableItems = group.items as! [RSDChoiceTableItem]
            for input in selectableItems {
                input.selected = answers.contains((input.choice as! RSDTrackedItem).identifier)
            }
            try! group.setAnswer(answers)
        }
        
        // Look through the sections first for a mapped item
        for section in sectionItems {
            let choices = trackedItems.remove(where: { $0.sectionIdentifier == section.identifier })
            appendSection(choices: choices, section: section)
        }
        
        // Look through the items for a sectionIdentifier without a matching section
        var otherSections: [String] = []
        for item in trackedItems {
            if let sectionIdentifier = item.sectionIdentifier, !otherSections.contains(sectionIdentifier) {
                otherSections.append(sectionIdentifier)
            }
        }
        for sectionIdentifier in otherSections {
            let choices = trackedItems.remove(where: { $0.sectionIdentifier == sectionIdentifier })
            let section = RSDTrackedSectionObject(identifier: sectionIdentifier)
            appendSection(choices: choices, section: section)
        }
        
        // Look for answers and items without a matching section and add those last
        let otherItems: [RSDTrackedItem] = trackedAnswers.map {
            return ($0 as? RSDTrackedItem) ?? RSDIdentifier(rawValue: $0.identifier)
        }
        trackedItems.append(contentsOf: otherItems)
        if trackedItems.count > 0 {
            appendSection(choices: trackedItems, section: nil)
        }

        return (tableSections, itemGroups)
    }
    
    // MARK: Selection management
    
    /// The tracking result associated with this data source. The default implementation is to search the
    /// `taskPath` for a matching result and if that fails to return a new instance created using
    /// `instantiateTrackingResult()`.
    ///
    /// - returns: The appropriate tracking result.
    open func trackingResult() -> RSDTrackedItemsResult {
        if let trackingResult = taskPath.result.stepHistory.rsd_last(where: { $0.identifier == step.identifier }) as? RSDTrackedItemsResult {
            return trackingResult
        }
        else {
            return instantiateTrackingResult()
        }
    }
    
    /// Instantiate a tracking result of the appropriate object type for this data source.
    /// The default implementation returns a new instance of `RSDTrackedItemsResultObject`.
    ///
    /// - returns: The appropriate tracking result.
    open func instantiateTrackingResult() -> RSDTrackedItemsResult {
        return self.step.instantiateStepResult() as? RSDTrackedItemsResult ??
            RSDTrackedItemsResultObject(identifier: step.identifier)
    }
    
    // MARK: RSDTableDataSource implementation
    
    open func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        guard indexPath.section < itemGroups.count else { return nil }
        return itemGroups[indexPath.section]
    }
    
    open func allAnswersValid() -> Bool {
        return self.trackingResult().selectedAnswers.count > 0
    }
    
    open func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        assertionFailure("This is not a valid method of changing the answer for this table data source")
    }
    
    open func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard let itemGroup = self.itemGroup(at: indexPath) as? RSDChoicePickerTableItemGroup else {
            return (false, false)
        }
        
        // TODO: syoung 03/01/2018 If the user is de-selecting a tracked item that they selected in a
        // previous run (and may have added details for it), then we want to alert them and confirm that
        // this was not an accident. Not sure where to add this particular special-case requirement, but
        // adding a TODO comment to track that it needs to be implemented.
        
        // update selection for this group
        let ret = try itemGroup.select(item, indexPath: indexPath)
        let selectedIdentifiers = itemGroups.rsd_mapAndFilter({ $0.answer as? [String] }).flatMap{$0}
        let items = (self.step as? RSDTrackedItemsStep)?.items ?? []
        
        // Update the answers
        var stepResult = self.trackingResult()
        stepResult.updateSelected(to: selectedIdentifiers, with: items)
        self.taskPath.appendStepHistory(with: stepResult)
        
        // inform delegate that answers have changed
        if let delegate = delegate {
            delegate.answersDidChange(in: indexPath.section)
        }
        
        return ret
    }
}
