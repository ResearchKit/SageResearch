//
//  RSDTableItemGroup.swift
//  Research
//

import Foundation

/// `RSDTableItemGroup` is a generic table item group object that can be used to display information in a tableview
/// that does not have an associated input field.
@available(*,deprecated, message: "Will be deleted in a future version.")
open class RSDTableItemGroup {
    
    /// The list of items (or rows) included in this group. A table group can be used to represent one or more rows.
    public let items: [RSDTableItem]
    
    /// The section index for this group.
    public var sectionIndex: Int = 0
    
    /// The row index for the first row in the group.
    public let beginningRowIndex: Int
    
    /// A unique identifier that can be used to track the group.
    public let uuid = UUID()
    
    /// Determine if the current answer is valid. Also checks the case where answer is required but one has not
    /// been provided.
    open var isAnswerValid: Bool {
        return true
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The row index for the first row in the group.
    ///     - items: The list of items (or rows) included in this group.
    public init(beginningRowIndex: Int, items: [RSDTableItem]) {
        self.beginningRowIndex = beginningRowIndex
        self.items = items
    }
}
