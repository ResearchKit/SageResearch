//
//  RSDStepViewController.swift
//  ResearchUI
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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
import AudioToolbox
import AVFoundation
import AVKit
import UIKit
import Research

/// `RSDStepViewController` is the default base class implementation for the steps presented using this
/// UI architecture.
open class RSDStepViewController : UIViewController, RSDStepController, RSDCancelActionController {
    
    /// The stepViewModel presented by the step view controller.
    ///
    /// If you use a storyboard to initialize the step view controller, `init(step:parent:)` isn't called,
    /// so you need to set the `stepViewModel` property directly before the step view controller is presented.
    ///
    /// Setting the value of `stepViewModel` after the controller has been presented is an error that
    /// generates an assertion. Modifying the value of `stepViewModel` after the controller has been
    /// presented is an error that has undefined results.
    open var stepViewModel: RSDStepViewPathComponent! {
        didSet {
            if isVisible {
                assertionFailure("Cannot set step after presenting step view controller")
            }
        }
    }
    
    /// Instantiate a step view model appropriate to this step.
    open func instantiateStepViewModel(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepViewPathComponent {
        return RSDStepViewModel(step: step, parent: parent)
    }
    
    /// Convenience property for accessing the step from the step view model.
    public var step: RSDStep! {
        return stepViewModel?.step
    }
    
    /// Convenience property for casting the step to a `RSDUIStep`.
    public var uiStep: RSDUIStep? {
        return step as? RSDUIStep
    }
    
    /// Convenience property for casting the step to a `RSDDesignableUIStep`.
    public var designableStep: RSDDesignableUIStep? {
        return step as? RSDDesignableUIStep
    }
    
    /// Convenience property for casting the step to a `RSDSpokenInstructionStep`.
    public var spokenInstructionStep: RSDSpokenInstructionStep? {
        return step as? RSDSpokenInstructionStep
    }
    
    /// Convenience property for casting the step to a `RSDActiveUIStep`.
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let designSystem = self.designSystem else { return .default }
        let background = self.designableStep?.colorMapping?.backgroundColor(for: .header, using: designSystem.colorRules, compatibleWith: self.traitCollection)
            ?? self.defaultBackgroundColorTile(for: .header)
        return background.usesLightStyle ? .lightContent : .default
    }
    
    /// Returns the current result associated with this step. This property uses a lazy initializer to instantiate
    /// the result and append it to the step history if not found in the step history.
    lazy open var currentResult: RSDResult = {
        if let lastResult = stepViewModel.taskResult.stepHistory.last, lastResult.identifier == self.step.identifier {
            return lastResult
        } else {
            let result = self.step.instantiateStepResult()
            stepViewModel.taskResult.appendStepHistory(with: result)
            return result
        }
    }()
    
    // MARK: Initialization
    
