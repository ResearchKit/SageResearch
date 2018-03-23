//
//  RSDRoundedButton.swift
//  ResearchStack2UI
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
                return traits & ~UIAccessibilityTraitNotEnabled
            }
            return traits
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
}

/// `RSDRoundedButton` is a UI element for displaying navigation buttons in the footer area of a view.
@IBDesignable open class RSDRoundedButton : RSDButton {
    
    public static let defaultHeight: CGFloat = 52.0
    public static let defaultWidthWith2Buttons: CGFloat = CGFloat(144.0).rsd_proportionalToScreenWidth(max: 160)
    public static let defaultWidthWith1Button: CGFloat = CGFloat(280.0).rsd_proportionalToScreenWidth(max: 320)
    
    override open var isEnabled: Bool {
        didSet {
            // show as disabled by lowering opacity unless alpha is used to set hidden
            guard alpha > 0.1 else { return }
            self.alpha = isEnabled ? CGFloat(1) : CGFloat(0.3)
        }
    }
    
    /// Should the button display using the "light" button style? Set this value to `true` for a button
    /// that is displayed on a dark background (which results in "light" colored elements). By default,
    /// this value is false, assuming a "light" colored background (white) which will display the "dark" UI
    /// elements.
    @IBInspectable
    open var usesLightStyle: Bool = false {
        didSet {
            updateColorStyle()
        }
    }
    
    /// Should the button display using the "secondary" button style? This style is used for buttons that
    /// are displayed inline with scrolling views for handling secondary actions.
    ///
    /// If `true`, then the button colors will be styled using the secondary colors for the rounded button.
    @IBInspectable
    open var isSecondaryButton: Bool = false {
        didSet {
            updateColorStyle()
        }
    }
    
    private func updateColorStyle() {
        let titleColor: UIColor
        if usesLightStyle {
            if isSecondaryButton {
                titleColor = UIColor.rsd_secondaryRoundedButtonTextLightStyle
                self.backgroundColor = UIColor.rsd_secondaryRoundedButtonBackgroundLightStyle
            } else {
                titleColor = UIColor.rsd_roundedButtonTextLightStyle
                self.backgroundColor = UIColor.rsd_roundedButtonBackgroundLightStyle
            }
        } else {
            if isSecondaryButton {
                titleColor = UIColor.rsd_secondaryRoundedButtonText
                self.backgroundColor = UIColor.rsd_secondaryRoundedButtonBackground
            } else {
                titleColor = UIColor.rsd_roundedButtonText
                self.backgroundColor = UIColor.rsd_roundedButtonBackground
            }
        }
        setTitleColor(titleColor, for: .normal)

    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateColorStyle()
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
        
        // In many cases, the below constraints will be overriden by the containing view, so we set the priority here to 950
        // add default constraint for height
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: RSDRoundedButton.defaultHeight)
        heightConstraint.priority = UILayoutPriority(rawValue: 950)
        heightConstraint.isActive = true
        
        // Set the title font to the font for a rounded button
        titleLabel?.font = UIFont.roundedButtonTitle
        
        // Update the color style
        updateColorStyle()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.height / 2.0
    }
}
