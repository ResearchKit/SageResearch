//
//  RSDCountdownUIStepObject.swift
//  Research
//

import Foundation

/// `RSDCountdownUIStepObject` extends the `RSDActiveUIStepObject` to include default values for a
/// countdown step that is intended to preceed an active step.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
