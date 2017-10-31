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
    
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
    public var imageStep: RSDImageUIStep? {
        return step as? RSDImageUIStep
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
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
        super.viewWillDisappear(animated)
        delegate?.stepViewController(self, willDisappear: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.stepViewController(self, didDisappear: animated)
    }
    
    
    // MARK: Navigation and Layout
    
    @IBOutlet open var statusBackgroundView: UIView?
    @IBOutlet open var navigationHeader: RSDNavigationBarView?
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
            setupNavigationView(footer)
        }
    }
    
    open func setupHeader(_ header: RSDNavigationBarView) {
        setupNavigationView(header)

        // setup progress
        if let (stepIndex, stepCount, _) = self.progress() {
            header.progressView?.totalSteps = stepCount
            header.progressView?.currentStep = stepIndex
        } else {
            header.shouldShowProgress = false
        }
        
        if let stepHeader = header as? RSDStepHeaderView {
        
            if (imageStep?.hasImageBefore ?? false), let imageView = stepHeader.imageView {
                stepHeader.hasImage = true
                imageStep!.imageBefore(for: imageView.bounds.size, callback: { [weak stepHeader] (img) in
                    stepHeader?.image = img
                })
            } else if let animatedImage = (step as? RSDAnimatedImageUIStep)?.animatedImage {
                stepHeader.hasImage = true
                if let backgroundColor = animatedImage.backgroundColor(compatibleWith: self.traitCollection) {
                    stepHeader.imageView?.superview?.backgroundColor = backgroundColor
                    self.statusBackgroundView?.backgroundColor = backgroundColor
                }
                let images = animatedImage.images(compatibleWith: self.traitCollection)
                if images.count > 1 {
                    stepHeader.imageView?.animationDuration = animatedImage.animationDuration
                    stepHeader.imageView?.animationImages = images
                    stepHeader.imageView?.startAnimating()
                }
                else if let image = images.first {
                    stepHeader.imageView?.image = image
                }
            }
            
            // setup label text
            stepHeader.titleLabel?.text = uiStep?.title
            stepHeader.textLabel?.text = uiStep?.text
            stepHeader.detailLabel?.text = uiStep?.detail
        }

        header.setNeedsLayout()
        header.setNeedsUpdateConstraints()
    }
    
    open func setupFooter(_ footer: RSDNavigationFooterView) {
        setupNavigationView(footer)
    }
    
    open func setupNavigationView(_ navigationView: RSDStepNavigationView) {
        
        // Check if the back button and skip button should be hidden for this task
        // and if so, then do so globally.
        if let task = self.taskController.topLevelTask, !(step is RSDTaskInfoStep) {
            navigationView.isBackHidden = task.shouldHideAction(for: .navigation(.goBackward), on: step) ?? false
            navigationView.isSkipHidden = task.shouldHideAction(for: .navigation(.skip), on: step) ?? true
        }
        
        setupButton(navigationView.cancelButton, for: .navigation(.cancel))
        setupButton(navigationView.learnMoreButton, for: .navigation(.learnMore))
        setupButton(navigationView.nextButton, for: .navigation(.goForward))
        setupButton(navigationView.backButton, for: .navigation(.goBackward))
        setupButton(navigationView.skipButton, for: .navigation(.skip))
        
        navigationView.setNeedsLayout()
        navigationView.setNeedsUpdateConstraints()
    }
    
    open func setupButton(_ button: UIButton?, for actionType: RSDUIActionType) {
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
        
        // If this is a goForward button, then there is some additional logic around
        // loading state and whether or not any input fields are optional
        if actionType == .navigation(.goForward) {
            btn.isEnabled = isForwardEnabled
        }
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
        self.taskController.goForward()
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
        // Default implementation does nothing
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
        else if let shouldHide = recursiveTaskShouldHideAction(for: actionType) {
            // Finally check if the task has any global settings
            return shouldHide
        }
        else {
            // Otherwise, look at the action and show the button based on the type
            switch actionType {
            case .navigation(.cancel), .navigation(.goForward):
                return false
            case .navigation(.goBackward):
                return !self.taskController.hasStepBefore
            default:
                return self.action(for: actionType) != nil
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
    
    public private(set) var startUptime: TimeInterval?
    private var timer: Timer?
    private var lastInstruction: Int = 0
    
    open func performStartCommands() {
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
        
        if let instruction = self.activeStep?.spokenInstruction(at: 0) {
            speak(instruction: instruction, timeInterval: 0)
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
        
        if let instruction = self.activeStep?.spokenInstruction(at: Double.infinity) {
            speak(instruction: instruction, timeInterval: Double.infinity)
        }
        
        // Always run the stop command
        stop()
    }
    
    open func playSound() {
        // TODO: Implement syoung 10/17/2017
    }
    
    open func vibrateDevice() {
        // TODO: Implement syoung 10/17/2017
    }
    
    open func speak(instruction: String, timeInterval: TimeInterval) {
        // TODO: Implement syoung 10/17/2017
    }
    
    open func start() {
        if startUptime == nil {
            startUptime = ProcessInfo.processInfo.systemUptime
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            self?.timerFired()
        })
    }
    
    open func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    open func timerFired() {
        guard let uptime = startUptime else { return }
        let duration = ProcessInfo.processInfo.systemUptime - uptime
        
        if let stepDuration = self.activeStep?.duration, stepDuration > 0,
            let commands = self.activeStep?.commands, commands.contains(.continueOnFinish),
            duration > stepDuration {
            // Look to see if this step should end and if so, go forward
            goForward()
        }
        else {
            // Otherwise, look for any spoekn instructions since last fire
            let nextInstruction = Int(duration)
            if nextInstruction > lastInstruction {
                for ii in (lastInstruction + 1)...nextInstruction {
                    let timeInterval = TimeInterval(ii)
                    if let instruction = self.activeStep?.spokenInstruction(at: timeInterval) {
                        speak(instruction: instruction, timeInterval: timeInterval)
                    }
                }
                lastInstruction = nextInstruction
            }
        }
    }
}
