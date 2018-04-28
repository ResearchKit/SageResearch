//
//  RSDStepController.swift
//  ResearchStack2
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

import Foundation

/// `RSDStepController` handles default implementations for running a step in a task.
public protocol RSDStepController : class, NSObjectProtocol {
    
    /// Pointer back to the task controller that is displaying the step controller. The implementation
    /// of the task controller should set this pointer before displaying the step controller.
    var taskController: RSDTaskController! { get set }
    
    /// A pointer to the step with the model information used to display and run the step. The
    /// implementation of the task controller should set this pointer before displaying the step controller.
    var step: RSDStep! { get set }
    
    /// Callback from the task controller called on the current step controller when loading is finished
    /// and the task is ready to continue.
    func didFinishLoading()
    
    /// Is forward navigation enabled? This property allows the step controller to indicate that forward
    /// step is not enabled.
    var isForwardEnabled: Bool { get }
    
    /// Navigate forward.
    func goForward()
    
    /// Navigate back.
    func goBack()
    
    /// Navigate forward by skipping the step.
    func skipForward()
    
    /// Cancel the task.
    func cancel()
    
    /// Returns a Boolean value indicating whether there is a previous step.
    ///
    /// This method is a convenience accessor that subclasses can call to make a delegate callback to
    /// determine whether a previous step exists. Subclasses can also override this method if the step
    /// view controller should always behave as if backward navigation is disabled.
    ///
    /// - returns: `true` if there is a previous step; otherwise, `false`.
    var hasStepBefore: Bool { get }
    
    /// Returns a Boolean value indicating whether there is a next step.
    ///
    /// This method is a convenience method that subclasses can call to make a delegate callback to
    /// determine whether a next step exists.
    ///
    /// - returns: `true` if there is a next step; otherwise, `false`.
    var hasStepAfter: Bool { get }
}

extension RSDStepController {
    
    /// Pointer back to the task controller that is displaying the step controller. The implementation
    /// of the task controller should set this pointer before displaying the step controller.
    public var taskUIController: RSDTaskUIController? {
        return self.taskController as? RSDTaskUIController
    }
    
    /// Convenience var for accessing the step path.
    public var stepPath: String {
        return self.taskController?.taskPath.stepPath ?? ""
    }
    
    /// Convenience method for accessing the step result associated with this step.
    public func findStepResult() -> RSDResult? {
        guard let step = self.step, let taskPath = self.taskController?.taskPath else { return nil }
        return taskPath.result.findResult(for: step)
    }
    
    /// Conveniece method for getting the progress through the task for the current step with
    /// the current result.
    ///
    /// - returns:
    ///     - current: The current progress. This indicates progress within the task.
    ///     - total: The total number of steps.
    ///     - isEstimated: Whether or not the progress is an estimate (if the task has variable navigation)
    public func progress() -> (current: Int, total: Int, isEstimated: Bool)? {
        
        // In case this gets called before the view has been loaded, check for the optionals
        guard let path = self.taskController?.taskPath, let currentStep = step
            else {
                return nil
        }
        
        // Look up the task chain for a progress that is *not* estimated and return either the top level
        // progress or the subtask progress if it defines progress using progress markers.
        var taskPath = path
        var progress = taskPath.task?.stepNavigator.progress(for: currentStep, with: taskPath.result)
        while (progress?.isEstimated ?? true) && (taskPath.parentPath != nil) {
            taskPath = taskPath.parentPath!
            progress = taskPath.task!.stepNavigator.progress(for: taskPath.currentStep!, with: taskPath.result)
        }

        return progress
    }
    
    /// An identifier string that can be appended to a step view controller to differentiate this step from
    /// another instance in a different section.
    public func sectionIdentifier() -> String {
        return (self.taskController.taskPath.parentPath != nil) ? "\(self.taskController.taskPath.result.identifier)_" : ""
    }
}
