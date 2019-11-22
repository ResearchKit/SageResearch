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
        
    /// The height of each individual cell
    open var cellHeight: CGFloat = 120
    
    /// The spacing between cells and between each cell and the collection view border
    open var cellSpacing: CGFloat = 10 {
        didSet {
            self.sectionInset = UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
            self.minimumInteritemSpacing = cellSpacing
            self.minimumLineSpacing = cellSpacing
        }
    }
    
    /// The number of items in the grid
    open var itemCount: Int = 0 {
        didSet {
            if itemCount > 0 {
                self.itemSize = self.gridCellSize(for: 0)
            }
        }
    }
    
    /// Calculate the row for the item index
    fileprivate func row(for itemIndex: Int) -> Int {
        return (itemIndex / columnCount)
    }
    
    /// The width of a cell in the row when it is full at the column count
    fileprivate var maxIconCollectionCellWidth: CGFloat {
        let collectionViewWidth = (collectionView?.bounds.width ?? 0)
        if collectionViewWidth == 0 {
            return 0
        }
        return ((collectionViewWidth - (CGFloat(columnCount + 1) * cellSpacing)) / CGFloat(columnCount))
    }
    
    /// The cell size for the items in a particular row. The last row may have different sizes
    /// then the rest of the rows as it may have less items and they need to fill the full space
    fileprivate func gridCellSize(for itemIndex: Int) -> CGSize {
        
        // Check for valid collection view size
        var collectionViewWidth = (collectionView?.bounds.width ?? 0)
        if collectionViewWidth == 0 {
            // Collection view size cannot be 0, 0
            return CGSize(width: 1, height: 1)
        }
        // Adjust the width to reflect outer leading/trailing padding
        collectionViewWidth -= (2 * cellSpacing)
        
        // The column width of a full row
        let columnWidth = self.maxIconCollectionCellWidth
        // See if we are in the last row, the row of interest
        let lastRowIndex = itemCount / columnCount
        let row = self.row(for: itemIndex)
        
        // Get the first and last item indexes of the last row
        let lastItemIndex = itemCount - 1
        let firstItemIndexOfLastRow = lastRowIndex * columnCount
        
        // Check for the special case of there only being one item in the row
        if row >= lastRowIndex && lastItemIndex == firstItemIndexOfLastRow {
            return CGSize(width: CGFloat(Int(collectionViewWidth)), height: cellHeight)
        } // Check to see if we should return the standard cell size, that of a full grid row
        else if row < lastRowIndex ||
            (itemIndex != lastItemIndex && itemIndex != firstItemIndexOfLastRow) {
            // Return the normal cell size of a full grid row
            return CGSize(width: CGFloat(Int(columnWidth)), height: cellHeight)
        }
        
        // Otherwise, the first and last cell will fill the rest of the width
        // To force the rest of the standard grid cells of the last row to be centered
        let middleCellsCount = (lastItemIndex - firstItemIndexOfLastRow - 1)
        let middleCellsWidth = (CGFloat(middleCellsCount + 1) * cellSpacing) + (CGFloat(middleCellsCount) * columnWidth)
        let outerCellsWidth = (collectionViewWidth - middleCellsWidth) * CGFloat(0.5)

        // Return an outer cell width for the last row
        return CGSize(width: CGFloat(Int(outerCellsWidth)), height: cellHeight)
    }
    
    /// The leading and trailing padding for a cell to make it centered horizontally
    /// For most items in most rows, this is 0, as they are a full row,
    /// but for the last row where there may be less items than the column count,
    /// this can be used to make those items the same size as the previous items rows
    public func horizontalPaddingToCenter(for itemIndex: Int) -> (leading: CGFloat, trailing: CGFloat) {
        // Calculate the horizontal padding to center the content with layout margins
        let cellSize = self.gridCellSize(for: itemIndex)
        let horizontalOffset = CGFloat(Int(cellSize.width - self.maxIconCollectionCellWidth))
        
        // Get the first and last item indexes of the last row
        let lastItemIndex = itemCount - 1
        let lastRowIndex = itemCount / columnCount
        let firstItemIndexOfLastRow = lastRowIndex * columnCount
                
        if itemIndex == lastItemIndex && lastItemIndex != firstItemIndexOfLastRow {
            // Have a trailing padding that will forec the last item of the last row centered
            return (0, horizontalOffset)
        } else if itemIndex == firstItemIndexOfLastRow && lastItemIndex != firstItemIndexOfLastRow {
            // Have a leading padding that will forec the first item of the last row centered
            return (horizontalOffset, 0)
        } else {
            // The horizontal offset will be 0 when it is a full row
            // or it may be non-zero if there is a single item in a row
            return (horizontalOffset * CGFloat(0.5), horizontalOffset * CGFloat(0.5))
        }
    }
    
    /// The cell size for the item index
    public func cellSize(for itemIndex: Int) -> CGSize {
        if itemCount == 0 {
            // Collectionview cannot have a cell of zero size
            return CGSize(width: 1, height: 1)
        }
        return self.gridCellSize(for: itemIndex)
    }
    
    public override init() {
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func refreshCellSpacing() {
        self.sectionInset = UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
        self.minimumInteritemSpacing = cellSpacing
        self.minimumLineSpacing = cellSpacing
    }
}

public protocol RSDGridCollectionViewCell {
    /// The grid collection view flow layout can communicate to a cell what the leading/trailing
    /// padding for the cell would be to make it the same size as the other smaller cells
    /// This can be used to make sure the content in all the cells is the same size
    func setLeadingTrailingPadding(leadingPadding: CGFloat, trailingPadding: CGFloat)
}
