//
//  RSDOverviewStep.swift
//  Research
//

import Foundation

/// `RSDOverviewStep` extends the `RSDUIStep` to include general overview information about an activity
/// including what permissions are required by this task. Without these preconditions, the task cannot
/// measure or collect the data needed for this task.
// TODO: syoung 10/28/2022 Break adherence to the StandardPermissionsStep protocol
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDOverviewStep : AnyObject, RSDUIStep, StandardPermissionsStep {
    
    /// For an overview step, the title is readwrite.
    var title: String? { get set }
    
    /// For an overview step, the text is readwrite.
    var subtitle: String? { get set }
    
    /// For an overview step, the detail is readwrite.
    var detail: String? { get set }
    
    /// The learn more action for the task that this overview step is describing.
    var learnMoreAction: RSDUIAction? { get set }
    
    /// The icons that are used to define the list of things you will need for an active task.
    var icons: [RSDIconInfo]? { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTask {
    
    /// Look to see if the first step in this task is an overview step and if so, return that
    /// step. Since the overview step is a class, then it can be mutated in-place without having
    /// to mutate the step navigators method of containing those steps.
    public var overviewStep: RSDOverviewStep? {
        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: self.identifier)
        let step = self.stepNavigator.step(after: nil, with: &taskResult).step
        return step as? RSDOverviewStep
    }
}
