//
//  RSDTaskViewModel.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

/// `RSDTaskPath` has been renamed as `RSDTaskViewModel`.
@available(*,deprecated)
public final class RSDTaskPath : RSDTaskViewModel {
}

/// The TaskViewModel is a base class implementation of the presentation layer for managing a task. It uses
/// the [Model–view–viewmodel (MVVM)](https://en.wikipedia.org/wiki/Model–view–viewmodel) design pattern to
/// separate out the UX functionality of running a task for a given device category from the UI and from the
/// domain layer.
///
/// This class is used to keep track of the current state of a running task. Conceptually, it is a similar
/// pattern to using a separate device-agnostic "DataSource" class to handle UX that is independent of the
/// operating system and which can be used by either a `UIViewController` on iOS and tvOS or a `WKInterface`
/// on watchOS.
///
/// The naming convention used is intended to ease cross-platform development with an Android app since on
/// that platform, there are significant advantages to using a Fragment-ViewModel architecture where the
/// base class is a `ViewModel` rather than an `NSObject`. The implementation details of this class and the
/// method names will differ from the Android architecture to fit the design patterns which are more common
/// to Swift and Obj-c development.
///
/// - seealso: `RSDTaskController`
open class RSDTaskViewModel : RSDTaskState, RSDTaskPathComponent {
        
    /// A unique identifier for this path component.
    open private(set) var identifier: String
    
    /// The task info object used to load the task.
    public private(set) var taskInfo: RSDTaskInfo?
    
    /// The task that is currently being run.
    public private(set) var task: RSDTask?
    
    /// A weak pointer to the task controller.
    public var taskController : RSDTaskController? {
        get {
            return self.rootPathComponent._taskController
        }
        set {
            self.rootPathComponent._taskController = newValue
        }
    }
    weak private var _taskController : RSDTaskController?
    
    /// The description of the path.
    override open var description: String {
        return "\(type(of: self)): \(fullPath) steps: [\(stepPath)]"
    }
    
    
    // MARK: Lifecycle
    
    /// Initialize the task path with a task.
    /// - parameters:
    ///     - task: The task to set for this path segment.
    ///     - parentPath: A pointer to the parent task path.
    public init(task: RSDTask, parentPath: RSDPathComponent? = nil) {
        self.identifier = task.identifier
        self.task = task
        let taskResult = task.instantiateTaskResult()
        super.init(taskResult: taskResult)
        commonInit(identifier: task.identifier, parentPath: parentPath)
    }
    
    /// Initialize the task path with a task.
    /// - parameters:
    ///     - taskInfo: The task info to set for this path segment.
    ///     - parentPath: A pointer to the parent task path.
    public init(taskInfo: RSDTaskInfo, parentPath: RSDPathComponent? = nil) {
        self.identifier = taskInfo.identifier
        self.taskInfo = taskInfo
        let taskResult = RSDTaskResultObject(identifier: taskInfo.identifier)  // Create a temporary result
        super.init(taskResult: taskResult)
        commonInit(identifier: taskInfo.identifier, parentPath: parentPath)
    }
        
    private func commonInit(identifier: String, parentPath: RSDPathComponent?) {
        self.parent = parentPath
        guard let parent = parentPath else { return }
        self.previousResults = (parent.taskResult.stepHistory.last(where: { $0.identifier == identifier }) as? RSDTaskResult)?.stepHistory
        self.taskResult.taskRunUUID = parent.taskResult.taskRunUUID
    }
    
        
    // MARK: RSDPathComponent implementation
    
    /// The current child that this component is pointing to.
    public var currentChild: RSDNodePathComponent?
    
    /// The parent path component. If nil, this is the top-level path component.
    weak public internal(set) var parent: RSDPathComponent?
    
    /// Convenience method for accessing the current step.
    open var currentStep: RSDStep? {
        return self.currentChild?.step
    }
    
    /// Can this task go forward? If forward navigation is enabled, then the task isn't waiting for a result
    /// or a task fetch to enable forward navigation.
    open var isForwardEnabled: Bool {
        return self.task != nil
    }
    
    /// Can the path navigate backward up the chain?
    open var canNavigateBackward: Bool {
        return self.currentChild?.canNavigateBackward ?? false
    }
    
