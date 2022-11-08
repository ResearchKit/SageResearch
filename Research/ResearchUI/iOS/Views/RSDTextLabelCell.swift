//
//  RSDTextLabelCell.swift
//  ResearchUI (iOS)
//

import Foundation
import UIKit
import Research

/// `RSDTextLabelCell` can be used to display a text element such as a footnote in a table.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
