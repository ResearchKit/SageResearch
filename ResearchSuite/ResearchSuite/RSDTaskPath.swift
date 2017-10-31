//
//  RSDTaskPath.swift
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

public class RSDTaskPath : NSObject, NSCopying {

    public typealias FetchCompletionHandler = (RSDTaskPath, Error?) -> Void
    
    /**
     Identifier for this path segment
     */
    public let identifier: String
    
    /**
     Identifier for this task that can be mapped back to a nofification. This may be the same as the task identifier, or it might be that a task is scheduled multiple times per day, and the app needs to track what the scheduled timing is for the task.
     */
    public var scheduleIdentifier: String?
    
    /**
     String identifying the full path for this task.
     */
    public var fullPath: String {
        let prefix = parentPath?.fullPath ?? ""
        return "\(prefix)\\\(identifier)"
    }
    
    /**
     String representing the current order of steps to this point in the task.
     */
    public var stepPath: String {
        return self.result.stepHistory.map( {$0.identifier }).joined(separator: ", ")
    }
    
    /**
     The task info object used to load the task.
     */
    public private(set) var taskInfo: RSDTaskInfoStep?
    
    /**
     The task that is currently being run.
     */
    public private(set) var task: RSDTask?
    
    /**
     Convenience method for accessing the top-level task path.
     */
    public var topLevelTaskPath: RSDTaskPath {
        var taskPath = self
        while let path = taskPath.parentPath {
            taskPath = path
        }
        return taskPath
    }
    
    /**
     The result associated with this task.
     */
    public var result: RSDTaskResult
    
    /**
     A listing of step results that were removed from the task result. These results can be accessed by a step view controller to load a result that was previously selected.
     */
    public private(set) var previousResults: [RSDResult]?
    
    /**
     The current step. If `nil` then the task has not been started.
     */
    open var currentStep: RSDStep?
 
    /**
     This is a flag that can be used to mark whether or not the task is ready to be saved.
     */
    public var isCompleted: Bool = false
    
    /**
     This is a flag that can be used to mark when a task was exited early.
     */
    public var didExitEarly: Bool = false
    
    /**
     Mutable array of the current actions attached to this task.
     */
    public var currentActions: [RSDAsyncActionController] = []
    
    /**
     A pointer to a parent path if this is subtask step.
     */
    public private(set) var parentPath: RSDTaskPath?
    
    /**
     Flag for tracking whether or not the `task` is loading from the `taskInfo`.
     */
    public private(set) var isLoading: Bool = false
    
    public init(task: RSDTask, parentPath: RSDTaskPath? = nil) {
        self.identifier = task.identifier
        self.task = task
        self.taskInfo = task.taskInfo
        self.result = task.instantiateTaskResult()
        super.init()
        commonInit(identifier: task.identifier, parentPath: parentPath)
    }
    
    public init(taskInfo: RSDTaskInfoStep, parentPath: RSDTaskPath? = nil) {
        self.identifier = taskInfo.identifier
        self.taskInfo = taskInfo
        self.result = RSDTaskResultObject(identifier: taskInfo.identifier)  // Create a temporary result
        super.init()
        commonInit(identifier: taskInfo.identifier, parentPath: parentPath)
    }
    
    private func commonInit(identifier: String, parentPath: RSDTaskPath?) {
        guard let parentPath = parentPath else { return }
        self.parentPath = parentPath
        self.previousResults = (parentPath.result.stepHistory.rsd_last(where: { $0.identifier == identifier }) as? RSDTaskResult)?.stepHistory
    }
    
    /**
     Fetch the task associated with this path. This
     */
    public func fetchTask(with factory:RSDFactory, completion: @escaping FetchCompletionHandler) {
        guard !self.isLoading && self.task == nil else {
            debugPrint("\(self.description): Already loading task.")
            return
        }
        guard let taskInfo = self.taskInfo else {
            fatalError("Cannot fetch a task with a nil task info.")
        }
        
        self.isLoading = true
        taskInfo.fetchTask(with: factory) { [weak self] (info, task, error) in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if task != nil {
                strongSelf.task = task
                strongSelf.result = task!.instantiateTaskResult()
            }
            completion(strongSelf, error)
        }
    }
    
    /**
     Convenience method for encoding a result. This is a work-around for a limitation of the encoder where it cannot encode an object without a Type for the object.
     
     @param encoder     The factory top-level encoder.
     
     @return            The encoded result.
     */
    public func encodeResult(to encoder: RSDFactoryEncoder) throws -> Data {
        let encodable = _EncodableResultWrapper(taskResult: self.result)
        return try encoder.encode(encodable)
    }
    
    /**
     Append the result to the end of the step history, replacing the previous instance with the same identifier and adding the previous instance to the previous results.
     
     @param newResult  The result to add to the step history.
     */
    public func appendStepHistory(with newResult: RSDResult) {
        guard let previousResult = result.appendStepHistory(with: newResult) else { return }
        _appendPreviousResults(previousResult)
    }
    
    /**
     Remove results from the step history from the result with the given identifier to the end of the array. Add these results to the previous results set.
     
     @param stepIdentifier  The identifier of the result associated with the given step.
     */
    public func removeStepHistory(from stepIdentifier: String) {
        guard let previous = result.removeStepHistory(from: stepIdentifier) else { return }
        for previousResult in previous {
            _appendPreviousResults(previousResult)
        }
    }
    
    private func _appendPreviousResults(_ previousResult: RSDResult) {
        if previousResults == nil {
            previousResults = [previousResult]
        }
        else {
            if let idx = previousResults!.index(where: { $0.identifier == previousResult.identifier }) {
                previousResults!.remove(at: idx)
            }
            previousResults!.append(previousResult)
        }
    }
    
    override public var description: String {
        return "\(type(of: self)): \(fullPath) steps: [\(stepPath)]"
    }
    
    
    // Copying
    
    public required init(with identifier: String, result: RSDTaskResult, taskInfo: RSDTaskInfoStep?, task: RSDTask?) {
        guard taskInfo != nil || task != nil else {
            fatalError("Cannot initializa a task path with both a nil task info and nil task.")
        }
        self.identifier = identifier
        self.result = result
        self.taskInfo = taskInfo
        self.task = task
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let result = (self.result as? NSCopying)?.copy(with: nil) as? RSDTaskResult ?? self.result
        let taskInfo = (self.taskInfo as? NSCopying)?.copy(with: nil) as? RSDTaskInfoStep ?? self.taskInfo
        let task = (self.task as? NSCopying)?.copy(with: nil) as? RSDTask ?? self.task

        let copy = type(of: self).init(with: self.identifier, result: result, taskInfo: taskInfo, task: task)
        copy.scheduleIdentifier = self.scheduleIdentifier
        copy.previousResults = self.previousResults?.map({ ($0 as? NSCopying)?.copy(with: nil) as? RSDResult ?? $0 })
        copy.parentPath = self.parentPath?.copy() as? RSDTaskPath
        copy.isCompleted = self.isCompleted
        return copy
    }
}

fileprivate struct _EncodableResultWrapper: Encodable {
    let taskResult: RSDTaskResult
    
    func encode(to encoder: Encoder) throws {
        try taskResult.encode(to: encoder)
    }
}