    /// File URL for the directory in which to store generated data files. Asynchronous actions with
    /// recorders (and potentially steps) can save data to files during the progress of the task.
    /// This property specifies where such data should be written.
    ///
    /// If no output directory is specified, this property will use lazy initialization to create a
    /// directory in the `NSTemporaryDirectory()` with a subpath of the `taskRunUUID` and the current
    /// date.
    ///
    /// In general, set this property after instantiating the task view controller and before
    /// presenting it in order to override the default location.
    ///
    /// Before presenting the view controller, set the `outputDirectory` property to specify a
    /// path where files should be written when an `ORKFileResult` object must be returned for
    /// a step.
    ///
    /// - note: The calling application is responsible for deleting this directory once the files
    /// are processed by encrypting them locally. The encrypted files can then be stored for upload
    /// to a server or cloud service. These files are **not** encrypted so depending upon the
    /// application, there is a risk of exposing PII data stored in these files.
    open var outputDirectory: URL! {
        get {
            guard parent == nil
                else {
                    return parent!.outputDirectory
            }
            if _outputDirectory == nil {
                _outputDirectory = createOutputDirectory()
            }
            return _outputDirectory
        }
        set {
            _outputDirectory = newValue
        }
    }
    private var _outputDirectory: URL!
    
    /// The result to use to mark the step history for this path component.
    open func pathResult() -> RSDResult {
        return self.taskResult
    }
    
    /// Perform the appropriate action.
    open func perform(actionType: RSDUIActionType) {
        switch actionType {
        case .navigation(.goForward):
            self.goForward()
        case .navigation(.goBackward):
            self.goBack()
        case .navigation(.cancel):
            self.cancel()
        default:
            debugPrint("WARNING! \(actionType) not handled")
        }
    }
    
    
    // MARK: Path navigation
    
    /// Should the step view controller confirm the cancel action? By default, this will return `false` if
    /// this is the first step in the task. Otherwise, this method will return `true`.
    /// - returns: Whether or not to confirm the cancel action.
    open func shouldConfirmCancel() -> Bool {
        return !self.isFirstStep
    }
    
    /// Can the task progress be saved? This should only return `true` if the task result can be saved and
    /// the current progress can be restored.
    open func canSaveTaskProgress() -> Bool {
        return false
    }
    
    /// This is a flag that can be used to mark whether or not the task is ready to be saved.
    open internal(set) var isCompleted: Bool = false
    
    /// This is a flag that can be used to mark whether or not the task exited early.
    open internal(set) var didExitEarly: Bool = false
    
    /// Is there a next step or is this the last step in the task?
    public var hasStepAfter: Bool {
        guard task != nil else {
            // If the task is still fetching, then this is assumed to return with a task until the loading returns
            return self.isLoading
        }
        
        // While this is the last step, look up the path chain for a task that has not reached the end
        var path: RSDPathComponent? = self
        while let nextPath = path {
            if let taskPath = path as? RSDTaskPathComponent,
                let task = taskPath.task,
                let thisStep = taskPath.currentChild?.step,
                task.stepNavigator.hasStep(after: thisStep, with: nextPath.taskResult) {
                // If the current task path has more steps then this is not the end
                return true
            }
            path = nextPath.parent
        }
        
        // Otherwise, this is the last step
        return false
    }
    
    /// Is there previous step that this task can go back to?
    public var hasStepBefore: Bool {
        // Exit early if this is the first step. There is no back button.
        if self.currentStep == nil && self.parent == nil {
            return false
        }
        
        // While this is the first step, look up the path chain for a task that has not reached the end
        var path: RSDPathComponent? = self
        while let nextPath = path {
            if let taskPath = path as? RSDTaskPathComponent,
                let task = taskPath.task,
                let thisStep = taskPath.currentChild?.step,
                task.stepNavigator.hasStep(before: thisStep, with: nextPath.taskResult) {
                // If the current task path has more steps then this is not the end
                return true
            }
            path = nextPath.parent
        }
        
        // Otherwise, this is the last step
        return false
    }
    
    /// Go forward to the next step. If the task is not loaded for the current point in the task path, then
    /// it will attempt to fetch it again.
    open func goForward() {
        guard let viewModel = self.currentTaskPath as? RSDTaskViewModel, viewModel == self
            else {
                self.currentTaskPath.moveForwardToNextStep()
                return
        }
        _goForward()
    }
    
