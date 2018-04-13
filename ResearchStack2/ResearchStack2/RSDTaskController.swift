//
//  RSDTaskController.swift
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

/// The direction of navigation for the steps.
public enum RSDStepDirection : Int {
    /// go back
    case reverse = -1
    /// initial step
    case none = 0
    /// go forward
    case forward = 1
}

// The `RSDTaskFinishReason` value indicates why the task controller has finished the task.
public enum RSDTaskFinishReason : Int {
    /// The task was canceled by the participant or the developer, and the participant asked to save the current result.
    case saved
    /// The task was canceled by the participant or the developer, and the participant asked to discard the current result.
    case discarded
    /// The task has completed successfully, because all steps have been completed.
    case completed
    /// An error was detected during the current step.
    case failed
    /// For a task with navigation, the participant or the developer elected to exit the task early.
    case earlyExit
}

/// `RSDTaskController` handles a base-level implementation for running a task. This object is expected to
/// be an appropriate instance of a view controller, depending upon the operating system.
public protocol RSDTaskController : class, NSObjectProtocol {
    
    /// A path object used to track the current state of a running task.
    var taskPath: RSDTaskPath! { get set }

    /// Can this task go forward? If forward navigation is disabled, then the task isn't waiting for a result
    /// or a task fetch to enable forward navigation.
    var isForwardEnabled: Bool { get }
    
    /// Is there a next step or is this the last step in the task?
    var hasStepAfter: Bool { get }
    
    /// Is there previous step that this task can go back to?
    var hasStepBefore: Bool { get }
    
    /// Go forward to the next step.
    func goForward()
    
    /// Go back to the previous step.
    func goBack()
    
    /// Can the task progress be saved? This should only return `true` if the task result can be saved and
    /// the current progress can be restored.
    var canSaveTaskProgress: Bool { get }
    
    /// The user has tapped the cancel button.
    /// - parameter shouldSave: Should the task progress be saved (if applicable).
    func handleTaskCancelled(shouldSave: Bool)
}

extension RSDTaskController {
    
    /// Convenience method for accessing the task path.
    public var taskResult: RSDTaskResult! {
        return self.taskPath?.result
    }
}

/// `RSDTaskControllerDelegate` is responsible for processing the results of the task, providing some input into
/// how the controller behaves, and providing additional content as needed. It's primary purpose is to handle
/// processing the results of running the task.
public protocol RSDTaskControllerDelegate : class, NSObjectProtocol {
    
    /// Tells the delegate that the task has finished.
    ///
    /// The task controller should call this method when an unrecoverable error occurs, when the user has
    /// canceled the task (with or without saving), or when the user completes the last step in the task.
    ///
    /// In most circumstances, the receiver should dismiss the task view controller in response to this
    /// method, and may also need to collect and process the results of the task.
    ///
    /// - parameters:
    ///     - taskController:   The `RSDTaskUIController` instance that is returning the result.
    ///     - reason:           An `RSDTaskFinishReason` value indicating how the user chose to complete the task.
    ///     - error:            If failure occurred, an `NSError` object indicating the reason for the failure.
    ///                         The value of this parameter is `nil` if `reason` does not indicate failure.
    func taskController(_ taskController: RSDTaskController, didFinishWith reason: RSDTaskFinishReason, error: Error?)
    
    /// Tells the delegate that the task is ready to save.
    ///
    /// The task controller should call this method when the task has completed all steps that add
    /// information to the result set. This may be called on the last step *or* prior to the last step if
    /// that step is a completion step or else a step used to display the results of a task. This allows the
    /// developers to mark the end timestamp for when a task ended rather than for when the participant
    /// dismissed the task.
    ///
    /// - parameters:
    ///     - taskController:   The `RSDTaskController` instance that is returning the result.
    ///     - taskPath:         The task path with the results for this task run.
    func taskController(_ taskController: RSDTaskController, readyToSave taskPath: RSDTaskPath)
    
    /// Requests the `RSDAsyncActionController` for a given `RSDAsyncActionConfiguration`.
    ///
    /// The task controller should call this method when the task controller determines that an async action
    /// should be started. If this method returns `nil` then the task controller should check if the
    /// `configuration` conforms to the `RSDAsyncActionControllerVendor` protocol and vend the controller
    /// returned by the `instantiateController()` method if applicable.
    ///
    /// - parameters:
    ///     - taskController:   The `RSDTaskController` instance that is returning the result.
    ///     - configuration:    The `RSDAsyncActionConfiguration` to be started.
    /// - returns: An `RSDAsyncActionController` if available.
    func taskController(_ taskController: RSDTaskController, asyncActionControllerFor configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController?
}

/// `RSDTaskUIController` handles default implementations for running a task.
///
/// To start a task, create an instance of a view controller that conforms to this protocol
/// and set either the `topLevelTask` or the `topLevelTaskInfo`.
public protocol RSDTaskUIController : RSDTaskController {
    
