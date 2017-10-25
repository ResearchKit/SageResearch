//
//  RSDStepHeaderView.swift
//  ResearchSuite-UI
//
//  Created by Josh Bruhin on 5/25/17.
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
 A custom UIView to be included in an RSDGenericStepViewController. It optionally contains several subViews
 and displays them in this order, from top to bottom of the view:
 
 1) progressView: RSDStepProgressView - show progress thru the current flow
 2) imageView: UIImageView - shows an image associated with the current step
 3) headerLabel: UILabel - generally the Title of the current step
 4) detailsLabel: UILabel - generally the Text of the current step
 5) customView: UIView - any custom view provided by the RSDGenericStepViewController
 6) learnMoreButton: UIButton - a button to call the learnMoreAction
 7) promptLabel: UILabel - a label intended to prompt the user to enter data or make a selection
 
 Several public properties are provided to configure the view, such has hiding or showing the learnMoreButton
 or progressView, and providing a minimumHeight or customView.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */
open class RSDStepHeaderView: UIView {
    
    private let kTopMargin: CGFloat = CGFloat(30.0).proportionalToScreenWidth()
    private let kSideMargin: CGFloat = CGFloat(30.0).proportionalToScreenWidth()
    private let kVerticalSpacing: CGFloat = CGFloat(20.0).proportionalToScreenWidth()
    private let kBottomMargin: CGFloat = CGFloat(30.0).proportionalToScreenWidth()
    private let kPromptBottomMargin: CGFloat = CGFloat(10.0).proportionalToScreenWidth()
    private let kImageViewHeight: CGFloat = CGFloat(100.0).proportionalToScreenWidth()
    private let kLearnMoreButtonHeight: CGFloat = 30.0
    private let kLabelMaxLayoutWidth: CGFloat = {
        return CGFloat(UIScreen.main.bounds.size.width - (2 * CGFloat(30.0).proportionalToScreenWidth()))
    }()
    