    private func _goForward() {
        
        guard self.task != nil else {
            _fetchTaskFromCurrentInfo()
            return
        }
        
        // Add or update the result end date if there was previous step
        if let previousStep = self.currentChild {
            if let result = self.taskResult.stepHistory.last, result.identifier == previousStep.identifier {
                var finalResult = result
                finalResult.endDate = Date()
                self.taskResult.appendStepHistory(with: finalResult)
            }
            else {
                let result = previousStep.pathResult()
                self.taskResult.appendStepHistory(with: result)
            }
        }
        
        // move to the next step
        _moveToNextStep()
    }
    
    /// Go back to the previous step.
    open func goBack() {
        // If calling `goBack()` from the `taskViewController.taskViewModel`, that node is always the root
        // node, and may not be the node that is currently being navigated.
        guard let viewModel = self.currentTaskPath as? RSDTaskViewModel, viewModel == self
            else {
                self.currentTaskPath.moveBackToPreviousStep()
                return
        }
        
        // move to the previous step
        _moveToPreviousStep()
    }
    
    /// Call through to the task controller to handle the task finished with a reason of `.cancelled`.
    open func cancel(shouldSave: Bool = false) {
        let reason: RSDTaskFinishReason = shouldSave ? .saved : .discarded
        self.taskController?.handleTaskDidFinish(with: reason, error: nil)
    }
    
    /// Start the task if it is not currently loaded with a task or first step.
    open func startTaskIfNeeded() {
        guard !self.isLoading else { return }
        if self.task == nil {
            _fetchTaskFromCurrentInfo()
        }
        else if self.currentStep == nil {
            _moveToNextStep()
        }
    }
    
    /// For the given step, returns the next path component and step controller (if applicable) for this step.
    /// The base class implementation will return an `RSDTaskStepNode` for either a subtask step or a section
    /// step. For all other steps, it will request a step controller for the step from the task controller and
    /// return both the step controller and the loaded step view model as the `node`.
    open func pathComponent(for step: RSDStep) -> (node: RSDNodePathComponent, stepController: RSDStepController?)? {
        if let node = self.instantiateTaskStepNode(for: step) {
            return (node, nil)
        }
        else if let stepController = self.loadStepController(for: step) {
            return (stepController.stepViewModel, stepController)
        }
        else {
            debugPrint("No view controller loaded for \(step)")
            return nil
        }
    }
    
    /// Overridable factory method for returning a "hidden" task step node to use in subtask navigation.
    open func instantiateTaskStepNode(for step: RSDStep) -> RSDNodePathComponent? {
        if let subtaskStep = step as? RSDTaskInfoStep {
            return RSDTaskStepNode(taskInfoStep: subtaskStep, parentPath: self)
        }
        else if let sectionStep = step as? RSDSectionStep {
            return RSDTaskStepNode(sectionStep: sectionStep, parentPath: self)
        }
        else if let taskStep = step as? RSDSubtaskStep {
            return RSDTaskStepNode(step: taskStep, task: taskStep.task, parentPath: self)
        }
        else {
            return nil
        }
    }
    
    /// Overridable factory method for returning a step controller for a given step.
    open func loadStepController(for step: RSDStep) -> RSDStepController? {
        
        // Before loading the step controller, add a new instance of the step result to the step history to
        // indicate that the step was "visited" even if it was not displayed b/c the task controller didn't
        // return a step controller.
        if self.taskResult.findResult(for: step) == nil {
            let stepResult = step.instantiateStepResult()
            self.taskResult.appendStepHistory(with: stepResult)
        }

        guard let stepController = self.taskController?.stepController(for: step, with: self)
            else {
                return nil
        }
        guard let pathComponent = stepController.stepViewModel,
            let parentPath = pathComponent.parent as? RSDTaskViewModel, parentPath == self
            else {
                assertionFailure("Failed to set the parent path on the step controller.")
                return nil
        }
        return stepController
    }
    
    /// Return the path component for a previously visited node.
    open func previousPathComponent(for step: RSDStep) -> (RSDNodePathComponent, RSDStepController?)? {
        // If there is a stored child path for this step (b/c the path has already been loaded)
        // then return that.
        if ((step is RSDTaskInfoStep) || (step is RSDSectionStep)),
            let childPath = self.childPaths[step.identifier] {
            return (childPath, nil)
        }
        return self.pathComponent(for: step)
    }
    