    /// Optional factory subclass that can be used to vend custom steps that are decoded
    /// from a plist or json.
    var factory: RSDFactory? { get }
    
    /// Returns the currently active step controller (if any).
    var currentStepController: RSDStepController? { get }
    
    /// Returns a list of the async action controllers that are currently active. This includes controllers
    /// that are requesting permissions, starting, running, *and* stopping.
    var currentAsyncControllers: [RSDAsyncActionController] { get }
    
    /// Should the protocol extension fetch the subtask from a task info object or does this
    /// implementation handle subtask step navigation using custom logic?
    /// - parameter step: The `RSDTaskStep` for which to fetch the task.
    /// - returns: `true` if the task should be fetched using the protocol extension.
    func shouldFetchSubtask(for step: RSDTaskInfoStep) -> Bool
    
    /// Should the protocol extension vend the steps in a section using paging to move to the next
    /// step or does this implementation handle section steps using custom logic?
    /// - parameter step: The `RSDSectionStep` for which show the paged steps.
    /// - returns: `true` if the protocol extension should handle paging the steps.
    func shouldPageSectionSteps(for step: RSDSectionStep) -> Bool
    
    /// Show a loading state while fetching the given task from the task info.
    /// - parameter taskInfo: The task info for the task being fetched.
    func showLoading(for taskInfo: RSDTaskInfoStep)
    
    /// Fired when the task controller is ready to go forward. This method must invoke the `goForward()`
    /// method either to go forward automatically or else go forward after a user action.
    func handleFinishedLoading()
    
    /// Hide the loading state if currently showing it.
    func hideLoadingIfNeeded()
    
    /// Navigate to the next step from the previous step in the given direction.
    ///
    /// - parameters:
    ///     - step: The step to show.
    ///     - previousStep: The previous step. This is either the step currently being displayed or
    ///                     else the `RSDSectionStep` or `RSDTaskStep` if the previous step was the
    ///                     last step in a paged section or fetched subtask.
    ///     - direction: The direction in which to show the animation change.
    ///     - completion: The completion to call once the navigation animation has completed.
    func navigate(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?)
    
    /// Failed to fetch the task from the current task path. Handle the error. A retry can be fired
    /// by calling `goForward()`.
    /// - parameter error:   The error returned by the failed task fetch.
    func handleTaskFailure(with error: Error)

    /// The task has completed, either as a result of all the steps being completed or because of an
    /// early exit.
    func handleTaskCompleted()
    
    /// This method is called when a task result is "ready" for upload, save, archive, etc. This method
    /// will be called when either (a) the task is ready to dismiss or (b) when the task is displaying
    /// the *last* completion step.
    func handleTaskResultReady(with taskPath: RSDTaskPath)
    
    /// Add async action controllers to the shared queue for the given configuations. It is up to the task
    /// controller to decide how to create the controllers and how to manage adding them to the
    /// `currentStepController` array.
    ///
    /// The async actions should *not* be started. Instead they should be returned with `idle` status.
    ///
    /// - note: If creating the recorder might take time, the task controller should move creation to a
    /// background thread so that the main thread is not blocked.
    ///
    /// - parameters:
    ///     - configurations: The configurations to start.
    ///     - completion: The completion to call with the instantiated controllers.
    func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (([RSDAsyncActionController]) -> Void))
    
    /// Start the async action controllers. The protocol extension calls this method when an async action
    /// should be started directly *after* the step is presented.
    ///
    /// The task controller needs to handle blocking any navigation changes until the async controllers are
    /// ready to proceed. Otherwise, the modal popup alert can be swallowed by the step change.
    ///
    func startAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void))
    
    /// Stop the async action controllers. The protocol extension does not directly implement stopping the
    /// async actions to allow customization of how the results are added to the task and whether or not
    /// forward navigation should be blocked until the completion handler is called. When the stop action
    /// is called, the view controller needs to handle stopping the controllers, adding the results, and
    /// showing a loading state until ready to move forward in the task navigation.
    func stopAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void))
}

extension RSDTaskUIController {
    
