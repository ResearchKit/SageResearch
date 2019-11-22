//
//  RSDVerticalGridCollectionView.swift
//  ResearchUI (iOS)
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// The 'RSDVerticalGridCollectionView' is a normal collection view that forces a
/// 'RSDVerticalGridCollectionViewFlowLayout' as the colelction view layout
open class RSDVerticalGridCollectionView: UICollectionView {
    
    /// Force cast of collectin view layout as a RSDVerticalGridCollectionViewFlowLayout
    open var gridLayout: RSDVerticalGridCollectionViewFlowLayout {
        return self.collectionViewLayout as! RSDVerticalGridCollectionViewFlowLayout
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(frame: frame, collectionViewLayout: layout)
                        
        if !layout.isKind(of: RSDVerticalGridCollectionViewFlowLayout.self) {
            debugPrint("WARNING: UICollectionViewLayout must be RSDVerticalGridCollectionViewFlowLayout, provided one will be overwritten")
            self.initDefaultFlowLayout()
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initDefaultFlowLayout()
    }
    
    fileprivate func initDefaultFlowLayout() {
        let layout = RSDVerticalGridCollectionViewFlowLayout()
        self.collectionViewLayout = layout
    }
}

/// The 'RSDVerticalGridCollectionViewFlowLayout' creates a centered grid layout in conjunction with
/// the 'RSDVerticalGridCollectionView'.  As the class name implies, this class only works currently in a vertical orientation.
open class RSDVerticalGridCollectionViewFlowLayout: UICollectionViewFlowLayout {
            
    /// The number of columns in each row of the grid
    open var columnCount: Int = 3
    
    /// The width of a cell in the row when it is full at the column count
    fileprivate var cellWidth: CGFloat {
        let collectionViewWidth = (collectionView?.bounds.width ?? 0)
        if collectionViewWidth == 0 {
            return 0
        }
        let width = (collectionViewWidth - (CGFloat(columnCount) * horizontalCellSpacing)) / CGFloat(columnCount)
        // Round down the value so that we make sure the cells fit in the full width
        return CGFloat(Int(width))
    }
        
    /// The height of each individual cell
    open var cellHeightAbsolute: CGFloat = 120
    /// If non-negative, this will be used  to determine height instead of the absolute height
    /// Ratio is width * ratio = height
    open var cellHeightRatio: CGFloat = -1
    
    /// If cellHeightRatio is non-negative, it will be used  to determine height instead of the absolute height
    /// Otherwise the height will be the absolute cellHeight var
    fileprivate var cellHeight: CGFloat {
        if cellHeightRatio > 0 {
            return cellWidth * cellHeightRatio
        }
        return cellHeightAbsolute
    }
    
    /// The horizontal spacing between cells
    open var horizontalCellSpacingAbsolute: CGFloat = 12 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    /// If non-negative, this will be used  to determine horizontal cell spacing instead of the absolute spacing.
    /// The ratio is cell width * ratio = horizontal spacing.
    open var horizontalCellSpacingRatio: CGFloat = -1 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    /// If the cellSpacingRatio is non-negative, it will be used  to determine cell spacing instead of absoluteCellSpacing.
    /// Otherwise, the spacing will be the absoluteCellSpacing.
    fileprivate var horizontalCellSpacing: CGFloat {
        if horizontalCellSpacingRatio > 0 {
            let collectionViewWidth = collectionView?.bounds.width ?? 0
            if collectionViewWidth == 0 || columnCount == 0 {
                return 0
            }
            let estimatedCellWidth = collectionViewWidth / CGFloat(columnCount)
            return estimatedCellWidth * horizontalCellSpacingRatio
        }
        return horizontalCellSpacingAbsolute
    }
    
