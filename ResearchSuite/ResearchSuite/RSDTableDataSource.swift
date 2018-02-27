//
//  RSDTableDataSource.swift
//  ResearchSuite
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

/// Delegate for the data source.
public protocol RSDTableDataSourceDelegate: class, NSObjectProtocol {
    
    /// Called when the answers tracked by the data source change.
    /// - parameter section: The section that changed.
    func answersDidChange(in section: Int)
}


/// `RSDTableDataSource`: the internal model for a table view controller. It provides the
/// UITableViewDataSource, manages and stores answers provided thru user input, and provides an RSDResult
/// with those answers upon request.
///
/// It also provides several convenience methods for saving or selecting answers, checking if all answers
/// are valid, and retrieving specific model objects that may be needed by the view controller.
///
/// The tableView data source is comprised of 2 objects:
///
/// 1. `RSDTableSection`: An object representing a section in the tableView. It has one or more
///    `RSDTableItem` objects.
///
/// 2. `RSDTableItem`: An object representing a specific table cell. There will be one `RSDTableItem` for
///     each indexPath in the tableView.
///
/// 3. `RSDTableItemGroup`: An object representing a specific question supplied by `RSDStep` as an input
///     field. Upon init(), the ItemGroup will create one or more `RSDTableItem` objects representing the
///     answer options for the `RSDInputField`. The ItemGroup is responsible for storing/computing the
///     answers for its `RSDInputField`.
///
public protocol RSDTableDataSource : class {
    
    /// The delegate associated with this data source.
    weak var delegate: RSDTableDataSourceDelegate? { get set }
    
    /// The step associated with this data source.
    var step: RSDStep { get }
    
    /// The current task path.
    var taskPath: RSDTaskPath { get }
    
    /// The table sections for this data source.
    var sections: [RSDTableSection] { get }
    
    /// Retrieve the `RSDTableItem` for a specific `IndexPath`.
    /// - parameter indexPath: The `IndexPath` that represents the table item in the table view.
    /// - returns: The requested `RSDTableItem`, or nil if it cannot be found.
    func tableItem(at indexPath: IndexPath) -> RSDTableItem?
    
    /// Retrieve the 'RSDTableItemGroup' for a specific IndexPath.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The requested `RSDTableItemGroup`, or nil if it cannot be found.
    func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup?
    
    /// Retrieve the next item group after the current one at the given index path.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The next `RSDTableItemGroup` or `nil` if this was the last item.
    func nextItem(after indexPath: IndexPath) -> RSDTableItemGroup?
    
    /// Retrieve the index path that points at the given item group.
    /// - parameter itemGroup: The item group.
    /// - returns: The index path for the given item group or `nil` if not found.
    func indexPath(for itemGroup: RSDTableItemGroup) -> IndexPath?
    
    /// Determine if all answers are valid. Also checks the case where answers are required but one has
    /// not been provided.
    /// - returns: A `Bool` indicating if all answers are valid.
    func allAnswersValid() -> Bool
    
    /// Save an answer for a specific IndexPath.
    /// - parameters:
    ///     - answer:      The object to be save as the answer.
    ///     - indexPath:   The `IndexPath` that represents the `RSDTableItem` in the table view.
    /// - throws: `RSDInputFieldError` if the answer is invalid.
    func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws
    
    /// Select or deselect the answer option for a specific IndexPath.
    /// - parameter indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws
}
