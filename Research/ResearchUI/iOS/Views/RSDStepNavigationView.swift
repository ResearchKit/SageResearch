//
//  RSDStepNavigationView.swift
//  ResearchUI
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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
import Research

/// A protocol that UIView subclasses can use to standardize the color of their view properties.
public protocol RSDViewDesignable : class {
    
    /// The background color mapping that this view should use as its key. Typically, for all but the
    /// top-level views, this will be the background of the superview.
    var backgroundColorTile: RSDColorTile? { get }
    
    /// The design system for this component.
    var designSystem: RSDDesignSystem? { get }
    
    /// All views will have a superview property.
    var superview: UIView? { get }
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    ///
    /// - parameters:
    ///     - designSystem: The design system that is used to set up this view.
    ///     - background: The background tile for this view.
    func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile)
}

extension UIView {
    
    /// Recursively set the design system for subviews of this view.
    ///
    /// - note: If the subview implements the `RSDViewDesignable` protocol, it is assumed that that view will
    /// call the recursive set on it's subviews should it need to.
    ///
    /// - parameters:
    ///     - designSystem: The design system that is used to set up this view.
    ///     - background: The background tile for this view.
    func recursiveSetDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.subviews.forEach { (view) in
            if let designable = view as? RSDViewDesignable,
                designable.designSystem == nil {
                designable.setDesignSystem(designSystem, with: background)
            }
            else {
                view.recursiveSetDesignSystem(designSystem, with: background)
            }
        }
    }
    
    /// Get the background color tile for this view. This may be the background color for the view or it may
    /// be that this view has a transparent background and gets its real backgrounnd from the super view.
    ///
    /// - returns: The color tile built for this view or `nil` if it could not be determined.
    public func backgroundTile() -> RSDColorTile? {
        var view : UIView? = self
        while let vw = view,
            ((vw as? RSDViewDesignable)?.backgroundColorTile == nil),
            (vw.backgroundColor == nil || vw.backgroundColor == UIColor.clear) {
            view = vw.superview
        }
        if let colorTile = (view as? RSDViewDesignable)?.backgroundColorTile {
            return colorTile
        }
        else if let background = view?.backgroundColor {
            return RSDColorTile(background, usesLightStyle: (background != UIColor.white))
        }
        else {
            return nil
        }
    }
}

/// `RSDStepNavigationView` is a custom `UIView` to be included in a `RSDStepViewController`.
/// It optionally contains references to standard step navigation UI including a next button,
/// back button, skip button, learn more button, and cancel button.
@IBDesignable
open class RSDStepNavigationView: UIView, RSDViewDesignable {
    
    /// Button for navigating to the next step.
    @IBOutlet open var nextButton: UIButton?
    
    /// Button for navigating back to the previous step.
    @IBOutlet open var backButton: UIButton?
    
    /// Button for skipping the step or task.
    @IBOutlet open var skipButton: UIButton?
    
    /// Button for showing learn more info about the step or task.
    @IBOutlet open var learnMoreButton: UIButton?
    
    /// Button for reviewing instructions for the task.
    @IBOutlet open var reviewInstructionsButton: UIButton?
    
    /// Button for cancelling the task.
    @IBOutlet open var cancelButton: UIButton?
    
    /// The label for displaying the title.
    @IBOutlet open var titleLabel: UILabel?
    
    /// The label for displaying step text.
    @IBOutlet open var textLabel: UILabel?
    
    /// The label for displaying step detail text.
    @IBOutlet open var detailLabel: UILabel?
    
    /// The image view for displaying an image.
    @IBOutlet open var imageView: UIImageView?
    
    /// Whether or not the view has an image.
    open var hasImage: Bool = false
    