    /// Move back in the navigation to the current step on this path component.
    open func moveBackToCurrentStep(from previousStep: RSDStep) {
        guard let step = self.currentStep else {
            (self.parent as? RSDTaskPathComponent)?.moveBackToPreviousStep()
            return
        }
        _moveBack(to: step, from: previousStep)
    }
    
    /// Move forward from this path subtask to the next step on the parent.
    open func moveForwardToNextStep() {
        _goForward()
    }
    
    /// Move back from this path subtask to the previous step on the parent.
    open func moveBackToPreviousStep() {
        _moveToPreviousStep()
    }
    
    
    // MARK: Task fetching
    
    /// Flag for tracking whether or not the `task` is loading from the `taskInfo`.
    public private(set) var isLoading: Bool = false
    
    /// The repository to use to load a task.
    lazy open var taskRepository: RSDTaskRepository = {
        if let root = self.rootPathComponent, root != self {
            return root.taskRepository
        }
        return RSDTaskRepository.shared
    }()
    
    /// Fetch the task associated with this path. This method loads the task and sets up the
    /// task result once finished.
    /// - parameters:
    ///     - factory: The factory to use to decode the task.
    ///     - completion: The callback handler to call when the task is loaded.
    public func fetchTask() {
        guard !self.isLoading && self.task == nil else {
            debugPrint("\(self.description): Already loading task.")
            return
        }
        guard let taskInfo = self.taskInfo else {
            fatalError("Cannot fetch a task with a nil task info.")
        }
        
        self.isLoading = true
        self.taskRepository.fetchTask(for: taskInfo) { [weak self] (_, task, error) in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if task != nil {
                strongSelf.task = task
                let previousResult = strongSelf.taskResult
                var taskResult = task!.instantiateTaskResult()
                if previousResult.asyncResults?.count ?? 0 > 0 {
                    var results = strongSelf.taskResult.asyncResults ?? []
                    results.append(contentsOf: previousResult.asyncResults!)
                    strongSelf.taskResult.asyncResults = results
                }
                taskResult.taskRunUUID = previousResult.taskRunUUID
                strongSelf.taskResult = taskResult
            }
            if let err = error {
                strongSelf.handleTaskFailure(with: err)
            }
            else {
                strongSelf.handleTaskLoaded()
            }
        }
    }
    
    /// Called when the task is successfully loaded.
    open func handleTaskLoaded() {
        guard let taskController = self.taskController else {
            assertionFailure("The base task view model is expecting a view controller. If none is provided, please use a subclass.")
            return
        }
        taskController.handleFinishedLoading()
    }
    
    /// Called when the task fails.
    open func handleTaskFailure(with error: Error) {
        guard let taskController = self.taskController else {
            assertionFailure("The base task view model is expecting a view controller. If none is provided, please use a subclass.")
            return
        }
        taskController.handleTaskFailure(with: error)
    }
    
    
    // MARK: Result management
    
    /// A pointer to the path sections visited.
    internal var childPaths: [String : RSDNodePathComponent] = [:]
    
    /// A listing of step results that were removed from the task result. These results can be accessed
    /// by a step view controller to load a result that was previously selected.
    public private(set) var previousResults: [RSDResult]?
    
    /// Get the previous result for the given step.
    open func previousResult(for step: RSDStep) -> RSDResult? {
        return self.previousResults?.last { $0.identifier == step.identifier }
    }
    
    /// Remove results from the step history from the result with the given identifier to the end of the
    /// array. Add these results to the previous results set.
    /// - parameter stepIdentifier:  The identifier of the result associated with the given step.
    func removeStepHistory(from stepIdentifier: String) {
        guard let results = taskResult.removeStepHistory(from: stepIdentifier) else { return }
        if self.previousResults == nil {
            self.previousResults = results
        }
        else {
            results.forEach { self.append(previousResult: $0) }
        }
    }
    
