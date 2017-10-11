//
//  RSDStepViewController.swift
//  ResearchSuite-UI
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
public protocol RSDStepViewControllerProtocol : class {
    weak var delegate: RSDStepViewControllerDelegate? { get set }
}

open class RSDStepViewController : UIViewController, RSDStepController, RSDUIActionHandler, RSDStepViewControllerProtocol {

    

    open weak var taskController: RSDTaskController!
    
    open weak var delegate: RSDStepViewControllerDelegate?
    
    open var step: RSDStep!
    
    public var uiStep: RSDUIStep? {
        return step as? RSDUIStep
    }
    
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.stepViewController(self, willAppear: animated)
        if isFirstAppearance {
            setupNavigation()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.stepViewController(self, didAppear: animated)
        if isFirstAppearance {
            performStartCommands()
        }
        isFirstAppearance = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.stepViewController(self, willDisappear: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.stepViewController(self, didDisappear: animated)
    }
    
    
    // MARK: Navigation
    
    @IBOutlet public weak var cancelButton: UIButton?
    @IBOutlet public weak var continueButton: UIButton?
    @IBOutlet public weak var backButton: UIButton?
    @IBOutlet public weak var skipButton: UIButton?
    @IBOutlet public weak var learnMoreButton: UIButton?
    
    open func didFinishLoading() {
        // TODO: Implement syoung 10/17/2017
        // Enable buttons or automatically go forward as appropriate
    }

    open func setupNavigation() {
        self.cancelButton?.isHidden = self.shouldHideAction(for: .navigation(.cancel)) ?? false
        if let action = self.action(for: .navigation(.cancel)) {
            cancelButton?.setTitle(action.buttonTitle, for: .normal)
            cancelButton?.setImage(action.buttonIcon, for: .normal)
        }
        
        self.backButton?.isHidden = self.shouldHideAction(for: .navigation(.goBackward)) ?? false
        if let action = self.action(for: .navigation(.goBackward)) {
            backButton?.setTitle(action.buttonTitle, for: .normal)
            backButton?.setImage(action.buttonIcon, for: .normal)
        }
        
        self.continueButton?.isHidden = self.shouldHideAction(for: .navigation(.goForward)) ?? false
        if let action = self.action(for: .navigation(.goForward)) {
            continueButton?.setTitle(action.buttonTitle, for: .normal)
            continueButton?.setImage(action.buttonIcon, for: .normal)
        }
        
        self.skipButton?.isHidden = self.shouldHideAction(for: .navigation(.skip)) ?? true
        if let action = self.action(for: .navigation(.skip)) {
            skipButton?.setTitle(action.buttonTitle, for: .normal)
            skipButton?.setImage(action.buttonIcon, for: .normal)
        }
        
        self.learnMoreButton?.isHidden = self.shouldHideAction(for: .navigation(.learnMore)) ?? true
        if let action = self.action(for: .navigation(.learnMore)) {
            learnMoreButton?.setTitle(action.buttonTitle, for: .normal)
            learnMoreButton?.setImage(action.buttonIcon, for: .normal)
        }
    }
    
    @IBAction open func goForward(_ sender: Any? = nil) {
        performStopCommands()
        self.taskController.goForward()
    }
    
    @IBAction open func goBack(_ sender: Any? = nil) {
        stop()
        self.taskController.goBack()
    }
    
    @IBAction open func skipForward(_ sender: Any? = nil) {
        stop()
        self.taskController.goForward()
    }
    
    @IBAction open func cancel(_ sender: Any? = nil) {
        stop()
        self.taskController.handleTaskCancelled()
    }
    
    
    // MARK: RSDUIActionHandler
    
    open func action(for actionType: RSDUIActionType) -> RSDUIAction? {
        if let action = (self.step as? RSDUIActionHandler)?.action(for: actionType) {
            // Allow the step to override the default from the delegate
            return action
        }
        else {
            // If no override by the step then return the action from the delegate
            return self.delegate?.action(for: actionType)
        }
    }
    
    open func shouldHideAction(for actionType: RSDUIActionType) -> Bool? {
        if let shouldHide = (self.step as? RSDUIActionHandler)?.shouldHideAction(for: actionType) {
            // Allow the step to override the default from the delegate
            return shouldHide
        }
        else if let shouldHide = self.delegate?.shouldHideAction(for: actionType) {
            // If no override by the step then return the action from the delegate if there is one
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
    
    
    // MARK: Active step handling
    
    public private(set) var isFirstAppearance: Bool = true
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
