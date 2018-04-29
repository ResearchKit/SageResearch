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
open class RSDActiveStepViewController: RSDStepViewController {

    /// An instruction label that is updated to show the same text that is spoken as a spoken instruction
    /// to the user.
    /// - seealso: `speakInstruction(_:, at:, completion:)
    @IBOutlet open var instructionLabel: UILabel?
    
    /// The countdown dial is a graphical element used to display progress to the user.
    @IBOutlet open var countdownDial: RSDProgressIndicator?
    
    /// The progress label is a label that can be used to indicate progress measured by some unit other than time (which
    /// is shown using the `countdownDial`). For example, in a walking step, a subclass may use this label to display the
    /// distance the user walked (calulated using GPS or pedometer sensor data) or the number of steps taken.
    ///
    /// - note: The default implementation does not use this label, but it is included so that subclasses may take advantage
    /// of it and still use the default nib included in this framework.
    ///
    /// - seealso: `unitLabel`
    @IBOutlet open var progressLabel: UILabel?
    
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

    /// Formatter for the countdown label.
    lazy open var countdownFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter
    }()
    
    /// This class overrides `didSet` to update the `countdownLabel` to the new value formatted as a time interval in seconds.
    /// The `countdownFormatter` is used to format the string derived from this time interval.
    open override var countdown: Int {
        didSet {
            countdownLabel?.text = countdownFormatter.string(from: TimeInterval(countdown))
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
        _startProgressAnimation()
    }
    
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
    
    
    // MARK: Dial progress indicator
    
    private func _pauseProgress() {
        guard let stepDuration = self.activeStep?.duration, let uptime = self.startUptime
            else {
                return
        }
        let duration = ProcessInfo.processInfo.systemUptime - uptime
        self.countdownDial?.progress = CGFloat(duration / stepDuration)
    }
    
    private func _startProgressAnimation() {
        guard pauseUptime == nil, let stepDuration = self.activeStep?.duration, let uptime = self.startUptime
            else {
                debugPrint("Start progress animation called before uptime validated.")
                return
        }
        
        // calculate how much time has already passed since the step timer
        // was started.
        let duration = ProcessInfo.processInfo.systemUptime - uptime
        
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
        self.progressLabel?.text = nil
        self.unitLabel?.text = nil
    }
    
    // MARK: Initialization
    
    /// The default nib name to use when instantiating the view controller using `init(step:)`.
    open class var nibName: String {
        return String(describing: RSDActiveStepViewController.self)
    }
    
    /// The default bundle to use when instantiating the view controller using `init(step:)`.
    open class var bundle: Bundle {
        return Bundle(for: RSDActiveStepViewController.self)
    }
    
    /// Default initializer. This initializer will initialize using the `nibName` and `bundle` defined on this class.
    /// - parameter step: The step to set for this view controller.
    public override init(step: RSDStep) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.step = step
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