    /// Append the previous result set with the given result.
    open func append(previousResult: RSDResult) {
        guard self.previousResults != nil else {
            self.previousResults = [previousResult]
            return
        }
        if let idx = self.previousResults!.index(where: { $0.identifier == previousResult.identifier }) {
            self.previousResults!.remove(at: idx)
        }
        self.previousResults!.append(previousResult)
    }
    
    // MARK: Task Finalization - The methods included in this section should **not** be called until the task is finished.
    
    override open func cleanup(_ completion: (() -> Void)? = nil) {
        self.deleteOutputDirectory(completion)
    }
    
    /// Delete the output directory on the file management queue. Do *not* call this method until the
    /// files generated by this task have been copied to a new location, unless the results are being
    /// discarded.
    public func deleteOutputDirectory(_ completion:(() -> Void)? = nil) {
        fileManagementQueue.async {
            
            guard let outputDirectory = self._outputDirectory else { return }
            do {
                try FileManager.default.removeItem(at: outputDirectory)
            } catch let error {
                print("Error removing output directory: \(error.localizedDescription)")
                debugPrint("\tat: \(outputDirectory)")
            }
            completion?()
        }
    }

}

extension RSDTaskViewModel {

    private func _fetchTaskFromCurrentInfo() {
        guard !self.isLoading else {
            print("Already loading \(self)")
            return
        }
        guard let taskInfo = self.taskInfo else {
            fatalError("Cannot fetch a task with a nil task info.")
        }
        
        self.taskController?.showLoading(for: taskInfo)
        self.fetchTask()
    }
    
    private func _moveToNextStep() {
        guard let task = self.task else {
            assertionFailure("Attempting to go forward without a task loaded.")
            return
        }
        
        // Check if the current step is nil, if so, then validate the task
        if self.currentChild == nil {
            do {
                try task.validate()
            } catch let error {
                self.handleTaskFailure(with: error)
                return
            }
        }
        
        // store the previous step and get the next step
        _moveToNextStep(from: self.currentStep)
    }
    
    private func _moveToNextStep(from previousStep: RSDStep?) {
        guard let task = self.task else {
            assertionFailure("Attempting to go forward without a task loaded.")
            return
        }
        
        let navigation = task.stepNavigator.step(after: previousStep, with: &self.taskResult)
        
        // save the previous step and look for a next step
        guard let step = navigation.step else {
            _finishStoppingTaskPart1(previousStep: previousStep)
            return
        }
        
        // if navigation should be in reverse, move back and exit early.
        if navigation.direction == .reverse, previousStep != nil {
            _moveBack(to: step, from: previousStep!)
            return
        }
        
        let isFirstSubtaskStep = (self.currentStep == nil)
        if let asyncActions = _asyncActionsToStart(at: step, isFirstStep: isFirstSubtaskStep),
            let taskController = self.taskController {
            // If there are action controllers to start then add them to the queue and get controllers
            // before transitioning to the next step.
            taskController.addAsyncActions(with: asyncActions, path: self, completion: { [weak self] (_) in
                DispatchQueue.main.async {
                    self?._moveToNextStepPart2(previousStep: previousStep, step: step)
                }
            })
            return
        }
        
        _moveToNextStepPart2(previousStep: previousStep, step: step)
    }
    
    private func _moveToNextStepPart2(previousStep: RSDStep?, step: RSDStep) {
        guard let (nextPath, stepController) = self.pathComponent(for: step)
            else {
                // skip the step.
                _moveToNextStep(from: step)
                return
        }

        if let stepController = stepController {
            let isFirstTaskStep = (self.currentStep == nil && self.parent == nil)
            let direction: RSDStepDirection = isFirstTaskStep ? .none : .forward
            _move(to: stepController, from: previousStep, direction: direction)
        }
        else {
            self.currentChild = nextPath
            self.childPaths[nextPath.identifier] = nextPath
            nextPath.perform(actionType: .navigation(.goForward))
        }
    }
    
    private func _moveToPreviousStep() {
        _moveToPreviousStep(from: self.currentStep, currentStep: self.currentStep)
    }
    
    private func _moveToPreviousStep(from thisStep: RSDStep?, currentStep: RSDStep?) {
        guard let thisStep = thisStep,
            let currentStep = currentStep,
            let step = self.task!.stepNavigator.step(before: thisStep, with: &self.taskResult)
            else {
                if let parentPath = self.parent as? RSDTaskPathComponent {
                    // If the parent path is non-nil then go back up to the parent and have that path
                    // go back.
                    parentPath.moveBackToPreviousStep()
                }
                return
        }
        _moveBack(to: step, from: currentStep)
    }
    
