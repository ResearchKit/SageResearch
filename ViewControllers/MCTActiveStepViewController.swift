//
//  MCTActiveStepViewController.swift
//  MotorControl
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

open class MCTActiveStepViewController : RSDActiveStepViewController, MCTHandStepController {
    
    /// Retuns the imageView, in this case the image from the navigationHeader.
    public var imageView: UIImageView? {
        return self.navigationHeader?.imageView ?? self.navigationBody?.imageView
    }
    
    /// Overriden to also update the unit label text when the
    /// countdown changes.
    override open var countdown: Int {
        didSet {
            self.updateUnitLabelText()
        }
    }
    
    /// The restart test button.
    @IBOutlet weak var restartButton: RSDRoundedButton!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Formatter for the countdown label.
        // Overriden to only display seconds.
        self.countdownFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = [ .pad ]
            return formatter
        }()
    }
    
    /// Override viewWillAppear to also set the unitLabel text.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Attempted to split the DataComponentsFormatter into a number and a unit label, however
        // DateComponentsFormatter doesn't actually translate into other languages.
        (self.step as? RSDActiveUIStepObject)?.nextStepIdentifier = nil
        self.updateImage()
        self.updateLabelText()
        self.updateUnitLabelText()
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }
    
    /// Updates the unit label text. Choses between the plural and
    /// singular label options (in English "SECONDS REMAINING" vs
    /// "SECOND REMAINING").
    open func updateUnitLabelText() {
        let localizationKey = self.countdown == 1 ? "ACTIVE_STEP_UNIT_LABEL_SINGULAR" : "ACTIVE_STEP_UNIT_LABEL"
        self.unitLabel?.text = Localization.localizedString(localizationKey)
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        skipForward()
    }
    
    /// Override skip forward to skip backward to the walk step.
    override open func skipForward() {
        // TODO: rkolmos 04/05/2018 refactor ResearchStack2 to support linking an RSDUIAction to navigation
        guard let activeStep = self.step as? RSDActiveUIStepObject else { return }
        activeStep.nextStepIdentifier = "walk"
        super.skipForward()
    }
    
    /// Override to return the instruction with the formatted text replaced.
    override open func spokenInstruction(at duration: TimeInterval) -> String? {
        guard let textFormat = super.spokenInstruction(at: duration) else { return nil }
        guard let direction = self.whichHand()?.rawValue.uppercased() else { return textFormat }
        // TODO rkolmos 04/09/2018 localize and standardize with java implementation
        return String.localizedStringWithFormat(textFormat, direction)
    }
}