    /// The image to display in the view.
    open var image: UIImage? {
        get { return imageView?.image }
        set {
            imageView?.image = newValue
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    /// Return all the buttons in this navigation view.
    open func allButtons() -> [UIButton] {
        return Array(1...5).compactMap { (idx) -> UIButton? in
            switch idx {
            case 1: return nextButton
            case 2: return backButton
            case 3: return skipButton
            case 4: return learnMoreButton
            case 5: return cancelButton
            default: return nil
            }
        }
    }
    
    /// Should the navigation view show the back button?
    @IBInspectable open var isBackHidden: Bool = false {
        didSet {
            backButton?.isHidden = isBackHidden
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// Should the navigation view show the skip button?
    @IBInspectable open var isSkipHidden: Bool = true {
        didSet {
            skipButton?.isHidden = isSkipHidden
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// Should the navigation view subcomponents be displayed with a dark background and light tint on the
    /// buttons and text?
    @available(*, unavailable)
    open var usesLightStyle: Bool = false
    
    /// The background color mapping that this view should use as its key.
    open private(set) var backgroundColorTile: RSDColorTile?
    
    /// The design system for this component.
    open private(set) var designSystem: RSDDesignSystem?
    
    /// Views can be used in nibs and storyboards without setting up a design system for them. This allows
    /// for setting up views to use the same design system and background color mapping as their parent view.
    open func setDesignSystem(_ designSystem: RSDDesignSystem, with background: RSDColorTile) {
        self.backgroundColorTile = background
        self.designSystem = designSystem
        self.backgroundColor = background.color
        
        let buttons = allButtons()
        let tintColor = designSystem.colorRules.tintedButtonColor(on: background)
        buttons.forEach {
            $0.tintColor = tintColor
            if let designable = $0 as? RSDViewDesignable,
                designable.designSystem == nil {
                designable.setDesignSystem(designSystem, with: background)
            }
        }
        
        updateColors()
        
        self.recursiveSetDesignSystem(designSystem, with: background)
        
        // Set the fonts for the labels
        titleLabel?.font = designSystem.fontRules.font(for: .largeHeader, compatibleWith: self.traitCollection)
        textLabel?.font = designSystem.fontRules.font(for: .body, compatibleWith: self.traitCollection)
        detailLabel?.font = designSystem.fontRules.font(for: .bodyDetail, compatibleWith: self.traitCollection)
        
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
    }
    
    fileprivate func updateColors() {
        let designSystem = self.designSystem ?? RSDDesignSystem()
        let colorTile: RSDColorTile = self.backgroundColorTile ?? {
            let background = self.backgroundColor ?? UIColor.white
            return RSDColorTile(background, usesLightStyle: background != UIColor.white)
        }()
        
        self.tintColor = designSystem.colorRules.tintedButtonColor(on: colorTile)
        titleLabel?.textColor = designSystem.colorRules.textColor(on: colorTile, for: .largeHeader)
        textLabel?.textColor = designSystem.colorRules.textColor(on: colorTile, for: .body)
        detailLabel?.textColor = designSystem.colorRules.textColor(on: colorTile, for: .bodyDetail)
    }
}

/// `RSDNavigationHeaderView` is a general purpose navigation header view that can be used
/// by the step view controller to include UI elements that may typically be shown at the top
/// of the step view.
@IBDesignable
open class RSDNavigationHeaderView: RSDStepNavigationView {
    
    /// A progress view for showing step progress.
    @IBOutlet open var progressView: RSDStepProgressView? {
        didSet {
            hookupStepLabel()
        }
    }
    
    /// A label used to display the number of steps. For example, "Step 2 out of 5".
    @IBOutlet open var stepCountLabel: UILabel?  {
        didSet {
            hookupStepLabel()
        }
    }
    
    /// Causes the progress view to be shown or hidden. Default is `true`.
    @IBInspectable open var shouldShowCloseButton = true {
        didSet {
            addCloseButtonIfNeeded()
            cancelButton?.isHidden = !shouldShowCloseButton
            setNeedsUpdateConstraints()
        }
    }
    
    /// Causes the progress view to be shown or hidden. Default is `true`.
    @IBInspectable open var shouldShowProgress = true {
        didSet {
            addProgressViewIfNeeded()
            progressView?.isHidden = !shouldShowProgress
            setNeedsUpdateConstraints()
        }
    }
    
    /// Should the step label be hidden?
    @IBInspectable open var isStepLabelHidden: Bool = false {
        didSet {
            stepCountLabel?.isHidden = isStepLabelHidden
            setNeedsUpdateConstraints()
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
    
    private func commonInit() {
        hookupStepLabel()
    }
    
    fileprivate func hookupStepLabel() {
        guard let label = self.stepCountLabel else { return }
        self.progressView?.stepCountLabel = label
    }
    
    /// Layout constants. Subclasses can override to customize; otherwise the default private
    /// constants are used.
    open private(set) var constants: RSDNavigationHeaderLayoutConstants = DefaultNavigationHeaderLayoutConstants()
    
    /// Convenience method for adding a close button if needed.
    open func addCloseButtonIfNeeded() {
        guard cancelButton == nil && shouldShowCloseButton else { return }
        cancelButton = UIButton()
        cancelButton!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cancelButton!)
    }
    
    /// Convenience method for adding a progress view if needed.
    open func addProgressViewIfNeeded() {
        guard progressView == nil && shouldShowProgress else { return }
        
        progressView = RSDStepProgressView()
        progressView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progressView!)
    }
}

/// Constants used by the navigation view header to set up standard constraints.
public protocol RSDNavigationHeaderLayoutConstants {
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var sideMargin: CGFloat { get }
    var promptBottomMargin: CGFloat { get }
    var horizontalSpacing: CGFloat { get }
    var verticalSpacing: CGFloat { get }
    var barButtonHeight: CGFloat { get }
    var buttonToTop: CGFloat { get }
    var buttonLeadng: CGFloat { get }
    var imageViewHeight: CGFloat { get }
    var labelMaxLayoutWidth: CGFloat { get }
}

/// Default constants.
fileprivate struct DefaultNavigationHeaderLayoutConstants {
    let topMargin: CGFloat = CGFloat(18.0).rsd_proportionalToScreenHeight(max: 28)
    let bottomMargin: CGFloat = CGFloat(18.0).rsd_iPadMultiplier(1.5)
    let sideMargin: CGFloat = CGFloat(30.0).rsd_proportionalToScreenWidth()
    let promptBottomMargin: CGFloat = CGFloat(10.0).rsd_iPadMultiplier(1.5)
    let horizontalSpacing: CGFloat = CGFloat(16.0).rsd_iPadMultiplier(2)
    let verticalSpacing: CGFloat = CGFloat(10.0).rsd_iPadMultiplier(1.5)
    let barButtonHeight: CGFloat = CGFloat(50.0).rsd_iPadMultiplier(1.5)
    let buttonToTop: CGFloat = CGFloat(8.0).rsd_iPadMultiplier(2)
    let buttonLeadng: CGFloat = CGFloat(8.0).rsd_iPadMultiplier(2)
    let imageViewHeight: CGFloat = CGFloat(100.0).rsd_proportionalToScreenHeight()
    let labelMaxLayoutWidth: CGFloat = {
        return CGFloat(UIScreen.main.bounds.size.width - (2 * CGFloat(30.0).rsd_proportionalToScreenWidth()))
    }()
}

extension DefaultNavigationHeaderLayoutConstants : RSDNavigationHeaderLayoutConstants {
}

/// `RSDStepHeaderView` is a custom `UIView` designed for use as a header view in a table view, such as
/// an `RSDTableStepViewController`.
@IBDesignable
open class RSDStepHeaderView: RSDNavigationHeaderView {
    
    /// Causes the main view to be resized to this minimum height, if necessary. The extra needed height
    /// is added to and divided equally between the top margin and bottom margin of the main view.
    open var minumumHeight: CGFloat = 0.0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
}

/// `RSDTableStepHeaderView` is a concrete implementation of `RSDStepHeaderView` that will automatically
/// lay out the UI elements in this order, from top to bottom of the view:
///
/// 1. cancelButton: UIButton - allows for cancelling the task
/// 2. progressView: RSDStepProgressView - show progress thru the current flow
/// 3. imageView: UIImageView - shows an image associated with the current step
/// 4. titleLabel: UILabel - generally the Title of the current step
/// 5. textLabel: UILabel - generally the Text of the current step
/// 6. learnMoreButton: UIButton - a button to call the learnMoreAction
/// 7. detailLabel: UILabel - a label intended to prompt the user to enter data or make a selection
///
/// Several public properties are provided to configure the view, such has hiding or showing the learnMoreButton
/// or progressView, and providing a minimumHeight or customView.
///
open class RSDTableStepHeaderView: RSDStepHeaderView {
    
    public init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
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
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        setNeedsDisplay()
    }

    /// Convenience method for adding a learn more button if needed.
    open func addLearnMoreIfNeeded() {
        guard learnMoreButton == nil else { return }
        learnMoreButton = RSDUnderlinedButton()
        learnMoreButton!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(learnMoreButton!)
        
        learnMoreButton!.rsd_alignCenterHorizontal(padding: 0.0)
    }
    
    /// Convenience method for adding an image view if needed.
    open func addImageViewIfNeeded() {
        guard imageView == nil else { return }
        imageView = UIImageView()
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        imageView!.contentMode = .scaleAspectFit
        self.addSubview(imageView!)
        
        imageView!.rsd_alignCenterHorizontal(padding: 0)
        let height = imageView!.heightAnchor.constraint(equalToConstant: constants.imageViewHeight)
        height.isActive = true
    }
    
    /// Convenience method for adding a label.
    open func addLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.preferredMaxLayoutWidth = constants.labelMaxLayoutWidth
        self.addSubview(label)
        
        label.rsd_alignToSuperview([.leading, .trailing], padding: constants.sideMargin)
        label.rsd_makeHeight(.greaterThanOrEqual, 0.0)
        
        return label
    }
    
    /// Convenience method for adding the title label if needed.
    open func addTitleLabelIfNeeded() {
        guard titleLabel == nil else { return }
        titleLabel = addLabel()
        titleLabel!.accessibilityTraits = UIAccessibilityTraits.header
    }
    
    /// Convenience method for adding the text label if needed.
    open func addTextLabelIfNeeded() {
        guard textLabel == nil else { return }
        textLabel = addLabel()
        textLabel!.accessibilityTraits = UIAccessibilityTraits.summaryElement
    }
    
    /// Convenience method for adding the detail label if needed.
    open func addDetailLabelIfNeeded() {
        guard detailLabel == nil else { return }
        detailLabel = addLabel()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
        textLabel?.preferredMaxLayoutWidth = textLabel?.frame.size.width ?? 0
        
        layoutIfNeeded()
    }
    
    open override func updateConstraints() {
        self.updateInteractiveConstraints()
        super.updateConstraints()
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    private func updateInteractiveConstraints() {
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        var topView: UIView?
        var lastView: UIView?
        
        if let cancelButton = cancelButton, shouldShowCloseButton, !cancelButton.isHidden {
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_alignToSuperview([.leading], padding: constants.buttonLeadng))
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_alignToSuperview([.topMargin], padding: constants.buttonToTop))
            _interactiveContraints.append(contentsOf:
                cancelButton.rsd_makeHeight(.equal, constants.barButtonHeight))
            topView = cancelButton
            lastView = cancelButton
        }
        
        // progress view
        if let progressView = progressView, shouldShowProgress {
            if let cancelButton = topView {
                progressView.hasRoundedEnds = true
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_align([.leading], .equal, to: cancelButton, [.trailing], padding: constants.horizontalSpacing))
                _interactiveContraints.append(contentsOf:
                    progressView.rsd_alignToSuperview([.trailing], padding: 2*constants.horizontalSpacing))
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
                let padding: CGFloat = (topView == cancelButton) ? 0.0 : 5.0
                _interactiveContraints.append(contentsOf:
                    stepCountLabel.rsd_align([.top], .equal, to: topView!, [.bottom], padding: padding))
                lastView = progressView.stepCountLabel
            }
        }
        
        // Set up vertical stack constraints for associated views
        let verticalViewResult = self.updateVerticalConstraints(currentLastView: lastView)
        let firstView = topView ?? verticalViewResult.firstView
        lastView = verticalViewResult.lastView
        
        if let lastView = lastView {
            if let detailLabel = detailLabel, shouldLayout(detailLabel) {
                _interactiveContraints.append(contentsOf:
                    detailLabel.rsd_alignBelow(view: lastView, padding: constants.bottomMargin))
                _interactiveContraints.append(contentsOf:
                    detailLabel.rsd_alignToSuperview([.bottom], padding: constants.promptBottomMargin))
            }
            else {
                _interactiveContraints.append(contentsOf:
                    lastView.rsd_alignToSuperview([.bottom], padding: constants.bottomMargin))
            }
            
            // check our minimum height
            let height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if height == 0 {
                NSLayoutConstraint.deactivate(self.constraints)
                self.rsd_makeHeight(.equal, 0.0)
            }
            else if height < minumumHeight, let firstView = firstView {
                
                // adjust our top and bottom margins
                let topConstraint = firstView.rsd_constraint(for: .top, relation: .equal)
                let bottomConstraint = lastView.rsd_constraint(for: .bottom, relation: .equal)
                
                let marginIncrease = (minumumHeight - height) / 2
                topConstraint?.constant += marginIncrease
                bottomConstraint?.constant -= marginIncrease
            }
        }
    }
    
    /// Your subclass can override this function to add more vertically stacked views, either before or after all the
    /// existing ones, depending on whether you add them before or after calling the `super` function. If you do,
    /// you'll need to manage removing and re-adding the associated constraints in your override as well.
    /// - parameter currentLastView: The last (vertical) view currently in the navigation header. If no views are
    ///                              added in a subclass override of this function, this should be returned in the
    ///                              lastView parameter.
    /// - returns:  A tuple with the firstView and lastView that had vertical constraints applied. If none were
    ///             applied, firstView will be nil, and lastView will be the same as currentLastView.
    open func updateVerticalConstraints(currentLastView: UIView?) -> (firstView: UIView?, lastView: UIView?) {
        
        var firstView: UIView?
        var lastView: UIView? = currentLastView
        
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
        
        return (firstView, lastView)
    }
    
    private func applyVerticalConstraint(to view: UIView, lastView: UIView?) {
        if lastView != nil {
            // align below last view. If the last view is the progressView, then we want our gap to be
            // the topMargin, otherwise it's verticalSpacing
            let gap = (lastView == progressView || lastView == cancelButton) ? constants.topMargin :
                ((lastView == imageView) ? 2 * constants.verticalSpacing : constants.verticalSpacing)
            _interactiveContraints.append(contentsOf:
                view.rsd_alignBelow(view: lastView!, padding: gap))
        } else {
            // align pinned to superview top
            _interactiveContraints.append(contentsOf:
                view.rsd_alignToSuperview([.top], padding: constants.topMargin))
        }
    }
    
    private func shouldLayout(_ view: UIView?) -> Bool {
        
        guard view != nil else { return false }
        
        if let progressView = view as? RSDStepProgressView {
            return shouldShowProgress && progressView.progress > 0
        }
        else if let imageView = view as? UIImageView {
            return hasImage || (imageView.image != nil)
        }
        else if let label = view as? UILabel {
            return (label.text?.count ?? 0) > 0
        }
        else if let underlineButton = view as? RSDUnderlinedButton {
            return (underlineButton.title(for: .normal)?.count ?? 0) > 0
        }
        else if let button = view as? UIButton {
            return !button.isHidden
        }
        
        return true
    }
}

/// `RSDNavigationFooterView` is an abstract implementation for the `RSDStepNavigationView` which can be
/// added to a Nib, Storyboard or instantiated using the `RSDTableStepUIConfig.instantiatNavigationView()`
/// method.
@IBDesignable
open class RSDNavigationFooterView: RSDStepNavigationView {
    
    /// An optional shadow gradient to use to display a shadow (used to indicate additional content below the fold).
    @IBOutlet open var shadowView: RSDShadowGradient?
    
    /// Should the footer view show a drop shadow above it?
    /// Default = false
    /// If the value in app configuration is false, that overrides any attempt to set to true.
    @IBInspectable
    open var shouldShowShadow: Bool = false {
        didSet {
            let shadowEnabled = RSDTableStepUIConfig.shouldShowNavigationViewShadow()
            _shouldShowShadow = shadowEnabled && shouldShowShadow
            self.shadowView?.isHidden = !_shouldShowShadow
            self.clipsToBounds = !_shouldShowShadow
        }
    }
    
    private var _shouldShowShadow = false
}

/// Constants used by the navigation view footer to set up standard constraints.
public protocol RSDNavigationFooterLayoutConstants {
    var topMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var oneButtonSideMargin: CGFloat { get }
    var twoButtonSideMargin: CGFloat { get }
    var horizontalPadding: CGFloat { get }
    var verticalPadding: CGFloat { get }
    var shadowHeight: CGFloat { get }
}

internal struct DefaultNavigationFooterLayoutConstants {
    let topMargin = CGFloat(16.0).rsd_proportionalToScreenHeight(max: 24.0)
    let bottomMargin = CGFloat(12.0).rsd_proportionalToScreenHeight(max: 24.0)
    let horizontalPadding = CGFloat(20.0)
    let verticalPadding = CGFloat(18.0)
    let oneButtonSideMargin = CGFloat(24.0)
    let twoButtonSideMargin = CGFloat(10.0).rsd_proportionalToScreenWidth()
    let shadowHeight = CGFloat(5.0)
}

extension DefaultNavigationFooterLayoutConstants : RSDNavigationFooterLayoutConstants {
}

/// `RSDGenericNavigationFooterView` is a concrete implementation of `RSDNavigationFooterView` that will
/// automatically lay out the UI elements included in the navigation footer:
///
/// 1. nextButton: UIButton - for navigating to the next step
/// 2. backButton: UIButton - for navigating to the previous step
/// 3. skipButton: UIButton - for skipping the step or task
/// 4. shadowView: RSDShadowGradient - shows a shadow to indicate that there is content below the fold
///
@IBDesignable
open class RSDGenericNavigationFooterView: RSDNavigationFooterView {
    
    public required init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
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
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        setNeedsDisplay()
    }
    
    private func commonInit() {
        addNextButtonIfNeeded()
        addBackButtonIfNeeded()
        addSkipButtonIfNeeded()
        addShadowIfNeeded()
        updateColors()
    }
    
    /// Layout constants. Subclasses can override to customize; otherwise the default private
    /// constants are used.
    open private(set) var constants: RSDNavigationFooterLayoutConstants = DefaultNavigationFooterLayoutConstants()
    
    /// Convenience method for adding a navigation button. The default method instantiates an `RSDRoundedButton`.
    open func addNavigationButton() -> UIButton {
        let button = RSDRoundedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        return button
    }
    
    /// Convenience method for adding a back button.
    open func addBackButtonIfNeeded() {
        guard backButton == nil else { return }
        backButton = addNavigationButton()
        backButton!.setTitle(Localization.buttonBack(), for: .normal)
    }
    
    /// Convenience method for adding a next button.
    open func addNextButtonIfNeeded() {
        guard nextButton == nil else { return }
        nextButton = addNavigationButton()
        nextButton!.setTitle(Localization.buttonNext(), for: .normal)
    }
    
    /// Convenience method for adding a skip button.
    open func addSkipButtonIfNeeded() {
        guard skipButton == nil else { return }
        let button = RSDUnderlinedButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        skipButton = button
        skipButton!.setTitle(Localization.buttonSkip(), for: .normal)
    }
    
    /// Convenience method for adding a shadow gradient.
    open func addShadowIfNeeded() {
        guard shadowView == nil else { return }
        
        shadowView = RSDShadowGradient()
        shadowView!.translatesAutoresizingMaskIntoConstraints = false
        shadowView!.heightAnchor.constraint(equalToConstant: constants.shadowHeight).isActive = true
        
        self.addSubview(shadowView!)
        
        shadowView!.rsd_alignToSuperview([.leading, .trailing], padding: 0.0)
        shadowView!.rsd_alignToSuperview([.top], padding:  -1 * constants.shadowHeight)
        shadowView!.isHidden = !shouldShowShadow
    }
    
    open override func updateConstraints() {
        addShadowIfNeeded()
        self.updateInteractiveConstraints()
        super.updateConstraints()
    }
    
    private var _interactiveContraints: [NSLayoutConstraint] = []
    
    private func updateInteractiveConstraints() {
        
        NSLayoutConstraint.deactivate(_interactiveContraints)
        _interactiveContraints.removeAll()
        
        addNextButtonIfNeeded()
        addBackButtonIfNeeded()
        addSkipButtonIfNeeded()

        backButton!.isHidden = isBackHidden
        skipButton!.isHidden = isSkipHidden
        
        _interactiveContraints.append(contentsOf:
            nextButton!.rsd_alignToSuperview([.top], padding: constants.topMargin, priority: UILayoutPriority(800.0)))
        
        _interactiveContraints.append(contentsOf:
            nextButton!.rsd_align([.top], .greaterThanOrEqual, to: nextButton!.superview, [.top], padding: constants.topMargin))
        
        if isBackHidden {
            // if we don't have backButton, align left edge of nextButton to superview left
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.leading, .trailing], padding: constants.oneButtonSideMargin, priority: UILayoutPriority(800.0)))
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
                backButton!.rsd_alignToSuperview([.leading], padding: constants.twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_alignToSuperview([.trailing], padding: constants.twoButtonSideMargin))
            _interactiveContraints.append(contentsOf:
                backButton!.rsd_alignLeftOf(view: nextButton!, padding: constants.horizontalPadding, priority: UILayoutPriority(800.0)))
        }
        
        if isSkipHidden {
            _interactiveContraints.append(contentsOf:
                nextButton!.rsd_align([.bottom], .equal, to: nextButton!.superview, [.bottomMargin], padding: constants.bottomMargin))
        }
        else {
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_alignBelow(view: nextButton!, padding: constants.verticalPadding))
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_align([.bottom], .equal, to: skipButton!.superview, [.bottomMargin], padding: constants.bottomMargin))
            _interactiveContraints.append(contentsOf:
                skipButton!.rsd_alignToSuperview([.centerX], padding: 0))
        }
    }
}