    private func _moveBack(to step: RSDStep, from currentStep: RSDStep) {
        // Remove the step from the step history for this path segment.
        self.removeStepHistory(from: step.identifier)
        
        // Get the previous path component.
        guard let (nextPath, stepController) = self.previousPathComponent(for: step)
            else {
                _moveToPreviousStep(from: step, currentStep: currentStep)
                return
        }
        
        // Check if this is a subtask and go back within the subtask
        if let stepController = stepController {
            _move(to: stepController, from: currentStep, direction: .reverse)
        }
        else if let taskPath = nextPath as? RSDTaskPathComponent, taskPath.currentChild != nil {
            self.currentChild = nextPath
            taskPath.moveBackToCurrentStep(from: currentStep)
        }
        else {
            _moveToPreviousStep(from: step, currentStep: currentStep)
        }
    }
    
    private func _move(to stepController: RSDStepController, from previousStep: RSDStep?, direction: RSDStepDirection) {
        
        self.currentChild = stepController.stepViewModel
        let step = stepController.stepViewModel.step
        guard let taskController = self.taskController
            else {
                assertionFailure("Attempting to navigate without a task controller.")
                return
        }
        
        taskController.hideLoadingIfNeeded()
        taskController.show(stepController, from: previousStep, direction: direction) { [weak self] (finished) in
            self?._finishMoving(to: step, from: previousStep, direction: direction)
        }
    }
    
    private func _finishMoving(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection) {
        guard direction != .reverse else {
            _notifyAsyncControllers(to: step, excludingControllers:[])
            return
        }
        
        // Get which controllers should be stopped
        let isTaskComplete = (step.stepType == .completion) && !self.task!.stepNavigator.hasStep(after: step, with: taskResult)
        //let path = self.taskViewModel!
        var excludedControllers: [RSDAsyncAction] = []
        var controllersToStop: [RSDAsyncAction]?
        if let stopStep = previousStep, let controllers = _asyncActionsToStop(after: stopStep, isTaskComplete: isTaskComplete) {
            controllersToStop = controllers
            excludedControllers.append(contentsOf: controllers)
        }
        
        // Notify the controllers that the task has moved to the given step and start the idle controllers.
        excludedControllers.append(contentsOf: _startIdleAsyncControllers(excludingControllers: excludedControllers))
        _notifyAsyncControllers(to: step, excludingControllers: excludedControllers)
        
        // Ready to save if this is the completion step and there isn't a back button.
        let readyToSave = isTaskComplete && !self.canNavigateBackward
        
        // stop the controllers that should be stopped at this point
        if let controllers = controllersToStop, let taskController = self.taskController {
            taskController.stopAsyncActions(for: controllers, showLoading: false, completion: { [weak self] in
                if readyToSave  {
                    // If this is a completion step and the user cannot go back and change previous answers,
                    // then do *not* use it to mark the end of the task. Instead, mark *now* as the end date.
                    self?._handleTaskReady()
                }
            })
        } else if readyToSave {
            self._handleTaskReady()
        }
    }
    
    private func _notifyAsyncControllers(to step: RSDStep, excludingControllers: [RSDAsyncAction]) {
        guard let currentControllers = self.taskController?.currentAsyncControllers else { return }
        let controllers = currentControllers.filter { (lhs) -> Bool in
            return (lhs.status <= .running) && !excludingControllers.contains(where: { $0.isEqual(lhs) })
        }
        for controller in controllers {
            // let any controllers know that the step has changed
            controller.moveTo(step: step, taskViewModel: self)
        }
    }
    
    private func _startIdleAsyncControllers(excludingControllers: [RSDAsyncAction]) -> [RSDAsyncAction] {
        guard let taskController = self.taskController else { return [] }
        let controllers = taskController.currentAsyncControllers.filter { (lhs) -> Bool in
            return (lhs.status == .idle) && !excludingControllers.contains(where: { $0.isEqual(lhs) })
        }
        guard controllers.count > 0 else { return [] }
        taskController.startAsyncActions(for: controllers, showLoading: false) {
            // Do nothing
        }
        return controllers
    }
    
