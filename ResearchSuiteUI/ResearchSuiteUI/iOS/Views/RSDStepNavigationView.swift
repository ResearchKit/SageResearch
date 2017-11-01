//
//  RSDStepNavigationView.swift
//  ResearchSuiteUI
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

/**
 A custom UIView to be included in an RSDStepViewController. It contains a Next button, back button, and shadowView. The ViewController is responsible for assigning targets and actions to the buttons.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */
@IBDesignable
open class RSDStepNavigationView: UIView {
    
    @IBOutlet open var nextButton: UIButton?
    @IBOutlet open var backButton: UIButton?
    @IBOutlet open var skipButton: UIButton?
    @IBOutlet open var learnMoreButton: UIButton?
    @IBOutlet open var cancelButton: UIButton?
    
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
    
    open func updateInteractiveConstraints() {
        // Do nothing - included to allow customized layout by having subclasses that override this anddo not call through to super
    }
    
    open override func updateConstraints() {
        self.updateInteractiveConstraints()
        super.updateConstraints()
    }
}

@IBDesignable
open class RSDNavigationBarView: RSDStepNavigationView {
    
    public let kSideMargin: CGFloat = CGFloat(30.0).rsd_proportionalToScreenWidth()
    public let kHorizontalSpacing: CGFloat = CGFloat(16.0).rsd_iPadMultiplier(2)
    public let kButtonHeight: CGFloat = CGFloat(32.0).rsd_iPadMultiplier(1.5)
    public let kButtonToTop: CGFloat = CGFloat(12.0).rsd_iPadMultiplier(2)
    
    @IBOutlet open var progressView: RSDStepProgressView?
    @IBOutlet open var stepCountLabel: UILabel?
    