    /**
     Causes the progress view to be shown or hidden. Default is the value from UI config.
     */
    open var shouldShowProgress = RSDGenericStepUIConfig.shouldShowProgressView() {
        didSet {
            progressView.isHidden = !shouldShowProgress
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Causes the learn more button to be shown or hidden.
     */
    open var shouldShowLearnMore: Bool = false {
        didSet {
            learnMoreButton.isHidden = !shouldShowLearnMore
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Causes an image to be shown or hidden. It will assign the provided image (or nil) to the
     imageView. The imageView will be hidden automatically if the imageView.image is nil.
     */
    open var image: UIImage? {
        didSet {
            imageView.image = image
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    private var _customView: UIView? {
        didSet {
            if let customView = _customView {
                self.addSubview(customView)
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     An optional view that can be included. It is shown directly below the detailsLabel
     and above the learnMoreButton. This view can be provided by subclasses in the initializeViews()
     method or assigned later.
     */
    open var customView: UIView? {
        get {
            return _customView
        }
        set {
            if let customView = customView {
                // if we already have a customView, we need to remove it from its superview
                customView.removeFromSuperview()
                setNeedsUpdateConstraints()
            }
            _customView = newValue
        }
    }
    
    /**
     Causes the main view to be resized to this minimum height, if necessary. The extra needed height
     is added to and divided equally between the top margin and bottom margin of the main view.
     */
    open var minumumHeight: CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    open var progressView: RSDStepProgressView!
    open var learnMoreButton: UIButton!
    
    open var headerLabel: UILabel!
    open var detailsLabel: UILabel!
    open var promptLabel: UILabel!
    open var imageView: UIImageView!    
    open var hasImage: Bool = false
    
    /**
     Layout constants. Subclasses can override to customize; otherwise the default private
     constants are used.
     */
    open func constants() -> (
        topMargin: CGFloat,
        bottomMargin: CGFloat,
        promptBottomMargin: CGFloat,
        sideMargin: CGFloat,
        verticalSpacing: CGFloat,
        imageViewHeight: CGFloat,
        labelMaxLayoutWidth: CGFloat)
    {
        return (kTopMargin,
                kBottomMargin,
                kPromptBottomMargin,
                kSideMargin,
                kVerticalSpacing,
                kImageViewHeight,
                kLabelMaxLayoutWidth)
    }
    
    /**
     Create all the view elements. Subclasses can override to provide custom instances. A customView
     can optionally be created here by the subclass.
     */
    open func initializeViews() {
        
        progressView = RSDStepProgressView()
        learnMoreButton = RSDUnderlinedButton()
        
        headerLabel = UILabel()
        detailsLabel = UILabel()
        promptLabel = UILabel()
        imageView = UIImageView()
        
        // customView used by subclass, not initialized here
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        
        initializeViews()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if shouldShowProgress {
            // add progress view
            self.addSubview(progressView)
        }
        
        
        // add imageView
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        
        // add labels
        self.addSubview(headerLabel)
        self.addSubview(detailsLabel)
        self.addSubview(promptLabel)
        
        headerLabel.accessibilityTraits = UIAccessibilityTraitHeader
        detailsLabel.accessibilityTraits = UIAccessibilityTraitSummaryElement
        
        headerLabel.numberOfLines = 0
        detailsLabel.numberOfLines = 0
        promptLabel.numberOfLines = 0
        
        headerLabel.font = UIFont.headerViewHeaderLabel
        detailsLabel.font = UIFont.headerViewDetailsLabel
        promptLabel.font = UIFont.headerViewPromptLabel
        
        headerLabel.textColor = UIColor.headerViewHeaderLabel
        detailsLabel.textColor = UIColor.headerViewDetailsLabel
        promptLabel.textColor = UIColor.headerViewPromptLabel
        
        headerLabel.textAlignment = .center
        detailsLabel.textAlignment = .center
        promptLabel.textAlignment = .center
        
        headerLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        detailsLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        promptLabel.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        
        // add learn more button
        self.addSubview(learnMoreButton)
        
        // customView, if any
        if let customView = customView {
            self.addSubview(customView)
        }
        
        setNeedsUpdateConstraints()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        headerLabel.preferredMaxLayoutWidth = headerLabel.frame.size.width
        detailsLabel.preferredMaxLayoutWidth = detailsLabel.frame.size.width
        
        layoutIfNeeded()
    }
    
    open override func updateConstraints() {
        
        NSLayoutConstraint.deactivate(self.constraints)
        
        var firstView: UIView? = nil
        var lastView: UIView? = nil
        
        // progress view
        if shouldLayout(progressView) {
            progressView.alignToSuperview([.leading, .trailing, .top], padding: 0.0)
            firstView = progressView
            lastView = progressView
        }
        
        // image view
        if shouldLayout(imageView) {
            applyVerticalConstraint(to: imageView, lastView: lastView)
            imageView.alignCenterHorizontal(padding: 0.0)
            imageView.makeHeight(.equal, constants().imageViewHeight)
            firstView = firstView == nil ? imageView : firstView
            lastView = imageView
        }
        
            
        // header label
        if shouldLayout(headerLabel) {
            applyVerticalConstraint(to: headerLabel, lastView: lastView)
            headerLabel.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
            headerLabel.makeHeight(.greaterThanOrEqual, 0.0)
            firstView = firstView == nil ? headerLabel : firstView
            lastView = headerLabel
        }
        
        
        // details label
        if shouldLayout(detailsLabel) {
            applyVerticalConstraint(to: detailsLabel, lastView: lastView)
            detailsLabel.alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
            detailsLabel.makeHeight(.greaterThanOrEqual, 0.0)
            firstView = firstView == nil ? detailsLabel : firstView
            lastView = detailsLabel
        }
        
        // custom view
        if let customView = customView, shouldLayout(customView) {
            // we align left and right to superview and top to view above
            customView.translatesAutoresizingMaskIntoConstraints = false
            applyVerticalConstraint(to: customView, lastView: lastView)
            customView.alignToSuperview([.leading, .trailing], padding: 0.0)
            firstView = firstView == nil ? customView : firstView
            lastView = customView
            
            // we assume the height constraint has been set
            // TODO: Josh Bruhin, 6/12/17 - check for or enforce this
        }
        
        // learn more button
        if shouldLayout(learnMoreButton) {
            applyVerticalConstraint(to: learnMoreButton, lastView: lastView)
            learnMoreButton.alignCenterHorizontal(padding: 0.0)
            learnMoreButton.makeHeight(.equal, kLearnMoreButtonHeight)
            firstView = firstView == nil ? learnMoreButton : firstView
            lastView = learnMoreButton
        }
        
        if lastView != nil {

            
            // prompt label
            if shouldLayout(promptLabel) {
                promptLabel.alignBelow(view: lastView!, padding: constants().bottomMargin)
                promptLabel.alignCenterHorizontal(padding: 0.0)
                promptLabel.makeHeight(.greaterThanOrEqual, 0.0)
                promptLabel!.alignToSuperview([.bottom], padding: constants().promptBottomMargin)
            }
            else {
                lastView!.alignToSuperview([.bottom], padding: constants().bottomMargin)
            }
            
            // check our minimum height
            let height = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            if height == 0 {
                NSLayoutConstraint.deactivate(self.constraints)
                self.makeHeight(.equal, 0.0)
            }
            else if height < minumumHeight {
                
                // adjust our top and bottom margins
                let topConstraint = firstView!.constraint(for: .top, relation: .equal)
                let bottomConstraint = lastView!.constraint(for: .bottom, relation: .equal)
                
                let marginIncrease = (minumumHeight - height) / 2
                topConstraint?.constant += marginIncrease
                bottomConstraint?.constant -= marginIncrease
            }
        }
        
        super.updateConstraints()
    }
    
    func applyVerticalConstraint(to view: UIView, lastView: UIView?) {
        if lastView != nil {
            // align below last view. If the last view is the progressView, then we want our gap to be
            // the topMargin, otherwise it's verticalSpacing
            let gap = lastView == progressView ? constants().topMargin : constants().verticalSpacing
            view.alignBelow(view: lastView!, padding: gap)
        } else {
            // align pinned to superview top
            view.alignToSuperview([.top], padding: constants().topMargin)
        }
    }
    
    func shouldLayout(_ view: UIView?) -> Bool {

        guard view != nil else { return false }
        
        if let progressView = view as? RSDStepProgressView {
            return shouldShowProgress && progressView.progress > 0
        }
        else if let imageView = view as? UIImageView {
            return hasImage || (imageView.image != nil)
        }
        else if let label = view as? UILabel {
            return (label.text?.characters.count ?? 0) > 0
        }
        else if let button = view as? UIButton, button == self.learnMoreButton {
            // If this is the learn more button then only show if used.
            return shouldShowLearnMore
        }
        
        return true
    }

}