    /// Returns a new step view controller for the specified step.
    /// - parameter step: The step to be presented.
    public init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: nil, bundle: nil)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
        self.modalPresentationStyle = .fullScreen
    }
    
    /// Initialize the class using the given nib and bundle.
    /// - parameters:
    ///     - nibNameOrNil: The name of the nib or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    /// Required initializer. This is the initializer used by a `UIStoryboard`.
    /// - parameter aDecoder: The decoder used to initialize this view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .fullScreen
    }
    
    // MARK: View appearance handling
    
    /// Track whether or not the view is visible. The value of this flag is set to `true` in
    /// `viewDidAppear` before anything else is done. It is set to `false` in `viewWillDisappear`
    /// before anything else is done.
    public private(set) var isVisible = false
    
    /// Track whether or not this is the first appearance. This flag is set to `true` in
    /// `viewDidAppear`. This flag is used to mark whether or not to call `performStartCommands()`.
    public private(set) var isFirstAppearance: Bool = true
    
    /// Should this step play an alarm if the phone screen is locked and the app is running in the
    /// background? If this is `true` then an alert will run (sound and vibration) until the user opens their
    /// phone. The default is `false`.
    ///
    /// This is intended for active tasks where the participant needs to look at their phone as soon as
    /// possible following a step that was running in the background to alert them to a follow-up action.
    ///
    open var playAlarmIfBackgrounded: Bool {
        return false
    }
    
    /// The design system to use with this step view controller.
    open var designSystem: RSDDesignSystem!
        
    /// Override `viewWillAppear` to set up the navigation, step details, and background color theme if this
    /// is the first appearance.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstAppearance {
            if self.designSystem == nil {
                let designSystem = (self.stepViewModel.parentTaskPath as? RSDTaskDesign)?.designSystem ?? RSDDesignSystem.shared
                let bundle = Bundle(for: type(of: self))
                if !designSystem.imageRules.registeredBundles.contains(bundle) {
                    designSystem.imageRules.insert(bundle: bundle, at: .max)
                }
                self.designSystem = designSystem
            }
            setupBackgroundColorTheme()
            setupViews()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// Override `viewDidAppear` to set the flag for `isVisible`, mark the result `startDate`, perform the
    /// start commands, and if the active commands include disabling the idle timer then do so in this method.
    open override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        super.viewDidAppear(animated)
        
        // Reset the goForward() flag.
        hasCalledGoForward = false
        
        // setup the result (lazy load) to mark the startDate
        let _ = currentResult
        
        // If this is the first appearance then perform the start commands
        if isFirstAppearance {
            performStartCommands()
            if UIApplication.shared.applicationState != .active, playAlarmIfBackgrounded {
                startBackgroundAlert()
            }
        }
        isFirstAppearance = false
        
        if let commands = self.activeStep?.commands, commands.contains(.shouldDisableIdleTimer) {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    /// Override `viewWillDisappear` to set the `isVisible` flag and enable the idle timer if it was disabled
    /// in view will appear.
    open override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
        super.viewWillDisappear(animated)
        
        if let commands = self.activeStep?.commands, commands.contains(.shouldDisableIdleTimer) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    // MARK: Navigation and Layout
    
    /// A mapping of all the buttons that were registered using `setupButton`.
    public private(set) var registeredButtons: [RSDUIActionType : Set<UIButton>] = [:]
    
    /// A UIView that is behind the status bar. This can be used to set the background for only the top
    /// part of a step view.
    @IBOutlet open var statusBarBackgroundView: UIView?
    
    /// A header view that includes navigation elements.
    @IBOutlet open var navigationHeader: RSDStepNavigationView?
    
    /// A footer view that includes navigation elements.
    @IBOutlet open var navigationFooter: RSDNavigationFooterView?
    
    /// A view for the main body.
    open var navigationBody: RSDStepNavigationView? {
        return self.view as? RSDStepNavigationView
    }
    
    /// The label for displaying step title text.
    open var stepTitleLabel: UILabel? {
        return self.navigationBody?.titleLabel ?? self.navigationHeader?.titleLabel ?? self.navigationFooter?.titleLabel
    }
    
    /// The label for displaying step text.
    open var stepTextLabel: UILabel? {
        return self.navigationBody?.textLabel ?? self.navigationHeader?.textLabel ?? self.navigationFooter?.textLabel
    }
    
    /// The label for displaying step detail text.
    open var stepDetailLabel: UILabel? {
        return self.navigationBody?.detailLabel ?? self.navigationHeader?.detailLabel ?? self.navigationFooter?.detailLabel
    }
    
    /// Convenience method for getting the "Next" button.
    open var nextButton: UIButton? {
        return registeredButtons[.navigation(.goForward)]?.first
    }
    
    /// Convenience method for getting the "Learn More" button.
    open var learnMoreButton: UIButton? {
        return self.navigationBody?.learnMoreButton ?? self.navigationHeader?.learnMoreButton ?? self.navigationFooter?.learnMoreButton
    }
    
    /// Is forward navigation enabled? The default implementation will check the task controller.
    public var isForwardEnabled: Bool {
        return stepViewModel.isForwardEnabled
    }
    
    /// Callback from the task controller called on the current step controller when loading is finished
    /// and the task is ready to continue.
    open func didFinishLoading() {
        // Enable the continue button(s) if all done.
        guard isForwardEnabled, let buttons = registeredButtons[.navigation(.goForward)] else { return }
        for button in buttons {
            button.isEnabled = true
        }
    }

    /// Set up the navigation header and footer. Additionally, set up the UI theme colors, UI images, and
    /// the step details such as the title, text, detail, and progress.
    open func setupViews() {
        
        // Set up label text.
        stepTitleLabel?.text = uiStep?.title
        stepTextLabel?.text = uiStep?.subtitle
        if let detail = uiStep?.detail {
            if let detailLabel = self.stepDetailLabel {
                detailLabel.text = detail
            }
            else {
                stepTextLabel?.text = (uiStep?.subtitle == nil) ? detail : "\(uiStep!.subtitle!)\n\n\(detail)"
            }
        }
        
        if let header = self.navigationHeader {
            setupHeader(header)
        }
        if let body = self.navigationBody {
            setupNavigationView(body, placement: .body)
        }
        if let footer = self.navigationFooter {
            setupFooter(footer)
        }
    }
    
    /// Set up the background color using the `colorTheme` from the step. This method does nothing
    /// if the step does not conform to the `RSDThemedUIStep` protocol.
    open func setupBackgroundColorTheme() {
        let placements: [RSDColorPlacement] = [.header, .body, .footer]
        for placement in placements {
            let background = self.backgroundColor(for: placement)
            setColorStyle(for: placement, background: background)
        }
    }
    
    /// Returns the background color tile to use for the given placement. This should look to see if there is
    /// color mapping defined by the designable step, then looks to the default if that is undefined.
    ///
    /// - parameter placement: The section of the view to which the color applies.
    /// - returns: The default color for that placement.
    open func backgroundColor(for placement: RSDColorPlacement) -> RSDColorTile {
        return self.designableStep?.colorMapping?.backgroundColor(for: placement,
                                                                  using: self.designSystem.colorRules,
                                                                  compatibleWith: self.traitCollection)
            ?? self.defaultBackgroundColorTile(for: placement)
    }
    
    /// Returns the default background color tile to use for the given placement.
    /// - parameter placement: The section of the view to which the color applies.
    /// - returns: The default color for that placement.
    open func defaultBackgroundColorTile(for placement: RSDColorPlacement) -> RSDColorTile {
        if placement == .header {
            return self.designSystem.colorRules.backgroundPrimary
        }
        else {
            return self.designSystem.colorRules.backgroundLight
        }
    }
    
    /// Set the color style for the given placement elements. This allows overriding by subclasses to
    /// customize the view style.
    open func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        
        var navigationComponent: RSDStepNavigationView?
        
        switch placement {
        case .header:
            navigationComponent = self.navigationHeader
            setupStatusBar(with: background)

        case .body:
            self.view.backgroundColor = background.color
            self.view.tintColor = self.designSystem.colorRules.tintedButtonColor(on: background)
            navigationComponent = self.navigationBody

        case .footer:
            navigationComponent = self.navigationFooter
        }
        
        navigationComponent?.setDesignSystem(self.designSystem, with: background)
    }
    
    /// The status bar overlay is a view that is set up to be underneath the status bar.
    ///
    /// - Default:
    ///     If the background uses light style
    ///         then the overlay is `clear`
    ///         else `RSDColor.black.withAlphaComponent(0.1)`
    ///     If there is a background image
    ///         then the statusbar background is `clear`
    ///         else `background.color`
    open func setupStatusBar(with background: RSDColorTile) {
        self.statusBarBackgroundView?.backgroundColor = background.color
        if let statusView = self.statusBarBackgroundView as? RSDStatusBarBackgroundView {
            statusView.overlayColor = background.usesLightStyle ? UIColor.clear : RSDColor.black.withAlphaComponent(0.1)
        }
    }
    
    /// Set up the header. Because this may be used in a table view as the table's header view, this includes
    /// all the step details that are typically at the top of the view such as setting images, text, and progress.
    /// Additionally, this method will set up the navigation buttons included in the header view and any color
    /// themes that are appropriate.
    /// - parameter header: The header view.
    open func setupHeader(_ header: RSDStepNavigationView) {
        setupNavigationView(header, placement: .header)

        // setup progress
        if let header = header as? RSDNavigationHeaderView {
            if let (stepIndex, stepCount, isEstimated) = self.stepViewModel.progress() {
                header.shouldShowProgress = true
                header.progressView?.totalSteps = stepCount
                header.progressView?.currentStep = stepIndex
                header.stepCountLabel?.text = header.progressView?.stringForLabel()
                header.isStepLabelHidden = isEstimated
            } else {
                header.shouldShowProgress = false
                header.isStepLabelHidden = true
            }
        }

        header.setNeedsLayout()
        header.setNeedsUpdateConstraints()
    }
    
    /// Set up the footer. This method will set up the navigation buttons included in the footer view
    /// and any color themes that are appropriate.
    /// - parameter footer: The footer view.
    open func setupFooter(_ footer: RSDNavigationFooterView) {
        setupNavigationView(footer, placement: .footer)
    }
    
    /// Set up the navigation UI elements for the given view.  By default, this method will
    /// check for whether or not a button should be hidden and set the visibility as is
    /// appropriate. For example, the first step in a task should never show a back button.
    /// This will also setup color themes, images, selectors, etc.
    ///
    /// - parameters:
    ///     - navigationView: The view to set up.
    ///     - isFooter: Is this the footer?
    open func setupNavigationView(_ navigationView: RSDStepNavigationView, placement: RSDColorPlacement) {
        
        // Check if the back button and skip button should be hidden for this task
        // and if so, then do so at this level. Otherwise, the button doesn't layout properly.
        let backHiddened = self.stepViewModel.shouldHideAction(for: .navigation(.goBackward))
        navigationView.isBackHidden = backHiddened
        let skipHidden = self.stepViewModel.shouldHideAction(for: .navigation(.skip))
        navigationView.isSkipHidden = skipHidden
        
        let isFooter = (placement == .footer)
        setupButton(navigationView.cancelButton, for: .navigation(.cancel), isFooter: isFooter)
        setupButton(navigationView.learnMoreButton, for: .navigation(.learnMore), isFooter: isFooter)
        setupButton(navigationView.nextButton, for: .navigation(.goForward), isFooter: isFooter)
        setupButton(navigationView.backButton, for: .navigation(.goBackward), isFooter: isFooter)
        setupButton(navigationView.skipButton, for: .navigation(.skip), isFooter: isFooter)
        setupButton(navigationView.reviewInstructionsButton, for: .navigation(.reviewInstructions), isFooter: isFooter)
        
        if let imageTheme = self.imageTheme {
            let imagePlacement = imageTheme.placementType ?? .iconBefore
            let shouldSetImage = shouldSetNavigationImage(for: placement, with: imagePlacement)
            if shouldSetImage {
                // Nil out the image that is used during testing and layout of the nib.
                navigationView.imageView?.image = nil
                navigationView.hasImage = true
                self.loadImages(into: navigationView)
            }
        }
        
        navigationView.setNeedsLayout()
        navigationView.setNeedsUpdateConstraints()
    }
    
    open func loadImages(into navigationView: RSDStepNavigationView) {
        guard let imageTheme = self.imageTheme,
            let imageView = navigationView.imageView
            else {
                return
        }
        let traitCollection = self.traitCollection
        let designSystem = self.designSystem
        self.loadImage(withKey: "RSDImageViewCell",
                       using: imageTheme,
                       into: imageView,
                       using: designSystem,
                       compatibleWith: traitCollection)
    }
    
    /// Return the image theme for this step view controller.
    open var imageTheme: RSDImageThemeElement? {
        return self.designableStep?.imageTheme
    }
    
    /// By default, this method will return `true` if the image theme uses a placement
    /// of `topBackground` or `topMarginBackground`.
    open func hasTopBackgroundImage() -> Bool {
        if let placement = self.imageTheme?.placementType {
            return placement == .topBackground || placement == .topMarginBackground
        } else {
            return false
        }
    }

    /// Convenience method for setting up each of the buttons. This will set up color theme, add the
    /// selector, and hide the button if indicated by the UI and the task state.
    ///
    /// - parameters:
    ///     - button:       The button to set up.
    ///     - actionType:   The navigation action type for the button.
    ///     - isFooter:     Is this button in the navigation footer?
    open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType, isFooter: Bool) {
        guard let btn = button else { return }
        
        // Register the buttons
        var buttonSet: Set<UIButton> = registeredButtons[actionType] ?? []
        buttonSet.insert(btn)
        registeredButtons[actionType] = buttonSet

        // Add an action if not setup already and the action type is recognized
        if btn.actions(forTarget: nil, forControlEvent: .touchUpInside) == nil {
            switch actionType {
            case .navigation(.goForward):
                btn.addTarget(self, action: #selector(_forwardTapped), for: .touchUpInside)
            case .navigation(.goBackward):
                btn.addTarget(self, action: #selector(_backTapped), for: .touchUpInside)
            case .navigation(.skip):
                btn.addTarget(self, action: #selector(_skipTapped), for: .touchUpInside)
            case .navigation(.cancel):
                btn.addTarget(self, action: #selector(_cancelTapped), for: .touchUpInside)
            case .navigation(.learnMore):
                btn.addTarget(self, action: #selector(_learnMoreTapped), for: .touchUpInside)
            case .navigation(.reviewInstructions):
                btn.addTarget(self, action: #selector(_reviewInstructionsTapped), for: .touchUpInside)
            default:
                break
            }
        }
        
        // Set up whether or not the button is visible and it's text/image
        btn.isHidden = self.stepViewModel.shouldHideAction(for: actionType)
        let btnAction: RSDUIAction? = self.stepViewModel.action(for: actionType) ?? {
            // Otherwise, look at the action and show the default based on the type
            switch actionType {
            case .navigation(.cancel):
                return RSDUIActionObject(iconName: "closeActivity", bundle: Bundle.module)
            case .navigation(.goForward):
                if self.step is RSDTaskInfoStep {
                    return RSDUIActionObject(buttonTitle: Localization.buttonGetStarted())
                } else if (self.stepViewModel.parentTaskPath?.hasStepAfter ?? false ){
                    return RSDUIActionObject(buttonTitle: Localization.buttonNext())
                } else {
                    return RSDUIActionObject(buttonTitle: Localization.buttonDone())
                }                
            case .navigation(.goBackward):
                return RSDUIActionObject(buttonTitle: Localization.buttonBack())
            case .navigation(.skip):
                if self.step is RSDTaskInfoStep {
                    return RSDUIActionObject(buttonTitle: Localization.buttonSkipTask())
                } else {
                    return RSDUIActionObject(buttonTitle: Localization.buttonSkip())
                }
                
            default:
                return nil
            }
        }()
        if let action = btnAction {
            btn.setTitle(action.buttonTitle, for: .normal)
            btn.setImage(action.buttonImage(using: self.designSystem, compatibleWith: self.traitCollection), for: .normal)
        }

        // If this is a goForward button, then there is some additional logic around
        // loading state and whether or not any input fields are optional
        if actionType == .navigation(.goForward) {
            btn.isEnabled = isForwardEnabled
        }
    }
    
    /// Returns `true` if the given RSDColorPlacement and RSDImagePlacementType indicate that
    /// this view controller should set an image, `false` otherwise.
    /// - parameters:
    ///     - placement:    the type of RSDColorPlacement that the view is using.
    ///     - imagePlacement:   the type of RSDImagePlacementType that the view is using.
    open func shouldSetNavigationImage(for placement: RSDColorPlacement, with imagePlacement: RSDImagePlacementType) -> Bool {
        switch placement {
        case .header:
            return imagePlacement == .topBackground || imagePlacement == .topMarginBackground || imagePlacement == .iconBefore
        case .body:
            return imagePlacement == .fullsizeBackground || imagePlacement == .iconAfter
        case .footer:
            return imagePlacement == .iconAfter
        }
    }
    
    @objc private func _forwardTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.goForward()
    }
    
    @objc private func _backTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.goBack()
    }
    
    @objc private func _skipTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.skipForward()
    }
    
    @objc private func _cancelTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.cancel()
    }
    
    @objc private func _learnMoreTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.showLearnMore()
    }
    
    @objc private func _reviewInstructionsTapped(_ sender: UIButton) {
        momentarilyDisableButton(sender)
        self.showReviewInstructions()
    }
    
    /// Momentarily disable the button.  This keeps a double-tap of a navigation button from
    /// triggering more than once. This is required b/c of how the UI handles the call to
    /// go forward/backward by calling a method that just looks at the current step.
    public func momentarilyDisableButton(_ button: UIButton) {
        if let transitionButton = button as? RSDButton {
            transitionButton.isInTransition = true
        }
        button.isUserInteractionEnabled = false
        let delay = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self, weak button] in
            self?._reenableButtons(button: button)
        }
    }
    
    private func _reenableButtons(button: UIButton?) {
        guard let button = button else { return }
        button.isUserInteractionEnabled = true
        if let transitionButton = button as? RSDButton {
            transitionButton.isInTransition = false
        }
    }
    
    /// Navigates forward to the next step. By default, it calls `performStopCommands()` to end
    /// the step and speaks the "end" instruction. When the end instruction is done, it will call
    /// `goForward` on the task controller.
    ///
    /// When a user taps a Next button, the information passes through this method. You can use
    /// this method as an override point or a target action for a subclass.
    @IBAction open func goForward() {
        guard !actionTapped(with: .navigation(.goForward)) else {
            debugPrint("WARNING: The default action of the `goForward()` method is being overridden by the associated action.")
            return
        }
        guard !hasCalledGoForward else { return }
        hasCalledGoForward = true
        performStopCommands()
        speakEndCommand {
            self.stepViewModel.perform(actionType: .navigation(.goForward))
        }
    }
    var hasCalledGoForward = false
    
    /// Navigates backward to the previous step. By default, it calls stop() to stop the timer
    /// and then calls `goBack` on the task controller.
    ///
    /// When a user taps the Back button, the information passes through this method. You can use
    /// this method as an override point or a target action for a subclass.
    @IBAction open func goBack() {
        guard !actionTapped(with: .navigation(.goBackward)) else {
            debugPrint("WARNING: The default action of the `goBack()` method is being overridden by the associated action.")
            return
        }
        stop()
        self.stepViewModel.perform(actionType: .navigation(.goBackward))
    }
    
    /// This method is called when the user taps the skip button. This method will call
    /// `actionTapped(with: .navigation(.skip))` to handle marking the result of the action (if required by
    /// the UI) and then will call `jumpForward()`.
    @IBAction open func skipForward() {
        guard !actionTapped(with: .navigation(.skip)) else { return }
        jumpForward()
    }
    
    /// By default, this method calls stop() to stop the timer and then calls `goForward` on the task
    /// controller. It is used to handle navigating away from the current step view controller in a manner
    /// which requires custom navigation because the step has not "ended" normally. For example, this method
    /// is called when a user taps the "skip" button.
    open func jumpForward() {
        if RSDSpeechSynthesizer.shared.isSpeaking {
            RSDSpeechSynthesizer.shared.stopTalking()
        }
        self.stop()
        self.stepViewModel.perform(actionType: .navigation(.goForward))
    }
    
    /// This method is called when the user taps the cancel button. By default, it confirms that the task
    /// should be canceled (unless this is the first step in the task). If the user confirms exit, then
    /// `cancelTask` is called.
    @IBAction open func cancel() {
        guard !actionTapped(with: .navigation(.cancel)) else {
            debugPrint("WARNING: The default action of the `cancel()` method is being overridden by the associated action.")
            return
        }
        self.confirmCancel()
    }
    
    /// Call through to the task view model.
    open func shouldConfirmCancel() -> Bool {
        return self.stepViewModel.rootPathComponent.shouldConfirmCancel()
    }
	
	/// Hook to let tasks know that user decided not to cancel.
	/// Default action is to do nothing, this method is to allow subclasses to override and have an action.
	open func didNotCancel() {
		//Defaults to do nothing.
	}

	/// Finish canceling the task. This is called once the cancel is confirmed by the user.
    ///
    /// - parameter shouldSave: Should the task progress be saved?
    open func cancelTask(shouldSave: Bool) {
        stop()
        self.stepViewModel.rootPathComponent.cancel(shouldSave: shouldSave)
    }
    
    /// This method is called when the user taps the "learn more" button. The default implementation
    /// will check if the learn more action is an `RSDResourceTransformer` and if so, will assume that
    /// the learn more is an embedded HTML file or an online URL. It will instantiate `RSDWebViewController`
    /// and present it modally.
    @IBAction open func showLearnMore() {
        guard actionTapped(with: .navigation(.learnMore))
            else {
                self.presentAlertWithOk(title: nil, message: "Missing learn more action for this task", actionHandler: nil)
                return
        }
    }
    
    
    /// This method is called when the user taps the "review instructions" button. The default implementation
    /// will check if the review action is an `RSDNavigationUIAction` and if so, will navigate back to that
    /// instruction, setting a value in the async results, marking that abbreviated instructions should *not*
    /// be shown.
    @IBAction open func showReviewInstructions() {
        // Reset the instructions to always be displayed
        self.stepViewModel.rootPathComponent.shouldShowAbbreviatedInstructions = false
        guard actionTapped(with: .navigation(.reviewInstructions))
            else {
                self.presentAlertWithOk(title: nil, message: "Missing learn more action for this task", actionHandler: nil)
                return
        }
    }
    
    /// Perform any actions associated with a given action type. By default, this is called *before* any other
    /// standard actions on a standard navigation are handled.
    /// - parameter actionType: The user-invoked action.
    /// - returns: `true` if the action was handled. If not handled, a default action associated with this
    ///            action type should be triggered by the calling method.
    open func actionTapped(with actionType: RSDUIActionType) -> Bool {
        guard let action = self.stepViewModel.action(for: actionType) else { return false }
        
        if let navAction = action as? RSDNavigationUIAction {
            // TODO: syoung 10/19/2018 FIXME! Replace the UIPageViewController with a more performant parent view controller.
            // The iPhone X takes a *really* long time to animate in reverse. Show a loading view.
            (self.taskController as? RSDTaskViewController)?.showLoadingView()
            DispatchQueue.main.async {
                // For a navigation action, assign the skip identifier and jump forward.
                self.assignSkipToIdentifier(navAction.skipToIdentifier)
                self.jumpForward()
            }
            return true
        }
        else if let webAction = action as? RSDWebViewUIAction {
            // For a webview action, present a web view modally.
            let (_, navVC) = RSDWebViewController.instantiateController(using: self.designSystem, action: webAction)
            self.present(navVC, animated: true, completion: nil)
            return true
        }
        else if let videoAction = action as? RSDVideoViewUIAction {
            // For a videoView action, present an AVPlayerViewController modally.
            do {                
                let url = try videoAction.fullURL()
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: url)
                self.present(vc, animated: true) {
                    vc.player?.play()
                }
            }
            catch let err {
                assertionFailure("Failed to get a url for this video. \(err)")
            }
            return true
        }
        else if let vcAction = action as? RSDShowViewUIAction {
            let vc = vcAction.instantiateViewController(for: self.stepViewModel)
            self.present(vc, animated: true, completion: nil)
            return true
        }
        else {
            // No action handler was found for this
            return false
        }
    }
    
    /// Mutate the current result by appending the results with a `skipToIdentifier`.
    /// - parameter skipToIdentifier: The identifier of the step to go to next.
    open func assignSkipToIdentifier(_ skipToIdentifier: String) {
        
        // Look to see if there is a navigation action that should be added based on the action handler.
        guard let previousResult = self.stepViewModel?.taskResult.stepHistory.last(where: { $0.identifier == step.identifier }) else {
                return
        }
        
        var navigationResult: RSDNavigationResult!
        if let navResult = previousResult as? RSDNavigationResult {
            // If this is a navigation result then set it as the navigation result.
            navigationResult = navResult
        }
        else {
            // Otherwise, replace the result with a collection result.
            var collectionResult = RSDCollectionResultObject(identifier: self.step.identifier)
            collectionResult.appendInputResults(with: previousResult)
            navigationResult = collectionResult
        }
        navigationResult.skipToIdentifier = skipToIdentifier
        self.stepViewModel!.taskResult.appendStepHistory(with: navigationResult)
    }
    
    
    // MARK: Permission handling
    
    /// Show an alert to the user to let them know that authorization has failed.
    open func handleAuthorizationFailed(status: RSDAuthorizationStatus, permission: RSDStandardPermission) {

        let settingsMessage = (status == .restricted) ? permission.restrictedMessage : permission.deniedMessage
        let message: String = {
            guard let reason = permission.reason else { return settingsMessage }
            return "\(reason)\n\n\(settingsMessage)"
        }()
        let title = Localization.localizedString("NOT_AUTHORIZED")
        
        var actions = [UIAlertAction]()
        
        if let url = URL(string:UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) {
            let settingsAction = UIAlertAction(title: Localization.localizedString("GOTO_SETTINGS"), style: .default) { (_) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            actions.append(settingsAction)
        }
        
        let okAction = UIAlertAction(title: Localization.buttonOK(), style: .default) { (_) in
            self.cancelTask(shouldSave: false)
        }
        actions.append(okAction)
        
        self.presentAlertWithActions(title: title, message: message, preferredStyle: .alert, actions: actions)
    }
    
    /// The authorization status for this view controller.
    open func checkAuthorizationStatus() -> (status: RSDAuthorizationStatus, permission: RSDStandardPermission?)  {
        guard let permissions = self.requiredPermissions(), permissions.count > 0 else {
            return (.authorized, nil)
        }
        for permission in permissions {
            let status = authorizationStatus(for: permission.permissionType)
            if status != .authorized {
                return (status, permission)
            }
        }
        return (.authorized, nil)
    }
    
    /// Check the authorization status for a given permission type.
    open func authorizationStatus(for permissionType: RSDStandardPermissionType) -> RSDAuthorizationStatus {
        return RSDAuthorizationHandler.authorizationStatus(for: permissionType.identifier)
    }
    
    /// The permissions required for this step.
    open func requiredPermissions() -> [RSDStandardPermission]? {
        return (self.step as? RSDStandardPermissionsStep)?.standardPermissions?.filter { !$0.isOptional }
    }
    
    /// The permissions that are requested as a part of this step.
    open func requestedPermissions() -> [RSDStandardPermission]? {
        return (self.step as? RSDStandardPermissionsStep)?.standardPermissions?.filter { $0.requestIfNeeded }
    }
    
    
    // MARK: Active step handling
    
    /// The countdown is a second countdown used by active steps. This value will be `0` if not used.
    /// Otherwise, `countdown = duration - timeIntervalSinceStart`.
    open var countdown: Int = 0
    
    /// Should this step start the timer? By default, this will return true for active steps. However,
    /// if you are running your app in the background, then you will need to set up a secondary means
    /// of keeping the app from suspending when the user locks the screen. You can do so by playing
    /// music or by using background GPS location updates.
    ///
    /// - note: The speech synthesizer does not work when the app is in background mode, but sounds
    /// and vibrations will still fire if the AVAudioSession is set up to do so.
    open var usesTimer: Bool {
        return self.activeStep != nil
    }
    
    /// Time interval for firing a repeating timer. Default = `1`.
    open var timerInterval: TimeInterval {
        return 1
    }
    
    /// The clock uptime for when the step was started. This is used by the timer to determine when to
    /// speak the next instruction and to set the value of the countdown.
    public var clock: RSDClock?
    
    /// The clock uptime for when the step was finished.
    public private(set) var completedUptime: TimeInterval?
    
    private var timer: Timer?
    private var lastInstruction: Int = -1
    
    /// Perform any start commands. This will speak an instruction that is set up for the start of the
    /// step, set the initial `countdown` value, and handle any `RSDActiveUIStepCommand` related to start
    /// up including starting the timer if the step should start automatically.
    open func performStartCommands() {
        
        if let stepDuration = self.activeStep?.duration {
            countdown = Int(stepDuration)
        }
        
        // Speak the start command
        speakInstruction(at: 0)
        
        if let commands = self.activeStep?.commands {
            if commands.contains(.playSoundOnStart) {
                playSound()
            }
            if commands.contains(.vibrateOnStart) {
                vibrateDevice()
            }
            if commands.contains(.startTimerAutomatically) {
                start()
            }
        }
    }
    
    /// Perform any stop command. This will also call `stop()` to stop the timer.
    open func performStopCommands() {
        if let commands = self.activeStep?.commands {
            if commands.contains(.playSoundOnFinish) {
                playSound()
            }
            if commands.contains(.vibrateOnFinish) {
                vibrateDevice()
            }
        }
        
        // Always run the stop command
        stop()
    }

    
    /// Play a sound. The default method will use the shared instance of `RSDAudioSoundPlayer`.
    /// - parameter sound: The sound to play.
    open func playSound(_ sound: RSDSound = .short_low_high) {
        RSDAudioSoundPlayer.shared.playSound(sound)
    }
    
    /// Vibrate the device (if applicable).
    open func vibrateDevice() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    /// Speak the given instruction. The default method will use the shared `RSDSpeechSynthesizer`.
    /// - parameters:
    ///     - instruction: The instruction to speak.
    ///     - timeInterval: The time interval marker (ignored by default implementation).
    ///     - completion: A completion handler to call when the instruction has finished.
    open func speakInstruction(_ instruction: String, at timeInterval: TimeInterval, completion: RSDVoiceBoxCompletionHandler?) {
        if self.activeStep?.requiresBackgroundAudio ?? false,
            let taskController = self.stepViewModel.rootPathComponent.taskController as? RSDTaskViewController {
            taskController.startBackgroundAudioSessionIfNeeded()
        }
        RSDSpeechSynthesizer.shared.speak(text: instruction, completion: completion)
    }
    
    /// Speak the instruction that is included at the given time marker (if any).
    open func speakInstruction(at duration: TimeInterval) {
        let nextInstruction = Int(duration)
        if let stepDuration = self.activeStep?.duration,
            duration >= stepDuration && stepDuration > 0 {
            // For the last instruction, speak the end command.
            speakEndCommand { }
        }
        else if nextInstruction > lastInstruction {
            for ii in (lastInstruction + 1)...nextInstruction {
                let timeInterval = TimeInterval(ii)
                if let instruction = self.spokenInstruction(at: timeInterval) {
                    speakInstruction(instruction, at: timeInterval, completion: nil)
                }
            }
            lastInstruction = nextInstruction
        }
    }
    
    /// Speak the "end" command (spoken instruction) and then call the completion once finished.
    /// If the "end" command was previously spoken, then this will call the completion immediately.
    public func speakEndCommand(_ completion: @escaping (() -> Void)) {
        if !_hasSpokenEndInstruction, let instruction = self.spokenInstruction(at: Double.infinity) {
            _hasSpokenEndInstruction = true
            speakInstruction(instruction, at: Double.infinity, completion: { (_, _) in
                completion()
            })
        } else {
            completion()
        }
    }
    private var _hasSpokenEndInstruction: Bool = false
    
    /// Returns the spoken instruction for a given time point. Default calls the active step spoken instruction.
    open func spokenInstruction(at duration: TimeInterval) -> String? {
        return self.spokenInstructionStep?.spokenInstruction(at: duration)
    }
    
    /// Start the timer.
    open func start() {
        _startTimer()
        _setupInterruptionObserver()
        self.taskController?.startAsyncActionsIfNeeded()
    }
    
    private func _startTimer() {
        if clock == nil {
            clock = RSDClock()
        }
        timer?.invalidate()
        if usesTimer {
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { [weak self] (_) in
                self?.timerFired()
            })
        }
    }
    
    /// Stop the timer.
    open func stop() {
        _stopTimer()
        _stopInterruptionObserver()
    }

    private func _stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Reset the countdown clock.
    open func reset() {
        clock = nil
        countdown = 0
    }
    
    /// Pause the timer.
    open func pause() {
        clock?.pause()
        _stopTimer()
        // If this is an active task that requests a spoken warning when the pause
        // button is tapped, then do so.
        if let commands = self.activeStep?.commands,
            commands.contains(.speakWarningOnPause) {
            let instruction = Localization.localizedString("STEP_PAUSED")
            RSDSpeechSynthesizer.shared.speak(text: instruction, completion: nil)
        }
    }
    
    /// Resume the timer.
    open func resume() {
        clock?.resume()
        _startTimer()
    }
    
    /// Method fired when the timer fires. This method will be called when the timer fires.
    /// Should you need to run in the background, you will need to use playing music or GPS
    /// updates to keep the app from going to sleep.
    ///
    /// The method will first check to see if the step should be transitioned automatically,
    /// based on the `uptime` and the step duration.
    ///
    /// If the step is completed (countdown == 0), it will transition to the next step.
    ///
    /// If the timer fires and the step is still running, it will check to see if there is
    /// a vocal instruction to speak since the last firing of the timer.
    open func timerFired() {
        guard completedUptime == nil, let duration = self.clock?.runningDuration() else { return }
        
        if let stepDuration = self.activeStep?.duration, stepDuration > 0,
            let commands = self.activeStep?.commands, commands.contains(.continueOnFinish),
            duration > stepDuration {
            
            // Look to see if this step should end and if so, go forward
            stepCompleted()
        }
        else {
            
            // Update the countdown
            if let stepDuration = self.activeStep?.duration {
                countdown = Int(ceil(stepDuration)) - Int(floor(duration))
            }
            
            // Otherwise, look for any spoken instructions since last fire
            speakInstruction(at: duration)
        }
    }
    
    private func stepCompleted() {
        guard completedUptime == nil else { return }
        completedUptime = RSDClock.uptime()
        goForward()
    }
    
    // MARK: Phone interruption
    
    private var _audioInterruptObserver: Any?
    
    func _setupInterruptionObserver() {
        
        // If the task should cancel if interrupted by a phone call, then set up a listener.
        _audioInterruptObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            guard let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: rawValue)
                else {
                    return
            }
            switch type {
            case .began:
                if self?.activeStep?.shouldEndOnInterrupt ?? false {
                    self?.taskController?.handleTaskFailure(with: RSDSampleRecorder.RecorderError.interrupted)
                }
                else {
                    // pause when the interruption starts
                    self?.pause()
                }
                
            case .ended:
                // When the interuption ends, look to see if the task should attempt to resume.
                if let rawValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt,
                    AVAudioSession.InterruptionOptions(rawValue: rawValue).contains(.shouldResume) {
                    self?.resume()
                }
                else {
                    self?.taskController?.handleTaskFailure(with: RSDSampleRecorder.RecorderError.interrupted)
                }
                
            @unknown default:
                break // ignored
            }
        })
    }
    
    func _stopInterruptionObserver() {
        if let observer = _audioInterruptObserver {
            NotificationCenter.default.removeObserver(observer)
            _audioInterruptObserver = nil
        }
    }
    
    
    // MARK: Alert user to open the app
        
    private var _startedAlarm: Bool = false
    
    private func startBackgroundAlert() {
        guard !_startedAlarm, UIApplication.shared.applicationState != .active else { return }
        _startedAlarm = true
        // Play the alarm after a delay.
        let delay = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay, execute: { [weak self] in
            self?._playAlarm()
        })
    }

    private func _playAlarm() {
        guard UIApplication.shared.applicationState != .active else { return }

        // play sound and vibrate to let the user know that the step is over.
        playAlert()

        // Fire again after a delay.
        let delay = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delay, execute: { [weak self] in
            self?._playAlarm()
        })
    }
    
    /// If the app is running in the background, and running in the background is not allowed for this step,
    /// then the app will start calling `playAlert()` using dispatch_async with a delay. By default, that
    /// method will play an alarm sound and vibrate the device to alert the user to bring the app to the
    /// foreground in order to continue the task. Once the app is active, then it will start the step.
    open func playAlert() {
        vibrateDevice()
        playSound(.alarm)
    }
}

