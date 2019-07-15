//
//  RSDTableSectionHeader.swift
//  ResearchUI (iOS)
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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


/// `RSDStepChoiceSectionHeader` is the base implementation for a selection table view section header of a form step.
@IBDesignable open class RSDTableSectionHeader: UITableViewHeaderFooterView, RSDViewDesignable {
    
    @IBOutlet open var titleLabel: UILabel!
    @IBOutlet open var detailLabel: UILabel!
    @IBOutlet open var separatorLine: UIView?
    
    open private(set) var titleTextType: RSDDesignSystem.TextType = .mediumHeader
    open private(set) var detailTextType: RSDDesignSystem.TextType = .bodyDetail
    
    /// The background color for the table section.
    open private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        let contentTile = designSystem.colorRules.tableSectionBackground(on: background)
        self.backgroundColorTile = contentTile
        self.recursiveSetDesignSystem(designSystem, with: contentTile)
    }
    
    func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let contentTile = self.backgroundColorTile ?? RSDGrayScale().white
        
        contentView.backgroundColor = contentTile.color
        separatorLine?.backgroundColor = designSystem.colorRules.separatorLine
        titleLabel.textColor = designSystem.colorRules.textColor(on: contentTile, for: titleTextType)
        titleLabel.font = designSystem.fontRules.font(for: titleTextType, compatibleWith: traitCollection)
        detailLabel?.textColor = designSystem.colorRules.textColor(on: contentTile, for: detailTextType)
        detailLabel.font = designSystem.fontRules.font(for: detailTextType, compatibleWith: traitCollection)
    }
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.white
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = .left
        titleLabel.rsd_alignToSuperview([.leading], padding: kTableSideMargin)
        titleLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kTableSideMargin, priority: .required)
        titleLabel.rsd_alignToSuperview([.top], padding: kTableSectionTopMargin, priority: UILayoutPriority(rawValue: 700))
        
        // Add the detail label
        detailLabel = UILabel()
        contentView.addSubview(detailLabel)
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor.darkGray
        detailLabel.textAlignment = .left
        detailLabel.rsd_alignToSuperview([.leading], padding: kTableSideMargin)
        detailLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kTableSideMargin, priority: .required)
        detailLabel.rsd_alignToSuperview([.bottom], padding: kTableBottomMargin)
        detailLabel.rsd_alignBelow(view: titleLabel, padding: 2.0)
        
        // Add the line separator
        separatorLine = UIView()
        separatorLine!.backgroundColor = UIColor.lightGray
        contentView.addSubview(separatorLine!)
        
        separatorLine!.translatesAutoresizingMaskIntoConstraints = false
        separatorLine!.rsd_alignToSuperview([.leading, .bottom, .trailing], padding: 0.0)
        separatorLine?.rsd_makeHeight(.equal, 1.0)
        
        setNeedsUpdateConstraints()
        updateColorsAndFonts()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateColorsAndFonts()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}