    /**
     Causes the progress view to be shown or hidden. Default is the value from UI config.
     */
    @IBInspectable open var shouldShowCloseButton = RSDGenericStepUIConfig.shouldShowCloseButton() {
        didSet {
            addCloseButtonIfNeeded()
            cancelButton?.isHidden = !shouldShowCloseButton
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Causes the progress view to be shown or hidden. Default is the value from UI config.
     */
    @IBInspectable open var shouldShowProgress = RSDGenericStepUIConfig.shouldShowProgressView() {
        didSet {
            addProgressViewIfNeeded()
            progressView?.isHidden = !shouldShowProgress
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     Should the step label be hidden?
     */
    @IBInspectable open var isStepLabelHidden: Bool = false {
        didSet {
            stepCountLabel?.isHidden = isStepLabelHidden
            setNeedsUpdateConstraints()
        }
    }
    
    open func addCloseButtonIfNeeded() {
        guard cancelButton == nil && shouldShowCloseButton else { return }
        cancelButton = UIButton()
        cancelButton!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cancelButton!)
    }
    
    open func addProgressViewIfNeeded() {
        
        guard progressView == nil && shouldShowProgress else { return }
        
        progressView = RSDStepProgressView()
        progressView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progressView!)
        
        stepCountLabel = UILabel()
        stepCountLabel!.translatesAutoresizingMaskIntoConstraints = false
        stepCountLabel!.font = UIFont.stepCountLabel
        stepCountLabel!.numberOfLines = 1
        stepCountLabel!.textAlignment = .center
        stepCountLabel!.attributedText = progressView!.attributedStringForLabel()
        stepCountLabel!.isHidden = isStepLabelHidden
        
        // Move the step count label to this view so that we can align it to center of *this* view.
        self.addSubview(stepCountLabel!)
        stepCountLabel!.rsd_alignToSuperview([.leading, .trailing], padding: kSideMargin)
        stepCountLabel!.rsd_makeHeight(.greaterThanOrEqual, 0.0)
        
        // Add pointer to the progress label
        progressView?.stepCountLabel = stepCountLabel
    }
}


/**
 A custom UIView to be included in an RSDGenericStepViewController. It optionally contains several subViews
 and displays them in this order, from top to bottom of the view:
 
 1) cancelButton: UIButton - allows for cancelling the task
 2) progressView: RSDStepProgressView - show progress thru the current flow
 3) imageView: UIImageView - shows an image associated with the current step
 4) titleLabel: UILabel - generally the Title of the current step
 5) textLabel: UILabel - generally the Text of the current step
 6) learnMoreButton: UIButton - a button to call the learnMoreAction
 7) detailLabel: UILabel - a label intended to prompt the user to enter data or make a selection
 
 Several public properties are provided to configure the view, such has hiding or showing the learnMoreButton
 or progressView, and providing a minimumHeight or customView.
 
 To customize the view elements, subclasses should override the initializeViews() method. This will allow
 the use of any custom element (of the appropriate type) to be used instead of the default instances.
 */
@IBDesignable
open class RSDStepHeaderView: RSDNavigationBarView {
    
    @IBOutlet open var imageView: UIImageView?
    @IBOutlet open var titleLabel: UILabel?
    @IBOutlet open var textLabel: UILabel?
    @IBOutlet open var detailLabel: UILabel?
    
    open var hasImage: Bool = false
    
    open var image: UIImage? {
        get { return imageView?.image }
        set {
            imageView?.image = newValue
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
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

    private let kTopMargin: CGFloat = CGFloat(30.0).rsd_proportionalToScreenHeight()
    private let kVerticalSpacing: CGFloat = CGFloat(20.0).rsd_proportionalToScreenHeight()
    private let kBottomMargin: CGFloat = CGFloat(30.0).rsd_proportionalToScreenHeight()
    private let kPromptBottomMargin: CGFloat = CGFloat(10.0).rsd_proportionalToScreenHeight()
    private let kImageViewHeight: CGFloat = CGFloat(100.0).rsd_proportionalToScreenHeight()
    private let kLearnMoreButtonHeight: CGFloat = 30.0
    private let kLabelMaxLayoutWidth: CGFloat = {
        return CGFloat(UIScreen.main.bounds.size.width - (2 * CGFloat(30.0).rsd_proportionalToScreenWidth()))
    }()
    
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
}

@IBDesignable
open class RSDGenericStepHeaderView: RSDStepHeaderView {
    
    public init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.appBackgroundLight
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        addCloseButtonIfNeeded()
        addProgressViewIfNeeded()
        addLearnMoreIfNeeded()
        addImageViewIfNeeded()
        addTitleLabelIfNeeded()
        addTextLabelIfNeeded()
        addDetailLabelIfNeeded()
        
        setNeedsUpdateConstraints()
    }

    open func addLearnMoreIfNeeded() {
        guard learnMoreButton == nil else { return }
        learnMoreButton = RSDUnderlinedButton()
        learnMoreButton!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(learnMoreButton!)
        
        learnMoreButton!.rsd_alignCenterHorizontal(padding: 0.0)
    }
    
    open func addImageViewIfNeeded() {
        guard imageView == nil else { return }
        imageView = UIImageView()
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        imageView!.contentMode = .scaleAspectFit
        self.addSubview(imageView!)
        
        imageView!.rsd_alignCenterHorizontal(padding: 0)
        let height = imageView!.heightAnchor.constraint(equalToConstant: constants().imageViewHeight)
        height.isActive = true
    }
    
    open func addLabel(font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = font
        label.textColor = color
        label.textAlignment = .center
        label.preferredMaxLayoutWidth = constants().labelMaxLayoutWidth
        self.addSubview(label)
        
        label.rsd_alignToSuperview([.leading, .trailing], padding: constants().sideMargin)
        label.rsd_makeHeight(.greaterThanOrEqual, 0.0)
        
        return label
    }
    
    open func addTitleLabelIfNeeded() {
        guard titleLabel == nil else { return }
        titleLabel = addLabel(font: UIFont.headerViewHeaderLabel, color: UIColor.headerTitleLabel)
        titleLabel!.accessibilityTraits = UIAccessibilityTraitHeader
    }
    
    open func addTextLabelIfNeeded() {
        guard textLabel == nil else { return }
        textLabel = addLabel(font: UIFont.headerViewDetailsLabel, color: UIColor.headerTextLabel)
        textLabel!.accessibilityTraits = UIAccessibilityTraitSummaryElement
    }
    
    open func addDetailLabelIfNeeded() {
        guard detailLabel == nil else { return }
        detailLabel = addLabel(font: UIFont.headerViewPromptLabel, color: UIColor.headerDetailLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        textLabel?.preferredMaxLayoutWidth = textLabel?.frame.size.width ?? 0
        
        layoutIfNeeded()
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    open override func updateInteractiveConstraints() {
        super.updateInteractiveConstraints()
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        var firstView: UIView?
        var lastView: UIView?
        var topView: UIView?
        
        if let cancelButton = cancelButton, shouldShowCloseButton, !cancelButton.isHidden {
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_alignToSuperview([.leading], padding: kHorizontalSpacing))
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_alignToSuperview([.top], padding: kButtonToTop))
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_makeHeight(.equal, kButtonHeight))
            topView = cancelButton
            lastView = cancelButton
        }
        
        // progress view
        if let progressView = progressView, shouldShowProgress {
            if let cancelButton = firstView {
                progressView.hasRoundedEnds = true
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_align([.leading], .equal, to: cancelButton, [.trailing], padding: kHorizontalSpacing))
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_alignToSuperview([.trailing], padding: kHorizontalSpacing))
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_align([.centerY], .equal, to: cancelButton, [.centerY], padding: 0.0))
            } else {
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_alignToSuperview([.leading, .trailing, .top], padding: 0.0))
                topView = progressView
                lastView = progressView
            }
            
