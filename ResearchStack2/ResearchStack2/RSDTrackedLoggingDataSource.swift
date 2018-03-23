//
//  RSDTrackedLoggingDataSource.swift
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

extension RSDFormUIHint {
    public static let logging: RSDFormUIHint = "logging"
}

/// `RSDTrackedLoggingDataSource` is a concrete implementation of the `RSDTableDataSource` protocol
/// that is designed to be used with a `RSDTrackedItemsStep` intended for logging of items that were
/// selected in a previous step.
open class RSDTrackedLoggingDataSource : RSDTrackingDataSource {
    
    /// Overrridable class function for building the sections of the table.
    /// - parameters:
    ///     - step: The RSDTrackedSelectionStep for this data source.
    ///     - initialResult: The initial result (if any).
    /// - returns:
    ///     - sections: The built table sections.
    ///     - itemGroups: The associated item groups.
    override open class func buildSections(step: RSDTrackedItemsStep, initialResult: RSDTrackedItemsResult?) -> (sections: [RSDTableSection], itemGroups: [RSDTableItemGroup]) {
        guard let result = initialResult else {
            assertionFailure("A non-nil initial result is expected for logging items")
            return ([], [])
        }
        
        let inputField = RSDChoiceInputFieldObject(identifier: step.identifier, choices: result.selectedAnswers, dataType: .collection(.multipleChoice, .string), uiHint: .logging)
        let trackedItems = result.selectedAnswers.enumerated().map { (idx, item) -> RSDTrackedLoggingTableItem in
            let choice: RSDChoice = step.items.first(where: { $0.identifier == item.identifier }) ?? item
            return RSDTrackedLoggingTableItem(rowIndex: idx, inputField: inputField, uiHint: .logging, choice: choice)
        }
        
        let itemGroup  = RSDTableItemGroup(beginningRowIndex: 0, items: trackedItems)
        let section = RSDTableSection(sectionIndex: 0, tableItems: trackedItems)
        
        return ([section], [itemGroup])
    }
    
    /// Override to mark the item as logged.
    /// - parameter indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - returns:
    ///     - isSelected: The new selection state of the selected item.
    ///     - reloadSection: `true` if the section needs to be reloaded b/c other answers have changed,
    ///                      otherwise returns `false`.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    override open func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard let loggingItem = item as? RSDTrackedLoggingTableItem else {
            return (false, false)
        }
        
        // update logged date for this item.
        loggingItem.loggedDate = Date()
        var loggedResult = RSDTrackedLoggingResultObject(identifier: loggingItem.identifier, text: loggingItem.choice.text, detail: loggingItem.choice.detail)
        loggedResult.loggedDate = loggingItem.loggedDate
        
        // Update the answers
        var stepResult = self.trackingResult()
        stepResult.updateDetails(to: loggedResult)
        self.taskPath.appendStepHistory(with: stepResult)
        
        // inform delegate that answers have changed
        if let delegate = delegate {
            delegate.answersDidChange(in: indexPath.section)
        }
        
        return (true, false)
    }
    
    /// Override to return valid if at least one answer is marked as logged.
    override open func allAnswersValid() -> Bool {
        return self.trackingResult().selectedAnswers.reduce(false, { $0 || $1.hasRequiredValues })
    }
    
    /// Open the selection view controller and edit the selection of the items to track.
    open func editSelectedItems() {
        
        // TODO: Implement syoung 03/23/2018
        
        // TODO: syoung 03/01/2018 If the user is de-selecting a tracked item that they selected in a
        // previous run (and may have added details for it), then we want to alert them and confirm that
        // this was not an accident. Not sure where to add this particular special-case requirement, but
        // adding a TODO comment to track that it needs to be implemented.
    }
}

/// Custom table group for handling marking items as selected with a timestamp.
open class RSDTrackedLoggingTableItem : RSDChoiceTableItem {
    
    /// The date when the event was logged.
    open var loggedDate: Date?
    
    /// The tracked item answer associated with the table item.
    open var identifier: String {
        return self.choice.answerValue as! String
    }

    /// Override the answer to return the timestamp.
    open override var answer: Any? {
        return loggedDate
    }
    
    /// Override the selected state to mark an item as selected using a timestamp.
    override open var selected : Bool {
        get { return loggedDate != nil }
        set {
            guard loggedDate == nil else { return }
            loggedDate = Date()
        }
    }
}
