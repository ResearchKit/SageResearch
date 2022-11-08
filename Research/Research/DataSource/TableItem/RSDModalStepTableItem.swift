//
//  RSDModalStepTableItem.swift
//  Research
//

import Foundation

/// `RSDModalStepTableItem` is used to represent a item row that, when selected, should display a
/// step view controller.
@available(*,deprecated, message: "Will be deleted in a future version.")
open class RSDModalStepTableItem : RSDTableItem {
    
    /// The action to link to the selection cell or button.
    public let action: RSDUIAction?
    
    /// Initialize a new `RSDTextTableItem`.
    /// parameters:
    ///     - identifier: The cell identifier.
    ///     - rowIndex: The index of this item relative to all rows in the section in which this item resides.
    ///     - reuseIdentifier: The string to use as the reuse identifier.
    ///     - action: The action to link to the selection cell or button.
    public init(identifier: String, rowIndex: Int, reuseIdentifier: String, action: RSDUIAction? = nil) {
        self.action = action
        super.init(identifier: identifier, rowIndex: rowIndex, reuseIdentifier: reuseIdentifier)
    }
}