            // If the progress view step count label has been moved in the view hierarchy to this view then
            // need to define constraints relative to *this* view.
            if let stepCountLabel = stepCountLabel, !isStepLabelHidden {
                _interactiveContraints.append(contentsOf:
                    stepCountLabel.rsd_align([.top], .equal, to: topView!, [.bottom], padding: 0.0))
                lastView = progressView.stepCountLabel
            }
        }
        
        func setupVerticalConstraints(_ nextView: UIView?) {
            if let vw = nextView, shouldLayout(vw) {
                applyVerticalConstraint(to: vw, lastView: lastView)
                firstView = firstView == nil ? vw : firstView
                lastView = vw
            } else {
                nextView?.isHidden = true
            }
        }
        
        // image view
        setupVerticalConstraints(imageView)
        setupVerticalConstraints(titleLabel)
        setupVerticalConstraints(textLabel)
        setupVerticalConstraints(learnMoreButton)
        
        if lastView != nil {
            if let detailLabel = detailLabel, shouldLayout(detailLabel) {
                _interactiveContraints.append(contentsOf:
                    detailLabel.rsd_alignBelow(view: lastView!, padding: constants().bottomMargin))
                _interactiveContraints.append(contentsOf:
                    detailLabel.rsd_alignToSuperview([.bottom], padding: constants().promptBottomMargin))
            }
            else {
                _interactiveContraints.append(contentsOf:
                    lastView!.rsd_alignToSuperview([.bottom], padding: constants().bottomMargin))
            }
            
            // check our minimum height
            let height = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            if height == 0 {
                NSLayoutConstraint.deactivate(self.constraints)
                self.rsd_makeHeight(.equal, 0.0)
            }
            else if height < minumumHeight {
                
                // adjust our top and bottom margins
                let topConstraint = firstView!.rsd_constraint(for: .top, relation: .equal)
                let bottomConstraint = lastView!.rsd_constraint(for: .bottom, relation: .equal)
                
                let marginIncrease = (minumumHeight - height) / 2
                topConstraint?.constant += marginIncrease
                bottomConstraint?.constant -= marginIncrease
            }
        }
    }
    
    func applyVerticalConstraint(to view: UIView, lastView: UIView?) {
        if lastView != nil {
            // align below last view. If the last view is the progressView, then we want our gap to be
            // the topMargin, otherwise it's verticalSpacing
            let gap = (lastView == progressView) ? constants().topMargin : constants().verticalSpacing
            _interactiveContraints.append(contentsOf:
                view.rsd_alignBelow(view: lastView!, padding: gap))
        } else {
            // align pinned to superview top
            _interactiveContraints.append(contentsOf:
                view.rsd_alignToSuperview([.top], padding: constants().topMargin))
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
        else if let underlineButton = view as? RSDUnderlinedButton {
            return (underlineButton.title(for: .normal)?.characters.count ?? 0) > 0
        }
        else if let button = view as? UIButton {
            return !button.isHidden
        }
        
        return true
    }
}

