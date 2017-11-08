//
//  RSDTaskController.swift
//  ResearchSuite
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

public enum RSDStepDirection : Int {
    case reverse = -1
    case none = 0
    case forward = 1
}

/**
 `RSDTaskController` handles default implementations for running a task.
 
 To start a task, create an instance of a view controller that conforms to this protocol and set either the `topLevelTask` or the `topLevelTaskInfo`.
 */
public protocol RSDTaskController : class, NSObjectProtocol {
    
    /**
     A mutable path object used to track the current state of a running task.
     */
    var taskPath: RSDTaskPath! { get set }
    
    /**
     Optional factory subclass that can be used to vend custom steps that are decoded from a plist or json.
     */
    var factory: RSDFactory? { get }
    
    /**
     Returns the currently active step controller (if any)
     */
    var currentStepController: RSDStepController? { get }
    
    /**
     Returns a list of the async action controllers that are currently active.
     */
    var currentAsyncControllers: [RSDAsyncActionController] { get }
    
    /**
     Should the protocol extension fetch the subtask from a task info object or does this implementation handle subtask step navigation using custom logic?
     
     @param step   The `RSDTaskStep` for which to fetch the task.
     
     @return        `true` if the task should be fetched using the protocol extension.
     */
    func shouldFetchSubtask(for step: RSDTaskInfoStep) -> Bool
    
    /**
     Should the protocol extension vend the steps in a section using paging to move to the next step or does this implementation handle section steps using custom logic?
     
     @param step   The `RSDSectionStep` for which show the paged steps.
     
     @return       `true` if the protocol extension should handle paging the steps.
     */
    func shouldPageSectionSteps(for step: RSDSectionStep) -> Bool
    
    /**
     Show a loading state while fetching the given task from the task info.
     
     @param taskInfo    The task info for the task being fetched.
     */
    func showLoading(for taskInfo: RSDTaskInfoStep)
    
    /**
     Fired when the task controller is ready to go forward. This method must invoke the `goForward()` method either to go forward automatically or else go forward after a user action.
     */
    func handleFinishedLoading()
    
    /**
     Hide the loading state if currently showing it.
     */
    func hideLoadingIfNeeded()
    
    /**
     Navigate to the next step from the previous step in the given direction.
     
     @param step            The step to show.
     @param previousStep    The previous step. This is either the step currently being displayed or else the `RSDSectionStep` or `RSDTaskStep` if the previous step was the last step in a paged section or fetched subtask.
     @param direction       The direction in which to show the animation change.
     */
    func navigate(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection)
    
    /**
     Failed to fetch the task from the current task path. Handle the error. A retry can be fired by calling `goForward()`.
     
     @param error   The error returned by the failed task fetch.
     */
    func handleTaskFailure(with error: Error)

    /**
     The task has completed, either as a result of all the steps being completed or because of an early exit.
     */
    func handleTaskCompleted()
    
    /**
     This method is called when a task result is "ready" for upload, save, archive, etc. This method will be called when either (a) the task is ready to dismiss or (b) when the task is displaying the *last* completion step.
     */
    func handleTaskResultReady(with taskPath: RSDTaskPath)
    
    /**
     The user has tapped the cancel button.
     */
    func handleTaskCancelled()
    
    /**
     Start the action for this as async configuration. The protocol extension calls this method when an async action should be started. It is up to the task controller to handle what should happen and how to create the controller. Any permissions required by this controller should be requested *before* returning the completion. Otherwise, the modal popup alert can be swallowed by the step change.
     
     Note: If creating the recorder might take time, the task controller should move creation to a background thread so that the main thread is not blocked.
     */
    func startAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (() -> Void))
    
    /**
     Stop the async action controller. The protocol extension does not directly implement stopping the async actions to allow customization of how the results are added to the task and whether or not forward navigation should be blocked until the completion handler is called. When the stop action is called, the view controller needs to handle stopping the controllers, adding the results and showing a loading state until ready to move forward in the task navigation.
     */
    func stopAsyncActions(for controllers: [RSDAsyncActionController], completion: @escaping (() -> Void))
}

extension RSDTaskController {
    
