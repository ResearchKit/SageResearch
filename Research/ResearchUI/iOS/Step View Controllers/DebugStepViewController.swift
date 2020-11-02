//
//  DebugStepViewController.swift
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

/// `DebugStepViewController` is an internal class that is used to display a view controller for a step without any UI.
/// This allows the developer to use a placeholder view controller when developing a new task.
class DebugStepViewController: RSDStepViewController {
    
    /// A label for displaying the step identifier.
    @IBOutlet var identifierLabel: UILabel!
    
    /// A label for displaying the step description.
    @IBOutlet var titleLabel: UILabel!
    
    /// Default initializer used to display "DebugStepViewController.xib" for the given step.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        super.init(nibName: "DebugStepViewController", bundle: Bundle.module)
        self.stepViewModel = self.instantiateStepViewModel(for: step, with: parent)
    }
    
    /// Required initializer. Unused.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Override `viewWillAppear()` to set the identifier label and title label.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the view
        self.identifierLabel.text = self.step.identifier
        self.titleLabel.text = String(describing: self.step!)
    }
    
    /// Override to always allow forward navigation.
    override var isForwardEnabled: Bool {
        return true
    }
}
