//
//  MCTCompletionStepViewController.swift
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

public class MCTCompletionStepViewController : RSDStepViewController {

    /// Override viewWillAppear to update the text label.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateTextLabel()
    }

    /// Updates the text label to display the count of the number of times this task
    /// has been completed. Also records the task's completion in UserDefaults.
    open func updateTextLabel() {
        let defaults = UserDefaults.standard
        let taskIdentifier = self.stepViewModel.parentTaskPath!.identifier
        let userDefaultsKey = "\(taskIdentifier)_timesCompleted"
        let runCount = defaults.integer(forKey: userDefaultsKey) + 1
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        if let textFormat = (self.step as? RSDUIStep)?.text,
           let ordinal = formatter.string(from: NSNumber(value: runCount)) {
            self.stepTextLabel?.text = Localization.localizedStringWithFormatKey(textFormat, ordinal)
        }
        
        defaults.set(runCount, forKey: userDefaultsKey)
    }
}
