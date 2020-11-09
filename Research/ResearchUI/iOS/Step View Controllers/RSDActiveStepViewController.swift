//
//  RSDActiveStepViewController.swift
//  ResearchUI
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
import Research

/// `RSDActiveStepViewController` is a simple timer for displaying a longer activity where the user is doing an action while
/// the countdown timer is running.
///
/// This view controller includes a default nib implementation that is included in this framework. It includes various UI
/// elements that can indicate to the user how much time is remaining in a longer-running step.  For example, this could be
/// used during a walk step to indicate to the user how long they have been walking as well as how much longer they have to
/// walk before the step is complete.
///
/// - seealso: `RSDTaskViewController.vendDefaultViewController(for:)`
///
open class RSDActiveStepViewController: RSDFullscreenImageStepViewController {

    /// An instruction label that is updated to show the same text that is spoken as a spoken instruction
    /// to the user.
    /// - seealso: `speakInstruction(_:, at:, completion:)
    @IBOutlet open var instructionLabel: UILabel?
    
    /// The countdown dial is a graphical element used to display progress to the user.
    @IBOutlet open var countdownDial: RSDProgressIndicator?
    
    /// The unit label is a label that can be used to indicate the unit of the progress label. It is included as a separate
    /// label to allow that text to be easily defined with a different font, color, and/or position in the associated nib
    /// or storyboard.For example, in a walking step, a subclass may use the progress label to display the distance the user
    /// walked (calulated using GPS or pedometer sensor data) and would then assign this label to the "feet" or "meters"
    /// showing the unit of measurement.
    ///
    /// - note: The default implementation does not use this label, but it is included so that subclasses may take advantage
    /// of it and still use the default nib included in this framework.
    ///
    /// - seealso: `progressLabel`
    @IBOutlet open var unitLabel: UILabel?
    
    /// A label that is updated to show a countdown. For example, "5:35".
    @IBOutlet open var countdownLabel: UILabel?
    
    /// A label that is displayed to the user when the countdown is finished.
    @IBOutlet open var doneLabel: UILabel?
    
    /// Returns the allowed countdown units for the countdown label. Default is to show only seconds
    /// if the duration is less than 90 seconds.
    open var allowedCountdownUnits: NSCalendar.Unit {
        if let stepDuration = self.activeStep?.duration, stepDuration > 90 {
            return [.minute, .second]
        }
        else {
            return [.second]
        }
    }

