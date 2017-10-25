//
//  RSDStepNavigationView.swift
//  ResearchSuiteUI
//
//  Created by Josh Bruhin on 5/23/17.
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

/**
 A custom UIView to be included in an RSDGenericStepViewController. It contains a Next button,
 back button, and shadowView. The ViewController is responsible for assigning targets and
 actions to the buttons.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */
open class RSDStepNavigationView: UIView {
    
    private let kTopMargin: CGFloat = 16.0
    private let kBottomMargin: CGFloat = 20.0
    private let kSideMargin: CGFloat = CGFloat(25.0).proportionalToScreenWidth()
    private let kButtonWidth: CGFloat = CGFloat(120.0).proportionalToScreenWidth()
    private let kShadowHeight: CGFloat = 5.0
    
    open var backButton: UIButton?
    open var nextButton: UIButton!
    open var shadowView: UIView!
    
    open var buttonCornerRadius = RSDRoundedButton.defaultCornerRadius
    
    /**
     Causes the drop shadow at the top of the view to be shown or hidden.
     If the value in app configuration is false, that overrides any attempt to set to true
     */
    open var shouldShowShadow: Bool {
        get {
            return _shouldShowShadow
        }
        set {
            let shadowEnabled = RSDGenericStepUIConfig.shouldShowNavigationViewShadow()
            _shouldShowShadow = shadowEnabled && newValue
            self.shadowView.isHidden = !_shouldShowShadow
            self.clipsToBounds = !_shouldShowShadow
        }
    }
    private var _shouldShowShadow = false
    
    /**
     Should the navigation view show the back button
     */
    open var shouldHideBackButton: Bool = true {
        didSet {
            self.needsUpdateConstraints()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        topMargin: CGFloat,
        bottomMargin: CGFloat,
        sideMargin: CGFloat,
        buttonWidth: CGFloat,
        shadowHeight: CGFloat)
    {
        return (kTopMargin,
                kBottomMargin,
                kSideMargin,
                kButtonWidth,
                kShadowHeight)
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances.
     */
    open func initializeViews() {
        backButton = RSDRoundedButton()
        nextButton = RSDRoundedButton()        
        shadowView = RSDShadowGradient()
    }
    
    fileprivate func commonInit() {
        
        initializeViews()
        
        if let nextRounded = nextButton as? RSDRoundedButton {
            nextRounded.corners = buttonCornerRadius
        }
        if let prevRounded = backButton as? RSDRoundedButton {
            prevRounded.corners = buttonCornerRadius
        }
        
        backButton?.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        // add back and next buttons
        if let btn = backButton {
            self.addSubview(btn)
        }
        self.addSubview(nextButton)
        self.addSubview(shadowView)
        
        shadowView.isHidden = !shouldShowShadow
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        if shouldHideBackButton {
            // Remove the back button and set to nil
            backButton?.removeFromSuperview()
            backButton = nil
            
            // if we don't have backButton, align left edge of nextButton to superview left
            nextButton.alignToSuperview([.leading], padding: constants().sideMargin)
        }
        else {

            backButton?.makeWidth(.equal, constants().buttonWidth)
            backButton?.makeHeight(.equal, RSDRoundedButton.defaultHeight)
            
            backButton?.alignToSuperview([.leading], padding: constants().sideMargin)
            backButton?.alignToSuperview([.top], padding: constants().topMargin)
            backButton?.alignToSuperview([.bottom], padding: constants().bottomMargin)
            
            // if we have a backButton, then define width or nextButton
            nextButton.makeWidth(.equal, constants().buttonWidth)
        }
        
        nextButton.makeHeight(.equal, RSDRoundedButton.defaultHeight)
        nextButton.alignToSuperview([.trailing], padding: constants().sideMargin)
        nextButton.alignToSuperview([.top], padding: constants().topMargin)
        nextButton.alignToSuperview([.bottom], padding: constants().bottomMargin)
        
        shadowView.alignToSuperview([.leading, .trailing], padding: 0.0)
        shadowView.alignToSuperview([.top], padding:  -1 * constants().shadowHeight)
        shadowView.makeHeight(.equal, constants().shadowHeight)
        
        super.updateConstraints()
    }
}
