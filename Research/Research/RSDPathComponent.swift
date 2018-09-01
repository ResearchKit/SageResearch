//
//  RSDPathComponent.swift
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


//
//  RSDPathComponent.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

/// A path component holds state for navigating and displaying a task with a UX that is appropriate to a
/// given platform.
public protocol RSDPathComponent : class {
    
    /// A unique identifier for this path component.
    var identifier : String { get }
    
    /// The current child that this component is pointing to.
    var currentChild : RSDNodePathComponent? { get }
    
    /// The parent path component. If nil, this is the top-level path component.
    var parent : RSDPathComponent? { get }
    
    /// A pointer to the task controller that is running the task.
    var taskController : RSDTaskController? { get }
    
    /// The task result associated with this path component.
    var taskResult : RSDTaskResult { get set }
    
    /// Can this task go forward? If forward navigation is disabled, then the task isn't waiting for a result
    /// or a task fetch to enable forward navigation.
    var isForwardEnabled : Bool { get }
    
    /// Can the path navigate backward up the chain?
    var canNavigateBackward : Bool { get }
    
    /// File URL for the directory in which to store generated data files. Asyncronous actions with
    /// recorders (and potentially steps) can save data to files during the progress of the task.
    /// This property specifies where such data should be written.
    var outputDirectory : URL! { get }
    
    /// The result to use to mark the step history for this path component.
    func pathResult() -> RSDResult
    
    /// Go forward to the next step.
    func perform(actionType: RSDUIActionType)
}

/// A node path component always has an associated step, which the step navigator can use to recover the
/// step path.
public protocol RSDNodePathComponent : RSDPathComponent {
    
    /// The step model object associated with this path component.
    var step : RSDStep { get }
}

public protocol RSDTaskPathComponent : RSDPathComponent {
    
    /// The task that is currently being run. This can be `nil` if the task has not yet been loaded.
    var task: RSDTask? { get }
    
    /// Move back up the path to the current step that has an associated view controller.
    func moveBackToCurrentStep(from previousStep: RSDStep)
    
    /// Move back from this path subtask to the previous step on the parent.
    func moveBackToPreviousStep()
    
    /// Move forward from this path subtask to the next step on the parent.
    func moveForwardToNextStep()
    
    /// Append the result to the end of the step history, replacing the previous instance with the same
    /// identifier and adding the previous instance to the previous results.
    ///
    /// - parameter newResult:  The result to add to the step history.
    func appendStepHistory(with newResult: RSDResult)
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    ///
    /// - parameter newResult:  The result to add to the async results.
    func appendAsyncResult(with newResult: RSDResult)
}

extension RSDPathComponent {
    
    /// Convenience method for accessing the top-level path component.
    public var rootPathComponent: RSDTaskViewModel! {
        var thisPath: RSDPathComponent = self
        while let path = thisPath.parent {
            thisPath = path
        }
        return thisPath as? RSDTaskViewModel
    }
    
    /// Convenience method for accessing the lowest-level node. For a UI task, this will point to the step
    /// that is currently being displayed.
    public var currentNode: RSDNodePathComponent? {
        var node: RSDNodePathComponent? = self.currentChild
        while let child = node?.currentChild {
            node = child
        }
        return node
    }
    
    /// Convenience method for accessing the lowest-level task path.
    public var currentTaskPath: RSDTaskPathComponent? {
        if let start = self as? RSDTaskPathComponent {
            // If this this node conforms to the task protocol, then start with it and look down the chain.
            var taskPath = start
            while let nextPath = taskPath.currentChild as? RSDTaskPathComponent {
                taskPath = nextPath
            }
            return taskPath
        }
        else {
            // Otherwise, go up the chain until the node above is a task node.
            var node: RSDPathComponent = self
            while let parent = node.parent {
                node = parent
                if let taskPath = node as? RSDTaskPathComponent {
                    return taskPath
                }
            }
            return nil
        }
    }
    
    //// String identifying the full path for this task.
    public var fullPath: String {
        let prefix = parent?.fullPath ?? ""
        return (prefix as NSString).appendingPathComponent(identifier)
    }
    
    /// String representing the current order of steps to this point in the task.
    public var stepPath: String {
        return self.taskResult.stepHistory.map( {$0.identifier }).joined(separator: ", ")
    }
    
    /// Is this the first step in the task?
    public var isFirstStep: Bool {
        var thisPath: RSDPathComponent! = self
        repeat {
            if thisPath.taskResult.stepHistory.count > 1 {
                return false
            }
            thisPath = thisPath.parent
        } while thisPath != nil
        return true
    }
    
    /// Create an output directory.
    func createOutputDirectory() -> URL? {
        let tempDir = NSTemporaryDirectory()
        let dir = self.taskResult.taskRunUUID.uuidString
        let path = (tempDir as NSString).appendingPathComponent(dir)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                #if os(macOS)
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [:])
                #else
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [ .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication ])
                #endif
            } catch let error as NSError {
                print ("Error creating file: \(error)")
                return nil
            }
        }
        return URL(fileURLWithPath: path, isDirectory: true)
    }
}