    /**
     Convenience method for getting/setting the main entry point for the task controller via the task info.
     */
    public var topLevelTaskInfo : RSDTaskInfoStep! {
        get {
            return topLevelTaskPath?.taskInfo
        }
        set {
            guard taskPath == nil else {
                assertionFailure("Cannot replace the task info on the task path once it is set.")
                return
            }
            self.taskPath = RSDTaskPath(taskInfo: newValue)
        }
    }
    
    /**
     Convenience method for getting/setting the main entry point for the task controller via the task.
     */
    public var topLevelTask : RSDTask! {
        get {
            return topLevelTaskPath?.task
        }
        set {
            guard taskPath == nil else {
                assertionFailure("Cannot replace the task on the task path once it is set.")
                return
            }
            self.taskPath = RSDTaskPath(task: newValue)
        }
    }
    
    /**
     Convenience method for getting the result for this task.
     */
    public var taskResult : RSDTaskResult! {
        return topLevelTaskPath?.result
    }
    
    /**
     Convenience method for getting the top level task path.
     */
    public var topLevelTaskPath : RSDTaskPath! {
        var taskPath = self.taskPath
        while taskPath?.parentPath != nil {
            taskPath = taskPath!.parentPath!
        }
        return taskPath
    }
    
    /**
     Start the task if it is not currently loaded with a task or first step.
     */
    public func startTaskIfNeeded() {
        guard !self.taskPath.isLoading else { return }
        if taskPath.task == nil {
            _fetchTaskFromCurrentInfo()
        }
        else if taskPath.currentStep == nil {
            _moveToNextStep()
        }
    }
    
    /**
     Can this task go forward? If forward navigation is disabled, then the task isn't waiting for a result or a task fetch to enable forward navigation.
     */
    public var isForwardEnabled: Bool {
        return self.taskPath.task != nil
    }
    
    /**
     Is there a next step or is this the last step in the task?
     */
    public var hasStepAfter: Bool {
        guard taskPath.task != nil else {
            // If the task is still fetching, then this is assumed to return with a task until the loading returns
            return taskPath.isLoading
        }
        
        // While this is the last step, look up the path chain for a task that has not reached the end
        var path = taskPath
        while let nextPath = path {
            if let task = nextPath.task,
                task.stepNavigator.hasStep(after: nextPath.currentStep, with: nextPath.result) {
                // If the current task path has more steps then this is not the end
                return true
            }
            path = nextPath.parentPath
        }

        // Otherwise, this is the last step
        return false
    }
    
    /**
     Is there previous step that this task can go back to?
     */
    public var hasStepBefore: Bool {
        // Exit early if this is the first step. There is no back button.
        if self.taskPath.currentStep == nil && self.taskPath.parentPath == nil {
            return false
        }
        
        // While this is the first step, look up the path chain for a task that has not reached the end
        var path = taskPath
        while let nextPath = path {
            if let step = nextPath.currentStep, let task = nextPath.task,
                task.stepNavigator.hasStep(before: step, with: nextPath.result) {
                // If the current task path has more steps then this is not the end
                return true
            }
            path = nextPath.parentPath
        }
        
        // Otherwise, this is the last step
        return false
    }
    
    /**
     Go forward to the next step. If the task is not loaded for the current point in the task path, then it will attempt to fetch it again.
     
     Note: This method will throw an assertion if it is called without first checking that the current task can navigate forward.
     */
    public func goForward() {
        guard self.taskPath.task != nil else {
            _fetchTaskFromCurrentInfo()
            return
        }
        
        // Add or update the result end date if there was previous step
        if let previousStep = self.taskPath.currentStep {
            if let result = self.taskPath.result.stepHistory.last, result.identifier == previousStep.identifier {
                var finalResult = result
                finalResult.endDate = Date()
                self.taskPath.result.appendStepHistory(with: finalResult)
            }
            else {
                let result = previousStep.instantiateStepResult()
                self.taskPath.result.appendStepHistory(with: result)
            }
        }
        
        // move to the next step
        _moveToNextStep()
    }
    
