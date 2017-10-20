//
//  RSDStepNavigationView.swift
//  ResearchSuite-UI
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
 Previous button, and shadowView. The ViewController is responsible for assigning targets and
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
    
    open var previousButton: UIButton!
    open var nextButton: UIButton!
    open var shadowView: UIView!
    
    open var buttonCornerRadius = RSDRoundedButton.defaultCornerRadius
    
    /**
     Causes the drop shadow at the top of the view to be shown or hidden.
     If the value in app configuration is false, that overrides any attempt to set to true
     */
    private var _shouldShowShadow = false
    open var shouldShowShadow: Bool {
        set {
            let shadowEnabled = RSDGenericStepUIConfig.shouldShowNavigationViewShadow()
            _shouldShowShadow = shadowEnabled && newValue
            self.shadowView.isHidden = !_shouldShowShadow
            self.clipsToBounds = !_shouldShowShadow
        }
        get {
            return _shouldShowShadow
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
        previousButton = RSDRoundedButton()
        nextButton = RSDRoundedButton()        
        shadowView = RSDShadowGradient()
    }
    
    fileprivate func commonInit() {
        
        initializeViews()
        
        if let nextRounded = nextButton as? RSDRoundedButton {
            nextRounded.corners = buttonCornerRadius
        }
        if let prevRounded = previousButton as? RSDRoundedButton {
            prevRounded.corners = buttonCornerRadius
        }
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        // add previous and next buttons
        self.addSubview(previousButton)
        self.addSubview(nextButton)
        self.addSubview(shadowView)
        
        shadowView.isHidden = !shouldShowShadow
        
        setNeedsUpdateConstraints()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        previousButton.makeWidth(.equal, constants().buttonWidth)
        previousButton.makeHeight(.equal, RSDRoundedButton.defaultHeight)
        
        previousButton.alignToSuperview([.leading], padding: constants().sideMargin)
        previousButton.alignToSuperview([.top], padding: constants().topMargin)
        previousButton.alignToSuperview([.bottom], padding: constants().bottomMargin)
        
        // if we have a previousButton, then define width or nextButton
        nextButton.makeWidth(.equal, constants().buttonWidth)
        
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
