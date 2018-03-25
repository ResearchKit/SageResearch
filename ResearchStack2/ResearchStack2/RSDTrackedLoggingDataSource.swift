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
    
    /// Display a cell appropriate to logging a timestamp.
    public static let logging: RSDFormUIHint = "logging"
}

/// `RSDTrackedLoggingDataSource` is a concrete implementation of the `RSDTableDataSource` protocol
/// that is designed to be used with a `RSDTrackedItemsStep` intended for logging of items that were
/// selected in a previous step.
open class RSDTrackedLoggingDataSource : RSDTrackingDataSource, RSDModalStepDataSource, RSDModalStepTaskControllerDelegate {

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
        
        var itemGroups: [RSDTableItemGroup] = [RSDTableItemGroup(beginningRowIndex: 0, items: trackedItems)]
        var sections: [RSDTableSection] = [RSDTableSection(identifier: "logging", sectionIndex: 0, tableItems: trackedItems)]
        
        let actionType: RSDUIActionType = .navigation(.addMore)
        if let uiStep = step as? RSDUIActionHandler, let action = uiStep.action(for: actionType, on: step) {
            let tableItem = RSDModalStepTableItem(identifier: actionType.stringValue, rowIndex: 0, reuseIdentifier: RSDFormUIHint.modalButton.stringValue, action: action)
            itemGroups.append(RSDTableItemGroup(beginningRowIndex: 0, items: [tableItem]))
            sections.append(RSDTableSection(identifier: "addMore", sectionIndex: 1, tableItems: [tableItem]))
        }
        
        return (sections, itemGroups)
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
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
        
        return (true, false)
    }
    
    /// Override to return valid if at least one answer is marked as logged.
    override open func allAnswersValid() -> Bool {
        return self.trackingResult().selectedAnswers.reduce(false, { $0 || $1.hasRequiredValues })
    }
    
    // MARK: RSDModalStepDataSource
    
    /// Returns the selection step.
    open func step(for tableItem: RSDModalStepTableItem) -> RSDStep {
        guard let step = (self.taskPath.task?.stepNavigator as? RSDTrackedItemsStepNavigator)?.getSelectionStep() as? RSDTrackedItemsStep
            else {
                assertionFailure("Expecting the task navigator to be a tracked items navigator.")
            return RSDUIStepObject(identifier: tableItem.identifier)
        }
        step.result = self.trackingResult()
        return step
    }
    
    /// The calling table view controller will present a step view controller for the modal step. This method
    /// should set up the task controller for the step and handle any other task management required before
    /// presenting the step.
    ///
    /// - parameters:
    ///     - stepController: The step controller that was instantiated to run the step.
    ///     - tableItem: The table item that was selected.
    open func willPresent(_ stepController: RSDStepController, from tableItem: RSDModalStepTableItem) {
        guard let task = taskPath.task else {
            assertionFailure("Failed to set the task controller because the current task is nil.")
            return
        }
        
        // Set up the path and the task controller for the current step. For this case, we what a new task path that uses the task
        // from *this* taskPath as it's source, but which does not directly edit this task path.
        let path = RSDTaskPath(task: task)
        path.currentStep = stepController.step
        let taskController = RSDModalStepTaskController()
        _currentTaskController = taskController
        taskController.taskPath = path
        taskController.stepController = stepController
        taskController.delegate = self
        stepController.taskController = taskController
    }
    
    private var _currentTaskController: RSDModalStepTaskController?
    
    // MARK: RSDModalStepTaskControllerDelegate
    
    open func goForward(with taskController: RSDModalStepTaskController) {
        if let result = taskController.taskPath.result.findResult(for: taskController.stepController.step) as? RSDTrackedItemsResult {

            // Let the delegate know that things are changing.
            self.delegate?.tableDataSourceWillBeginUpdate(self)
            
            // Update the result set for this source.
            var stepResult = self.trackingResult()
            stepResult.updateSelected(to: result.selectedIdentifiers, with: trackedStep.items)
            self.taskPath.appendStepHistory(with: stepResult)
            let changes = self.reloadDataSource(with: result)

            // reload the table delegate.
            self.delegate?.tableDataSourceDidEndUpdate(self, addedRows: changes.addedRows, removedRows: changes.removedRows)
        }
        self.delegate?.tableDataSource(self, didFinishWith: taskController.stepController)
        _currentTaskController = nil
    }
    
    /// Default behavior is to dismiss the view controller without changes.
    open func goBack(with taskController: RSDModalStepTaskController) {
        self.delegate?.tableDataSource(self, didFinishWith: taskController.stepController)
        _currentTaskController = nil
    }
}

/// Custom table group for handling marking items as selected with a timestamp.
open class RSDTrackedLoggingTableItem : RSDChoiceTableItem {
    
    /// The date when the event was logged.
    open var loggedDate: Date?

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
