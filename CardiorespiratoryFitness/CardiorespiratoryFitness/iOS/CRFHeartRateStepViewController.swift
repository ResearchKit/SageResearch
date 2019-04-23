//
//  CRFHeartRateStepViewController.swift
//  CardiorespiratoryFitness
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

import UIKit

extension CRFHeartRateStep : RSDStepViewControllerVendor {
    
    /// By default, return the task view controller from the storyboard.
    public func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)? {
        let bundle = Bundle(for: CRFHeartRateStepViewController.self)
        let storyboard = UIStoryboard(name: "ActiveTaskSteps", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "HeartRate") as? CRFHeartRateStepViewController
        vc?.stepViewModel = vc?.instantiateStepViewModel(for: self, with: parent)
        return vc
    }
}

extension RSDIdentifier {
    static let restingHRResultIdentifier: RSDIdentifier = "resting"
    static let vo2MaxResultIdentifier: RSDIdentifier = "vo2_max"
    static let endHRResultIdentifier: RSDIdentifier = "end"
    static let samplesResultIdentifier: RSDIdentifier = "samples"
}

/// The view controller to use to record the participant's heart rate.
public final class CRFHeartRateStepViewController: RSDActiveStepViewController, CRFHeartRateRecorderDelegate {

    /// The image view for showing the heart image.
    @IBOutlet public var imageView: UIImageView!
    
    /// The loading indicator to show while starting the camera.
    @IBOutlet public var loadingIndicator: UIActivityIndicatorView!
    
    /// The video preview window.
    @IBOutlet public var previewView: UIView!
    
    /// The label for displaying the hr once the footer with the next button is displayed.
    @IBOutlet var hrResultLabel: UILabel!
    
    /// The label for the bpm unit to display once the next buttonn is displayed.
    @IBOutlet var bpmLabel: UILabel!
    
    /// A label with a title for the instruction.
    @IBOutlet var instructionTitleLabel: UILabel!
    
    /// A button for handling what to do once heart rate is captured.
    var continueButton: UIButton! {
        return self.nextButton
    }
    
    /// The heart rate recorder.
    public private(set) var bpmRecorder: CRFHeartRateRecorder?
    
    /// This step has multiple results so use a collection result to store them.
    public private(set) var collectionResult: RSDCollectionResult?
    
    /// Add the result to the collection. This will fail to add the result if called before the step is
    /// added to the view controller.
    /// - parameter result: The result to add to the collection.
    public func addResult(_ result: RSDResult) {
        guard step != nil else { return }
        var stepResult = self.collectionResult ?? RSDCollectionResultObject(identifier: self.step.identifier)
        stepResult.appendInputResults(with: result)
        self.collectionResult = stepResult
        self.stepViewModel.taskResult.appendStepHistory(with: stepResult)
    }
    