    /**
     Go back to the previous step.
     
     Note: This method will throw an assertion if there isn't a previous step.
     */
    public func goBack() {
        guard let _ = self.taskPath.currentStep else {
            assertionFailure("Cannot go backward with a nil current step. path = \(self.taskPath)")
            return
        }
        
        // move to the previous step
        _moveToPreviousStep()
    }
    
    private func _fetchTaskFromCurrentInfo() {
        guard !self.taskPath.isLoading else {
            debugPrint("Already loading \(self.taskPath)")
            return
        }
        guard let taskInfo = taskPath.taskInfo else {
            fatalError("Cannot fetch a task with a nil task info.")
        }
        
        self.showLoading(for: taskInfo)
        self.taskPath.fetchTask(with: self.factory ?? RSDFactory.shared) { [weak self] (path, error) in
            guard let strongSelf = self, strongSelf.taskPath == path else { return }
            guard error == nil else {
                strongSelf.handleTaskFailure(with: error ?? RSDTaskFetchError.unknown)
                return
            }
            strongSelf.handleFinishedLoading()
        }
    }
    
    private func _moveToNextStep(hasPreviousEarlyExit: Bool = false) {
        
        if taskPath.currentStep == nil {
            // Check if the current step is nil, if so, then validate the task
            do {
                try taskPath.task!.validate()
            } catch let error {
                self.handleTaskFailure(with: error)
                return
            }
        }
        
        let previousStep = taskPath.currentStep
        let nextStep = taskPath.task!.stepNavigator.step(after: previousStep, with: &taskPath.result)
        let isTaskComplete = (nextStep == nil) ||
            ((nextStep!.type == RSDFactory.StepType.completion.rawValue) &&
                !taskPath.task!.stepNavigator.hasStep(after: nextStep!, with: taskPath.result))
        
        if !hasPreviousEarlyExit, let stopStep = previousStep,
            let controllers = _asyncActionsToStop(after: stopStep, isTaskComplete: isTaskComplete) {
            // If there are action controllers to stop then do that before continuing
            // and call this method again after they have been stopped. Use the hasPreviousEarlyExit
            // flag to indicate that this is the second go-around and don't check the controllers the
            // second time.
            self.stopAsyncActions(for: controllers, completion: { [weak self] in
                DispatchQueue.main.async {
                    self?._moveToNextStep(hasPreviousEarlyExit: true)
                }
            })
            return
        }
        
        // save the previous step and look for a next step
        guard let step = nextStep else {
            // Update the end date for the task result but only if the last step is *not*
            // a completion step, in which case the true end date will already be set.
            if !self.taskPath.isCompleted  {
                _handleTaskReady(with: self.taskPath)
            }
            
            let shouldExit = taskPath.task!.stepNavigator.shouldExit(after: previousStep, with: taskPath.result)
            if !shouldExit, let parent = taskPath.parentPath {
                // If the parent path is non-nil then go back up to the parent
                parent.appendStepHistory(with: taskPath.result)
                self.taskPath = parent
                _moveToNextStep()
            }
            else {
                // move up the parent chain
                var path = taskPath!
                while path.parentPath != nil {
                    path = path.parentPath!
                }
                self.taskPath = path
                self.taskPath.didExitEarly = shouldExit
                if !taskPath.isCompleted {
                    _handleTaskReady(with: taskPath)
                }
                handleTaskCompleted()
            }
            return
        }
        
        _moveToNextStepPart2(previousStep: previousStep, step: step, isTaskComplete: isTaskComplete)
    }
    
