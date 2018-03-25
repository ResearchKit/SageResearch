//
//  RSDTrackingDataSource.swift
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

/// `RSDTrackingDataSource` is an abstract class for handling shared data tracking.
open class RSDTrackingDataSource : NSObject, RSDTableDataSource {
    
    /// The delegate associated with this data source.
    open weak var delegate: RSDTableDataSourceDelegate?
    
    /// The step associated with this data source.
    public var step: RSDStep {
        return trackedStep
    }
    
    /// The current task path.
    public private(set) var taskPath: RSDTaskPath!
    
    /// The table sections for this data source.
    public var sections: [RSDTableSection] {
        return _sections
    }
    private var _sections: [RSDTableSection]
    
    /// The list of item groups.
    public private(set) var itemGroups: [RSDTableItemGroup]
    
    /// The initial result when the data source was first displayed.
    public let initialResult: RSDTrackedItemsResult?
    
    // The tracked step for this source.
    public let trackedStep: RSDTrackedItemsStep
    
    /// Initialize a new `RSDFormStepDataSourceObject`.
    /// - parameters:
    ///     - step:             The RSDTrackedSelectionStep for this data source.
    ///     - taskPath:         The current task path for this data source.
    public init(step: RSDTrackedItemsStep, taskPath: RSDTaskPath) {
        self.trackedStep = step
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
        self._sections = sections
        self.itemGroups = groups
    }
    
    /// Reload the sections and groups for this table.
    /// - parameter selectionResult: The updated selection result.
    public func reloadDataSource(with selectionResult: RSDTrackedItemsResult) -> (addedRows: [IndexPath], removedRows: [IndexPath]) {
        let (sections, groups) = type(of: self).buildSections(step: trackedStep, initialResult: selectionResult)
        
        // Get the previous and new items
        let previousItems = Set(self.sections.flatMap { $0.tableItems })
        let newItems = Set(sections.flatMap { $0.tableItems })
        let addedRows = newItems.subtracting(previousItems).map { $0.indexPath }
        let removedRows = previousItems.subtracting(newItems).map { $0.indexPath }
        
        // Update the current sections
        self._sections = sections
        self.itemGroups = groups
        
        return (addedRows, removedRows)
    }
    
    /// Overrridable class function for building the sections of the table.
    /// - parameters:
    ///     - step: The RSDTrackedSelectionStep for this data source.
    ///     - initialResult: The initial result (if any).
    /// - returns:
    ///     - sections: The built table sections.
    ///     - itemGroups: The associated item groups.
    open class func buildSections(step: RSDTrackedItemsStep, initialResult: RSDTrackedItemsResult?) -> (sections: [RSDTableSection], itemGroups: [RSDTableItemGroup]) {
        fatalError("Abstract method - subclass must override")
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
    
    /// Retrieve the 'RSDTableItemGroup' for a specific IndexPath.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The requested `RSDTableItemGroup`, or nil if it cannot be found.
    open func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        guard indexPath.section < itemGroups.count else { return nil }
        return itemGroups[indexPath.section]
    }
    
    /// Determine if all answers are valid. Also checks the case where answers are required but one has
    /// not been provided.
    /// - returns: A `Bool` indicating if all answers are valid.
    open func allAnswersValid() -> Bool {
        return self.trackingResult().selectedAnswers.count > 0
    }
    
    /// Save an answer for a specific IndexPath.
    /// - parameters:
    ///     - answer:      The object to be save as the answer.
    ///     - indexPath:   The `IndexPath` that represents the `RSDTableItem` in the table view.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    open func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        assertionFailure("This is not a valid method of changing the answer for this table data source")
    }
    
    /// Select or deselect the answer option for a specific IndexPath.
    /// - parameter indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - returns:
    ///     - isSelected: The new selection state of the selected item.
    ///     - reloadSection: `true` if the section needs to be reloaded b/c other answers have changed,
    ///                      otherwise returns `false`.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    open func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        fatalError("Abstract method - subclass must override")
    }
}
