//
//  RSDCollectionViewCell.swift
//  ResearchUI (iOS)
//

import UIKit

/// `RSDCollectionViewCell` is used to display a collection cell.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDCollectionViewCell : RSDDesignableCollectionViewCell {
    
    /// The index path of the cell.
    public var indexPath: IndexPath!
}

/// `RSDDesignableCollectionViewCell` is used to display a collection cell that conforms to the `RSDViewDesignable` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDDesignableCollectionViewCell : UICollectionViewCell, RSDViewDesignable {
    
    /// Does this cell use the colection view background color to set the color of the content view?
    open private(set) var usesCollectionBackgroundColor: Bool = false
    
    /// The background color for the collection cell.
    open var backgroundColorTile: RSDColorTile? {
        if usesCollectionBackgroundColor {
            if let background = collectionViewBackgroundColorTile {
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
    
    /// The background color tile for the collection view.
    open private(set) var collectionViewBackgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.collectionViewBackgroundColorTile = background
        if usesCollectionBackgroundColor {
            self.contentView.backgroundColor = background.color
        }
        if let contentTile = self.backgroundColorTile {
            self.recursiveSetDesignSystem(designSystem, with: contentTile)
        }
    }
}