extension RSDStepViewController : ThemeImageViewOwner {
    
    /// For this case, the image theme identifier should not change while the step view is loaded
    /// and if it does then the *new* image theme is the newly set value.
    func themeImageIdentifier(withKey key: String) -> String? {
        return self.imageTheme?.imageIdentifier
    }
}

/// `RSDCancelActionController` is a shared protocol that can be used to present a consistent
/// response to a cancel action (button tap) where the implementation of the step view controller
/// is not shared.
public protocol RSDCancelActionController : RSDStepController, RSDAlertPresenter {
    
    /// Should the step view controller confirm the cancel action? By default, this will return `false` if
    /// this is the first step in the task. Otherwise, this method will return `true`.
    /// - returns: Whether or not to confirm the cancel action.
    func shouldConfirmCancel() -> Bool
    
    /// Finish canceling the task. This is called once the cancel is confirmed by the user.
    ///
    /// - parameter shouldSave: Should the task progress be saved?
    func cancelTask(shouldSave: Bool)

	/// This is called when the user decides to keep going with the task instead of canceling it
	func didNotCancel()
}

extension RSDCancelActionController {
    
    /// This method is called when the user taps the cancel button. It confirms that the task should
    /// be canceled (unless this is the first step in the task). If the user confirms exit, then
    /// `cancelTask` is called.
    public func confirmCancel() {
        guard shouldConfirmCancel() else {
            cancelTask(shouldSave: false)
            return
        }
        
        var actions: [UIAlertAction] = []
        
        // Always add a choice to discard the results.
        let discardResults = UIAlertAction(title: Localization.localizedString("BUTTON_OPTION_DISCARD"), style: .destructive) { (_) in
            self.cancelTask(shouldSave: false)
        }
        actions.append(discardResults)
        
        // Only add the option to save if the task controller supports it.
        if self.stepViewModel.rootPathComponent.canSaveTaskProgress() {
            let saveResults = UIAlertAction(title: Localization.localizedString("BUTTON_OPTION_SAVE"), style: .default) { (_) in
                self.cancelTask(shouldSave: true)
            }
            actions.append(saveResults)
        }
        
        // Always add a choice to keep going.
        let keepGoing = UIAlertAction(title: Localization.localizedString("BUTTON_OPTION_CONTINUE"), style: .cancel) { (_) in
            self.didNotCancel()
        }
        actions.append(keepGoing)
        
        self.presentAlertWithActions(title: nil, message: Localization.localizedString("MESSAGE_CONFIRM_CANCEL_TASK"), preferredStyle: .actionSheet, actions: actions)
    }
}
