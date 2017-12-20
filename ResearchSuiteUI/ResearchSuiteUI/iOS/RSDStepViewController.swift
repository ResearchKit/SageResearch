//
//  RSDStepViewController.swift
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

import Foundation
import AudioToolbox

public protocol RSDStepViewControllerDelegate : class, RSDUIActionHandler {
    
    func stepViewController(_ stepViewController: (UIViewController & RSDStepController), willAppear animated: Bool)
    func stepViewController(_ stepViewController: (UIViewController & RSDStepController), didAppear animated: Bool)
    func stepViewController(_ stepViewController: (UIViewController & RSDStepController), willDisappear animated: Bool)
    func stepViewController(_ stepViewController: (UIViewController & RSDStepController), didDisappear animated: Bool)
}

/**
 Protocol to allow setting the step view controller delegate on a view controller that may not inherit directly from
 UIViewController.
 
 Note: Any implementation should call the delegate methods during view appearance transitions.
 */
public protocol RSDStepViewControllerProtocol : RSDStepController {
    weak var delegate: RSDStepViewControllerDelegate? { get set }
}

open class RSDStepViewController : UIViewController, RSDStepViewControllerProtocol {

    open weak var taskController: RSDTaskController!
    
    open weak var delegate: RSDStepViewControllerDelegate?
    
    open var step: RSDStep!
    
    public var uiStep: RSDUIStep? {
        return step as? RSDUIStep
    }
    
    public var themedStep: RSDThemedUIStep? {
        return step as? RSDThemedUIStep
    }
    
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
    open var originalResult: RSDResult? {
        return taskController.taskPath.previousResults?.rsd_last(where: { $0.identifier == self.step.identifier })
    }
    
    lazy open var currentResult: RSDResult = {
        if let lastResult = taskController.taskPath.result.stepHistory.last, lastResult.identifier == self.step.identifier {
            return lastResult
        } else {
            let result = self.step.instantiateStepResult()
            taskController.taskPath.appendStepHistory(with: result)
            return result
        }
    }()
    
    public init(step: RSDStep) {
        super.init(nibName: nil, bundle: nil)
        self.step = step
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: View appearance handling
    
    // We use a flag to track whether viewWillDisappear has been called because we run a check on
    // viewDidAppear to see if we have any textFields in the tableView. This check is done after a delay,
    // so we need to track if viewWillDisappear was called during the delay
    public private(set) var isVisible = false
    public private(set) var isFirstAppearance: Bool = true
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.stepViewController(self, willAppear: animated)
        if isFirstAppearance {
            setupNavigation()
            setupBackgroundColorTheme()
        }
    }
    
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
    
    open override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
        super.viewWillDisappear(animated)
        delegate?.stepViewController(self, willDisappear: animated)
        
