//
//  RSDCollectionViewCell.swift
//  ResearchUI (iOS)
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
