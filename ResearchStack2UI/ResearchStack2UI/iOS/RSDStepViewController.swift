//
//  RSDStepViewController.swift
//  ResearchStack2UI
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

import Foundation
import AudioToolbox

/// `RSDOptionalStepViewControllerDelegate` is a delegate protocol defined as `@objc` to allow the
/// methods to be optionally implemented. As such, these methods cannot take Swift protocols as their
/// paramenters.
@objc
public protocol RSDOptionalStepViewControllerDelegate : class, NSObjectProtocol {
    
    /// Called when the view is about to made visible.
    func stepViewController(_ stepViewController: UIViewController, willAppear animated: Bool)
    
    /// Called when the view has been fully transitioned onto the screen.
    func stepViewController(_ stepViewController: UIViewController, didAppear animated: Bool)
    
    ///  Called when the view is dismissed, covered, or otherwise hidden.
    func stepViewController(_ stepViewController: UIViewController, willDisappear animated: Bool)
    
    /// Called after the view was dismissed, covered, or otherwise hidden.
    func stepViewController(_ stepViewController: UIViewController, didDisappear animated: Bool)
}

/// `RSDStepViewControllerDelegate` is an extension of the `RSDUIActionHandler` protocol that also
/// implements optional methods defined by `RSDOptionalStepViewControllerDelegate`.
public protocol RSDStepViewControllerDelegate : RSDOptionalStepViewControllerDelegate, RSDUIActionHandler {
}

/// Protocol to allow setting the step view controller delegate on a view controller that may not
/// inherit directly from UIViewController.
/// - note: Any implementation should call the delegate methods during view appearance transitions.
public protocol RSDStepViewControllerProtocol : RSDStepController {
    
    /// The step view controller delegate.
    weak var delegate: RSDStepViewControllerDelegate? { get set }
}

/// `RSDStepViewController` is the default base class implementation for the steps presented using this
/// UI architecture.
open class RSDStepViewController : UIViewController, RSDStepViewControllerProtocol, RSDCancelActionController {

    /// Pointer back to the task controller that is displaying the step controller. The implementation
    /// of the task controller should set this pointer before displaying the step controller.
    open weak var taskController: RSDTaskController!
    
    /// The step view controller delegate.
    open weak var delegate: RSDStepViewControllerDelegate?
    
    /// The step presented by the step view controller.
    ///
    /// If you use a storyboard to initialize the step view controller, `init(step:)` isn't called,
    /// so you need to set the `step` property directly before the step view controller is presented.
    ///
    /// Setting the value of `step` after the controller has been presented is an error that
    /// generates an assertion. Modifying the value of `step` after the controller has been
    /// presented is an error that has undefined results.
    ///
    /// Subclasses that override the setter of this property must call super.
    open var step: RSDStep! {
        didSet {
            if isVisible {
                assertionFailure("Cannot set step after presenting step view controller")
            }
        }
    }
    
    /// Convenience property for casting the step to a `RSDUIStep`.
    public var uiStep: RSDUIStep? {
        return step as? RSDUIStep
    }
    
    /// Convenience property for casting the step to a `RSDThemedUIStep`.
    public var themedStep: RSDThemedUIStep? {
        return step as? RSDThemedUIStep
    }
    
    /// Convenience property for casting the step to a `RSDActiveUIStep`.
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
    /// Convenience property for accessing the original result after navigating back or from a previous task run.
    open var originalResult: RSDResult? {
        return taskController.taskPath.previousResults?.rsd_last(where: { $0.identifier == self.step.identifier })
    }
    
    /// Returns the current result associated with this step. This property uses a lazy initializer to instantiate
    /// the result and append it to the step history if not found in the step history.
    lazy open var currentResult: RSDResult = {
        if let lastResult = taskController.taskPath.result.stepHistory.last, lastResult.identifier == self.step.identifier {
            return lastResult
        } else {
            let result = self.step.instantiateStepResult()
            taskController.taskPath.appendStepHistory(with: result)
            return result
        }
    }()
    
    // MARK: Initialization
    