        if let commands = self.activeStep?.commands, commands.contains(.shouldDisableIdleTimer) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.stepViewController(self, didDisappear: animated)
    }
    
    
    // MARK: Navigation and Layout
    
    /// A UIView that is behind the status bar. This can be used to set the background for only the top
    /// part of a step view.
    @IBOutlet open var statusBarBackgroundView: UIView?
    
    /// A header view that includes navigation elements.
    @IBOutlet open var navigationHeader: RSDNavigationHeaderView?
    
    /// A footer view that includes navigation elements.
    @IBOutlet open var navigationFooter: RSDNavigationFooterView?
    
    open var continueButton: UIButton? {
        return navigationFooter?.nextButton
    }
    
    open var isForwardEnabled: Bool {
        return taskController.isForwardEnabled
    }
    
    open func didFinishLoading() {
        // Enable the continue button if all done
        continueButton?.isEnabled = isForwardEnabled
    }

    open func setupNavigation() {
        if let header = self.navigationHeader {
            setupHeader(header)
        }
        if let footer = self.navigationFooter {
            setupNavigationView(footer, isFooter: true)
        }
    }
    
    open func setupBackgroundColorTheme() {
        guard let colorTheme = themedStep?.colorTheme,
            let backgroundColor = colorTheme.backgroundColor(compatibleWith: self.traitCollection)
            else {
                return
        }
        
        self.statusBarBackgroundView?.backgroundColor = backgroundColor
        if self.hasTopBackgroundImage() {
            (self.navigationHeader as? RSDStepHeaderView)?.imageView?.superview?.backgroundColor = backgroundColor
        }
        else {
            self.navigationHeader?.backgroundColor = backgroundColor
            self.view.backgroundColor = backgroundColor
            self.navigationFooter?.backgroundColor = backgroundColor
        }
    }
    
    open func setupHeader(_ header: RSDNavigationHeaderView) {
        setupNavigationView(header, isFooter: false)

        // setup progress
        if let (stepIndex, stepCount, _) = self.progress() {
            header.progressView?.totalSteps = stepCount
            header.progressView?.currentStep = stepIndex
            if let colorTheme = themedStep?.colorTheme {
                header.progressView?.usesLightStyle = colorTheme.usesLightStyle
                header.stepCountLabel?.textColor = colorTheme.usesLightStyle ? UIColor.rsd_stepCountLabelLight : UIColor.rsd_stepCountLabelDark
            }
            header.stepCountLabel?.attributedText = header.progressView?.attributedStringForLabel()
        } else {
            header.shouldShowProgress = false
        }
        
        if let stepHeader = header as? RSDStepHeaderView {
            
            if let imageTheme = self.themedStep?.imageTheme, let imageView = stepHeader.imageView {
                let placement = imageTheme.placementType ?? .iconBefore
                if placement == .topBackground || placement == .iconBefore {
                    stepHeader.hasImage = true
                    if let animatedImage = imageTheme as? RSDAnimatedImageThemeElement {
                        let images = animatedImage.images(compatibleWith: self.traitCollection)
                        if images.count > 1 {
                            stepHeader.imageView?.animationDuration = animatedImage.animationDuration
                            stepHeader.imageView?.animationImages = images
                            stepHeader.imageView?.startAnimating()
                        }
                        else if let image = images.first {
                            stepHeader.imageView?.image = image
                        }
                    } else if let fetchLoader = imageTheme as? RSDFetchableImageThemeElement {
                        fetchLoader.fetchImage(for: imageView.bounds.size, callback: { [weak stepHeader] (img) in
                            stepHeader?.image = img
                        })
                    }
                }
            }
            
            // setup label text
            stepHeader.titleLabel?.text = uiStep?.title
            stepHeader.textLabel?.text = uiStep?.text
            stepHeader.detailLabel?.text = uiStep?.detail
            
            if let colorTheme = themedStep?.colorTheme,
                let foregroundColor = colorTheme.foregroundColor(compatibleWith: self.traitCollection) {
                stepHeader.titleLabel?.textColor = foregroundColor
                stepHeader.textLabel?.textColor = foregroundColor
                stepHeader.detailLabel?.textColor = foregroundColor
            }
        }

        header.setNeedsLayout()
        header.setNeedsUpdateConstraints()
    }
    
    open func hasTopBackgroundImage() -> Bool {
        if let imageTheme = self.themedStep?.imageTheme, let placement = imageTheme.placementType {
            return placement == .topBackground
        } else {
            return false
        }
    }
    
    open func setupFooter(_ footer: RSDNavigationFooterView) {
        setupNavigationView(footer, isFooter: true)
    }
    
    @available(*, deprecated)
    open func shouldUseGlobalButtonVisibility() -> Bool {
        return false
    }
    
    open func setupNavigationView(_ navigationView: RSDStepNavigationView, isFooter: Bool) {
        
        // Check if the back button and skip button should be hidden for this task
        // and if so, then do so at this level. Otherwise, the button doesn't layout properly.
        let backHiddened = self.shouldHideAction(for: .navigation(.goBackward))
        navigationView.isBackHidden = backHiddened
        let skipHidden = self.shouldHideAction(for: .navigation(.skip))
        navigationView.isSkipHidden = skipHidden
        
        setupButton(navigationView.cancelButton, for: .navigation(.cancel), isFooter: isFooter)
        setupButton(navigationView.learnMoreButton, for: .navigation(.learnMore), isFooter: isFooter)
        setupButton(navigationView.nextButton, for: .navigation(.goForward), isFooter: isFooter)
        setupButton(navigationView.backButton, for: .navigation(.goBackward), isFooter: isFooter)
        setupButton(navigationView.skipButton, for: .navigation(.skip), isFooter: isFooter)
        
        if let usesLightStyle = usesLightStyle(isFooter: isFooter) {
            navigationView.tintColor = usesLightStyle ? UIColor.rsd_underlinedButtonTextLight : UIColor.rsd_underlinedButtonTextDark
        }
        
        navigationView.setNeedsLayout()
        navigationView.setNeedsUpdateConstraints()
    }
    
    open func usesLightStyle(isFooter: Bool) -> Bool? {
        guard let colorTheme = themedStep?.colorTheme else { return nil }
        let hasTopBackgroundImage = self.hasTopBackgroundImage()
        return colorTheme.usesLightStyle && (!isFooter || !hasTopBackgroundImage)
    }

    open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType, isFooter: Bool) {
        guard let btn = button else { return }
        
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
                return RSDUIActionObject(buttonTitle: Localization.buttonCancel())
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
        
        if let roundedButton = btn as? RSDRoundedButton, let colorTheme = themedStep?.colorTheme, (usesLightStyle(isFooter: isFooter) ?? false) {
            roundedButton.backgroundColor = UIColor.rsd_roundedButtonBackgroundLight
            roundedButton.shadowColor = UIColor.rsd_roundedButtonShadowLight
            roundedButton.titleColor = colorTheme.backgroundColor(compatibleWith: self.traitCollection) ?? UIColor.rsd_roundedButtonTextLight
        }

        // If this is a goForward button, then there is some additional logic around
        // loading state and whether or not any input fields are optional
        if actionType == .navigation(.goForward) {
            btn.isEnabled = isForwardEnabled
        }
    }
    
    open func color(named name: String?) -> UIColor? {
        guard #available(iOS 11.0, *), let colorName = name else { return nil }
        return UIColor(named: colorName, in: nil, compatibleWith: self.traitCollection)
    }
    
    @objc private func _forwardTapped() {
        self.goForward()
    }
    
    @objc private func _backTapped() {
        self.goBack()
    }
    
    @objc private func _skipTapped() {
        self.skipForward()
    }
    
    @objc private func _cancelTapped() {
        self.cancel()
    }
    
    @objc private func _learnMoreTapped() {
        self.showLearnMore()
    }
    
    @IBAction open func goForward() {
        performStopCommands()
        _speakEndCommand {
            self.taskController.goForward()
        }
    }
    
    @IBAction open func goBack() {
        stop()
        self.taskController.goBack()
    }
    
    @IBAction open func skipForward() {
        stop()
        self.taskController.goForward()
    }
    
    @IBAction open func cancel() {
        stop()
        self.taskController.handleTaskCancelled()
    }
    
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
    
    
    // MARK: Active step handling
    
    open var countdown: Int = 0
    
    /**
     Should this step start the timer? By default, this will return true for active steps. However, if you are running your app in the background, then you will need to set up a secondary means of keeping the app from suspending when the user locks the screen. You can do so by playing music or by using background GPS location updates.
     
     Note: The speech synthesizer does not work when the app is in background mode, but sounds and vibrations will still fire if the AVAudioSession is set up to do so.
     */
    open var usesTimer: Bool {
        return self.activeStep != nil
    }
    
    /**
     Time interval for firing a repeating timer.
     */
    open var timerInterval: TimeInterval {
        return 1
    }
    
    public private(set) var pauseUptime: TimeInterval?
    public private(set) var startUptime: TimeInterval?
    public private(set) var completedUptime: TimeInterval?
    
    private var timer: Timer?
    private var lastInstruction: Int = -1
    
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
    
    open func playSound(_ sound: RSDSound = .short_low_high) {
        RSDAudioSoundPlayer.shared.playSound(sound)
    }
    
    open func vibrateDevice() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    open func speakInstruction(_ instruction: String, at timeInterval: TimeInterval, completion: RSDVoiceBoxCompletionHandler?) {
        RSDSpeechSynthesizer.shared.speak(text: instruction, completion: completion)
    }
    
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
    
    open func stop() {
        _stopTimer()
    }

    private func _stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    open func pause() {
        if pauseUptime == nil {
            pauseUptime = ProcessInfo.processInfo.systemUptime
        }
        _stopTimer()
    }
    
    open func resume() {
        if let pauseTime = pauseUptime, let startTime = startUptime {
            startUptime = ProcessInfo.processInfo.systemUptime - pauseTime + startTime
        }
        pauseUptime = nil
        _startTimer()
    }
    
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
    
    open func playCompletedAlert() {
        vibrateDevice()
        playSound(.alarm)
    }
}
