//
//  RSDRoundedToggleButton.swift
//  BridgeApp (iOS)
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

@IBDesignable
open class RSDRoundedToggleButton : UIButton, RSDViewDesignable {
    
    override open var isHighlighted: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            updateFontAndColorState()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            // If the alpha component is used to set this as hidden, then don't do anything.
            guard alpha > 0.1 else { return }
            updateFontAndColorState()
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
        
        // If the alpha component is not being used to hide this button, then reset to 1.0 b/c this
        // component is *not* used to denote button state but it might have been set up that way in the
        // initialization because of the override of isEnabled and isHighlighted.
        self.alpha = 1.0
        
        // Set the title color for each of the states used by this button
        let states: [RSDControlState] = [.normal, .highlighted, .disabled, .selected]
        states.forEach {
            let titleColor = designSystem.colorRules.roundedButtonText(on: colorTile, with: .secondary, forState: $0)
            setTitleColor(titleColor, for: $0.controlState)
        }

        // Set the image tint
        imageView?.tintColor = designSystem.colorRules.palette.primary.normal.color
        
        updateFontAndColorState()
    }
    
    private func updateFontAndColorState() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let colorTile: RSDColorTile = self.backgroundTile() ?? designSystem.colorRules.backgroundLight
        
        // Set the background and font to the current state.
        // iOS 11 does not support setting these based on the button state.
        let currentState: RSDControlState = (isHighlighted ? .highlighted : isSelected ? .selected : .normal)
        self.backgroundColor = designSystem.colorRules.roundedButton(on: colorTile, with: .secondary, forState: currentState)
        titleLabel?.font = designSystem.fontRules.buttonFont(for: .toggle, state: currentState)
    }
    
    public required init() {
        super.init(frame: CGRect(x: 0, y: 0,
                                 width: RSDRoundedButton.defaultWidthWith2Buttons,
                                 height: RSDRoundedButton.defaultHeight))
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
        heightConstraint.priority = .defaultLow
        heightConstraint.isActive = true
        
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: RSDRoundedButton.defaultWidthWith2Buttons)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
        
        let image = UIImage(named: "checkmark", in: Bundle.module, compatibleWith: self.traitCollection)
        setImage(image, for: .selected)
        
        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: -10, bottom: 10, right: 10)
        
        // Update the color style.
        updateColorsAndFonts()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.bounds.height / 2.0
    }
}
