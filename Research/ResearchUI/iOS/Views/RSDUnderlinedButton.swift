//
//  RSDUnderlinedButton.swift
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
    
    @available(*, deprecated)
    open var textFont : UIFont? {
        didSet {
            debugPrint("WARNING! Setting a deprecated property on RSDUnderlinedButton. Likely using a NIB or storyboard.")
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
        
        let textFont = self.textFont ?? designSystem.fontRules.buttonFont(for: buttonType, state: controlState)
        
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
