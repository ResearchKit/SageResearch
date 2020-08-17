//
//  RSDTaskController.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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
public enum RSDStepDirection : Int, Codable {
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

/// `RSDTaskControllerDelegate` is responsible for processing the results of the task, providing some input into
/// how the controller behaves, and providing additional content as needed. It's primary purpose is to handle
/// processing the results of running the task.
public protocol RSDTaskControllerDelegate : class {
    
    /// Tells the delegate that the task has finished.
    ///
    /// The task controller should call this method when an unrecoverable error occurs, when the user has
    /// canceled the task (with or without saving), or when the user completes the last step in the task.
    ///
    /// In most circumstances, the receiver should dismiss the task view controller in response to this
    /// method, and may also need to collect and process the results of the task.
    ///
    /// - parameters:
    ///     - taskController:   The `RSDTaskController` instance that is returning the result.
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
    ///     - taskViewModel:         The task path with the results for this task run.
    func taskController(_ taskController: RSDTaskController, readyToSave taskViewModel: RSDTaskViewModel)
}

/// `RSDTaskController` handles a base-level implementation for running a task. This object is expected to
/// be an appropriate instance of a view controller, depending upon the operating system.
///
/// To start a task, create an instance of a view controller that conforms to this protocol
/// and set the `task`, `taskInfo`, or `taskViewModel`.
public protocol RSDTaskController : class {
    
    /// A path object used to track the current state of a running task.
    var taskViewModel: RSDTaskViewModel! { get set }
    
    /// Returns a step controller appropriate to the given step. If this method returns `nil` then the step
    /// should be ignored.
    func stepController(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepController?

    /// Returns a list of the async action controllers that are currently active. This includes controllers
    /// that are requesting permissions, starting, running, *and* stopping.
    var currentAsyncControllers: [RSDAsyncAction] { get }
    
    /// Navigate to the next step from the previous step in the given direction.
    ///
    /// - parameters:
    ///     - stepController: The step controller to show.
    ///     - previousStep: The previous step. This is either the step currently being displayed or
    ///                     else the `RSDSectionStep` or `RSDTaskStep` if the previous step was the
    ///                     last step in a paged section or fetched subtask.
    ///     - direction: The direction in which to show the animation change.
    ///     - completion: The completion to call once the navigation animation has completed.
    func show(_ stepController: RSDStepController, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?)
    
    /// Show a loading state while fetching the given task from the task info.
    /// - parameter taskInfo: The task info for the task being fetched.
    func showLoading(for taskInfo: RSDTaskInfo)
    
    /// Fired when the task controller is ready to go forward. This method must invoke the `goForward()`
    /// method either to go forward automatically or else go forward after a user action.
    func handleFinishedLoading()
    
    /// Hide the loading state if currently showing it.
    func hideLoadingIfNeeded()
    
    /// Failed to fetch the task from the current task path. Handle the error. A retry can be fired
    /// by calling `goForward()`.
    /// - parameter error:   The error returned by the failed task fetch.
    func handleTaskFailure(with error: Error)

    /// The task has completed.
    ///
    /// - parameters:
    ///     - reason: The reason the task is finished.
    ///     - error: The error, if any, that resulted in stopping the task early.
    func handleTaskDidFinish(with reason: RSDTaskFinishReason, error: Error?)
    
    /// This method is called when a task result is "ready" for upload, save, archive, etc. This method
    /// will be called when either (a) the task is ready to dismiss or (b) when the task is displaying
    /// the *last* completion step.
    ///
    /// - parameter taskViewModel: The root task view model for this task.
    func handleTaskResultReady(with taskViewModel: RSDTaskViewModel)
    
    /// Add async action controllers to the shared queue for the given configuations. It is up to the task
    /// controller to decide how to create the controllers and how to manage adding them to the
    /// `currentAsyncControllers` array.
    ///
    /// Handling async actions is left to the view controller on Apple devices because this is commonly tied
    /// to UI/UX and thread management that the view controller is best suited to determining as appropriate
    /// for the given platform.
    ///
    /// The async actions should *not* be started. Instead they should be returned with `idle` status.
    ///
    /// The task controller needs to handle blocking any navigation changes until the async actions are
    /// ready to proceed; meaning that navigation should be blocked until after required authorizations are
    /// checked. Otherwise, the modal popup alert can be swallowed by the step change.
    ///
    /// - note: If creating the recorder might take time, the task controller should move creation to a
    /// background thread so that the main thread is not blocked.
    ///
    /// - parameters:
    ///     - configurations: The configurations to start.
    ///     - path: The path component that is currently being navigated.
    ///     - completion: The completion to call with the instantiated controllers.
    func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], path: RSDPathComponent, completion: @escaping (([RSDAsyncAction]) -> Void))
    
    /// Request permissions for controllers but do *not* start the controllers.
    ///
    /// - parameters:
    ///     - controllers: The controllers for which to request permissions.
    ///     - completion: The completion to call with the instantiated controllers.
    func requestPermission(for controllers: [RSDAsyncAction], completion: @escaping (() -> Void))
    
    /// Start all async actions that are waiting to be started.
    func startAsyncActionsIfNeeded()

    /// Start the async actions. The protocol extension calls this method when an async action should be
    /// started directly *after* the step is presented.
    func startAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void))

    /// Stop the async actions. The protocol extension does not directly implement stopping the async actions
    /// to allow customization of how the results are added to the task and whether or not forward navigation
    /// should be blocked until the completion handler is called. When the stop action is called, the view
    /// controller needs to handle stopping the controllers, adding the results, and showing a loading state
    /// until ready to move forward in the task navigation.
    func stopAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void))
}

extension RSDTaskController {
    
    /// Convenience method for getting/setting the main entry point for the task controller via the task info.
    public var taskInfo : RSDTaskInfo! {
        get {
            return taskViewModel?.taskInfo
        }
        set {
            guard taskViewModel == nil else {
                assertionFailure("Cannot replace the task info on the task path once it is set.")
                return
            }
            self.taskViewModel = RSDTaskViewModel(taskInfo: newValue)
        }
    }
    
    /// Convenience property for getting/setting the main entry point for the task controller via the task.
    public var task : RSDTask! {
        get {
            return taskViewModel?.task
        }
        set {
            guard taskViewModel == nil else {
                assertionFailure("Cannot replace the task on the task path once it is set.")
                return
            }
            self.taskViewModel = RSDTaskViewModel(task: newValue)
        }
    }
}
