//
//  RSDStepChoiceCell.swift
//  ResearchSuite-UI
//
//  Created by Josh Bruhin on 5/30/17.
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
    private let kSideMargin = CGFloat(20.0).proportionalToScreenWidth()
    private let kVertMargin: CGFloat = 10.0
    private let kMinHeight: CGFloat = 75.0

    var choiceValueLabel = UILabel()
    
    open var shadowAlpha: CGFloat {
        return isSelected ? 0.2 : 0.05
    }
    
    open var bgColor: UIColor {
        return isSelected ? UIColor.choiceCellBackgroundHighlighted : UIColor.choiceCellBackground
    }
    
    open var labelColor: UIColor {
        return isSelected ? UIColor.choiceCellLabelHighlighted : UIColor.choiceCellLabel
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
        
        choiceValueLabel.alignToSuperview([.leading, .trailing], padding: kSideMargin)
        choiceValueLabel.alignToSuperview([.top], padding: kVertMargin)
        
        shadowView.makeHeight(.equal, kShadowHeight)
        shadowView.alignToSuperview([.leading, .trailing, .bottom], padding: 0.0)
        shadowView.alignBelow(view: choiceValueLabel, padding: kVertMargin)
        
        contentView.makeHeight(.greaterThanOrEqual, kMinHeight)

        super.updateConstraints()
    }
}

// MARK: TextField Cell

open class RSDStepTextFieldCell: UITableViewCell {
    
    private let kVerticalMargin: CGFloat = 10.0
    private let kVerticalPadding: CGFloat = 7.0
    private let kSideMargin = CGFloat(25.0).proportionalToScreenWidth()
    
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
        fieldLabel.textColor = UIColor.textFieldCellLabel
        fieldLabel.numberOfLines = 1
        fieldLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (2 * constants().sideMargin)
        
        // we don't want auto correction since this is for email address. This should really be
        // part of the step config, like keyboardType, but it's not currently
        textField.autocorrectionType = .no
        
        // override defaults
        textField.font = UIFont.textFieldCellText
        textField.textColor = UIColor.textFieldCellText
        textField.textAlignment = .left
        
        ruleView.backgroundColor = UIColor.textFieldCellBorder
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
        
        textField.removeSiblingAndAncestorConstraints()
        ruleView.removeSiblingAndAncestorConstraints()
        
        fieldLabel.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        fieldLabel.alignToSuperview([.top], padding: constants().verticalMargin)
        
        textField.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        textField.alignBelow(view: fieldLabel, padding: constants().verticalPadding)
        
        ruleView.alignBelow(view: textField, padding: constants().verticalPadding)
        ruleView.makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
        
        ruleView.alignToSuperview([.bottom], padding: constants().verticalMargin)

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
        
        textField.removeSiblingAndAncestorConstraints()
        ruleView.removeSiblingAndAncestorConstraints()
        
        // if we have a defined textField width, we use that and center the text field and ruleView horizontally.
        // Otherwise, we pin left and right edges to the superview with some side margin
        
        if kTextFieldWidth > 0 {
            
            textField.makeWidth(.equal, kTextFieldWidth)
            textField.alignCenterHorizontal(padding: 0.0)
        } else {
            
            textField.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        }
        
        textField.alignToSuperview([.top], padding: constants().verticalMargin)
        
        ruleView.alignBelow(view: textField, padding: constants().verticalPadding)
        ruleView.makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
    }
}

class RSDStepTextField: UITextField {
    var indexPath: IndexPath?
}

