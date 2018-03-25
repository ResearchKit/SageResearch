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
open class RSDTrackedSelectionDataSource : RSDTrackingDataSource {

    /// Overrridable class function for building the sections of the table.
    /// - parameters:
    ///     - step: The RSDTrackedSelectionStep for this data source.
    ///     - initialResult: The initial result (if any).
    /// - returns:
    ///     - sections: The built table sections.
    ///     - itemGroups: The associated item groups.
    override open class func buildSections(step: RSDTrackedItemsStep, initialResult: RSDTrackedItemsResult?) -> (sections: [RSDTableSection], itemGroups: [RSDTableItemGroup]) {

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
            let tableSection = RSDTableSection(identifier: identifier, sectionIndex: idx, tableItems: group.items)
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
    
    /// Select or deselect the answer option for a specific IndexPath.
    /// - parameter indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - returns:
    ///     - isSelected: The new selection state of the selected item.
    ///     - reloadSection: `true` if the section needs to be reloaded b/c other answers have changed,
    ///                      otherwise returns `false`.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    override open func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard let itemGroup = self.itemGroup(at: indexPath) as? RSDChoicePickerTableItemGroup else {
            return (false, false)
        }
        
        // update selection for this group
        let ret = try itemGroup.select(item, indexPath: indexPath)
        let choiceGroups = self.itemGroups.filter { $0 is RSDChoicePickerTableItemGroup } as! [RSDChoicePickerTableItemGroup]
        let selectedIdentifiers = choiceGroups.flatMap({ $0.answer as? [String] }).flatMap{$0}
        let items = (self.step as? RSDTrackedItemsStep)?.items ?? []
        
        // Update the answers
        var stepResult = self.trackingResult()
        stepResult.updateSelected(to: selectedIdentifiers, with: items)
        self.taskPath.appendStepHistory(with: stepResult)
        
        // inform delegate that answers have changed
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
        
        return ret
    }
}
