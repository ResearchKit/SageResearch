//
//  RSDStepChoiceCell.swift
//  ResearchSuiteUI
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

import UIKit

// MARK: Choice Cell

open class RSDStepChoiceCell: UITableViewCell {
    
    private let kShadowHeight: CGFloat = 5.0
    private let kSideMargin = CGFloat(20.0).rsd_proportionalToScreenWidth()
    private let kVertMargin: CGFloat = 10.0
    private let kMinHeight: CGFloat = 75.0

    var choiceValueLabel = UILabel()
    
    open var shadowAlpha: CGFloat {
        return isSelected ? 0.2 : 0.05
    }
    
    open var bgColor: UIColor {
        return isSelected ? UIColor.rsd_choiceCellBackgroundHighlighted : UIColor.rsd_choiceCellBackground
    }
    
    open var labelColor: UIColor {
        return isSelected ? UIColor.rsd_choiceCellLabelHighlighted : UIColor.rsd_choiceCellLabel
    }
    
    open let shadowView: UIView = {
        let rule = UIView()
        rule.backgroundColor = UIColor.black
        return rule
    }()
    
    open override var isSelected: Bool {
        didSet {
            backgroundColor = bgColor
            choiceValueLabel.textColor = labelColor
            shadowView.alpha = shadowAlpha
        }
    }

    public init(uiHint: RSDFormUIHint, reuseIdentifier: String?) {
        // TODO: syoung 12/18/2017 Support checkbox and radio button hint types.
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
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
        
        contentView.addSubview(choiceValueLabel)
        contentView.addSubview(shadowView)
        
        choiceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        choiceValueLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (kSideMargin * 2)
        
        choiceValueLabel.numberOfLines = 0
        choiceValueLabel.font = UIFont.choiceCellLabel
        choiceValueLabel.textColor = labelColor
        choiceValueLabel.textAlignment = .left
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        choiceValueLabel.rsd_alignToSuperview([.leading, .trailing], padding: kSideMargin)
        choiceValueLabel.rsd_alignToSuperview([.top], padding: kVertMargin)
        
        shadowView.rsd_makeHeight(.equal, kShadowHeight)
        shadowView.rsd_alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
        shadowView.rsd_alignBelow(view: choiceValueLabel, padding: kVertMargin)
        
        contentView.rsd_makeHeight(.greaterThanOrEqual, kMinHeight)

        super.updateConstraints()
    }
}

// MARK: TextField Cell

open class RSDStepTextFieldCell: UITableViewCell {
    
    private let kVerticalMargin: CGFloat = 10.0
    private let kVerticalPadding: CGFloat = 7.0
    private let kSideMargin = CGFloat(25.0).rsd_proportionalToScreenWidth()
    
    public var textField: UITextField!
    open var fieldLabel: UILabel!
    open var ruleView: UIView!
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        verticalMargin: CGFloat,
        verticalPadding: CGFloat,
        sideMargin: CGFloat) {
        return (kVerticalMargin,
                kVerticalPadding,
                kSideMargin)
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances.
     */
    open func initializeViews() {
        textField = RSDStepTextField()
        ruleView = UIView()
        fieldLabel = UILabel()
    }
    
    /**
     Define the subView properties.
     */
    open func setupViews() {

        // configure our field label
        fieldLabel.font = UIFont.textFieldCellLabel
        fieldLabel.textColor = UIColor.rsd_textFieldCellLabel
        fieldLabel.numberOfLines = 1
        fieldLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (2 * constants().sideMargin)
        
        // we don't want auto correction since this is for email address. This should really be
        // part of the step config, like keyboardType, but it's not currently
        textField.autocorrectionType = .no
        
        // override defaults
        textField.font = UIFont.textFieldCellText
        textField.textColor = UIColor.rsd_textFieldCellText
        textField.textAlignment = .left
        
        ruleView.backgroundColor = UIColor.rsd_textFieldCellBorder
    }
    
    /**
     Set the string for the text field placeholder. View controllers should use this methods rather
     than accessing the text field's 'placeholder' directly because some subclasses may not display
     the placeholder text.
     
     @param text    The 'String' to use as the text field's placeholder text.
    */
    open func setPlaceholderText(_ text: String) {
        textField.placeholder = text
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
        
        fieldLabel.rsd_alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        fieldLabel.rsd_alignToSuperview([.top], padding: constants().verticalMargin)
        
        textField.rsd_alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        textField.rsd_alignBelow(view: fieldLabel, padding: constants().verticalPadding)
        
        ruleView.rsd_alignBelow(view: textField, padding: constants().verticalPadding)
        ruleView.rsd_makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.rsd_align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
        
        ruleView.rsd_alignToSuperview([.bottom], padding: constants().verticalMargin)

        super.updateConstraints()
    }
}