    private func _moveToNextStepPart2(previousStep: RSDStep?, step: RSDStep, isTaskComplete: Bool, hasPreviousEarlyExit: Bool = false) {
        
        // Set the new current step
        let isFirstTaskStep = self.taskPath.currentStep == nil && self.taskPath.parentPath == nil
        let isFirstSubtaskStep = self.taskPath.currentStep == nil
        
        if !hasPreviousEarlyExit, let asyncActions = _asyncActionsToStart(at: step, isFirstStep: isFirstSubtaskStep) {
            // If there are action controllers to start then do that before continuing
            // and call this method again after they have been started. Use the hasPreviousEarlyExit
            // flag to indicate that this is the second go-around and don't check the controllers the
            // second time.
            self.startAsyncActions(with: asyncActions) { [weak self] in
                DispatchQueue.main.async {
                    self?._moveToNextStepPart2(previousStep: previousStep, step: step, isTaskComplete: isTaskComplete, hasPreviousEarlyExit: true)
                }
            }
            return
        }
        
        self.taskPath.currentStep = step
        
        if let subtaskStep = step as? RSDTaskInfoStep, shouldFetchSubtask(for: subtaskStep) {
            // If this is a subtask step, then update the task path and fetch the subtask
            self.taskPath = RSDTaskPath(taskInfo: subtaskStep, parentPath: self.taskPath)
            _fetchTaskFromCurrentInfo()
        }
        else if let sectionStep = step as? RSDSectionStep, shouldPageSectionSteps(for: sectionStep) {
            self.taskPath = RSDTaskPath(task: sectionStep, parentPath: self.taskPath)
            _moveToNextStep()
        }
        else {
            // If not a subtask (or if this implementation handles subtasks using custom logic)
            // then update the path and navigate forward.
            let direction: RSDStepDirection = isFirstTaskStep ? .none : .forward
            if isTaskComplete {
                // If this is a completion step and the user cannot go back and change previous answers,
                // then do *not* use it to mark the end of the task. Instead, mark *now* as the end date.
                _handleTaskReady(with: self.taskPath)
            }
            _move(to: step, from: previousStep, direction: direction)
        }
    }
    
    private func _handleTaskReady(with taskPath: RSDTaskPath) {
        // Mark the task end date and isCompleted
        taskPath.result.endDate = Date()
        taskPath.isCompleted = true
        if taskPath.parentPath == nil {
            // ONLY send the message to save the results if this is the end of the task
            self.handleTaskResultReady(with: taskPath.copy() as! RSDTaskPath)
        }
    }
    
    private func _moveToPreviousStep() {
        guard let previousStep = taskPath.currentStep,
            let step = taskPath.task!.stepNavigator.step(before: previousStep, with: &taskPath.result)
            else {
                if let parent = taskPath.parentPath {
                    // If the parent path is non-nil then go back up to the parent
                    self.taskPath = parent
                    _moveToPreviousStep()
                }
                return
        }
        self.taskPath.isCompleted = false
        self.taskPath.removeStepHistory(from: previousStep.identifier)
        self.taskPath.currentStep = step
        _move(to: step, from: previousStep, direction: .reverse)
    }
    
    private func _move(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection) {
        for controller in self.currentAsyncControllers {
            // let any controllers know that the step has changed
            controller.moveTo(step: step, taskPath: self.taskPath)
        }
        let stepResult = step.instantiateStepResult()
        self.taskPath.appendStepHistory(with: stepResult)
        self.navigate(to: step, from: previousStep, direction: direction)
        self.hideLoadingIfNeeded()
    }
    
    private func _asyncActionsToStart(at step: RSDStep, isFirstStep: Bool) -> [RSDAsyncActionConfiguration]? {
        guard let asyncActions = self.taskPath.task?.asyncActionsToStart(at: step, isFirstStep: isFirstStep), asyncActions.count > 0
            else {
                return nil
        }
        let current = self.currentAsyncControllers.map { $0.configuration.identifier }
        let configs = asyncActions.filter { !current.contains($0.identifier) }
        return configs.count > 0 ? configs : nil
    }
    
    private func _asyncActionsToStop(after step: RSDStep?, isTaskComplete: Bool) -> [RSDAsyncActionController]? {
        guard let task = self.taskPath.task else { return nil }
        var asyncActions = task.asyncActionsToStop(after: step)
        if isTaskComplete, step != nil {
            asyncActions.append(contentsOf: task.asyncActionsToStop(after: nil))
        }
        guard asyncActions.count > 0 else {
            return nil
        }
        let identifiers = asyncActions.map { $0.identifier }
        let controllers = self.currentAsyncControllers.filter {
            identifiers.contains($0.configuration.identifier) && $0.isRunning
        }
        return controllers.count > 0 ? controllers : nil
    }
}