    /// Override `viewDidLoad` to set up the preview layer and hide the heart image.
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previewView.layer.masksToBounds = true
        _setupStartUI()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the corner radius for the preview window.
        self.previewView.layer.cornerRadius = self.previewView.bounds.width / 2.0
    }
    
    public override func setColorStyle(for placement: RSDColorPlacement, background: RSDColorTile) {
        super.setColorStyle(for: placement, background: background)
        
        if placement == .body {
            self.instructionTitleLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .heading4)
            self.instructionLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .heading4)
            self.progressLabel?.textColor = self.designSystem.colorRules.textColor(on: background, for: .heading2)
        }
    }
    
    private var _firstAppearance: Bool = true
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.countdownDial as! RSDCountdownDial).innerColor = UIColor.clear
        
        if _firstAppearance {
            // Make sure the learn more button is hidden
            self.learnMoreButton?.isHidden = true
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if _firstAppearance {
            // Use a delay to let the page view controller finish its animation.
            let delay = DispatchTime.now() + .milliseconds(100)
            DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
                self?._startCamera()
            }
            
            let instruction = Localization.localizedString("HEARTRATE_CAPTURE_CONTINUE_TEXT")
            self.setInstruction(instruction) 
        }
        _firstAppearance = false
    }
    
    private func _startCamera() {
        guard isVisible, let taskPath = self.stepViewModel.parentTaskPath else { return }
        
        // Create a recorder that runs only during this step
        let config = (self.step as? CRFHeartRateStep) ?? CRFHeartRateStep(identifier: self.step.identifier)
        bpmRecorder = CRFHeartRateRecorder(configuration: config, taskViewModel: taskPath, outputDirectory: taskPath.outputDirectory)
        bpmRecorder!.delegate = self
        
        // add an observer for changes in the bpm
        _bpmObserver = bpmRecorder!.observe(\.bpm, changeHandler: { [weak self] (recorder, _) in
            self?._updateBPMLabelOnMainQueue(recorder.bpm, recorder.confidence)
        })
        
        // Setup a listener to start the timer when the lens is covered.
        _isCoveredObserver = bpmRecorder!.observe(\.isCoveringLens, changeHandler: { [weak self] (recorder, _) in
            self?._handleLensCoveredOnMainQueue(recorder.isCoveringLens)
        })
        
        // If the user is trying for 5 seconds to cover the lens and it isn't recognized,
        // then just keep going. The result might be a 0 heart rate measurement, but we will
        // still capture the data and can analyze it later.
        let delay = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            self?._startCountdownIfNeeded()
        }
        
        // start the recorders
        let taskController = self.stepViewModel.rootPathComponent.taskController!
        taskController.startAsyncActions(for: [bpmRecorder!], showLoading: false, completion:{})
    }
    
    public func didFinishStartingCamera() {
        DispatchQueue.main.async {
            self.loadingIndicator?.stopAnimating()
            self.loadingIndicator?.isHidden = true
        }
    }
    
    func invalidateObservers() {
        
        _bpmObserver?.invalidate()
        _bpmObserver = nil
        
        _isCoveredObserver?.invalidate()
        _isCoveredObserver = nil
    }
    
    func compileResults() -> CRFHeartRateBPMSample? {
        
        var resultSample: CRFHeartRateBPMSample?
        
        // Record the average or initial heart rate depending upon whether or not the participant is at rest.
        if let recorder = bpmRecorder {
            
            // Get the "most appropriate" heart rate.
            
            let isResting = (self.step as? CRFHeartRateStep)?.isResting ?? true
            if isResting {
                if let bpm = recorder.restingHeartRate() {
                    addSample(bpm, RSDIdentifier.restingHRResultIdentifier.stringValue)
                    resultSample = bpm
                }
            }
            else {

                if let vo2 = recorder.vo2Max(), let bpm = recorder.endHeartRate()  {
                    addResult(RSDAnswerResultObject(identifier: RSDIdentifier.vo2MaxResultIdentifier.stringValue, answerType: .integer, value: Int(round(vo2))))
                    addSample(bpm, RSDIdentifier.endHRResultIdentifier.stringValue)
                    resultSample = bpm
                }
            }
            
            // Add all the samples.
            let samplesResult = CRFHeartRateSamplesResult(identifier: RSDIdentifier.samplesResultIdentifier.stringValue, samples: recorder.sampleProcessor.bpmSamples)
            addResult(samplesResult)
        }
        
        return resultSample
    }

    override public func stop() {
        invalidateObservers()
        _stopAnimatingHeart()
        super.stop()
    }
    
    private func addSample(_ bpm: CRFHeartRateBPMSample, _ identifier: String) {
        addSample(bpm.bpm, confidence: bpm.confidence, identifier)
    }
    
    private func addSample(_ value: Double, confidence: Double, _ identifier: String) {
        var bpmResult = RSDAnswerResultObject(identifier: identifier, answerType: RSDAnswerResultType(baseType: .integer))
        bpmResult.value = value
        addResult(bpmResult)
        
        var confidenceResult = RSDAnswerResultObject(identifier: "\(identifier)_confidence", answerType: RSDAnswerResultType(baseType: .decimal))
        confidenceResult.value = confidence
        addResult(confidenceResult)
    }
    
    public func asyncAction(_ controller: RSDAsyncAction, didFailWith error: Error) {
        guard let taskController = self.stepViewModel.rootPathComponent.taskController else { return }
        taskController.handleTaskFailure(with: error)
    }
    
    override public func timerFired() {
        super.timerFired()
        if countdown <= 0 {
            _handleTimerFinished()
        }
    }
    
    private var _bpmObserver: NSKeyValueObservation?
    private var _isCoveredObserver: NSKeyValueObservation?
    private var _isFinished: Bool = false
    
    private func _handleTimerFinished() {
        if let recorder = self.bpmRecorder {
            // stop the recorder
            self.taskController?.stopAsyncActions(for: [recorder], showLoading: false) {
            }
        }
        
        // Delay stopping everything else to give the processor time to finish processing the samples.
        let delay = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            self?._finishStopping()
        }
    }
    
    private func _finishStopping() {
        self.stop()
        if let sample = self.compileResults(),
            let bpmString = numberFormatter.string(from: NSNumber(value: sample.bpm)) {

            _isFinished = true
            self.hrResultLabel.text = bpmString
            self.hrResultLabel.isHidden = false
            self.bpmLabel.isHidden = false
            self.imageView.isHidden = true
            self.progressLabel?.isHidden = true
            self.instructionTitleLabel?.isHidden = false
            self.instructionTitleLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_DONE_TITLE")
            self.instructionLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_DONE_TEXT")
            self.continueButton?.setTitle(Localization.buttonNext(), for: .normal)
            self.continueButton?.isHidden = false
        }
        else {
            self.reset()
            self.learnMoreButton?.isHidden = false
            self.imageView.isHidden = false
            self.imageView.image = UIImage(named: "AlertIcon",
                                           in: Bundle(for: CRFHeartRateStepViewController.self),
                                           compatibleWith: self.traitCollection)
            self.progressLabel?.isHidden = true
            self.instructionTitleLabel?.isHidden = false
            self.instructionTitleLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_REDO_TITLE")
            self.instructionLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_REDO_TEXT")
            
            if (self.step as? CRFHeartRateStep)?.isResting ?? false {
                self.continueButton?.setTitle(Localization.localizedString("HEARTRATE_CAPTURE_REDO_BUTTON"), for: .normal)
            }
            else {
                _isFinished = true
                self.continueButton?.setTitle(Localization.buttonDone(), for: .normal)
            }
            self.continueButton?.isHidden = false
        }
    }
    
    // Override the default for go forward to restart if not finished.
    override public func goForward() {
        if _isFinished {
            super.goForward()
        }
        else {
            _setupStartUI()
            _startCamera()
        }
    }
    
    private func _startCountdownIfNeeded() {
        if _markTime == nil {
            _markTime = ProcessInfo.processInfo.systemUptime
        }
        guard self.clock == nil else { return }
        self.start()
        _startAnimatingHeart()
    }
    
    private func _startAnimatingHeart() {
        self.imageView.isHidden = false
        self.imageView.layer.removeAllAnimations()
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        fadeAnimation.autoreverses = true
        fadeAnimation.repeatCount = Float.greatestFiniteMagnitude
        
        self.imageView.layer.add(fadeAnimation, forKey: "beatingHeart")
    }
    
    private func _stopAnimatingHeart() {
        self.imageView.layer.removeAllAnimations()
        self.imageView.layer.opacity = 1.0
    }
    
    private let blankText = "---"
    private func _setupStartUI() {
        
        self.learnMoreButton?.isHidden = true
        self.progressLabel?.isHidden = false
        self.hrResultLabel?.isHidden = true
        self.bpmLabel?.isHidden = true
        self.instructionTitleLabel?.isHidden = true
        self.continueButton?.isHidden = true
        self.imageView?.isHidden = false
        self.imageView?.image = UIImage(named: "heartRateIconCapturing",
                                        in: Bundle(for: CRFHeartRateStepViewController.self),
                                        compatibleWith: self.traitCollection)
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        
        self.progressLabel?.text = self.blankText
        self.bpmLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_BPM")
        self.instructionLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_START_TEXT")
    }
    
    private func _handleLensCoveredOnMainQueue(_ isCoveringLens: Bool) {
        DispatchQueue.main.async {
            self.imageView.isHidden = !isCoveringLens
            self.loadingIndicator?.stopAnimating()
            self.loadingIndicator?.isHidden = true
            if isCoveringLens {
                self._startCountdownIfNeeded()
                if self.progressLabel?.text == self.blankText {
                    self.progressLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_CAPTURING")
                }
                self.instructionTitleLabel?.isHidden = true
                let instruction = Localization.localizedString("HEARTRATE_CAPTURE_CONTINUE_TEXT")
                self.setInstruction(instruction)
            } else {
                // zero out the BPM to indicate to the user that they need to cover the flash
                // and show the initial instruction.
                self.progressLabel?.text = self.blankText
                self._markTime = nil
                self.vibrateDevice()
                self.instructionTitleLabel?.isHidden = false
                self.instructionTitleLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_ERROR_TITLE")
                let instruction = Localization.localizedString("HEARTRATE_CAPTURE_ERROR_TEXT")
                self.setInstruction(instruction)
            }
        }
    }
    
    public override func reset() {
        super.reset()
        _markTime = nil
    }
    
    private var _currentLabel: String?
    func setInstruction(_ instruction: String) {
        guard _currentLabel != instruction else { return }
        _currentLabel = instruction
        self.instructionLabel?.text = instruction
        UIAccessibility.post(notification: .announcement, argument: instruction)
    }
    
    private func _updateBPMLabelOnMainQueue(_ bpm: Int, _ confidence: Double) {
        DispatchQueue.main.async {
            self.updateBPMLabel(bpm, confidence)
        }
    }
    
    private let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()
    
    private var _markTime: TimeInterval?
    
    private func updateBPMLabel(_ bpm: Int, _ confidence: Double) {
        guard confidence >= CRFMinConfidence,
            let bpmString = numberFormatter.string(from: NSNumber(value: bpm))
            else {
                alertUserLowConfidence()
                return
        }
        self.progressLabel?.text = Localization.localizedStringWithFormatKey("HEARTRATE_CAPTURE_%@_BPM", bpmString)
    }
    
    private func alertUserLowConfidence() {
        // syoung 04/16/2019 Do nothing. Just keep the previous result.
        // self.progressLabel?.text = Localization.localizedString("HEARTRATE_CAPTURE_CAPTURING")
    }
}
