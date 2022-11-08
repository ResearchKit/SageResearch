//
//  RSDStepController.swift
//  Research
//

import Foundation


/// `RSDStepController` handles default implementations for running a step in a task.
public protocol RSDStepController : AnyObject {

    /// A pointer to the step with the model information used to display and run the step. The
    /// implementation of the task controller should set this pointer before displaying the step controller
    /// by calling `setStep(_ step: RSDStep, with parent: RSDPathComponent?)`.
    var stepViewModel: RSDStepViewPathComponent! { get set }
    
    /// Callback from the task controller called on the current step controller when loading is finished
    /// and the task is ready to continue.
    func didFinishLoading()
    
    /// Navigates forward to the next step.
    func goForward()
    
    /// Navigates backward to the previous step.
    func goBack()
}

extension RSDStepController {
    
    /// Pointer back to the task controller that is displaying the step controller.
    public var taskController: RSDTaskController? {
        return self.stepViewModel?.parentTaskPath?.taskController
    }
}