/**
 `RSDNavigationFooterView` is the default implementation for the `RSDStepNavigationView` which can be added to a Nib, Storyboard or instantiated using the `RSDGenericStepUIConfig.instantiatNavigationView()` method.
 */
@IBDesignable
open class RSDNavigationFooterView: RSDStepNavigationView {
    
    @IBOutlet open var shadowView: RSDShadowGradient?
    
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
    
    public required init() {
        super.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@IBDesignable
open class RSDGenericNavigationFooterView: RSDNavigationFooterView {

    private let kTopMargin = CGFloat(16.0).rsd_proportionalToScreenHeight(max: 24.0)
    private let kBottomMargin = CGFloat(20.0).rsd_proportionalToScreenHeight(max: 40.0)
    private let kHorizontalPadding = CGFloat(20.0).rsd_proportionalToScreenWidth()
    private let kVerticalPadding = CGFloat(20.0).rsd_proportionalToScreenHeight(max: 30.0)
    private let kOneButtonSideMargin = CGFloat(20.0).rsd_proportionalToScreenWidth()
    private let kTwoButtonSideMargin = CGFloat(10.0).rsd_proportionalToScreenWidth()
    private let kShadowHeight = CGFloat(5.0)
    
    public required init() {
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
        backButton!.setTitle(Localization.buttonBack(), for: .normal)
    }
    
    open func addNextButtonIfNeeded() {
        guard nextButton == nil else { return }
        nextButton = addNavigationButton()
        nextButton!.setTitle(Localization.buttonNext(), for: .normal)
    }
    
    open func addSkipButtonIfNeeded() {
        guard skipButton == nil else { return }
        let button = RSDUnderlinedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        skipButton = button
        skipButton!.setTitle(Localization.buttonSkip(), for: .normal)
    }
    
    open func addShadowIfNeeded() {
        guard shadowView == nil else { return }
        
        shadowView = RSDShadowGradient()
        shadowView!.translatesAutoresizingMaskIntoConstraints = false
        shadowView!.heightAnchor.constraint(equalToConstant: constants().shadowHeight).isActive = true
        
        self.addSubview(shadowView!)
        
        shadowView!.rsd_alignToSuperview([.leading, .trailing], padding: 0.0)
        shadowView!.rsd_alignToSuperview([.top], padding:  -1 * constants().shadowHeight)
        shadowView!.isHidden = !shouldShowShadow
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    open override func updateInteractiveConstraints() {
        super.updateInteractiveConstraints()
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        addNextButtonIfNeeded()
        addBackButtonIfNeeded()
        addSkipButtonIfNeeded()

        backButton!.isHidden = isBackHidden
        skipButton!.isHidden = isSkipHidden
        
        _interactiveContraints.append(contentsOf:
            nextButton!.rsd_alignToSuperview([.top], padding: constants().topMargin))
        
        if isBackHidden {
            // if we don't have backButton, align left edge of nextButton to superview left
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.leading, .trailing], padding: constants().oneButtonSideMargin, priority: UILayoutPriority(800.0)))
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.centerX], padding: 0))
        }
        else {
            // Otherwise, align the buttons to the edges and grow in the middle if needed
            _interactiveContraints.append(contentsOf:
                backButton!.rsd_align([.centerY], .equal, to: nextButton, [.centerY], padding: 0))
            _interactiveContraints.append(contentsOf:
                backButton!.rsd_makeWidthEqualToView(nextButton!))
            _interactiveContraints.append(contentsOf:
                backButton!.rsd_alignToSuperview([.leading], padding: constants().twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.trailing], padding: constants().twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                backButton!.rsd_alignLeftOf(view: nextButton!, padding: constants().horizontalPadding, priority: UILayoutPriority(800.0)))
        }
        
        if isSkipHidden {
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.bottom], padding: constants().bottomMargin))
        }
        else {
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_alignBelow(view: nextButton!, padding: constants().verticalPadding))
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_alignToSuperview([.bottom], padding: constants().bottomMargin))
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_alignToSuperview([.centerX], padding: 0))
        }
    }
    
    open override func updateConstraints() {
        addShadowIfNeeded()
        super.updateConstraints()
    }
}
