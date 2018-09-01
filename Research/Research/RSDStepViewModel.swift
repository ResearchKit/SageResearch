//
//  RSDStepViewModel.swift
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

/// Base class implementation for a step view model.
///
/// - seealso: `RSDTaskViewModel`
open class RSDStepViewModel : NSObject, RSDNodePathComponent {
    
    /// The step that backs this view model.
    public let step: RSDStep
    
    public init(step: RSDStep, parent: RSDPathComponent?) {
        self.step = step
        self.parent = parent
        super.init()
    }
    
    /// The identifier associated with this step. Default returns `self.step.identifier`.
    open var identifier: String {
        return self.step.identifier
    }
    
    /// The child path component. Default returns `nil`.
    open var currentChild: RSDNodePathComponent? {
        return nil
    }
    
    /// The parent path component.
    weak open var parent: RSDPathComponent? {
        willSet {
            if let parent = self.parent {
                _taskResult = parent.taskResult
            }
        }
        didSet {
            if let taskResult = _taskResult, let parent = self.parent {
                parent.taskResult = taskResult
                _taskResult = nil
            }
        }
    }
    
    /// The parent task controller. Default returns `self.parent?.taskController`
    public var taskController: RSDTaskController? {
        return self.parent?.taskController
    }
    
    /// The task result is the task result from the parent, unless the parent is `nil` in which case it uses
    /// a local variable.
    public var taskResult: RSDTaskResult {
        get {
            let taskResult = self.parent?.taskResult ?? _taskResult
            if taskResult == nil {
                _taskResult = RSDTaskResultObject(identifier: self.identifier)
            }
            return taskResult ?? _taskResult!
        }
        set {
            if let parent = self.parent {
                parent.taskResult = newValue
            }
            else {
                _taskResult = newValue
            }
        }
    }
    private var _taskResult: RSDTaskResult?
    
    /// Is the "Next" button enabled? The default looks at the parent and if the parent is `nil` then it
    /// will return `true`.
    open var isForwardEnabled: Bool {
        return self.parent?.isForwardEnabled ?? true
    }
    
    /// Is backward navigation allowed? Default is to allow back navigation unless this is a completion step.
    open var canNavigateBackward: Bool {
        return self.step.stepType != .completion
    }
    
    /// Returns the parent output directory.
    public var outputDirectory: URL! {
        return self.parent?.outputDirectory
    }
    
    /// Instantiates a step result for this step.
    public func pathResult() -> RSDResult {
        return self.step.instantiateStepResult()
    }
    
    /// Calls `perform(action:)` on the parent.
    open func perform(actionType: RSDUIActionType) {
        self.parent?.perform(actionType: actionType)
    }
    
    /// Convenience method for accessing the step result associated with this step.
    open func findStepResult() -> RSDResult? {
        return self.taskResult.findResult(for: step)
    }

    /// Conveniece method for getting the progress through the task for the current step with
    /// the current result.
    ///
    /// - returns:
    ///     - current: The current progress. This indicates progress within the task.
    ///     - total: The total number of steps.
    ///     - isEstimated: Whether or not the progress is an estimate (if the task has variable navigation)
    public func progress() -> (current: Int, total: Int, isEstimated: Bool)? {
        guard let path = self.parent as? RSDTaskPathComponent else { return nil }

        // Look up the task chain for a progress that is *not* estimated and return either the top level
        // progress or the subtask progress if it defines progress using progress markers.
        var taskPath = path
        var progress = taskPath.task?.stepNavigator.progress(for: step, with: taskPath.taskResult)
        while (progress?.isEstimated ?? true),
            let parentPath = taskPath.parent as? RSDTaskPathComponent,
            let task = parentPath.task,
            let currentStep = parentPath.currentChild?.step {
            taskPath = parentPath
            progress = task.stepNavigator.progress(for: currentStep, with: taskPath.taskResult)
        }

        return progress
    }

    /// An identifier string that can be appended to a step view controller to differentiate this step from
    /// another instance in a different section.
    public func sectionIdentifier() -> String {
        let isSection = (self.parent?.parent != nil)
        return isSection ? "\(self.taskResult.identifier)_" : ""
    }
    
    /// The description of the path.
    override open var description: String {
        return "\(type(of: self)): \(fullPath) steps: [\(stepPath)]"
    }
}
