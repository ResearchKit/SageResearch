//
//  RSDVerticalGridCollectionViewFlowLayout.swift
//  ResearchUI (iOS)
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// The 'RSDVerticalGridCollectionViewFlowLayout' creates a centered grid layout.
/// As the class name implies, this class only works currently in a vertical orientation.
///
/// 'itemCount' and 'collectionViewWidth' must be set, and the collection view delegate
/// must use 'sectionCount', 'itemCountInGridRow', and 'sectionInset' functions,
/// provided by this class to render the collection view grid correctly.
/// This is because the class works by making each row of the grid be a section.
///
public class RSDVerticalGridCollectionViewFlowLayout: UICollectionViewFlowLayout {
            
    /// The number of columns in each row of the grid.
    open var columnCount: Int = 3 {
        didSet {
            self.invalidateLayout()
        }
    }
    
    /// Set the collection view width so the view can calculate the cell width.
    open var collectionViewWidth: CGFloat = -1.0
    
    /// The width of a cell in the row when it is full at the column count.
    fileprivate var cellWidth: CGFloat {
        guard collectionViewWidth > 0,
            columnCount > 0
            else {
                return 0
            }
        
        let width = (collectionViewWidth - (CGFloat(columnCount) * horizontalCellSpacing)) / CGFloat(columnCount)
        // Round down the value so that we make sure the cells fit in the full width.
        return CGFloat(Int(width))
    }
        
    /// The height of each individual cell.
    open var cellHeightAbsolute: CGFloat = 120
    
    /// If non-negative, this will be used  to determine height instead of the absolute height,
    /// ratio is width * ratio = height.
    open var cellHeightRatio: CGFloat = -1
    
    /// If cellHeightRatio is non-negative, it will be used  to determine height instead of the absolute height.
    /// Otherwise the height will be the absolute cellHeight var.
    fileprivate var cellHeight: CGFloat {
        if cellHeightRatio > 0 {
            return cellWidth * cellHeightRatio
        }
        return cellHeightAbsolute
    }
    
    /// The horizontal spacing between cells.
    open var horizontalCellSpacing: CGFloat = 0 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    
    /// The vertical spacing between each individual cell.
    open var verticalCellSpacing: CGFloat = 0 {
        didSet {
            self.refreshCellSpacing()
        }
    }
    
    /// The ratio of cellSpacing to cell horizontal border.
    open var cellHorizontalBorderRatio = 0.5
    
    /// The number of items in the grid.
    open var itemCount: Int = 0 {
        didSet {
            if itemCount > 0 {
                self.itemSize = self.cellSize(for: IndexPath(row: 0, section: 0))
                self.invalidateLayout()
            }
        }
    }
    
    /// This needs to be used for the collection view delegate section count.
    public var sectionCount: Int {
        guard columnCount > 0 else { return 0 }
        return ((itemCount - 1) / columnCount) + 1
    }
    
    /// This needs to be used for the collection view delegate section count.
    public func itemCountInGridRow(gridRow: Int) -> Int {
        guard columnCount > 0 else { return 0 }
        let lastGridRow = itemCount / columnCount
        if gridRow < lastGridRow {
            return columnCount
        }
        return itemCount % columnCount
    }
    
    /// Return the item index from the index path.
    public func itemIndex(for indexPath: IndexPath) -> Int {
        return (indexPath.gridrow * columnCount) + indexPath.gridcolumn
    }
    
    /// The leading and trailing padding for a cell to make it centered horizontally.
    /// For most items in most rows, this is 0, as they are a full row,
    /// but for the last row where there may be less items than the column count,
    /// this can be used to make those items the same size as the previous items rows.
    public func secionInset(for gridRow: Int) -> UIEdgeInsets {
        
        // Check for valid collection view size
        guard collectionViewWidth > 0,
            columnCount > 0
            else {
                return UIEdgeInsets.zero
            }

        // See if we are in the last row, the row of interest.
        let lastGridRow = itemCount / columnCount

        // Top inset is zero on first row, and cell spacing for every other.
        let topInset = (gridRow == 0) ? 0 : verticalCellSpacing
        // Bottom inset is zero for all row but the last.
        let bottomInset: CGFloat = (gridRow >= lastGridRow) ? verticalCellSpacing : 0
        // Calculate the cells width in the row and find the section inset to center them.
        let itemsInRow = itemCountInGridRow(gridRow: gridRow)
        let cellsWidth = (self.cellWidth * CGFloat(itemsInRow)) + (horizontalCellSpacing * CGFloat(itemsInRow - 1))
        let leadingTrailingInset = CGFloat(Int((collectionViewWidth - cellsWidth) * CGFloat(0.5))) - 1
        
        return UIEdgeInsets(top: topInset, left: leadingTrailingInset, bottom: bottomInset, right: leadingTrailingInset)
    }
    
    /// The cell size for the item.
    public final func cellSize(for indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    /// Refresh the cell spacing in the underlying flow layout.
    private func refreshCellSpacing() {
        self.sectionInset = UIEdgeInsets(top: verticalCellSpacing, left: horizontalCellSpacing, bottom: verticalCellSpacing, right: horizontalCellSpacing)
        self.minimumInteritemSpacing = horizontalCellSpacing
        self.minimumLineSpacing = verticalCellSpacing
        self.invalidateLayout()
    }
}

extension IndexPath {
   fileprivate var gridrow: Int { return section }
   fileprivate var gridcolumn: Int { return item }
}