    // Mark: Private methods for finishing a task.
    
    private func _finishStoppingTaskPart1(previousStep: RSDStep?) {
        guard let task = self.task else {
            assertionFailure("Trying to stop a task before it's loaded. How did we get here?")
            return
        }
        
        let shouldExit = task.stepNavigator.shouldExit(after: previousStep, with: taskResult)
        
        // Look to see if there is a task path parent to go up to
        if !shouldExit, let parent = self.parent as? RSDTaskPathComponent {
            _moveUpThePath(from: previousStep, to: parent)
        }
        else {
            // look to see if there are any controllers that need to be stopped due to an early exit.
            if let controllers = self.taskController?.currentAsyncControllers.filter ({ $0.status <= .running }),
                controllers.count > 0 {
                self.taskController!.stopAsyncActions(for: controllers, showLoading: true, completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?._finishStoppingTaskPart2(didExitEarly: shouldExit)
                    }
                })
            } else {
                _finishStoppingTaskPart2(didExitEarly: shouldExit)
            }
        }
    }
    
    private func _moveUpThePath(from previousStep: RSDStep?, to parent: RSDTaskPathComponent, hasPreviousEarlyExit: Bool = false) {
        
        if !hasPreviousEarlyExit, let stopStep = previousStep,
            let controllers = _asyncActionsToStop(after: stopStep, isTaskComplete: true),
            let taskController = self.taskController {
            // If there are action controllers to stop and this is the last step then do that before continuing
            // and call this method again after they have been stopped. Use the hasPreviousEarlyExit
            // flag to indicate that this is the second go-around and don't check the controllers the
            // second time in case the called task controller returns before all the async controllers
            // have been removed from the queue.
            taskController.stopAsyncActions(for: controllers, showLoading: true, completion: { [weak self] in
                DispatchQueue.main.async {
                    self?._moveUpThePath(from: previousStep, to: parent, hasPreviousEarlyExit: true)
                }
            })
            return
        }
        
        // Mark the task as complete
        _handleTaskReady()
        
        // If the parent path is non-nil then go back up to the parent
        parent.taskResult.appendStepHistory(with: self.taskResult)
        parent.moveForwardToNextStep()
    }
    
    private func _finishStoppingTaskPart2(didExitEarly: Bool) {
        guard let root = self.rootPathComponent else {
            assertionFailure("This task path does not have a root task view model. Cannot complete.")
            return
        }
        root.didExitEarly = didExitEarly
        root._handleTaskReady()
        let reason: RSDTaskFinishReason = didExitEarly ? .earlyExit : .completed
        root.taskController?.handleTaskDidFinish(with: reason, error: nil)
    }
    
    private func _handleTaskReady() {
        guard !self.isCompleted else { return }
        // Mark the task end date and isCompleted
        self.taskResult.endDate = Date()
        self.isCompleted = true
        if self.parent == nil, let taskController = self.taskController {
            // ONLY send the message to save the results if this is the end of the task.
            taskController.handleTaskResultReady(with: self)
        }
    }
    
    // MARK: private methods for handling async actions
    
    private func _asyncActionsToStart(at step: RSDStep, isFirstStep: Bool) -> [RSDAsyncActionConfiguration]? {
        guard let taskController = self.taskController,
            let asyncActions = self.task?.asyncActionsToStart(at: step, isFirstStep: isFirstStep), asyncActions.count > 0
            else {
                return nil
        }
        let current = taskController.currentAsyncControllers.map { $0.configuration.identifier }
        let configs = asyncActions.filter { !current.contains($0.identifier) }
        
        return configs.count > 0 ? configs : nil
    }
    
    private func _asyncActionsToStop(after step: RSDStep?, isTaskComplete: Bool) -> [RSDAsyncAction]? {
        guard let currentControllers = self.taskController?.currentAsyncControllers
            else {
                return nil
        }
        
        let controllers = currentControllers.filter { (controller) -> Bool in
            // Verify that the controller is running
            guard controller.status <= .running else { return false }
            
            // verify that the controller task path is either the input path *or* a child of the current path.
            let path = controller.taskViewModel.fullPath
            guard path == self.fullPath || self.childPaths.contains(where: { $0.value.fullPath == path})
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

