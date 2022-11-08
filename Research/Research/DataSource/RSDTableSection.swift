//
//  RSDTableSection.swift
//  Research
//

import Foundation

/// Defines a section in a table. A table is made up of sections, groups, and items.
///
/// For most group types, there is one cell per group and there can be one or more groups per section.
/// However, there are exceptions such as multiple-choice lists where each value is displayed in a
/// selectable table item.
@available(*,deprecated, message: "Will be deleted in a future version.")
open class RSDTableSection {
    
    /// A unique identifier for the section.
    public let identifier: String
    
    /// The list of items included in this section.
    open private(set) var tableItems: [RSDTableItem]
    
    /// The table section index.
    open private(set) var index: Int
    
    /// The title for this section.
    public var title: String?
    
    /// The subtitle for this section.
    public var subtitle: String?
    
    /// Returns the total count of all Items in this section.
    /// - returns: The total number of `RSDTableItems` in this section.
    open func rowCount() -> Int {
        return tableItems.count
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - sectionIndex: The table section index for this item.
    ///     - tableItems: The table items in this section.
    public init(identifier: String, sectionIndex: Int, tableItems: [RSDTableItem]) {
        self.identifier = identifier
        self.index = sectionIndex
        for (idx, item) in tableItems.enumerated() {
            item.sectionIndex = sectionIndex
            item.rowIndex = idx
            item.sectionIdentifier = identifier
        }
        self.tableItems = tableItems
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTableSection : CustomStringConvertible {

    public var description: String {
        var description = "<\(String(describing: type(of: self))) \(self.index) \(self.identifier)>"
        if let title = self.title {
            description.append(" \(title)")
        }
        for item in tableItems {
            description.append("\n  \(String(describing: item))")
        }
        description.append("\n")
        return description
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTableSection : Equatable {
    
    public static func ==(lhs: RSDTableSection, rhs: RSDTableSection) -> Bool {
        return lhs.tableItems == rhs.tableItems && lhs.title == rhs.title
    }
}
