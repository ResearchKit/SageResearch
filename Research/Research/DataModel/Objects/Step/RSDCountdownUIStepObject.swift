//
//  RSDCountdownUIStepObject.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// `RSDCountdownUIStepObject` extends the `RSDActiveUIStepObject` to include default values for a
/// countdown step that is intended to preceed an active step.
open class RSDCountdownUIStepObject : RSDActiveUIStepObject, RSDCountdownUIStep {

    /// The active step that follows this step.
    public internal(set) var activeStep: RSDActiveUIStep?
    
    /// The default step type is `countdown`.
    open override class func defaultType() -> RSDStepType {
        return .countdown
    }
    
    /// Override setting the title to return a value of "Begin in..." if the title is `nil`.
    open override var title: String? {
        get {
            return super.title ?? Localization.localizedString("COUNTDOWN_STEP_DEFAULT_TITLE")
        }
        set {
            super.title = newValue
        }
    }
    
    /// Override to return a default duration of 5 seconds.
    open override var duration: TimeInterval {
        get {
            let duration = super.duration
            return duration > 0 ? duration : 5
        }
        set {
            super.duration = newValue
        }
    }
    
    /// Override to always include transitioning automatically.
    open override var commands: RSDActiveUIStepCommand {
        get {
            return super.commands.union(.transitionAutomatically)
        }
        set {
            super.commands = newValue
        }
    }
    
    /// Override the action handler to return the "review instructions" from the active step
    /// if available.
    override open func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        let action = super.action(for: actionType, on: step)
        guard action == nil, actionType == .navigation(.reviewInstructions),
            let activeStep = self.activeStep
            else {
                return action
        }
        return activeStep.action(for: actionType, on: activeStep)
    }
}
