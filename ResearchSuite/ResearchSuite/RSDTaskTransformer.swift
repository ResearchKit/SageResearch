//
//  RSDTaskTransformer.swift
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

/// `RSDTaskTransformer` The task transformer is a lightweight protocol for vending a task. This can be used by
/// an `RSDTaskInfoStep` to fetch a task or depending upon the design of the application, it could be used to
/// fetch a task that is loaded from a table or collection view before presenting the task.
public protocol RSDTaskTransformer {
    
    /// The estimated time to fetch the task. This can be used by the UI to determine whether or not to
    /// display a loading state while fetching the task. If `0` then the task is assumed to be cached on the device.
    var estimatedFetchTime: TimeInterval { get }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - factory:     The factory to use for creating the task and steps.
    ///     - taskInfo:    The task info for the task (if applicable).
    ///     - schemaInfo:  The schema info for the task (if applicable).
    ///     - callback:    The callback with the task or an error if the task failed, run on the main thread.
    func fetchTask(with factory: RSDFactory, taskInfo: RSDTaskInfoStep, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler)
}

/// `RSDTaskResourceTransformer` is an implementation of a `RSDTaskTransformer` that uses a `RSDResourceTransformer`
/// to support transforming a resource either using an online URL or an embedded file.
public protocol RSDTaskResourceTransformer : RSDTaskTransformer, RSDResourceTransformer {
}

extension RSDTaskResourceTransformer {
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - factory:     The factory to use for creating the task and steps.
    ///     - taskInfo:    The task info for the task (if applicable).
    ///     - schemaInfo:  The schema info for the task (if applicable).
    ///     - callback:    The callback with the task or an error if the task failed, run on the main thread.
    public func fetchTask(with factory: RSDFactory, taskInfo: RSDTaskInfoStep, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        DispatchQueue.global().async {
            do {
                let task = try factory.decodeTask(with: self, taskInfo: taskInfo, schemaInfo: schemaInfo)
                DispatchQueue.main.async {
                    callback(taskInfo, task, nil)
                }
            } catch let err {
                DispatchQueue.main.async {
                    callback(taskInfo, nil, err)
                }
            }
        }
    }
}