open class RSDStepTextFieldFeaturedCell: RSDStepTextFieldCell {
    
    private let kTextFieldWidth: CGFloat = 150.0

    override open func setupViews() {
        
        super.setupViews()
        
        textField.textAlignment = .center
        textField.font = UIFont.textFieldFeaturedCellText
        
        // we don't want the field label
        fieldLabel.isHidden = true
    }
    
    override open func setPlaceholderText(_ text: String) {
        // we don't want placeholder text
    }

    override open func updateConstraints() {
        
        super.updateConstraints()
        
        textField.rsd_removeSiblingAndAncestorConstraints()
        ruleView.rsd_removeSiblingAndAncestorConstraints()
        
        // if we have a defined textField width, we use that and center the text field and ruleView horizontally.
        // Otherwise, we pin left and right edges to the superview with some side margin
        
        if kTextFieldWidth > 0 {
            
            textField.rsd_makeWidth(.equal, kTextFieldWidth)
            textField.rsd_alignCenterHorizontal(padding: 0.0)
        } else {
            
            textField.rsd_alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        }
        
        textField.rsd_alignToSuperview([.top], padding: constants().verticalMargin)
        
        ruleView.rsd_alignBelow(view: textField, padding: constants().verticalPadding)
        ruleView.rsd_makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.rsd_align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
    }
}

class RSDStepTextField: UITextField {
    var indexPath: IndexPath?
}

// MARK: Text label cell

open class RSDTextLabelCell : UITableViewCell {
    
    private let kSideMargin = CGFloat(20.0).rsd_proportionalToScreenWidth()
    private let kVertMargin: CGFloat = 10.0
    private let kMinHeight: CGFloat = 75.0
    
    public var label = UILabel()
    
    open var labelColor: UIColor {
        return UIColor.rsd_choiceCellLabel
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
        
        contentView.addSubview(label)
        
        label.accessibilityTraits = UIAccessibilityTraitSummaryElement

        label.translatesAutoresizingMaskIntoConstraints = false
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (kSideMargin * 2)
        
        label.numberOfLines = 0
        label.font = UIFont.footnoteLabel
        label.textColor = UIColor.rsd_headerTextLabel
        label.textAlignment = .left
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        label.rsd_alignToSuperview([.leading, .trailing], padding: kSideMargin)
        label.rsd_alignToSuperview([.top], padding: kVertMargin)
        
        contentView.rsd_makeHeight(.greaterThanOrEqual, kMinHeight)
        
        super.updateConstraints()
    }
}

// MARK: Image cell

open class RSDImageViewCell : UITableViewCell {
    
    private let kVertMargin: CGFloat = 10.0
    private let kImageViewHeight: CGFloat = CGFloat(150.0).rsd_proportionalToScreenWidth()

    @IBOutlet public var iconView: UIImageView!
    
    private var _loading = false
    public var imageLoader: RSDImageThemeElement? {
        didSet {
            if !_loading, let loader = imageLoader, iconView.image == nil {
                _loading = true
                if let animatedVendor = loader as? RSDAnimatedImageThemeElement {
                    DispatchQueue.main.async {
                        self.iconView.animationImages = animatedVendor.images(compatibleWith: nil)
                        self.iconView.animationDuration = animatedVendor.animationDuration
                        self.iconView.startAnimating()
                    }
                } else if let fetchLoader = loader as? RSDFetchableImageThemeElement {
                    fetchLoader.fetchImage(for: iconView.bounds.size, callback: { [weak self] (img) in
                        self?.iconView.image = img
                    })
                } else {
                    assertionFailure("Unknown image theme class. \(loader)")
                }
            }
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

