//
//  RSDTableDataSource.swift
//  Research
//

import Foundation

@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDUIRowAnimation : Int {
    case fade, right, left, top, bottom, none, middle, automatic
}

/// Delegate for the data source.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTableDataSourceDelegate: AnyObject {
    
    /// Called when the answers tracked by the data source change.
    /// - parameters:
    ///     - dataSource: The calling data source.
    ///     - section: The section that changed.
    func tableDataSource(_ dataSource: RSDTableDataSource, didChangeAnswersIn section: Int)
    
    /// Called *before* editing the table rows and sections.
    func tableDataSourceWillBeginUpdate(_ dataSource: RSDTableDataSource)
    
    /// Called to remove rows from a data source. Calls to this method should be wrapped within a begin/end
    /// update.
    func tableDataSource(_ dataSource: RSDTableDataSource, didRemoveRows removedRows:[IndexPath], with animation: RSDUIRowAnimation)
    
    /// Called to add rows to a data source. Calls to this method should be wrapped within a begin/end
    /// update.
    func tableDataSource(_ dataSource: RSDTableDataSource, didAddRows addedRows:[IndexPath], with animation: RSDUIRowAnimation)
    
    /// Called *after* editing the table rows and sections.
    func tableDataSourceDidEndUpdate(_ dataSource: RSDTableDataSource)
}

/// `RSDTableDataSource` is the model for a table view controller. It provides the UITableViewDataSource,
/// manages and stores answers provided through user input, and provides an `RSDResult` with those answers upon
/// request.
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
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTableDataSource : RSDStepViewPathComponent {
    
    /// The delegate associated with this data source.
    var delegate: RSDTableDataSourceDelegate? { get set }
    
    /// The table sections for this data source.
    var sections: [RSDTableSection] { get }
    
    /// Retrieve the 'RSDTableItemGroup' for a specific IndexPath.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The requested `RSDTableItemGroup`, or nil if it cannot be found.
    func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup?
    
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
    /// - parameters:
    ///     - item: The table item that was selected or deselected.
    ///     - indexPath: The `IndexPath` that represents the `RSDTableItem` in the  table view.
    /// - returns:
    ///     - isSelected: The new selection state of the selected item.
    ///     - reloadSection: `true` if the section needs to be reloaded b/c other answers have changed,
    ///                      otherwise returns `false`.
    /// - throws: `RSDInputFieldError` if the selection is invalid.
    func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool)
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTableDataSource {
    
    /// Retrieve the `RSDTableItem` for a specific `IndexPath`.
    /// - parameter indexPath: The `IndexPath` that represents the table item in the table view.
    /// - returns: The requested `RSDTableItem`, or nil if it cannot be found.
    public func tableItem(at indexPath: IndexPath) -> RSDTableItem? {
        guard indexPath.section < sections.count,
            indexPath.item < sections[indexPath.section].tableItems.count
            else {
                debugPrint("Failed to get index path: \(indexPath): \(sections.count) ")
                if indexPath.section < sections.count {
                    debugPrint(sections[indexPath.section].tableItems)
                }
                return nil
        }
        return sections[indexPath.section].tableItems[indexPath.item]
    }
    
    /// Retrieve the next table item after the current one at the given index path.
    /// - parameter indexPath: The index path that represents the item group in the table view.
    /// - returns: The next `RSDTableItem` or `nil` if this was the last item.
    public func nextItem(after indexPath: IndexPath) -> RSDTableItem? {
        guard indexPath.section < sections.count else { return nil }
        if indexPath.item + 1 < sections[indexPath.section].tableItems.count {
            return sections[indexPath.section].tableItems[indexPath.item + 1]
        } else if indexPath.section + 1 < sections.count {
            return sections[indexPath.section + 1].tableItems.first
        } else {
            return nil
        }
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol ItemState : AnyObject {
    var identifier: String { get }
    var indexPath: IndexPath { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol TextInputItemState : ItemState {
    var answerText: String? { get }
    var answer: Any? { get }
    var keyboardOptions: KeyboardOptions { get }
    var inputPrompt: String? { get }
    var placeholder: String? { get }
    var uiHint: RSDFormUIHint { get }
    var pickerSource: RSDPickerDataSource? { get }
    func answerText(for answer: Any?) -> String?
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol ChoiceInputItemState : ItemState {
    var selected: Bool { get }
    var choice: RSDChoice { get }
}
