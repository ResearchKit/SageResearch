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
open class RSDStepViewModel : NSObject, RSDStepViewPathComponent {
    
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
    
    /// The task result is the task result from the parent, unless the parent is `nil` in which case it uses
    /// a local instance variable.
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
    
    /// Is the "Next" button enabled? The default implementation will check if the parent node is non-nil and
    /// return whether or not the parent has forward enabled, otherwise it will return `true`.
    open var isForwardEnabled: Bool {
        return self.parent?.isForwardEnabled ?? true
    }
    
    /// Is backward navigation allowed? Default is to allow backward navigation unless the `step.stepType` is
    /// `.completion`.
    open var canNavigateBackward: Bool {
        return !shouldHideAction(for: .navigation(.goBackward)) && (self.step.stepType != .completion)
    }
    
    /// Calls through to `!shouldHideAction(for: .navigation(.goForward))`
    public var hasStepAfter: Bool {
        return !shouldHideAction(for: .navigation(.goForward))
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
    ///     - isEstimated: Whether or not the progress is an estimate (if the task has variable navigation).
    open func progress() -> (current: Int, total: Int, isEstimated: Bool)? {
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
    open func sectionIdentifier() -> String {
        let isSection = (self.parent?.parent != nil)
        return isSection ? "\(self.taskResult.identifier)_" : ""
    }
    
    /// The description of the path.
    override open var description: String {
        return "\(type(of: self)): \(fullPath) steps: [\(fullPath)]"
    }
    
    // MARK: UIAction handling
    
    /// Convenience property for casting the step to a `RSDUIStep`.
    public var uiStep: RSDUIStep? {
        return step as? RSDUIStep
    }
    
    /// Convenience property for casting the step to a `RSDActiveUIStep`.
    public var activeStep: RSDActiveUIStep? {
        return step as? RSDActiveUIStep
    }
    
    /// Get the action for the given action type. The default implementation check the step, the delegate
    /// and the task as follows:
    /// - Query the step for an action.
    /// - If that returns nil, it will then check the delegate.
    /// - If that returns nil, it will look up the task path chain for an action.
    /// - Finally, if not found it will return nil.
    ///
    /// - parameter actionType: The action type to get.
    /// - returns: The action if found.
    open func action(for actionType: RSDUIActionType) -> RSDUIAction? {        
        // Check the cached actions first.
        if let cachedAction = _mappedActions[actionType] {
            return cachedAction as? RSDUIAction
        }
        
        // If not in the cache, then find it.
        var ret = _findAction(for: actionType)
        // By default, nil out the reminder if this the study configuration does not support it's use.
        if let _ = ret as? RSDReminderUIAction, !RSDStudyConfiguration.shared.shouldShowRemindMe {
            ret = nil
        }
        _mappedActions[actionType] = ret ?? NSNull()
        return ret
    }
    
    private func _findAction(for actionType: RSDUIActionType) -> RSDUIAction? {
        if let action = (self.step as? RSDUIActionHandler)?.action(for: actionType, on: step) {
            // Allow the step to override the default from the delegate
            return action
        }
        else if let action = recursiveTaskAction(for: actionType) {
            // Finally check the task for a global action
            return action
        }
        else {
            return nil
        }
    }
    
    private var _mappedActions: [RSDUIActionType : Any] = [:]
    
    private func recursiveTaskAction(for actionType: RSDUIActionType) -> RSDUIAction? {
        var parentPath: RSDPathComponent? = self.parent
        while let path = parentPath {
            if let taskPath = path as? RSDTaskPathComponent,
                let actionHandler = taskPath.task as? RSDUIActionHandler,
                let action = actionHandler.action(for: actionType, on: step) {
                return action
            }
            parentPath = path.parent
        }
        return nil
    }
    
    /// Should the action be hidden for the given action type?
    ///
    /// - The default implementation will first look to see if the step overrides and forces the
    /// action to be hidden.
    /// - If not, then the delegate will be queried next.
    /// - If that does not return a value, then the task path will be checked.
    ///
    /// Finally, whether or not to hide the action will be determined based on the action type and
    /// the state of the task as follows:
    /// 1. `.navigation(.cancel)` - Always defaults to `false` (not hidden).
    /// 2. `.navigation(.goForward)` - Hidden if the step is an active step that transitions automatically.
    /// 3. `.navigation(.goBack)` - Hidden if the step is an active step that transitions automatically,
    ///                             or if the task does not allow backward navigation.
    /// 4. Others - Hidden if the `action()` is nil.
    ///
    /// - parameter actionType: The action type to get.
    /// - returns: `true` if the action should be hidden.
    open func shouldHideAction(for actionType: RSDUIActionType) -> Bool {
        if let shouldHide = uiStep?.shouldHideAction(for: actionType, on: step) {
            // Allow the step to override the default from the delegate
            return shouldHide
        }
        else if let shouldHide = recursiveTaskShouldHideAction(for: actionType), self.action(for: actionType) == nil {
            // Finally check if the task has any global settings
            return shouldHide
        }
        else {
            // Otherwise, look at the action and show the button based on the type
            let transitionAutomatically = activeStep?.commands.contains(.transitionAutomatically) ?? false
            switch actionType {
            case .navigation(.cancel):
                return false
            case .navigation(.goForward):
                return transitionAutomatically
            case .navigation(.goBackward):
                return !self.rootPathComponent.hasStepBefore || transitionAutomatically
            default:
                return self.action(for: actionType) == nil
            }
        }
    }
    
    private func recursiveTaskShouldHideAction(for actionType: RSDUIActionType) -> Bool? {
        var parentPath: RSDPathComponent? = self.parent
        while let path = parentPath {
            if let taskPath = path as? RSDTaskPathComponent,
                let actionHandler = taskPath.task as? RSDUIActionHandler,
                let shouldHide = actionHandler.shouldHideAction(for: actionType, on: step) {
                return shouldHide
            }
            parentPath = path.parent
        }
        return nil
    }
}