    /// The output directory used for any file results.
    public var outputDirectory: URL? {
        return self.topLevelTaskPath.outputDirectory
    }
    
    /// Convenience method for getting/setting the main entry point for the task controller via the task info.
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
    
    /// Convenience property for getting/setting the main entry point for the task controller via the task.
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
    
    /// Convenience property for getting the result for this task.
    public var taskResult : RSDTaskResult! {
        return topLevelTaskPath?.result
    }
    
    /// Convenience property for getting the top level task path.
    public var topLevelTaskPath : RSDTaskPath! {
        var taskPath = self.taskPath
        while taskPath?.parentPath != nil {
            taskPath = taskPath!.parentPath!
        }
        return taskPath
    }
    
    /// Start the task if it is not currently loaded with a task or first step.
    public func startTaskIfNeeded() {
        guard !self.taskPath.isLoading else { return }
        if taskPath.task == nil {
            _fetchTaskFromCurrentInfo()
        }
        else if taskPath.currentStep == nil {
            _moveToNextStep()
        }
    }
    
    /// Can this task go forward? If forward navigation is disabled, then the task isn't waiting for a result or a
    /// task fetch to enable forward navigation.
    public var isForwardEnabled: Bool {
        return self.taskPath.task != nil
    }
    
    /// Is there a next step or is this the last step in the task?
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
    
    /// Is there previous step that this task can go back to?
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
    
    /// Go forward to the next step. If the task is not loaded for the current point in the task path, then
    /// it will attempt to fetch it again.
    ///
    /// - note: This method will throw an assertion if it is called without first checking that the current
    /// task can navigate forward.
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
    
    /// Go back to the previous step.
    ///
    /// - note: This method will throw an assertion if there isn't a previous step.
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
    
    // Mark: private methods for navigating between steps
    