    /// The veritcal spacing between each individual cell
    open var verticalCellSpacingAbsolute: CGFloat = 12 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    /// If non-negative, this will be used  to determine cell spacing instead of the absolute spacing
    /// Ratio is cell height * ratio = vertical spacing
    open var verticalCellSpacingRatio: CGFloat = -1 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    /// If the vertical ratio is non-negative, it will be used to determine vertical spacing between each cell.
    /// Otherwise, the vertical spacing will be the absolute value
    fileprivate var verticalCellSpacing: CGFloat {
        if verticalCellSpacingRatio > 0 {
            let collectionViewWidth = collectionView?.bounds.width ?? 0
            if collectionViewWidth == 0 || columnCount == 0 {
                return 0
            }
            var cellHeight = cellHeightAbsolute
            if cellHeightRatio > 0 {
                let estimatedCellWidth = collectionViewWidth / CGFloat(columnCount)
                cellHeight = estimatedCellWidth * cellHeightRatio
            }
            return cellHeight * verticalCellSpacingRatio
        }
        return verticalCellSpacingAbsolute
    }
    
    /// The ratio of cellSpacing to cell horizontal border
    open var cellHorizontalBorderRatio = 0.5
    
    /// The number of items in the grid
    open var itemCount: Int = 0 {
        didSet {
            if itemCount > 0 {
                self.itemSize = self.cellSize(for: IndexPath(row: 0, section: 0))
            }
        }
    }
    
    /// This needs to be used for the collection view delegate section count
    public var sectionCount: Int {
        return ((itemCount - 1) / columnCount) + 1
    }
    
    /// This needs to be used for the collection view delegate section count
    public func itemCountInSection(section: Int) -> Int {
        let lastRowIndex = itemCount / columnCount
        if section < lastRowIndex {
            return columnCount
        }
        return itemCount % columnCount
    }
    
    /// Return the item index from the index path
    public func itemIndex(for indexPath: IndexPath) -> Int {
        return (indexPath.section * columnCount) + indexPath.row
    }
    
    /// The leading and trailing padding for a cell to make it centered horizontally
    /// For most items in most rows, this is 0, as they are a full row,
    /// but for the last row where there may be less items than the column count,
    /// this can be used to make those items the same size as the previous items rows
    public func seciontInset(for section: Int) -> UIEdgeInsets {
        
        // Check for valid collection view size
        let collectionViewWidth = (collectionView?.bounds.width ?? 0)
        if collectionViewWidth == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        // See if we are in the last row, the row of interest
        let lastRowIndex = itemCount / columnCount

        // Top inset is zero on first row, and cell spacing for every other
        var topInset = verticalCellSpacing
        if section == 0 {
            topInset = 0
        }
        // Bottom inset is zero for all row but the last, and may be set again below
        var bottomInset = CGFloat(0)
        
        // Default insets of the cell spacing
        var leadingTrailingInset = CGFloat(Int(horizontalCellSpacing * CGFloat(cellHorizontalBorderRatio)))
        // Check for item being in the last row
        if section >= lastRowIndex {
            bottomInset = verticalCellSpacing
            // Calculate the cells width in the last row and find the section inset to center them
            let itemsInLastRow = itemCountInSection(section: lastRowIndex)
            let cellsWidth = (CGFloat(itemsInLastRow - 1) * horizontalCellSpacing) + (cellWidth * CGFloat(itemsInLastRow))
            leadingTrailingInset = (collectionViewWidth - cellsWidth) * CGFloat(0.5)
        }
        return UIEdgeInsets(top: topInset, left: leadingTrailingInset, bottom: bottomInset, right: leadingTrailingInset)
    }
    
    /// The cell size for the item
    public func cellSize(for indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    /// Refresh the cell spacing in the underlying flow layout
    func refreshCellSpacing() {
        self.sectionInset = UIEdgeInsets(top: verticalCellSpacing, left: horizontalCellSpacing, bottom: verticalCellSpacing, right: horizontalCellSpacing)
        self.minimumInteritemSpacing = horizontalCellSpacing
        self.minimumLineSpacing = verticalCellSpacing
    }
}
