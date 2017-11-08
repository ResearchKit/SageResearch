//
//  RSDActiveStepViewController.swift
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

open class RSDActiveStepViewController: RSDStepViewController {

    @IBOutlet open var countdownLabel: UILabel?
    @IBOutlet open var instructionLabel: UILabel?
    @IBOutlet open var countdownDial: RSDProgressIndicator?
    @IBOutlet open var progressLabel: UILabel?
    @IBOutlet open var unitLabel: UILabel?

    /**
     Formatter for the countdown label.
     */
    lazy open var countdownFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter
    }()
    
    open override var countdown: Int {
        didSet {
            countdownLabel?.text = countdownFormatter.string(from: TimeInterval(countdown))
        }
    }

    open override func speak(instruction: String, timeInterval: TimeInterval, completion: RSDVoiceBoxCompletionHandler?) {
        instructionLabel?.text = instruction
        super.speak(instruction: instruction, timeInterval: timeInterval, completion: completion)
    }

    open override func start() {
        super.start()
        _startProgressAnimation()
    }
    
    override open func pause() {
        super.pause()
        _pauseProgress()
    }
    
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
    
    open class var nibName: String {
        return String(describing: RSDActiveStepViewController.self)
    }
    
    open class var bundle: Bundle {
        return Bundle(for: RSDActiveStepViewController.self)
    }
    
    public override init(step: RSDStep) {
        super.init(nibName: type(of: self).nibName, bundle: type(of: self).bundle)
        self.step = step
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
