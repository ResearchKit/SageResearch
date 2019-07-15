//
//  RSDStepTextFieldCell.swift
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
    
    open private(set) var fieldLabelTextType: RSDDesignSystem.TextType = .microHeader
    open private(set) var textfieldTextType: RSDDesignSystem.TextType = .body
    
    override open var usesTableBackgroundColor: Bool {
        return true
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateColorsAndFonts()
    }
    
    func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        guard let background = self.backgroundColorTile else { return }
        
        fieldLabel.font = designSystem.fontRules.font(for: fieldLabelTextType, compatibleWith: traitCollection)
        fieldLabel.textColor = designSystem.colorRules.textColor(on: background, for: fieldLabelTextType)
        
        textField.font = designSystem.fontRules.font(for: textfieldTextType, compatibleWith: traitCollection)
        textField.textColor = designSystem.colorRules.textColor(on: background, for: textfieldTextType)
        
        ruleView.backgroundColor = designSystem.colorRules.textFieldUnderline(on: background)
    }
    
    /// Define the subView properties.
    open func setupViews() {
        fieldLabel.numberOfLines = 1
        fieldLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (2 * constants.sideMargin)
        textField.autocorrectionType = .no
        textField.textAlignment = .left
        updateColorsAndFonts()
    }
    
    /// Set the string for the text field placeholder. View controllers should use this method rather
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
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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

/// `RSDStepTextViewCell` is the base implementation of a text view used to enter answers in a
/// form step table view.
open class RSDStepTextViewCell: RSDTableViewCell {
    
    /// The text field associated with this cell.
    public var textView: RSDStepTextView!
    
    /// The label used to display the prompt for the input field.
    open var viewLabel: UILabel!
    
    /// Layout constants. Subclasses can override to customize; otherwise the default private
    /// constants are used.
    open private(set) var constants: RSDStepTextViewCellLayoutConstants = RSDDefaultStepTextViewCellLayoutConstants()
    
    /// Create all the view elements. Subclasses can override to provide custom instances.
    open func initializeViews() {
        textView = RSDStepTextView()
        viewLabel = UILabel()
    }
    
    /// Define the subView properties.
    open func setupViews() {
        
        // configure our field label
        viewLabel.numberOfLines = 1
        viewLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width - (2 * constants.sideMargin)
        
        // override defaults
        textView.textAlignment = .left
        
        // configure layer
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = constants.borderRadius
        
        // configure the text inset
        let inset = constants.textInset
        textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        updateColorsAndFonts()
    }
    
    open private(set) var fieldLabelTextType: RSDDesignSystem.TextType = .microHeader
    open private(set) var textViewTextType: RSDDesignSystem.TextType = .body
    
    override open var usesTableBackgroundColor: Bool {
        return true
    }
    
    override open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        super.setDesignSystem(designSystem, with: background)
        updateColorsAndFonts()
    }
    
    func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        guard let background = self.backgroundColorTile else { return }
        
        viewLabel.font = designSystem.fontRules.font(for: fieldLabelTextType, compatibleWith: traitCollection)
        viewLabel.textColor = designSystem.colorRules.textColor(on: background, for: fieldLabelTextType)
        
        textView.font = designSystem.fontRules.font(for: textViewTextType, compatibleWith: traitCollection)
        textView.textColor = designSystem.colorRules.textColor(on: background, for: textViewTextType)
        
        textView.layer.borderColor = designSystem.colorRules.textFieldUnderline(on: background).cgColor
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        contentView.addSubview(textView)
        contentView.addSubview(viewLabel)
        
        setupViews()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setNeedsUpdateConstraints()
    }
    
    override open func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        textView.rsd_removeSiblingAndAncestorConstraints()
        
        viewLabel.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        viewLabel.rsd_alignToSuperview([.top], padding: constants.verticalMargin)
        
        textView.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        textView.rsd_alignBelow(view: viewLabel, padding: constants.verticalPadding)
        textView.rsd_makeHeight(.equal, constants.height)
        
        textView.rsd_alignToSuperview([.bottom], padding: constants.verticalMargin)
        
        super.updateConstraints()
    }
}

