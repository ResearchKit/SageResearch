//
//  RSDStepChoiceCell.swift
//  ResearchUI
//

import UIKit
import Research


/// `RSDSelectionTableViewCell` is the base implementation for a selection table view cell.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable open class RSDSelectionTableViewCell: RSDTableViewCell {
    
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var detailLabel: UILabel?
    @IBOutlet public var separatorLine: UIView?
    
    open override var isSelected: Bool {
        didSet {
            updateColorsAndFonts()
        }
    }
    
    open private(set) var titleTextType: RSDDesignSystem.TextType = .small
    open private(set) var detailTextType: RSDDesignSystem.TextType = .bodyDetail
    
    func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let background = self.backgroundColorTile ?? RSDGrayScale().white
        let contentTile = designSystem.colorRules.tableCellBackground(on: background, isSelected: isSelected)
        
        contentView.backgroundColor = contentTile.color
        separatorLine?.backgroundColor = designSystem.colorRules.separatorLine
        titleLabel?.textColor = designSystem.colorRules.textColor(on: contentTile, for: titleTextType)
        titleLabel?.font = designSystem.fontRules.font(for: titleTextType, compatibleWith: traitCollection)
        detailLabel?.textColor = designSystem.colorRules.textColor(on: contentTile, for: detailTextType)
        detailLabel?.font = designSystem.fontRules.font(for: detailTextType, compatibleWith: traitCollection)
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateColorsAndFonts()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel!)
        
        titleLabel!.translatesAutoresizingMaskIntoConstraints = false
        titleLabel!.numberOfLines = 0
        titleLabel!.textAlignment = .left
        titleLabel!.rsd_alignToSuperview([.leading], padding: kTableSideMargin)
        titleLabel!.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kTableSideMargin, priority: .required)
        titleLabel!.rsd_alignToSuperview([.top], padding: kTableTopMargin, priority: UILayoutPriority(rawValue: 700))
        
        // Add the detail label
        detailLabel = UILabel()
        contentView.addSubview(detailLabel!)
        
        detailLabel!.translatesAutoresizingMaskIntoConstraints = false
        detailLabel!.numberOfLines = 0
        detailLabel!.textAlignment = .left
        detailLabel!.rsd_alignToSuperview([.leading], padding: kTableSideMargin)
        detailLabel!.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kTableSideMargin, priority: .required)
        detailLabel!.rsd_alignToSuperview([.bottom], padding: kTableBottomMargin)
        detailLabel!.rsd_alignBelow(view: titleLabel!, padding: 2.0)
        
        // Add the line separator
        separatorLine = UIView()
        separatorLine!.backgroundColor = UIColor.lightGray
        contentView.addSubview(separatorLine!)
        
        separatorLine!.translatesAutoresizingMaskIntoConstraints = false
        separatorLine!.rsd_alignToSuperview([.leading], padding: kTableSeparatorInsetMargin)
        separatorLine!.rsd_alignToSuperview([.bottom, .trailing], padding: 0.0)
        separatorLine?.rsd_makeHeight(.equal, 1.0)
        
        updateColorsAndFonts()
        setNeedsUpdateConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateColorsAndFonts()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}

/// `RSDStepChoiceCell` is a custom implementationn of a selection table cell to use for choice selection
/// from a list of choices.
@available(*,deprecated, message: "Will be deleted in a future version.")
@IBDesignable public class RSDStepChoiceCell: RSDSelectionTableViewCell {
    
    override public var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? ChoiceInputItemState else { return }
            isSelected = item.selected
            titleLabel?.text = item.choice.text
            detailLabel?.text = item.choice.detail
        }
    }
}
