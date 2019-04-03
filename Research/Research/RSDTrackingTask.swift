//
//  RSDDataTracker.swift
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

/// The tracking task protocol is intended for tasks that use scoring data from a previous task run to
/// inform subsequent runs of the same task by a given participant. `RSDTaskViewModel` will check a task for
/// conformance to this method when the view model is initialized.
///
/// - note: Because sometimes it is actually the step navigator attached to a task that uses the previous
/// run data, the tracking task does *not* inherit from `RSDTask`.
///
/// - seealso: `RSDTaskObject` for example implementation.
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
    func shouldSkipStep(_ step: RSDStep) -> (shouldSkip: Bool, stepResult: RSDResult?)
}

