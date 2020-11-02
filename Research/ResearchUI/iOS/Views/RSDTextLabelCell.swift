//
//  RSDTextLabelCell.swift
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
import UIKit
import Research

/// `RSDTextLabelCell` can be used to display a text element such as a footnote in a table.
@IBDesignable open class RSDTextLabelCell : RSDTableViewCell {
    
    private let kSideMargin = CGFloat(20.0).rsd_proportionalToScreenWidth()
    private let kVertMargin: CGFloat = 10.0
    private let kMinHeight: CGFloat = 75.0
    
    /// The label used to display text using this cell.
    @IBOutlet public var label: UILabel!
    
    /// Set the label text.
    override open var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDTextTableItem else { return }
            label.text = item.text
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        
        self.selectionStyle = .none
        
        if label == nil {
            
            label = UILabel()
            contentView.addSubview(label)
            
            label.accessibilityTraits = UIAccessibilityTraits.summaryElement
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (kSideMargin * 2)
            
            label.numberOfLines = 0
            label.textAlignment = .left
            
            label.rsd_alignToSuperview([.leading, .trailing], padding: kSideMargin)
            label.rsd_alignToSuperview([.top], padding: kVertMargin)
        }
        
        contentView.rsd_makeHeight(.greaterThanOrEqual, kMinHeight)
        
        updateColorAndFont()
        setNeedsUpdateConstraints()
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateColorAndFont()
    }
    
    func updateColorAndFont() {
        guard let colorTile = self.backgroundColorTile else { return }
        let designSystem = self.designSystem ?? RSDDesignSystem()
        label.font = designSystem.fontRules.font(for: .microDetail, compatibleWith: traitCollection)
        label.textColor = designSystem.colorRules.textColor(on: colorTile, for: .microDetail)
    }
}