    /// Formatter for the countdown label.
    lazy open var countdownFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = self.allowedCountdownUnits
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter
    }()
    
    /// This class overrides `didSet` to update the `countdownLabel` to the new value formatted as a time interval in seconds.
    /// The `countdownFormatter` is used to format the string derived from this time interval.
    open override var countdown: Int {
        didSet {
            updateCountdownLabels()
        }
    }
    
    /// Update the countdown labels
    open func updateCountdownLabels() {
        guard let stepDuration = self.activeStep?.duration
            else {
                unitLabel?.text = nil
                countdownLabel?.text = nil
                doneLabel?.isHidden = true
                return
        }
        
        let countdown = (self.clock == nil) ? Int(stepDuration) : self.countdown
        if countdown == 0 {
            unitLabel?.text = nil
            countdownLabel?.text = nil
            doneLabel?.isHidden = false
        }
        else {
            doneLabel?.isHidden = true
            countdownLabel?.text = countdownFormatter.string(from: TimeInterval(countdown))
            if self.allowedCountdownUnits == [.second] {
                switch countdown {
                case 1:
                    unitLabel?.text = Localization.localizedString("ACTIVE_STEP_UNIT_LABEL_ONE")
                default:
                    unitLabel?.text = Localization.localizedString("ACTIVE_STEP_UNIT_LABEL_OTHER")
                }
            }
            else {
                unitLabel?.text = nil
            }
        }
    }

    /// This class overrides the speak instruction method and will set the `instructionLabel` to the same text that the voice
    /// synthesizer speaks.
    open override func speakInstruction(_ instruction: String, at timeInterval: TimeInterval, completion: RSDVoiceBoxCompletionHandler?) {
        instructionLabel?.text = instruction
        super.speakInstruction(instruction, at: timeInterval, completion: completion)
    }

    /// The start method is overridden to start the countdown dial animation.
    open override func start() {
        super.start()
        if UIApplication.shared.applicationState == .active {
            _startProgressAnimation()
        }
        else {
            _activeObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
                self?._startProgressAnimation()
            })
        }
    }
    
    private var _activeObserver: Any?
    
    /// The pause method is overridden to pause the countdown dial animation.
    override open func pause() {
        super.pause()
        _pauseProgress()
    }

    /// The pause method is overridden to resume the countdown dial animation.
    override open func resume() {
        super.resume()
        _startProgressAnimation()
    }
    
    override open func reset() {
        super.reset()
        self.countdownDial?.progress = 0
    }
    
    /// Override the timer to check if finished.
    override open func timerFired() {
        super.timerFired()
        guard let duration = self.clock?.runningDuration(),
            let stepDuration = self.activeStep?.duration
            else {
                return
        }
        
        // If running in the background, do not animate updating the progress.
        if UIApplication.shared.applicationState != .active {
            self.countdownDial?.progress = CGFloat(duration / stepDuration)
        }
        
        // TODO: syoung 07/02/2019 Update implementation to include *restart* of the step should the step
        // be reset and need the recorders to restart.

        // If the timer duration is more than the step duration, then call the
        // timer finished method.
        if duration > stepDuration, !_timerFinishedCalled {
            _timerFinishedCalled = true
            self.timerFinished(duration)
        }
    }
    private var _timerFinishedCalled: Bool = false
    
    /// Stop any recorders that are attached to this step which would normally be stopped when the participant
    /// navigates away from the step.
    open func stopAsyncActions() {

        guard !_asyncActionsStopped,
            let taskViewModel = self.stepViewModel?.parentTaskPath as? RSDTaskViewModel,
            let step = self.step
            else {
                return
        }
        _asyncActionsStopped = true
        taskViewModel.stopAsyncActions(after: step)
    }
    private var _asyncActionsStopped: Bool = false
    
    /// Called when the timer has fired and should either transition to the next step or update the display.
    open func timerFinished(_ duration: TimeInterval) {
        
        // Call stop immediately.
        stop()
        
        // Check if should go forward automatically (or if the next button is nil).
        if (self.activeStep?.commands.contains(.continueOnFinish) ?? (self.nextButton == nil))  {
            self.goForward()
        }
        else {
            
            // Only need to call through to stop the async actions if the step does *not* automatically
            // transition to the next step. Otherwise, any recorder that *should* stop will do so
            // when the step transitions.
            stopAsyncActions()
            
            func updateViewVisibility() {
                self.nextButton!.alpha = 1
                if let activeViews = self.activeViews {
                    activeViews.forEach {
                        $0.alpha = 0
                    }
                }
            }
            
            // Hide the left/right buttons and show the next button.
            self.nextButton!.isHidden = false
            if UIApplication.shared.applicationState != .active {
                updateViewVisibility()
            }
            else {
                self.nextButton!.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    updateViewVisibility()
                }
            }
            
            // Disable the next button to guard against accidental hit.
            self.momentarilyDisableButton(self.nextButton!)
            
            // Speak the end command
            self.speakEndCommand { }
        }
    }
    
    /// List of views that are hidden when transitioning to the "finished" state.
    /// - seealso: `timerFinished()`
    @IBOutlet open var activeViews: [UIView]?
    
    // MARK: Dial progress indicator
    
    private func _pauseProgress() {
        guard let stepDuration = self.activeStep?.duration, let duration = self.clock?.runningDuration()
            else {
                return
        }
        self.countdownDial?.progress = CGFloat(duration / stepDuration)
    }
    
    private func _startProgressAnimation() {
        guard let stepDuration = self.activeStep?.duration,
            let clock = self.clock, !clock.isPaused
            else {
                debugPrint("Start progress animation called before uptime validated.")
                return
        }
        
        // calculate how much time has already passed since the step timer
        // was started.
        let duration = clock.runningDuration()
        
        // For shorter duration intervals,the animation will run more smoothly if it
        // is only fired once. For longer running steps, use a shorter interval to
        // mask the stutter while still accounting for animation timing drift and
        // pause intervals.
        let maxInterval = stepDuration > 60.0 ? 10.0 : stepDuration
        
        // The animation duration is either the time remaining or the max interval
        // (if the time remaining is more that the total step duration.
        let animationDuration = max(min(stepDuration - duration, maxInterval), 0.0)
        guard animationDuration > 0.0 else {
            debugPrint("Animation duration is less than or equal to zero.")
            return
        }
        
        // Set the progress to the value at the end of the
        let nextDuration = duration + animationDuration
        let nextProgress = CGFloat(nextDuration / stepDuration)
        let previousProgress = CGFloat(duration / stepDuration)
        if let progress = self.countdownDial?.progress, abs(progress - previousProgress) > 0.05 {
            // If the progress is somehow muddled and the dial isn't set correctly, then offset the
            // initial value by the previous progress amount before starting the next animation
            self.countdownDial?.progress = previousProgress
        }
        self.countdownDial?.setProgressPosition(nextProgress, animationDuration: animationDuration)
        if nextProgress < 1.0 {
            _fireNextProgressAnimation(with: Int(animationDuration * 1000))
        }
    }
    
    private func _fireNextProgressAnimation(with milliseconds: Int) {
        let delay = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            self?._startProgressAnimation()
        }
    }
    
    
    // MARK: View appearance
    
    /// Override `viewDidLoad` to set up initial values for the labels and progress indicators.
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nil out the values used to display the labels in interface builder.
        // These may be updated during viewWillAppear, but depending upon the model
        // it might display the view controller before these are changed (if changed at all)
        self.instructionLabel?.text = nil
        self.countdownLabel?.text = nil
        self.countdownDial?.progress = 0.0
        self.unitLabel?.text = nil
        self.doneLabel?.text = Localization.buttonDone()
        
        // Hide the next button to begin with.
        self.nextButton?.isHidden = true
        self.doneLabel?.isHidden = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the countdown label.
        self.updateCountdownLabels()
        
        // Hide the next button to begin with.
        self.nextButton?.isHidden = true
        self.nextButton?.alpha = 0
        
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.doneLabel?.font = self.designSystem.fontRules.font(for: .largeNumber, compatibleWith: traitCollection)
        self.unitLabel?.font = self.designSystem.fontRules.baseFont(for: .mediumHeader)  // NOT DYNAMIC
        self.instructionLabel?.font = self.designSystem.fontRules.font(for: .largeHeader, compatibleWith: traitCollection)
        self.countdownLabel?.font = self.designSystem.fontRules.font(for: .largeNumber, compatibleWith: traitCollection)
    }
    
    override open func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        if placement == .body {
            self.instructionLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .largeHeader)
        }
    }
    
    // MARK: Initialization
    
    class func initializeStepViewController(step: RSDStep, parent: RSDPathComponent?) -> RSDActiveStepViewController? {
        // Only return a view controller if this is an active step with a duration greater than 0.
        guard let activeStep = step as? RSDActiveUIStep, activeStep.duration > 0
            else {
                return nil
        }
        return RSDActiveStepViewController(step: step, parent: parent)
    }
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDActiveStepViewController.self)
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
