//
//  RSDStepChoiceCell.swift
//  ResearchStack2UI
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

fileprivate let kSideMargin: CGFloat = 28.0
fileprivate let kSeparatorInsetMargin: CGFloat = 0.0
fileprivate let kTopMargin: CGFloat = 20.0
fileprivate let kBottomMargin: CGFloat = 12.0
fileprivate let kSectionTopMargin: CGFloat = 40.0

/// `RSDTableViewCell` is used to display a table cell that is linked to a `RSDTableItem`.
@IBDesignable open class RSDTableViewCell : UITableViewCell {
    
    /// The index path of the cell.
    public var indexPath: IndexPath!
    
    /// The table item associated with this cell.
    open var tableItem: RSDTableItem!
    
    /// The background color of the containing table.
    open var tableBackgroundColor: UIColor!
    
    /// Whether or not the table uses light style.
    @IBInspectable open var usesLightStyle: Bool = false
}

/// `RSDStepChoiceCell` is the base implementation for a selection table view cell of a form step.
@IBDesignable public class RSDStepChoiceCell: RSDTableViewCell {
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var detailLabel: UILabel!
    @IBOutlet public var separatorLine: UIView?
    
    override public var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDChoiceTableItem else { return }
            titleLabel.text = item.choice.text
            detailLabel.text = item.choice.detail
            isSelected = item.selected
        }
    }
    
    private var bgColor: UIColor {
        return isSelected ? UIColor.rsd_choiceCellBackgroundHighlighted : UIColor.rsd_choiceCellBackground
    }
    
    private var labelColor: UIColor {
        return isSelected ? UIColor.rsd_choiceCellLabelHighlighted : UIColor.rsd_choiceCellLabel
    }
    
    private var detailLabelColor: UIColor {
        return isSelected ? UIColor.rsd_choiceCellDetailLabelHighlighted : UIColor.rsd_choiceCellDetailLabel
    }
    
    open override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = bgColor
            titleLabel.textColor = labelColor
            detailLabel?.textColor = detailLabelColor
        }
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.appBackgroundLight
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.rsd_choiceCellLabel
        titleLabel.textColor = labelColor
        titleLabel.textAlignment = .left
        titleLabel.rsd_alignToSuperview([.leading], padding: kSideMargin)
        titleLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kSideMargin, priority: .required)
        titleLabel.rsd_alignToSuperview([.top], padding: kTopMargin, priority: UILayoutPriority(rawValue: 700))
        
        // Add the detail label
        detailLabel = UILabel()
        contentView.addSubview(detailLabel)
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.numberOfLines = 0
        detailLabel.font = UIFont.rsd_choiceCellDetailLabel
        detailLabel.textColor = detailLabelColor
        detailLabel.textAlignment = .left
        detailLabel.rsd_alignToSuperview([.leading], padding: kSideMargin)
        detailLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kSideMargin, priority: .required)
        detailLabel.rsd_alignToSuperview([.bottom], padding: kBottomMargin)
        detailLabel.rsd_alignBelow(view: titleLabel, padding: 2.0)
        
        // Add the line separator
        separatorLine = UIView()
        separatorLine!.backgroundColor = UIColor.rsd_cellSeparatorLine
        contentView.addSubview(separatorLine!)
        
        separatorLine!.translatesAutoresizingMaskIntoConstraints = false
        separatorLine!.rsd_alignToSuperview([.leading], padding: kSeparatorInsetMargin)
        separatorLine!.rsd_alignToSuperview([.bottom, .trailing], padding: 0.0)
        separatorLine?.rsd_makeHeight(.equal, 1.0)
        
        setNeedsUpdateConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}

/// `RSDStepChoiceSectionHeader` is the base implementation for a selection table view section header of a form step.
@IBDesignable public class RSDStepChoiceSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var detailLabel: UILabel!
    @IBOutlet public var separatorLine: UIView?
    
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.rsd_choiceCellBackground
        
        // Add the title label
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.rsd_choiceSectionLabel
        titleLabel.textColor = UIColor.rsd_choiceCellLabel
        titleLabel.textAlignment = .left
        titleLabel.rsd_alignToSuperview([.leading], padding: kSideMargin)
        titleLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kSideMargin, priority: .required)
        titleLabel.rsd_alignToSuperview([.top], padding: kSectionTopMargin, priority: UILayoutPriority(rawValue: 700))
        
        // Add the detail label
        detailLabel = UILabel()
        contentView.addSubview(detailLabel)
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.numberOfLines = 0
        detailLabel.font = UIFont.rsd_choiceSectionDetailLabel
        detailLabel.textColor = UIColor.rsd_choiceCellDetailLabel
        detailLabel.textAlignment = .left
        detailLabel.rsd_alignToSuperview([.leading], padding: kSideMargin)
        detailLabel.rsd_align([.trailing], .lessThanOrEqual, to: contentView, [.trailing], padding: kSideMargin, priority: .required)
        detailLabel.rsd_alignToSuperview([.bottom], padding: kBottomMargin)
        detailLabel.rsd_alignBelow(view: titleLabel, padding: 2.0)
        
        // Add the line separator
        separatorLine = UIView()
        separatorLine!.backgroundColor = UIColor.rsd_cellSeparatorLine
        contentView.addSubview(separatorLine!)
        
        separatorLine!.translatesAutoresizingMaskIntoConstraints = false
        separatorLine!.rsd_alignToSuperview([.leading, .bottom, .trailing], padding: 0.0)
        separatorLine?.rsd_makeHeight(.equal, 1.0)
        
        setNeedsUpdateConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}