    private func _moveToNextStep() {
        
        // Check if the current step is nil, if so, then validate the task
        if taskPath.currentStep == nil {
            do {
                try taskPath.task!.validate()
            } catch let error {
                self.handleTaskFailure(with: error)
                return
            }
        }
        
        // store the previous step and get the next step
        let previousStep = taskPath.currentStep
        let navigation = taskPath.task!.stepNavigator.step(after: previousStep, with: &taskPath.result)

        // save the previous step and look for a next step
        guard let step = navigation?.step else {
            _finishStoppingTaskPart1(previousStep: previousStep)
            return
        }
        
        // if navigation should be in reverse, move back and EXIT.
        if navigation?.direction == .reverse, previousStep != nil {
            _moveBack(to: step, from: previousStep!)
            return
        }
        
        let isFirstSubtaskStep = self.taskPath.currentStep == nil
        if let asyncActions = _asyncActionsToStart(at: step, isFirstStep: isFirstSubtaskStep) {
            // If there are action controllers to start then add them to the queue and get controllers
            // before transitioning to the next step. 
            self.addAsyncActions(with: asyncActions, completion: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?._moveToNextStepPart2(previousStep: previousStep, step: step)
                }
            })
            return
        }
        
        _moveToNextStepPart2(previousStep: previousStep, step: step)
    }
    
    private func _moveToNextStepPart2(previousStep: RSDStep?, step: RSDStep) {
        
        if let subtaskStep = step as? RSDTaskInfoStep, shouldFetchSubtask(for: subtaskStep) {
            // If this is a subtask step, then update the task path and fetch the subtask
            self.taskPath.currentStep = step
            self.taskPath = RSDTaskPath(taskInfo: subtaskStep, parentPath: self.taskPath)
            _fetchTaskFromCurrentInfo()
        }
        else if let sectionStep = step as? RSDSectionStep, shouldPageSectionSteps(for: sectionStep) {
            // If this is a section step, then update the task path and move to the first step in that section
            self.taskPath.currentStep = step
            self.taskPath = RSDTaskPath(task: sectionStep, parentPath: self.taskPath)
            _moveToNextStep()
        }
        else {
            // If not a subtask (or if this implementation handles subtasks using custom logic)
            // then update the path and navigate forward.
            let isFirstTaskStep = self.taskPath.currentStep == nil && self.taskPath.parentPath == nil
            let direction: RSDStepDirection = isFirstTaskStep ? .none : .forward
            _move(to: step, from: previousStep, direction: direction)
        }
    }
    
    private func _moveToPreviousStep() {
        guard let currentStep = taskPath.currentStep,
            let step = taskPath.task!.stepNavigator.step(before: currentStep, with: &taskPath.result)
            else {
                if let parent = taskPath.parentPath {
                    // If the parent path is non-nil then go back up to the parent
                    self.taskPath = parent
                    _moveToPreviousStep()
                }
                return
        }
        _moveBack(to: step, from: currentStep)
    }
    
    private func _moveBack(to step: RSDStep, from currentStep: RSDStep) {

        // This is a subtask step if it is either a task info step or a section step and the
        // task controller is setup to page those steps.
        var isSubtask = false
        if let subtaskStep = step as? RSDTaskInfoStep, shouldFetchSubtask(for: subtaskStep) {
            isSubtask = true
        } else if let sectionStep = step as? RSDSectionStep, shouldPageSectionSteps(for: sectionStep) {
            isSubtask = true
        }
        
        // remove the step from the step history for this path segment
        self.taskPath.removeStepHistory(from: step.identifier)
        
        // Check if this is a subtask and go back within the subtask
        if isSubtask, let childPath = self.taskPath.childPaths[step.identifier] {
            if let lastStep = childPath.currentStep {
                self.taskPath.currentStep = step
                self.taskPath = childPath
                _moveBack(to: lastStep, from: currentStep)
            } else if let lastStep = taskPath.task!.stepNavigator.step(before: step, with: &taskPath.result) {
                _moveBack(to: lastStep, from: currentStep)
            } else {
                assertionFailure("Trying to move back to nil step.")
            }
        } else {
            _move(to: step, from: currentStep, direction: .reverse)
        }
    }
    
    private func _move(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection) {
        
        self.taskPath.currentStep = step
        let stepResult = step.instantiateStepResult()
        self.taskPath.appendStepHistory(with: stepResult)
        self.navigate(to: step, from: previousStep, direction: direction) { [weak self] (finished) in
            self?._finishMoving(to: step, from: previousStep, direction: direction)
        }
        
        self.hideLoadingIfNeeded()
    }
    
    private func _finishMoving(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection) {
        guard direction != .reverse else {
            _notifyAsyncControllers(to: step, excludingControllers:[])
            return
        }
        
        // Get which controllers should be stopped
        let isTaskComplete = (step.stepType == .completion) && !taskPath.task!.stepNavigator.hasStep(after: step, with: taskPath.result)
        let path = self.taskPath!
        var excludedControllers: [RSDAsyncActionController] = []
        var controllersToStop: [RSDAsyncActionController]?
        if let stopStep = previousStep, let controllers = _asyncActionsToStop(after: stopStep, taskPath: path, isTaskComplete: isTaskComplete) {
            controllersToStop = controllers
            excludedControllers.append(contentsOf: controllers)
        }
        
        // Notify the controllers that the task has moved to the given step and start the idle controllers.
        excludedControllers.append(contentsOf: _startIdleAsyncControllers(excludingControllers: excludedControllers))
        _notifyAsyncControllers(to: step, excludingControllers: excludedControllers)
        
        // Ready to save if this is the completion step and there isn't a back button.
        let hasStepBefore = (self.currentStepController?.hasStepBefore ?? self.hasStepBefore)
        let readyToSave = isTaskComplete && !hasStepBefore
        
        // stop the controllers that should be stopped at this point
        if let controllers = controllersToStop {
            self.stopAsyncActions(for: controllers, showLoading: false, completion: { [weak self] in
                if readyToSave  {
                    // If this is a completion step and the user cannot go back and change previous answers,
                    // then do *not* use it to mark the end of the task. Instead, mark *now* as the end date.
                    self?._handleTaskReady(with: path)
                }
            })
        } else if readyToSave {
            self._handleTaskReady(with: path)
        }
    }
    
    private func _notifyAsyncControllers(to step: RSDStep, excludingControllers: [RSDAsyncActionController]) {
        let controllers = self.currentAsyncControllers.filter { (lhs) -> Bool in
            return (lhs.status <= .running) && !excludingControllers.contains(where: { $0.isEqual(lhs) })
        }
        for controller in controllers {
            // let any controllers know that the step has changed
            controller.moveTo(step: step, taskPath: self.taskPath)
        }
    }
    
    private func _startIdleAsyncControllers(excludingControllers: [RSDAsyncActionController]) -> [RSDAsyncActionController] {
        let controllers = self.currentAsyncControllers.filter { (lhs) -> Bool in
            return (lhs.status == .idle) && !excludingControllers.contains(where: { $0.isEqual(lhs) })
        }
        guard controllers.count > 0 else { return [] }
        self.startAsyncActions(for: controllers, showLoading: false) {
            // Do nothing
        }
        return controllers
    }
    
    // Mark: Private methods for finishing a task.
    
    private func _finishStoppingTaskPart1(previousStep: RSDStep?) {
        
        let shouldExit = taskPath.task!.stepNavigator.shouldExit(after: previousStep, with: taskPath.result)
        
        // Look to see if there is a task path parent to go up to
        if !shouldExit, let parent = taskPath.parentPath {
            _moveUpThePath(from: previousStep, to: parent)
        }
        else {
            // move up the parent chain if we aren't already there
            var path = taskPath!
            while path.parentPath != nil {
                path = path.parentPath!
            }
            self.taskPath = path
            self.taskPath.didExitEarly = shouldExit
            
            // look to see if there are any controllers that need to be stopped due to an early exit.
            let controllers = self.currentAsyncControllers.filter() { $0.status <= .running }
            if controllers.count > 0 {
                self.stopAsyncActions(for: controllers, showLoading: true, completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?._finishStoppingTaskPart2()
                    }
                })
            } else {
                _finishStoppingTaskPart2()
            }
        }
    }
    
    private func _moveUpThePath(from previousStep: RSDStep?, to parent: RSDTaskPath, hasPreviousEarlyExit: Bool = false) {
        
        if !hasPreviousEarlyExit, let stopStep = previousStep,
            let controllers = _asyncActionsToStop(after: stopStep, taskPath: taskPath, isTaskComplete: true) {
            // If there are action controllers to stop and this is the last step then do that before continuing
            // and call this method again after they have been stopped. Use the hasPreviousEarlyExit
            // flag to indicate that this is the second go-around and don't check the controllers the
            // second time in case the called task controller returns before all the async controllers
            // have been removed from the queue.
            self.stopAsyncActions(for: controllers, showLoading: true, completion: { [weak self] in
                DispatchQueue.main.async {
                    self?._moveUpThePath(from: previousStep, to: parent, hasPreviousEarlyExit: true)
                }
            })
            return
        }
        
        // Mark the task as complete
        _handleTaskReady(with: taskPath)
        
        // If the parent path is non-nil then go back up to the parent
        parent.appendStepHistory(with: taskPath.result)
        self.taskPath = parent
        _moveToNextStep()
    }
    
    private func _finishStoppingTaskPart2() {
        _handleTaskReady(with: taskPath)
        handleTaskCompleted()
    }
    
    private func _handleTaskReady(with taskPath: RSDTaskPath) {
        guard !taskPath.isCompleted else { return }
        // Mark the task end date and isCompleted
        taskPath.result.endDate = Date()
        taskPath.isCompleted = true
        if taskPath.parentPath == nil {
            // ONLY send the message to save the results if this is the end of the task
            self.handleTaskResultReady(with: taskPath.copy() as! RSDTaskPath)
        }
    }
    
    // MARK: private methods for handling async actions
    
    private func _asyncActionsToStart(at step: RSDStep, isFirstStep: Bool) -> [RSDAsyncActionConfiguration]? {
        guard let asyncActions = self.taskPath.task?.asyncActionsToStart(at: step, isFirstStep: isFirstStep), asyncActions.count > 0
            else {
                return nil
        }
        let current = self.currentAsyncControllers.map { $0.configuration.identifier }
        let configs = asyncActions.filter { !current.contains($0.identifier) }
        
        return configs.count > 0 ? configs : nil
    }
    
    private func _asyncActionsToStop(after step: RSDStep?, taskPath: RSDTaskPath, isTaskComplete: Bool) -> [RSDAsyncActionController]? {
        let controllers = self.currentAsyncControllers.filter { (controller) -> Bool in
            // Verify that the controller is running
            guard controller.status <= .running else { return false }
            
            // verify that the controller task path is either the input path *or* a child of the current path.
            let path = controller.taskPath.fullPath
            guard path == taskPath.fullPath || taskPath.childPaths.contains(where: { $0.value.fullPath == path})
                else {
                    return false
            }
            
            // If this is a recorder and the stop step matches then it should be stopped.
            if let recorderConfig = controller.configuration as? RSDRecorderConfiguration,
                step?.identifier == recorderConfig.stopStepIdentifier {
                return true
            }
            
            // Otherwise, should be stopped only if this is the end of this task path
            return isTaskComplete
        }
                
        // Return nil if the filtered count == 0
        return controllers.count > 0 ? controllers : nil
    }
}

