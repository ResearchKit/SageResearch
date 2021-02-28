//
//  RSDInstructionStepViewController.swift
//  ResearchUI (iOS)
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

import UIKit
import Research

/// `RSDInstructionStepViewController` is a custom step view controller that is intended to be used with the
/// `RSDInstructionStepViewController.nib` file. This is the default view controller for steps that
open class RSDInstructionStepViewController: RSDPermissionStepViewController {

    /// Retuns the imageView, in this case the image from the navigationHeader.
    open var imageView: UIImageView? {
        return self.navigationHeader?.imageView
    }
    
    /// Scrollview for the image and instruction text.
    @IBOutlet var scrollView: UIScrollView?
    
    /// The constraint that sets the scroll bar's top background view's height.
    @IBOutlet var imageBackgroundTopConstraint: NSLayoutConstraint?
    
    /// The constraint that sets the image height. This needs to be adjusted for smaller screens.
    @IBOutlet var headerHeightConstraint: NSLayoutConstraint?
    
    /// The constraint between the learn more button and the bottom of the view.
    @IBOutlet var learnMoreBottomConstraint: NSLayoutConstraint?
    
    /// A view that is used to mark the height of the text instruction area.
    @IBOutlet var instructionTextView: UIView?
    
    /// The image leading constraint can be used to set up the image to use different constraints for
    /// the `iconBefore` image placement type.
    @IBOutlet var imageLeadingConstraint: NSLayoutConstraint?
    
    /// The image top constraint can be used to set up the image to use different constraints for the
    /// `iconBefore` image placement type.
    @IBOutlet var imageTopConstraint: NSLayoutConstraint?
    
    /// Save the previously calculated instruction height.
    private var _remainingHeight: CGFloat = 0
    
    /// Override `viewDidLayoutSubviews` to set up resizing the image to balance the the space provided to
    /// the image verse the space provided for the text.
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageHeightConstraintIfNeeded()
    }
    
    /// Override `viewWillAppear` to update image placement constraints.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImagePlacementConstraintsIfNeeded()
        self.updateLearnMoreContraints()
    }
    
    /// Sets the height of the scrollview's top background view depending on the image placement type from
    /// this step. Default behavior is to constrain the scrollview to be under the status bar if the placement
    /// type is `.topMarginBackground`.
    open func updateImagePlacementConstraintsIfNeeded() {
        
        // Update the image placement for iconBefore.
        if (self.imageTheme?.placementType == .iconBefore),
            let leading = self.imageLeadingConstraint,
            let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            let themeSize = self.imageTheme?.imageSize?.cgSize
            let imageSize: CGSize? = themeSize != .zero ? themeSize : self.imageView?.image?.size
            let desiredWidth = min(imageSize?.width ?? 999999, self.view.bounds.width * 0.5)
            let constant = floor((self.view.bounds.width - desiredWidth) * 0.5)
            if constant != leading.constant {
                leading.constant = constant
                self.view.setNeedsUpdateConstraints()
                self.view.setNeedsLayout()
            }
        }
        
        // Update the image placement for top background.
        if let headerTopConstraint = self.imageBackgroundTopConstraint {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let constant = (self.imageTheme?.placementType == .topBackground) ? CGFloat(0) : statusBarHeight
            if constant != headerTopConstraint.constant {
                headerTopConstraint.constant = constant
                self.view.setNeedsUpdateConstraints()
                self.view.setNeedsLayout()
            }
        }
    }
    
    /// If the learn more button is hidden, then the constraints for it should be deactivated.
    open func updateLearnMoreContraints() {
        guard let button = registeredButtons[.navigation(.learnMore)]?.first,
            let constraint = self.learnMoreBottomConstraint
            else {
                return
        }
        constraint.isActive = (!button.isHidden && button.alpha > 0.1)
        self.view.setNeedsUpdateConstraints()
    }
    
    /// Update the image height constraint to balance the the space provided to the image versus the space
    /// provided for the text. The default is to look at the overall screen height and size the image to take
    /// up half the space if the text does not fit (iPhone SE) or resize to take the remaining space if the
    /// image is for a longer screen (iPhone X).
    open func updateImageHeightConstraintIfNeeded() {
        guard let instructionTextView = self.instructionTextView,
            let scrollView = self.scrollView,
            let headerTopConstraint = self.imageBackgroundTopConstraint,
            let headerHeightConstraint = self.headerHeightConstraint
            else {
                return
        }
        
        let remainingHeight = scrollView.bounds.height - instructionTextView.bounds.height - headerTopConstraint.constant
        let minHeight = (self.imageTheme?.placementType == .iconBefore) ? self.view.bounds.height / 3 : self.view.bounds.height / 2
        let height = max(remainingHeight, minHeight)
        if headerHeightConstraint.constant != height {
            headerHeightConstraint.constant = height
            self.navigationFooter?.shouldShowShadow = (height != remainingHeight)
            self.view.setNeedsUpdateConstraints()
            self.view.setNeedsLayout()
        }
    }
    
    override open func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        if placement == .body {
            scrollView?.backgroundColor = background.color
        }
    }
    
    
    // MARK: Initialization
    
    /// Static method to determine if this view controller class supports the provided step.
    ///
    /// Only UI Themed steps with an image that is top-background are supported.  Additionally, if there are
    /// form items that need to be displayed then this view controller is not appropriate.
    ///
    /// - note: support for elements such as a footnote, detail, learn more, etc. require using a custom
    /// implementation for the nib or storyboard.
    open class func doesSupport(_ step: RSDStep) -> Bool {
        
        // Must have a top background image.
        guard let themedStep = step as? RSDDesignableUIStep,
            let imageTheme = themedStep.imageTheme,
            let placement = imageTheme.placementType
            else {
                return false
        }
        
        // Question steps are not supported.
        if step is QuestionStep {
            return false
        }
        
        // Footnotes and review instructions buttons are not supported.
        guard (themedStep.footnote == nil),
            (themedStep.shouldHideAction(for: .navigation(.reviewInstructions), on: step) ?? true)
            else {
                return false
        }
        
        return (placement == .topBackground || placement == .topMarginBackground || placement == .iconBefore)
    }
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDInstructionStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle.module
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Initialize the class using the given nib and bundle.
    /// - note: If this initializer is used with a `nil` nib, then it must assign the expected outlets.
    /// - parameters:
    ///     - nibNameOrNil: The name of the nib or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Required initializer. This is the initializer used by a `UIStoryboard`.
    /// - parameter aDecoder: The decoder used to initialize this view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