    /// Returns a new step view controller for the specified step.
    /// - parameter step: The step to be presented.
    public init(step: RSDStep) {
        super.init(nibName: nil, bundle: nil)
        self.step = step
    }
    
    /// Initialize the class using the given nib and bundle.
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
    
    // MARK: View appearance handling
    
    /// Track whether or not the view is visible. The value of this flag is set to `true` in
    /// `viewDidAppear` before anything else is done. It is set to `false` in `viewWillDisappear`
    /// before anything else is done.
    public private(set) var isVisible = false
    
    /// Track whether or not this is the first appearance. This flag is set to `true` in
    /// `viewDidAppear`. This flag is used to mark whether or not to call `performStartCommands()`.
    public private(set) var isFirstAppearance: Bool = true
    
    /// Sets whether or not the body of the view uses light style.
    public private(set) var usesLightStyle: Bool = false
    
    /// Override `viewWillAppear` to call through to the delegate method and if this is the first
    /// appearance to set up the navigation, step details, and background color theme.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.stepViewController(self, willAppear: animated)
        if isFirstAppearance {
            setupViews()
            setupBackgroundColorTheme()
        }
    }
    
    /// Override `viewDidAppear` to set the flag for `isVisible`, call the delegate, mark the result
    /// `startDate`, perform the start commands, and if the active commands include disabling the
    /// idle timer then do so in this method.
    open override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        super.viewDidAppear(animated)
        delegate?.stepViewController(self, didAppear: animated)
        
        // setup the result (lazy load) to mark the startDate
        let _ = currentResult
        
        // If this is the first appearance then perform the start commands
        if isFirstAppearance {
            performStartCommands()
        }
        isFirstAppearance = false
        
        if let commands = self.activeStep?.commands, commands.contains(.shouldDisableIdleTimer) {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    /// Override `viewWillDisappear` to set the `isVisible` flag, call the delegate, and enable
    /// the idle timer if it was disabled in view will appear.
    open override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
        super.viewWillDisappear(animated)
        delegate?.stepViewController(self, willDisappear: animated)
        
        if let commands = self.activeStep?.commands, commands.contains(.shouldDisableIdleTimer) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    /// Override `viewDidDisappear` to call the delegate.
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.stepViewController(self, didDisappear: animated)
    }
    
    // MARK: Navigation and Layout
    
    /// A mapping of all the buttons that were registered using `setupButton`.
    public private(set) var registeredButtons: [RSDUIActionType : Set<UIButton>] = [:]
    
    /// A UIView that is behind the status bar. This can be used to set the background for only the top
    /// part of a step view.
    @IBOutlet open var statusBarBackgroundView: UIView?
    
    /// A header view that includes navigation elements.
    @IBOutlet open var navigationHeader: RSDNavigationHeaderView?
    
    /// A footer view that includes navigation elements.
    @IBOutlet open var navigationFooter: RSDNavigationFooterView?
    
    /// A view for the main body.
    open var navigationBody: RSDStepNavigationView? {
        return self.view as? RSDStepNavigationView
    }
    
    /// The label for displaying step title text.
    open var stepTitleLabel: UILabel? {
        return self.navigationHeader?.titleLabel ?? self.navigationFooter?.titleLabel
    }
    
    /// The label for displaying step text.
    open var stepTextLabel: UILabel? {
        return self.navigationHeader?.textLabel ?? self.navigationFooter?.textLabel
    }
    
    /// The label for displaying step detail text.
    open var stepDetailLabel: UILabel? {
        return self.navigationHeader?.detailLabel ?? self.navigationFooter?.detailLabel
    }
    
    /// Convenience method for getting the "Next" button.
    open var nextButton: UIButton? {
        return registeredButtons[.navigation(.goForward)]?.first
    }
    
    /// Is forward navigation enabled? The default implementation will check the task controller.
    open var isForwardEnabled: Bool {
        return taskController.isForwardEnabled
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
        stepTextLabel?.text = uiStep?.text
        stepDetailLabel?.text = uiStep?.detail
        
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
        guard let colorTheme = themedStep?.colorTheme else { return }
        
        let backgroundColor = colorTheme.backgroundColor(compatibleWith: self.traitCollection)
        
        let placements: [RSDColorPlacement] = [.header, .body, .footer]
        for placement in placements {
            guard let colorStyle = self.colorStyle(for: placement, hasCustomBackgroundColor: backgroundColor != nil),
                (colorStyle != .customBackground || (backgroundColor != nil))
                else {
                    continue
            }
            
            // Get the color and foreground element style
            switch colorStyle {
            case .customBackground:
                setColorStyle(for: placement, usesLightStyle: colorTheme.usesLightStyle, backgroundColor: backgroundColor!)
            case .darkBackground:
                setColorStyle(for: placement, usesLightStyle: true, backgroundColor: UIColor.appBackgroundDark)
            case .lightBackground:
                setColorStyle(for: placement, usesLightStyle: false, backgroundColor: UIColor.appBackgroundLight)
            }
        }
    }
    
    /// Set the color style for the given placement elements. This allows overriding by subclasses to
    /// customize the view style.
    open func setColorStyle(for placement: RSDColorPlacement, usesLightStyle: Bool, backgroundColor: UIColor) {
        switch placement {
        case .header:
            self.navigationHeader?.backgroundColor = backgroundColor
            self.navigationHeader?.usesLightStyle = usesLightStyle
            self.statusBarBackgroundView?.backgroundColor = backgroundColor
            if let statusView = self.statusBarBackgroundView as? RSDStatusBarBackgroundView {
                statusView.overlayColor = usesLightStyle ? UIColor.rsd_statusBarOverlayLightStyle : UIColor.rsd_statusBarOverlay
            }
            
        case .body:
            self.view.backgroundColor = backgroundColor
            self.usesLightStyle = usesLightStyle
            
        case .footer:
            self.navigationFooter?.backgroundColor = backgroundColor
            self.navigationFooter?.usesLightStyle = usesLightStyle
        }
    }
    
    /// Set up the header. Because this may be used in a table view as the table's header view, this includes
    /// all the step details that are typically at the top of the view such as setting images, text, and progress.
    /// Additionally, this method will set up the navigation buttons included in the header view and any color
    /// themes that are appropriate.
    /// - parameter header: The header view.
    open func setupHeader(_ header: RSDNavigationHeaderView) {
        setupNavigationView(header, placement: .header)

        // setup progress
        if let (stepIndex, stepCount, _) = self.progress() {
            header.progressView?.totalSteps = stepCount
            header.progressView?.currentStep = stepIndex
            header.stepCountLabel?.attributedText = header.progressView?.attributedStringForLabel()
        } else {
            header.shouldShowProgress = false
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
        let backHiddened = self.shouldHideAction(for: .navigation(.goBackward))
        navigationView.isBackHidden = backHiddened
        let skipHidden = self.shouldHideAction(for: .navigation(.skip))
        navigationView.isSkipHidden = skipHidden
        
        let isFooter = (placement == .footer)
        setupButton(navigationView.cancelButton, for: .navigation(.cancel), isFooter: isFooter)
        setupButton(navigationView.learnMoreButton, for: .navigation(.learnMore), isFooter: isFooter)
        setupButton(navigationView.nextButton, for: .navigation(.goForward), isFooter: isFooter)
        setupButton(navigationView.backButton, for: .navigation(.goBackward), isFooter: isFooter)
        setupButton(navigationView.skipButton, for: .navigation(.skip), isFooter: isFooter)
        
        
        if let imageTheme = self.themedStep?.imageTheme, let imageView = navigationView.imageView {
            let imagePlacement = imageTheme.placementType ?? .iconBefore
            let shouldSetImage = shouldSetNavigationImage(for: placement, with: imagePlacement)
            if shouldSetImage {
                navigationView.hasImage = true
                if let animatedImage = imageTheme as? RSDAnimatedImageThemeElement {
                    let images = animatedImage.images(compatibleWith: self.traitCollection)
                    if images.count > 1 {
                        navigationView.imageView?.animationDuration = animatedImage.animationDuration
                        navigationView.imageView?.animationImages = images
                        navigationView.imageView?.startAnimating()
                    }
                    else if let image = images.first {
                        navigationView.imageView?.image = image
                    }
                } else if let fetchLoader = imageTheme as? RSDFetchableImageThemeElement {
                    fetchLoader.fetchImage(for: imageView.bounds.size, callback: { [weak navigationView] (_, img) in
                        navigationView?.image = img
                    })
                }
            }
        }
        
        navigationView.setNeedsLayout()
        navigationView.setNeedsUpdateConstraints()
    }
    
    /// By default, this method will return `true` if the image theme uses a placement
    /// of `topBackground` or `topMarginBackground`.
    open func hasTopBackgroundImage() -> Bool {
        if let imageTheme = self.themedStep?.imageTheme, let placement = imageTheme.placementType {
            return placement == .topBackground || placement == .topMarginBackground
        } else {
            return false
        }
    }
    
    /// What is the color style for the given placement?
    /// - parameter placement: The view placement of the element.
    /// - returns: The color style (if any) defined for that element.
    open func colorStyle(for placement: RSDColorPlacement, hasCustomBackgroundColor: Bool) -> RSDColorStyle? {
        guard let colorTheme = themedStep?.colorTheme else { return nil }

        if let colorStyle = colorTheme.colorStyle(for: placement), (colorStyle != .customBackground || hasCustomBackgroundColor) {
            // Exit early if there is a specific color style defined.
            return colorStyle
        }
        else if placement != .header && hasTopBackgroundImage() {
            // If this is a footer and the view has a top background image, then the footer should be the
            // light color background.
            return .lightBackground
        }
        else if hasCustomBackgroundColor {
            return .customBackground
        }
        return colorTheme.usesLightStyle ? .darkBackground : .lightBackground
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
            default:
                break
            }
        }
        
        // Set up whether or not the button is visible and it's text/image
        btn.isHidden = self.shouldHideAction(for: actionType)
        let btnAction: RSDUIAction? = self.action(for: actionType) ?? {
            // Otherwise, look at the action and show the default based on the type
            switch actionType {
            case .navigation(.cancel):
                return RSDUIActionObject(iconName: "closeActivity", bundle: Bundle(for: RSDStepViewController.self))
            case .navigation(.goForward):
                if self.step is RSDTaskInfoStep {
                    return RSDUIActionObject(buttonTitle: Localization.buttonGetStarted())
                } else if self.taskController.hasStepAfter {
                    return RSDUIActionObject(buttonTitle: Localization.buttonNext())
                } else {
                    return RSDUIActionObject(buttonTitle: Localization.buttonDone())
                }                
            case .navigation(.goBackward):
                return self.taskController.hasStepBefore ? RSDUIActionObject(buttonTitle: Localization.buttonBack()) : nil
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
            btn.setImage(action.buttonIcon, for: .normal)
        }

        // If this is a goForward button, then there is some additional logic around
        // loading state and whether or not any input fields are optional
        if actionType == .navigation(.goForward) {
            btn.isEnabled = isForwardEnabled
        }
    }
    
    /// Returns `true` if the given RSDColorPlacement and RSDImagePlacementType indicate that
    /// this view controller should set an image, `false` otherwise.
    /// Arguments:
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
        self.showLearnMore()
    }
    
    /// Momentarily disable the button.  This keeps a double-tap of a navigation button from
    /// triggering more than once. This is required b/c of how the UI handles the call to
    /// go forward/backward by calling a method that just looks at the current step.
    private func momentarilyDisableButton(_ button: UIButton) {
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
        performStopCommands()
        _speakEndCommand {
            self.taskController.goForward()
        }
    }
    
    /// Navigates backward to the previous step. By default, it calls stop() to stop the timer
    /// and then calls `goBack` on the task controller.
    ///
    /// When a user taps the Back button, the information passes through this method. You can use
    /// this method as an override point or a target action for a subclass.
    @IBAction open func goBack() {
        stop()
        self.taskController.goBack()
    }
    
    /// This method is called when the user taps the skip button. By default, it calls stop() to
    /// stop the timer and then calls `goForward` on the task controller.
    @IBAction open func skipForward() {
        stop()
        self.taskController.goForward()
    }
    
    /// This method is called when the user taps the cancel button. By default, it confirms that the task
    /// should be canceled (unless this is the first step in the task). If the user confirms exit, then
    /// `cancelTask` is called.
    @IBAction open func cancel() {
        self.confirmCancel()
    }
    
    /// Should the step view controller confirm the cancel action? By default, this will return `false` if
    /// this is the first step in the task. Otherwise, this method will return `true`.
    /// - returns: Whether or not to confirm the cancel action.
    open func shouldConfirmCancel() -> Bool {
        return !self.taskController.taskPath.isFirstStep
    }
    
    /// Finish canceling the task. This is called once the cancel is confirmed by the user.
    ///
    /// - parameter shouldSave: Should the task progress be saved?
    open func cancelTask(shouldSave: Bool) {
        stop()
        self.taskController.handleTaskCancelled(shouldSave: shouldSave)
    }
    
    /// This method is called when the user taps the "learn more" button. The default implementation
    /// will check if the learn more action is an `RSDResourceTransformer` and if so, will assume that
    /// the learn more is an embedded HTML file or an online URL. It will instantiate `RSDWebViewController`
    /// and present it modally.
    @IBAction open func showLearnMore() {
        guard let action = self.action(for: .navigation(.learnMore)) as? RSDResourceTransformer
            else {
                self.presentAlertWithOk(title: nil, message: "Missing learn more action for this task", actionHandler: nil)
                return
        }
        
        let (webVC, navVC) = RSDWebViewController.instantiateController()
        webVC.resourceTransformer = action
        self.present(navVC, animated: true, completion: nil)
    }
    
    /// Get the action for the given action type. The default implementation check the step, the delegate
    /// and the task as follows:
    /// - Query the step for an action.
    /// - If that returns nil, it will then check the delegate.
    /// - If that returns nil, it will look up the task path chain for an action.
    /// - Finally, if not found it will return nil.
    ///
    /// - parameter actionType: The action type to get.
    /// - returns: The action if found.
    open func action(for actionType: RSDUIActionType) -> RSDUIAction? {
        guard step.identifier == self.step.identifier else { return nil }
        
        if let action = (self.step as? RSDUIActionHandler)?.action(for: actionType, on: step) {
            // Allow the step to override the default from the delegate
            return action
        }
        else if let action = self.delegate?.action(for: actionType, on: step) {
            // If no override by the step then return the action from the delegate
           return action
        }
        else if let action = recursiveTaskAction(for: actionType) {
            // Finally check the task for a global action
            return action
        }
        else {
            return nil
        }
    }
    
    private func recursiveTaskAction(for actionType: RSDUIActionType) -> RSDUIAction? {
        var taskPath = self.taskController.taskPath
        repeat {
            if let action = taskPath?.task?.action(for: actionType, on: step) {
                return action
            }
            taskPath = taskPath?.parentPath
        } while (taskPath != nil)
        return nil
    }
    
    /// Calls through to `!shouldHideAction(for: .navigation(.goBackward))`
    public var hasStepBefore: Bool {
        return !shouldHideAction(for: .navigation(.goBackward))
    }
    
    /// Calls through to `!shouldHideAction(for: .navigation(.goForward))`
    public var hasStepAfter: Bool {
        return !shouldHideAction(for: .navigation(.goForward))
    }
    
    /// Should the action be hidden for the given action type?
    ///
    /// - The default implementation will first look to see if the step overrides and forces the
    /// action to be hidden.
    /// - If not, then the delegate will be queried next.
    /// - If that does not return a value, then the task path will be checked.
    ///
    /// Finally, whether or not to hide the action will be determined based on the action type and
    /// the state of the task as follows:
    /// 1. `.navigation(.cancel)` - Always defaults to `false` (not hidden).
    /// 2. `.navigation(.goForward)` - Hidden if the step is an active step that transitions automatically.
    /// 3. `.navigation(.goBack)` - Hidden if the step is an active step that transitions automatically,
    ///                             or if the task does not allow backward navigation.
    /// 4. Others - Hidden if the `action()` is nil.
    ///
    /// - parameter actionType: The action type to get.
    /// - returns: `true` if the action should be hidden.
    open func shouldHideAction(for actionType: RSDUIActionType) -> Bool {
        if let shouldHide = uiStep?.shouldHideAction(for: actionType, on: step) {
            // Allow the step to override the default from the delegate
            return shouldHide
        }
        else if let shouldHide = self.delegate?.shouldHideAction(for: actionType, on: step) {
            // If no override by the step then return the action from the delegate if there is one
            return shouldHide
        }
        else if let shouldHide = recursiveTaskShouldHideAction(for: actionType), self.action(for: actionType) == nil {
            // Finally check if the task has any global settings
            return shouldHide
        }
        else {
            // Otherwise, look at the action and show the button based on the type
            let transitionAutomatically = activeStep?.commands.contains(.transitionAutomatically) ?? false
            switch actionType {
            case .navigation(.cancel):
                return false
            case .navigation(.goForward):
                return transitionAutomatically
            case .navigation(.goBackward):
                return !self.taskController.hasStepBefore || transitionAutomatically
            default:
                return self.action(for: actionType) == nil
            }
        }
    }
    
    private func recursiveTaskShouldHideAction(for actionType: RSDUIActionType) -> Bool? {
        var taskPath = self.taskController.taskPath
        repeat {
            if let shouldHide = taskPath?.task?.shouldHideAction(for: actionType, on: step) {
                return shouldHide
            }
            taskPath = taskPath?.parentPath
        } while (taskPath != nil)
        return nil
    }
    
    // MARK: Permission handling
    
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
        switch permissionType {
        case .camera, .microphone:
            return RSDAudioVisualAuthorization.authorizationStatus(for: permissionType)
        case .photoLibrary:
            return RSDPhotoLibraryAuthorization.authorizationStatus()
        case .location, .locationWhenInUse:
            return RSDLocationAuthorization.authorizationStatus(for: permissionType)
        case .motion:
            return RSDMotionAuthorization.authorizationStatus()
        }
    }
    
    /// The permissions required for this step.
    open func requiredPermissions() -> [RSDStandardPermission]? {
        return (self.step as? RSDStandardPermissionsStep)?.standardPermissions
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
    
    /// The system uptime for when the step was started. This is used by the timer to determine when to
    /// speak the next instruction and to set the value of the countdown.
    public private(set) var startUptime: TimeInterval?
    
    /// The system uptime for when the step was paused.
    public private(set) var pauseUptime: TimeInterval?
    
    /// The system uptime for when the step was finished.
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
    
    private func _speakEndCommand(_ completion: @escaping (() -> Void)) {
        if let instruction = self.activeStep?.spokenInstruction(at: Double.infinity) {
            speakInstruction(instruction, at: Double.infinity, completion: { (_, _) in
                completion()
            })
        } else {
            completion()
        }
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
        if self.activeStep?.requiresBackgroundAudio ?? false {
            (self.taskController as? RSDTaskViewController)?.startBackgroundAudioSessionIfNeeded()
        }
        RSDSpeechSynthesizer.shared.speak(text: instruction, completion: completion)
    }
    
    /// Speak the instruction that is included at the given time marker (if any).
    open func speakInstruction(at duration: TimeInterval) {
        let nextInstruction = Int(duration)
        if nextInstruction > lastInstruction {
            for ii in (lastInstruction + 1)...nextInstruction {
                let timeInterval = TimeInterval(ii)
                if let instruction = self.activeStep?.spokenInstruction(at: timeInterval) {
                    speakInstruction(instruction, at: timeInterval, completion: nil)
                }
            }
            lastInstruction = nextInstruction
        }
    }
    
    /// Start the timer.
    open func start() {
        _startTimer()
    }
    
    private func _startTimer() {
        if startUptime == nil {
            startUptime = ProcessInfo.processInfo.systemUptime
        }
        pauseUptime = nil
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
    }

    private func _stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Pause the timer.
    open func pause() {
        if pauseUptime == nil {
            pauseUptime = ProcessInfo.processInfo.systemUptime
        }
        _stopTimer()
    }
    
    /// Resume the timer.
    open func resume() {
        if let pauseTime = pauseUptime, let startTime = startUptime {
            startUptime = ProcessInfo.processInfo.systemUptime - pauseTime + startTime
        }
        pauseUptime = nil
        _startTimer()
    }
    
    /// Method fired when the timer fires. This method will be called when the timer fires.
    /// Should you need to run in the background, you will need to use playing music or GPS
    /// updates to keep the app from going to sleep in which case the timer will not fire
    /// automatically. Instead, you will need to call this method directly.
    ///
    /// The method will first check to see if the step should be transitioned automatically,
    /// based on the `uptime` and the step duration.
    ///
    /// If the step is completed (countdown == 0), then this method will check if the app
    /// is running in the background. If not, it will transition to the next step.
    ///
    /// If the app **is** running in the background then the app will start calling
    /// `playCompletedAlert()` using dispatch_async with a delay. By default, that method
    /// will play an alarm sound and vibrate the device to alert the user to bring the
    /// app to the foreground. Once the app is active, then it will transition to the next
    /// step.
    ///
    /// If the timer fires and the step is still running, it will check to see if there is
    /// a vocal instruction to speak since the last firing of the timer.
    open func timerFired() {
        guard let uptime = startUptime, completedUptime == nil else { return }
        let duration = ProcessInfo.processInfo.systemUptime - uptime
        
        if let stepDuration = self.activeStep?.duration, stepDuration > 0,
            let commands = self.activeStep?.commands, commands.contains(.continueOnFinish),
            duration > stepDuration {
            
            // Look to see if this step should end and if so, go forward
            stepCompleted()
        }
        else {
            
            // Update the countdown
            if let stepDuration = self.activeStep?.duration {
                countdown = Int(stepDuration - duration)
            }
            
            // Otherwise, look for any spoken instructions since last fire
            speakInstruction(at: duration)
        }
    }
    
    /// An alert to play if the step should transition automatically and the user has put the
    /// app into the background either by locking the screen or else because the system idle
    /// timer has fired. This is **only** called if the app is running in the background.
    /// Otherwise, the app will automatically call `goForward`.
    open func playCompletedAlert() {
        vibrateDevice()
        playSound(.alarm)
    }
    
    private var _activeObserver: Any?
    private var _hasCalledGoForward: Bool = false
    
    private func stepCompleted() {
        guard completedUptime == nil else { return }
        completedUptime = ProcessInfo.processInfo.systemUptime
        if UIApplication.shared.applicationState == .active {
            _goForwardOnActive()
        } else {
            _playAlarm()
            _activeObserver = NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
                self?._goForwardOnActive()
            })
        }
    }
    
    private func _goForwardOnActive() {
        guard !_hasCalledGoForward else { return }
        _hasCalledGoForward = true
        
        if let observer = _activeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        goForward()
    }
    
    private func _playAlarm() {
        guard !_hasCalledGoForward, UIApplication.shared.applicationState != .active else { return }
        
        // play sound and vibrate to let the user know that the step is over
        playCompletedAlert()
        
        // Fire again after a delay
        let delay = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: delay, execute: { [weak self] in
            self?._playAlarm()
        })
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
        if self.taskController.canSaveTaskProgress {
            let saveResults = UIAlertAction(title: Localization.localizedString("BUTTON_OPTION_SAVE"), style: .default) { (_) in
                self.cancelTask(shouldSave: true)
            }
            actions.append(saveResults)
        }
        
        // Always add a choice to keep going.
        let keepGoing = UIAlertAction(title: Localization.localizedString("BUTTON_OPTION_CONTINUE"), style: .cancel) { (_) in
            // Do nothing, just hide the alert
        }
        actions.append(keepGoing)
        
        self.presentAlertWithActions(title: nil, message: Localization.localizedString("MESSAGE_CONFIRM_CANCEL_TASK"), preferredStyle: .actionSheet, actions: actions)
    }
}
