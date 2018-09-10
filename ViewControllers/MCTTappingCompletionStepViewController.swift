//
//  MCTTappingCompletionViewController.swift
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

open class MCTTappingCompletionStepViewController : RSDStepViewController {
    
    /// The constraint that makes both tapping count labels have equal height.
    @IBOutlet weak var labelHeightEqualityConstraint: NSLayoutConstraint!
    
    /// The constraint on the height of the right count label.
    @IBOutlet weak var rightHeightConstraint: NSLayoutConstraint!
    
    /// The constraint on the height of the left count label.
    @IBOutlet weak var leftHeightConstraint: NSLayoutConstraint!
    
    /// The label that describes what the right tap count means to the user.
    @IBOutlet weak var rightUnitLabel: UILabel!
    
    /// The label that displays the right tap count.
    @IBOutlet weak var rightCountLabel: UILabel!
    
    /// The label that describes what the left tap count means to the user.
    @IBOutlet weak var leftUnitLabel: UILabel!
    
    /// The label that displays the left tap count.
    @IBOutlet weak var leftCountLabel: UILabel!
    
    /// Override viewWillAppear to get the tapping results, hide the appropriate views,
    /// and update the labels text.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let results = _getTappingResults()
        self._hideViews(shouldHideLeft: results.leftCount == nil, shouldHideRight: results.rightCount == nil)
        self.updateLabels(leftCount: results.leftCount, rightCount: results.rightCount)
    }
    
    /// Updates the text of both the labels displaying the tap count numbers, and the
    /// labels describing what these numbers mean (ie "LEFT HAND TAPS").
    open func updateLabels(leftCount: Int?, rightCount: Int?) {
        if leftCount != nil {
            self.leftUnitLabel.text = Localization.localizedString("TAPPING_COMPLETION_LEFT_UNIT_LABEL")
            self.leftCountLabel.text = String(leftCount!)
        }
        
        if rightCount != nil {
            self.rightUnitLabel.text = Localization.localizedString("TAPPING_COMPLETION_RIGHT_UNIT_LABEL")
            self.rightCountLabel.text = String(rightCount!)
        }
    }
    
    // Returns a tuple containing the number of taps from each hand. A hand that doesn't
    // perform the activity will have `nil` returned as its number of taps.
    private func _getTappingResults() -> (leftCount: Int?, rightCount: Int?) {
        let leftCount = _getTappingResult(with: .left)
        let rightCount = _getTappingResult(with: .right)
        return (leftCount: leftCount, rightCount: rightCount)
    }
    
    // Returns the number of taps for the result with the given identifier.
    // identifier is typically expected to be either "left" or "right"
    private func _getTappingResult(with identifier: MCTHandSelection) -> Int? {
        let taskResult = self.taskController.taskResult
        guard let result = taskResult?.findResult(with: identifier.stringValue) as? RSDTaskResult,
            let tappingResult = result.findResult(with: "tapping") as? MCTTappingResultObject
            else {
                return nil
        }
        
        return tappingResult.tapCount
    }
    
    // Hides the left and right results labels depinding on whether or not
    // they should be hidden.
    private func _hideViews(shouldHideLeft: Bool, shouldHideRight: Bool) {
        self.leftHeightConstraint.constant = shouldHideLeft ? CGFloat(0) : CGFloat(80)
        self.leftCountLabel.isHidden = shouldHideLeft
        self.leftUnitLabel.isHidden = shouldHideLeft
        
        self.rightHeightConstraint.constant = shouldHideRight ? CGFloat(0) : CGFloat(80)
        self.rightCountLabel.isHidden = shouldHideRight
        self.rightUnitLabel.isHidden = shouldHideRight
        self.labelHeightEqualityConstraint.isActive = !(shouldHideLeft || shouldHideRight)
        self.view.setNeedsLayout()
    }
}
