//
//  RSDTableViewCell.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research

internal let kTableSideMargin: CGFloat = 28.0
internal let kTableSeparatorInsetMargin: CGFloat = 0.0
internal let kTableTopMargin: CGFloat = 20.0
internal let kTableBottomMargin: CGFloat = 12.0
internal let kTableSectionTopMargin: CGFloat = 40.0

/// `RSDTableViewCell` is used to display a table cell that is linked to a `RSDTableItem`.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDTableViewCell : RSDDesignableTableViewCell {
    
    /// The index path of the cell.
    public var indexPath: IndexPath!
    
    /// The table item associated with this cell.
    open var tableItem: RSDTableItem!
}

/// `RSDTableViewCell` is used to display a table cell that conforms to the `RSDViewDesignable` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDDesignableTableViewCell : UITableViewCell, RSDViewDesignable {
    
    /// Does this cell use the table background color to set the color of the content view?
    open private(set) var usesTableBackgroundColor: Bool = false
    
    /// The background color for the table cell.
    open var backgroundColorTile: RSDColorTile? {
        if usesTableBackgroundColor {
            if let background = tableBackgroundColorTile {
                return background
            }
            else {
                return RSDDesignSystem.shared.colorRules.palette.primary.normal
            }
        }
        else {
            return RSDDesignSystem.shared.colorRules.palette.grayScale.white
        }
    }
    
    /// The background color tile for the table.
    open private(set) var tableBackgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.tableBackgroundColorTile = background
        if usesTableBackgroundColor {
            self.contentView.backgroundColor = background.color
        }
        if let contentTile = self.backgroundColorTile {
            self.recursiveSetDesignSystem(designSystem, with: contentTile)
        }
    }
}
