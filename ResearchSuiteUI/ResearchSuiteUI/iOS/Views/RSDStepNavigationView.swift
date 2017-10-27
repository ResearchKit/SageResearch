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
 A custom UIView to be included in an RSDStepViewController. It contains a Next button, back button, and shadowView. The ViewController is responsible for assigning targets and actions to the buttons.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */
@IBDesignable
open class RSDStepNavigationView: UIView {
    @IBOutlet open var nextButton: UIButton!
    @IBOutlet open var backButton: UIButton!
    @IBOutlet open var skipButton: UIButton!
    @IBOutlet open var shadowView: RSDShadowGradient!
    
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
            self.shadowView?.isHidden = !_shouldShowShadow
            self.clipsToBounds = !_shouldShowShadow
        }
    }
    private var _shouldShowShadow = false
    
    /**
     Should the navigation view show the back button
     */
    @IBInspectable open var isBackHidden: Bool = false {
        didSet {
            backButton?.isHidden = isBackHidden
            self.setNeedsUpdateConstraints()
        }
    }
    
    /**
     Should the navigation view show the back button
     */
    @IBInspectable open var isSkipHidden: Bool = true {
        didSet {
            skipButton?.isHidden = isSkipHidden
            self.setNeedsUpdateConstraints()
        }
    }
}

/**
 `RSDGenericStepNavigationView` is the default implementation for the `RSDStepNavigationView` which can be added to a Nib, Storyboard or instantiated using the `RSDGenericStepUIConfig.instantiatNavigationView()` method.
 */
@IBDesignable
open class RSDGenericStepNavigationView: RSDStepNavigationView {
    
    private let kTopMargin = CGFloat(16.0).proportionalToScreenHeight(max: 24.0)
    private let kBottomMargin = CGFloat(20.0).proportionalToScreenHeight(max: 40.0)
    private let kHorizontalPadding = CGFloat(20.0).proportionalToScreenWidth()
    private let kVerticalPadding = CGFloat(20.0).proportionalToScreenHeight(max: 30.0)
    private let kOneButtonSideMargin = CGFloat(20.0).proportionalToScreenWidth()
    private let kTwoButtonSideMargin = CGFloat(10.0).proportionalToScreenWidth()
    private let kShadowHeight = CGFloat(5.0)
    
    public init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.appBackgroundLight
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addNextButtonIfNeeded()
        addBackButtonIfNeeded()
        addSkipButtonIfNeeded()
        addShadowIfNeeded()
    }
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        topMargin: CGFloat,
        bottomMargin: CGFloat,
        oneButtonSideMargin: CGFloat,
        twoButtonSideMargin: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        shadowHeight: CGFloat)
    {
        return (kTopMargin,
                kBottomMargin,
                kOneButtonSideMargin,
                kTwoButtonSideMargin,
                kHorizontalPadding,
                kVerticalPadding,
                kShadowHeight)
    }
    
    open func addNavigationButton() -> UIButton {
        let button = RSDRoundedButton()
        button.corners = RSDRoundedButton.defaultCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        return button
    }
    
    open func addBackButtonIfNeeded() {
        guard backButton == nil else { return }
        backButton = addNavigationButton()
        backButton.setTitle(Localization.buttonBack(), for: .normal)
    }
    
    open func addNextButtonIfNeeded() {
        guard nextButton == nil else { return }
        nextButton = addNavigationButton()
        nextButton.setTitle(Localization.buttonNext(), for: .normal)
    }
    
    open func addSkipButtonIfNeeded() {
        guard skipButton == nil else { return }
        let button = RSDUnderlinedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        skipButton = button
        skipButton.setTitle(Localization.buttonSkip(), for: .normal)
    }
    
    open func addShadowIfNeeded() {
        guard shadowView == nil else { return }
        
        shadowView = RSDShadowGradient()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.heightAnchor.constraint(equalToConstant: constants().shadowHeight).isActive = true
        
        self.addSubview(shadowView)
        
        shadowView.alignToSuperview([.leading, .trailing], padding: 0.0)
        shadowView.alignToSuperview([.top], padding:  -1 * constants().shadowHeight)
        shadowView.isHidden = !shouldShowShadow
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    open func updateInteractiveConstraints() {
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        addNextButtonIfNeeded()
        addBackButtonIfNeeded()
        addSkipButtonIfNeeded()

        backButton.isHidden = isBackHidden
        skipButton.isHidden = isSkipHidden
        
        _interactiveContraints.append(contentsOf:
            nextButton.alignToSuperview([.top], padding: constants().topMargin))
        
        if isBackHidden {
            // if we don't have backButton, align left edge of nextButton to superview left
            _interactiveContraints.append(contentsOf:
                nextButton.alignToSuperview([.leading, .trailing], padding: constants().oneButtonSideMargin, priority: UILayoutPriority(800.0)))
            _interactiveContraints.append(contentsOf:
                nextButton.alignToSuperview([.centerX], padding: 0))
        }
        else {
            // Otherwise, align the buttons to the edges and grow in the middle if needed
            _interactiveContraints.append(contentsOf:
                backButton.align([.centerY], .equal, to: nextButton, [.centerY], padding: 0))
            _interactiveContraints.append(contentsOf:
                backButton.makeWidthEqualToView(nextButton))
            _interactiveContraints.append(contentsOf:
                backButton.alignToSuperview([.leading], padding: constants().twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                nextButton.alignToSuperview([.trailing], padding: constants().twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                backButton.alignLeftOf(view: nextButton, padding: constants().horizontalPadding, priority: UILayoutPriority(800.0)))
        }
        
        if isSkipHidden {
            _interactiveContraints.append(contentsOf:
                nextButton.alignToSuperview([.bottom], padding: constants().bottomMargin))
        }
        else {
            _interactiveContraints.append(contentsOf:
                skipButton.alignBelow(view: nextButton, padding: constants().verticalPadding))
            _interactiveContraints.append(contentsOf:
                skipButton.alignToSuperview([.bottom], padding: constants().bottomMargin))
            _interactiveContraints.append(contentsOf:
                skipButton.alignToSuperview([.centerX], padding: 0))
        }
    }
    
    open override func updateConstraints() {
        updateInteractiveConstraints()
        addShadowIfNeeded()
        super.updateConstraints()
    }
}
