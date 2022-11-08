//
//  RSDTableItem.swift
//  Research
//

import Foundation

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDUIStep {

    /// Convenience method for building the sections of the table from the input fields.
    /// - returns: The footer items to add to the table.
    public func buildFooterTableItems() -> [RSDTableItem]? {
        
        // add image below and footnote
        var items: [RSDTableItem] = []
        if let imageTheme = (self as? RSDDesignableUIStep)?.imageTheme, imageTheme.placementType == .iconAfter {
            items.append(RSDImageTableItem(rowIndex: items.count, imageTheme: imageTheme))
        }
        if let footnote = self.footnote {
            items.append(RSDTextTableItem(rowIndex: items.count, text: footnote))
        }
        
        guard items.count > 0 else { return nil }
        return items
    }
}

/// `RSDTableItem` can be used to represent the type of the row to display.
@available(*,deprecated, message: "Will be deleted in a future version.")
open class RSDTableItem {
    
    /// A unique identifier for the table item.
    public let identifier: String
    
    /// The index of this item relative to all rows in the section in which this item resides.
    public var rowIndex: Int
    
    /// A unique identifier for the section.
    public internal(set) var sectionIdentifier: String!
    
    /// The section index for this group.
    public internal(set) var sectionIndex: Int = 0
    
    /// The string to use as the reuse identifier.
    public let reuseIdentifier: String
    
    /// Return the index path of the item.
    public var indexPath: IndexPath {
        return IndexPath(item: rowIndex, section: sectionIndex)
    }
    
    /// Initialize a new RSDTableItem.
    /// - parameters:
    ///     - identifier: The cell identifier.
    ///     - rowIndex: The index of this item relative to all rows in the section in which this item resides.
    ///     - reuseIdentifier: The string to use as the reuse identifier.
    public init(identifier: String, rowIndex: Int, reuseIdentifier: String) {
        self.identifier = identifier
        self.rowIndex = rowIndex
        self.reuseIdentifier = reuseIdentifier
    }
    
    /// The `ReuseIdentifier` is a list of reuse identifiers used by this framework
    /// to register table cells in a table.
    ///
    /// In addition to the values listed here, the default behavior for the `RSDTableItem`
    /// subclasses includes optional support for all standard `RSDFormUIHint` values.
    ///
    public enum ReuseIdentifier : String, Codable {
        
        /// Display a label (text that cannot be edited). This is used for
        /// text in a footnote or other additional detail information.
        case label = "label"
        
        /// Display an image.
        case image = "image"
    }
    
    /// A list of all the `RSDTableItem.reuseIdentifier` values that are standard to this framework.
    public static var allStandardReuseIdentifiers: [String] {
        let baseIds: [ReuseIdentifier] = [.label, .image]
        var reuseIds = baseIds.map { $0.stringValue }
        reuseIds.append(contentsOf: RSDFormUIHint.allStandardHints.map { $0.stringValue })
        return reuseIds
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTableItem : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(sectionIdentifier ?? "")
    }
    
    public static func ==(lhs: RSDTableItem, rhs: RSDTableItem) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.sectionIdentifier == rhs.sectionIdentifier
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTableItem : CustomStringConvertible {
    
    public var description: String {
        return "<\(String(describing: type(of: self))) \(rowIndex) {\(String(describing: self.sectionIdentifier)) : \(self.identifier)} >"
    }
}

/// `RSDTextTableItem` is used to represent a item row that has static text.
@available(*,deprecated, message: "Will be deleted in a future version.")
public final class RSDTextTableItem : RSDTableItem {
    
    /// The text to display.
    public let text: String
    
    /// Initialize a new `RSDTextTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - text:          The text to display.
    public init(rowIndex: Int, text: String) {
        self.text = text
        super.init(identifier: text, rowIndex: rowIndex, reuseIdentifier: RSDTableItem.ReuseIdentifier.label.rawValue)
    }
}

/// `RSDImageTableItem` is used to represent a item row that has a static image.
@available(*,deprecated, message: "Will be deleted in a future version.")
public final class RSDImageTableItem : RSDTableItem {
    
    /// The image to display.
    public let imageTheme: RSDImageThemeElement
    
    /// Initialize a new `RSDImageTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - imageTheme:    The image to display.
    public init(rowIndex: Int, imageTheme: RSDImageThemeElement) {
        self.imageTheme = imageTheme
        super.init(identifier: imageTheme.imageIdentifier, rowIndex: rowIndex, reuseIdentifier: RSDTableItem.ReuseIdentifier.image.rawValue)
    }
}
