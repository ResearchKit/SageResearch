//
//  RSDDataTracker.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// The tracking task protocol is intended for tasks that use scoring data from a previous task run to
/// inform subsequent runs of the same task by a given participant. `RSDTaskViewModel` will check a task for
/// conformance to this method when the view model is initialized.
///
/// - note: Because sometimes it is actually the step navigator attached to a task that uses the previous
/// run data, the tracking task does *not* inherit from `RSDTask`.
///
/// - seealso: `RSDTaskObject` for example implementation.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDTrackingTask {
    
    /// Create and return the tracked data task that may be used to inform subsequent runs of this task.
    /// - parameter taskResult: The task result for this task that is used to build the task data.
    /// - returns: The task data or `nil` if there is no data to track.
    func taskData(for taskResult: RSDTaskResult) -> RSDTaskData?
    
    /// Called following initialization and before presentation of the task to allow setting up a task
    /// for custom navigation based on the previous stored data.
    /// - parameters:
    ///     - data: The stored task data.
    ///     - path: The task path component that is calling this method. If a pointer is kept, it should use a weak reference.
    func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent)
    
    /// Called before showing a step to conditionally skip the step in favor of instead adding the returned
    /// result to the step history. This can be used by tracking tasks to check a step for a previous result
    /// that is not expected to change across different runs, such as demographics data. Then if the app had
    /// a mechanism for storing the results of a previous run, it can skip this step on subsequent runs.
    ///
    /// - parameter step: The step to check for previous run data.
    /// - returns:
    ///     - shouldSkip: Whether or not the step should be skipped.
    ///     - stepResult: The step to add to the task result for this step in lieu of showing it.
    func shouldSkipStep(_ step: RSDStep) -> (shouldSkip: Bool, stepResult: ResultData?)
}

