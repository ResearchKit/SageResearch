//
//  RSDUnderlinedButton.swift
//  ResearchUI
//

import UIKit

/// `RSDUnderlinedButton` is a UI element for displaying an underlined button.
@IBDesignable open class RSDUnderlinedButton : RSDButton, RSDViewDesignable {
    
    override open var isEnabled: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            self.alpha = isEnabled ? CGFloat(1) : CGFloat(0.35)
        }
    }

    @IBInspectable
    open var isHeaderLink: Bool = false {
        didSet {
            refreshView()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        setNeedsDisplay()
    }
    
    open func commonInit() {
        backgroundColor = UIColor.clear
        refreshView()
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        refreshView()
    }
    
    func refreshView() {
        // Forces refresh of current title to be attributed.
        setTitle(self.currentTitle, for: .normal)
    }
    
    /// Force all titles to be an attributed title.
    override open func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        let attributedText = attributedString(title, for: state)
        self.setAttributedTitle(attributedText, for: state)
    }
    
    /// Create an attributed string for this class.
    private func attributedString(_ title: String?, for state: UIControl.State) -> NSAttributedString? {
       
        let controlState = RSDControlState(controlState: state)
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let buttonType: RSDDesignSystem.ButtonType = self.isHeaderLink ? .headerLink : .bodyLink
        
        let foregroundColor: UIColor = {
            guard let background = self.backgroundColorTile
                else {
                    return self.tintColor
            }
            return designSystem.colorRules.underlinedTextButton(on: background, state: controlState)
        }()
        
        let textFont = designSystem.fontRules.buttonFont(for: buttonType, state: controlState)
        
        if let titleUnwrapped = title {
            let attributes: [NSAttributedString.Key : Any] = [
                .font : textFont,
                .foregroundColor : foregroundColor,
                .underlineStyle : NSUnderlineStyle.single.rawValue
            ]
            return NSAttributedString(string: titleUnwrapped, attributes: attributes)
        } else {
            return nil
        }
    }
    
    public private(set) var backgroundColorTile: RSDColorTile?
    
    public private(set) var designSystem: RSDDesignSystem?
    
    public func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.designSystem = designSystem
        self.backgroundColorTile = background
        refreshView()
    }
}
