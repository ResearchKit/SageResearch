//
//  RSDTaskRepository.swift
//  Research
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

/// The task repository is used by an app to configure fetching tasks.
open class RSDTaskRepository {
    
    /// Singleton for the shared task repository.
    public static var shared = RSDTaskRepository()
    
    public init() {
    }
    
    /// The completion handler for a fetched task.
    public typealias FetchCompletionHandler = (RSDTaskInfo, RSDTask?, Error?) -> Void
    
    /// Pointer to a task transformer used to retain the transformer while the task is being fetched.
    private var _taskTransformers = [UUID : RSDTaskTransformer]()
    
    /// Fetch the task for a given task info. The base class implementation will fetch the task from the
    /// `resourceTransformer` that is optionally included on the task info or from an embedded resource.
    open func fetchTask(for taskInfo: RSDTaskInfo, completion: @escaping FetchCompletionHandler) {
        do {
            let taskTransformer = try self.taskTransformer(for: taskInfo)
            let schemaInfo = self.schemaInfo(for: taskInfo)
            let uuid = UUID()
            _taskTransformers[uuid] = taskTransformer
            taskTransformer.fetchTask(with: taskInfo.identifier, schemaInfo: schemaInfo) { [weak self] (task, error) in
                completion(taskInfo, task, error)
                self?._taskTransformers[uuid] = nil
            }
        } catch let error {
            DispatchQueue.main.async {
                completion(taskInfo, nil, error)
            }
        }
    }
    
    /// Returns the schema to use for the given task info.
    open func schemaInfo(for taskInfo: RSDTaskInfo) -> RSDSchemaInfo? {
        return taskInfo.schemaInfo
    }
    
    /// Returns the task transformer for the given task info.
    open func taskTransformer(for taskInfo: RSDTaskInfo) throws -> RSDTaskTransformer {
        if let transformer = taskInfo.resourceTransformer {
            return transformer
        }
        else if let transformer = taskInfo as? RSDTaskTransformer {
            return transformer
        }
        else {
            return RSDResourceTransformerObject(resourceName: taskInfo.identifier)
        }
    }
}