/// `RSDStepTextFieldCell` is the base implementation of a text field used to enter answers in a
/// form step table view.
open class RSDStepTextFieldCell: RSDTableViewCell {
    
    /// The text field associated with this cell.
    public var textField: RSDStepTextField!
    
    /// The label used to display the prompt for the input field.
    open var fieldLabel: UILabel!
    
    /// A line show below the text field.
    open var ruleView: UIView!
    
    /// Layout constants. Subclasses can override to customize; otherwise the default private
    /// constants are used.
    open private(set) var constants: RSDStepTextFieldCellLayoutConstants = RSDDefaultStepTextFieldCellLayoutConstants()
    
    /// Create all the view elements. Subclasses can override to provide custom instances.
    open func initializeViews() {
        textField = RSDStepTextField()
        ruleView = UIView()
        fieldLabel = UILabel()
    }
    
    /// Define the subView properties.
    open func setupViews() {

        // configure our field label
        fieldLabel.font = UIFont.rsd_textFieldCellLabel
        fieldLabel.textColor = UIColor.rsd_textFieldCellLabel
        fieldLabel.numberOfLines = 1
        fieldLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (2 * constants.sideMargin)
        
        // we don't want auto correction since this is for email address. This should really be
        // part of the step config, like keyboardType, but it's not currently
        textField.autocorrectionType = .no
        
        // override defaults
        textField.font = UIFont.rsd_textFieldCellText
        textField.textColor = UIColor.rsd_textFieldCellText
        textField.textAlignment = .left
        
        ruleView.backgroundColor = UIColor.rsd_textFieldCellBorder
    }
    
    /// Override to set the content view background color to the color of the table background.
    override open var tableBackgroundColor: UIColor! {
        didSet {
            self.contentView.backgroundColor = tableBackgroundColor
        }
    }
    
    /// Override to set the text element colors based on whether the color style calls for a dark background
    /// with light elements or a light background with dark elements.
    override open var usesLightStyle: Bool {
        didSet {
            if usesLightStyle {
                fieldLabel.textColor = UIColor.rsd_textFieldCellLabelLightStyle
                textField.textColor = UIColor.rsd_textFieldCellTextLightStyle
                ruleView.backgroundColor = UIColor.rsd_textFieldCellBorderLightStyle
            }
            else {
                fieldLabel.textColor = UIColor.rsd_textFieldCellLabel
                textField.textColor = UIColor.rsd_textFieldCellText
                ruleView.backgroundColor = UIColor.rsd_textFieldCellBorder
            }
        }
    }
    
    /// Set the string for the text field placeholder. View controllers should use this methods rather
    /// than accessing the text field's 'placeholder' directly because some subclasses may not display
    /// the placeholder text.
    open var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        
        initializeViews()
        
        contentView.addSubview(textField)
        contentView.addSubview(ruleView)
        contentView.addSubview(fieldLabel)

        setupViews()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        ruleView.translatesAutoresizingMaskIntoConstraints = false
        fieldLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setNeedsUpdateConstraints()
    }
    
    override open func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        textField.rsd_removeSiblingAndAncestorConstraints()
        ruleView.rsd_removeSiblingAndAncestorConstraints()
        
        fieldLabel.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        fieldLabel.rsd_alignToSuperview([.top], padding: constants.verticalMargin)
        
        textField.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        textField.rsd_alignBelow(view: fieldLabel, padding: constants.verticalPadding)
        
        ruleView.rsd_alignBelow(view: textField, padding: constants.verticalPadding)
        ruleView.rsd_makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.rsd_align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
        
        ruleView.rsd_alignToSuperview([.bottom], padding: constants.verticalMargin)

        super.updateConstraints()
    }
}

/// `RSDStepTextFieldCellLayoutConstants` defines the layout constants used by a `RSDStepTextFieldCell`.
public protocol RSDStepTextFieldCellLayoutConstants {
    var verticalMargin: CGFloat { get }
    var verticalPadding: CGFloat { get }
    var sideMargin: CGFloat { get }
}

