//
//  RSDRoundedButton.swift
//  ResearchUI
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


import UIKit

/// `RSDButton` is a base-class implementation of `RSDButtonProtocol` that handles overriding
/// default accessibility behavior for a button in transition.
@IBDesignable open class RSDButton : UIButton {
    
    var isInTransition : Bool = false

    override open var accessibilityTraits: UIAccessibilityTraits {
        get {
            let traits = super.accessibilityTraits
            // Prevent VoiceOver from speaking "dimmed" when transitioning between pages.
            if self.isInTransition {
                return traits.subtracting(.notEnabled)
            }
            return traits
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
}

/// `RSDRoundedButton` is a UI element for displaying navigation buttons in the footer area of a view.
@IBDesignable open class RSDRoundedButton : RSDButton, RSDViewDesignable {
    
    public static let defaultHeight: CGFloat = 52.0
    public static let defaultWidthWith2Buttons: CGFloat = CGFloat(144.0).rsd_proportionalToScreenWidth(max: 160)
    public static let defaultWidthWith1Button: CGFloat = CGFloat(280.0).rsd_proportionalToScreenWidth(max: 320)
    
    override open var isEnabled: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }

            guard let colorTile = self.backgroundColorTile,
                let designSystem = self.designSystem
                else {
                    self.alpha = isEnabled ? CGFloat(1) : CGFloat(0.35)
                    return
            }
            
            self.alpha = 1.0
            let buttonType: RSDDesignSystem.ButtonType = isSecondaryButton ? .secondary : .primary
            let state: RSDControlState = isEnabled ? .normal : .disabled
            self.backgroundColor = designSystem.colorRules.roundedButton(on: colorTile, with: buttonType, forState: state)
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            
            guard let colorTile = self.backgroundColorTile,
                let designSystem = self.designSystem
                else {
                    // show as highlighted by lowering opacity unless alpha is used to set hidden
                    self.alpha = isHighlighted ? CGFloat(0.8) : CGFloat(1)
                    return
            }
            
            self.alpha = 1.0
            let buttonType: RSDDesignSystem.ButtonType = isSecondaryButton ? .secondary : .primary
            let state: RSDControlState = isHighlighted ? .highlighted : .normal
            self.backgroundColor = designSystem.colorRules.roundedButton(on: colorTile, with: buttonType, forState: state)
        }
    }
    
    // TODO: syoung 03/19/2019 Remove these properties once the modules that use them have been updated.
    @available(*, unavailable)
    open var usesLightStyle: Bool = false
    
    /// Should the button display using the "secondary" button style? This style is used for buttons that
    /// are displayed inline with scrolling views for handling secondary actions.
    ///
    /// If `true`, then the button colors will be styled using the secondary colors for the rounded button.
    @IBInspectable
    open var isSecondaryButton: Bool = false {
        didSet {
            updateColorsAndFonts()
        }
    }
    
    /// The background color mapping that this view should use as its key. Typically, for all but the
    /// top-level views, this will be the background of the superview.
    open private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.backgroundColorTile = background
        self.designSystem = designSystem
        updateColorsAndFonts()
    }
    
    private func updateColorsAndFonts() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let colorTile: RSDColorTile = self.backgroundTile() ?? designSystem.colorRules.backgroundLight

        // Set the background to the current state. iOS 11 does not support setting the background of the
        // button based on the button state.
        let buttonType: RSDDesignSystem.ButtonType = isSecondaryButton ? .secondary : .primary
        let currentState: RSDControlState = isEnabled ? (isHighlighted ? .highlighted : .normal) : .disabled
        self.backgroundColor = designSystem.colorRules.roundedButton(on: colorTile, with: buttonType, forState: currentState)
        
        // If the alpha component is not being used to hide this button, then reset to 1.0 b/c this
        // component is *not* used to denote button state but it might have been set up that way in the
        // initialization because of the override of isEnabled and isHighlighted.
        if alpha > 0.1 {
            self.alpha = 1.0
        }
        
        // Set the title color for each of the states used by this button
        let states: [RSDControlState] = [.normal, .highlighted, .disabled]
        states.forEach {
            let titleColor = designSystem.colorRules.roundedButtonText(on: colorTile, with: buttonType, forState: $0)
            setTitleColor(titleColor, for: $0.controlState)
        }
        
        // Set the title font to the font for a rounded button.
        titleLabel?.font = designSystem.fontRules.buttonFont(for: buttonType, state: .normal)
    }
    
    public required init() {
        let preferredWidth = RSDRoundedButton.defaultWidthWith1Button
        super.init(frame: CGRect(x: 0, y: 0, width: preferredWidth, height: RSDRoundedButton.defaultHeight))
        
        // For the width, need to allow the preferred width to be overridden by the containing view.
        self.rsd_makeWidth(.lessThanOrEqual, RSDRoundedButton.defaultWidthWith1Button)
        let widthConstraint = self.heightAnchor.constraint(equalToConstant: RSDRoundedButton.defaultWidthWith1Button)
        widthConstraint.priority = UILayoutPriority(rawValue: 750)
        widthConstraint.isActive = true

        commonInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    open func commonInit() {
        
        // Set the height to the standard height.
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: RSDRoundedButton.defaultHeight)
        heightConstraint.isActive = true

        // Update the color style.
        updateColorsAndFonts()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.height / 2.0
    }
}