/// `RSDStepTextFieldCellLayoutConstants` defines the layout constants used by a `RSDStepTextFieldCell`.
public protocol RSDStepTextFieldCellLayoutConstants {
    var featuredCellVerticalMargin: CGFloat { get }
    var verticalMargin: CGFloat { get }
    var verticalPadding: CGFloat { get }
    var sideMargin: CGFloat { get }
}

/// `RSDStepTextViewCellLayoutConstants` defines the layout constants used by a `RSDStepTextViewCell`.
public protocol RSDStepTextViewCellLayoutConstants {
    var verticalMargin: CGFloat { get }
    var verticalPadding: CGFloat { get }
    var sideMargin: CGFloat { get }
    var height: CGFloat { get }
    var textInset: CGFloat { get }
    var borderRadius: CGFloat { get }
}

/// Default constants used by a `RSDStepTextFieldCell`.
fileprivate struct RSDDefaultStepTextFieldCellLayoutConstants {
    let featuredCellVerticalMargin: CGFloat = CGFloat(22).rsd_proportionalToScreenHeight()
    let verticalMargin: CGFloat = 10.0
    let verticalPadding: CGFloat = 7.0
    let sideMargin: CGFloat = 42.0
}

/// Default constants used by a `RSDStepTextViewCell`.
fileprivate struct RSDDefaultStepTextViewCellLayoutConstants {
    let verticalMargin: CGFloat = 10.0
    let verticalPadding: CGFloat = 7.0
    let sideMargin: CGFloat = 24.0
    let height: CGFloat = 150.0
    let textInset: CGFloat = 10.0
    let borderRadius: CGFloat = 8.0
}

extension RSDDefaultStepTextFieldCellLayoutConstants : RSDStepTextFieldCellLayoutConstants {
}

extension RSDDefaultStepTextViewCellLayoutConstants : RSDStepTextViewCellLayoutConstants {
}

/// `RSDStepTextFieldFeaturedCell` is an implementation of the text field form step entry cell for
/// use when there is a single input field on for the step.
open class RSDStepTextFieldFeaturedCell: RSDStepTextFieldCell {
    
    override open var textfieldTextType: RSDDesignSystem.TextType {
        return .largeBody
    }
    
    /// Override `setupViews()` to change alignment and set the field label hidden.
    override open func setupViews() {
        
        super.setupViews()
        
        textField.textAlignment = .center
        
        // we don't want the field label
        fieldLabel.isHidden = true
    }
    
    override open func updateConstraints() {
        
        super.updateConstraints()
        
        textField.rsd_removeSiblingAndAncestorConstraints()
        ruleView.rsd_removeSiblingAndAncestorConstraints()
        
        textField.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        textField.rsd_alignToSuperview([.top], padding: constants.featuredCellVerticalMargin)
        
        ruleView.rsd_alignBelow(view: textField, padding: constants.verticalPadding)
        ruleView.rsd_makeHeight(.equal, 1.0)
        
        // align left and right edges of ruleView to the textField
        ruleView.rsd_align([.leading, .trailing], .equal, to: textField, [.leading, .trailing], padding: 0.0)
        
        ruleView.rsd_alignToSuperview([.bottom], padding: constants.verticalMargin)
    }
}

/// `RSDStepTextInputView` defines custom properties associated with a 'UITextView' or 'UITextField'
/// and provides read only access to other common properties.
public protocol RSDStepTextInputView: class {
    var inputAccessoryView: UIView? { get }
    var inputView: UIView? { get }
    var currentText: String? { get set }
    var indexPath: IndexPath? { get set }
}

/// `RSDStepTextField` is a subclass of `UITextField` that conforms to 'RSDStepTextInputView'.
open class RSDStepTextField: UITextField, RSDStepTextInputView {
    public var currentText: String? {
        get {
            return self.text
        }
        set {
            self.text = currentText
        }
    }
    public var indexPath: IndexPath?
}

/// `RSDStepTextView` is a subclass of `UITextView` that conforms to 'RSDStepTextInputView'.
open class RSDStepTextView: UITextView, RSDStepTextInputView {
    public var currentText: String? {
        get {
            return self.text
        }
        set {
            self.text = currentText
        }
    }
    public var indexPath: IndexPath?
}