/// Default constants.
fileprivate struct RSDDefaultStepTextFieldCellLayoutConstants {
    let verticalMargin: CGFloat = 10.0
    let verticalPadding: CGFloat = 7.0
    let sideMargin: CGFloat = 24.0
}

extension RSDDefaultStepTextFieldCellLayoutConstants : RSDStepTextFieldCellLayoutConstants {
}

/// `RSDStepTextFieldFeaturedCell` is an implementation of the text field form step entry cell for
/// use when there is a single input field on for the step.
open class RSDStepTextFieldFeaturedCell: RSDStepTextFieldCell {
    
    /// Override `setupViews()` to increase the size of the text field.
    override open func setupViews() {
        
        super.setupViews()
        
        textField.textAlignment = .center
        textField.font = UIFont.rsd_textFieldFeaturedCellText
        
        // we don't want the field label
        fieldLabel.isHidden = true
    }

    override open func updateConstraints() {
        
        super.updateConstraints()
        
        textField.rsd_removeSiblingAndAncestorConstraints()
        ruleView.rsd_removeSiblingAndAncestorConstraints()
        
        textField.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        textField.rsd_alignToSuperview([.top], padding: constants.verticalMargin)
        
        ruleView.rsd_alignBelow(view: textField, padding: constants.verticalPadding)
        ruleView.rsd_makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.rsd_align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
    }
}

/// `RSDStepTextField` is a subclass of `UITextField` that keeps a reference to the index path
/// associated with this text field.
public class RSDStepTextField: UITextField {
    public var indexPath: IndexPath?
}

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
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
            
            label.accessibilityTraits = UIAccessibilityTraitSummaryElement

            label.translatesAutoresizingMaskIntoConstraints = false
            label.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (kSideMargin * 2)
            
            label.numberOfLines = 0
            label.font = UIFont.rsd_footnoteLabel
            label.textColor = UIColor.rsd_footnoteLabel
            label.textAlignment = .left
            
            label.rsd_alignToSuperview([.leading, .trailing], padding: kSideMargin)
            label.rsd_alignToSuperview([.top], padding: kVertMargin)
        }
        
        contentView.rsd_makeHeight(.greaterThanOrEqual, kMinHeight)
        
        setNeedsUpdateConstraints()
    }
}

/// `RSDImageViewCell` can be used to display images amongst the table cells.
@IBDesignable open class RSDImageViewCell : RSDTableViewCell {
    
    private let kVertMargin: CGFloat = 10.0
    private let kImageViewHeight: CGFloat = CGFloat(150.0).rsd_proportionalToScreenWidth()

    /// The image view to load into.
    @IBOutlet public var iconView: UIImageView!
    
    /// Set the label text.
    override open var tableItem: RSDTableItem! {
        didSet {
            guard let item = tableItem as? RSDImageTableItem else { return }
            imageLoader = item.imageTheme
        }
    }
    
    /// Set the image loader for this cell. This will automatically load the image or animation.
    public var imageLoader: RSDImageThemeElement? {
        didSet {
            guard _imageIdentifier != imageLoader?.imageIdentifier else {
                return
            }
            _imageIdentifier = imageLoader?.imageIdentifier
            if let loader = imageLoader {
                if let animatedVendor = loader as? RSDAnimatedImageThemeElement {
                    DispatchQueue.main.async {
                        self.iconView.animationImages = animatedVendor.images(compatibleWith: nil)
                        self.iconView.animationDuration = animatedVendor.animationDuration
                        self.iconView.startAnimating()
                    }
                } else if let fetchLoader = loader as? RSDFetchableImageThemeElement {
                    fetchLoader.fetchImage(for: iconView.bounds.size, callback: { [weak self] (loadingIdentifier, img) in
                        guard self?._imageIdentifier == loadingIdentifier else { return }
                        self?.iconView.image = img
                    })
                } else {
                    assertionFailure("Unknown image theme class. \(loader)")
                }
            } else {
                // Nil out the image if the identifier is nil
                iconView.image = nil
            }
        }
    }
    private var _imageIdentifier: String?
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        self.selectionStyle = .none
        
        if iconView == nil {
            iconView = UIImageView()
            iconView.contentMode = .scaleAspectFit
            contentView.addSubview(iconView)
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.rsd_alignToSuperview([.top, .bottom], padding: kVertMargin)
            iconView.rsd_alignCenterHorizontal(padding: 0.0)
            let height = iconView.heightAnchor.constraint(equalToConstant: kImageViewHeight)
            height.priority = UILayoutPriority(950)
            height.isActive = true
            
            setNeedsUpdateConstraints()
        }
    }
}

