//
//  RSDTask.swift
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

import UIKit

/**
 A light-weight reference interface for information about the task. This includes information that can be displayed in a table or collection view.
 */
public protocol RSDTaskInfo {
    
    /**
     A short string that uniquely identifies the task.
     */
    var identifier: String { get }
    
    /**
     The primary text to display for the task in a localized string.
     */
    var title: String? { get }
    
    /**
     Additional detail text to display for the task.
     */
    var detail: String? { get }
    
    /**
     Copyright information for the task.
     */
    var copyright: String? { get }
    
    /**
     The estimated number of minutes that the task will take. If `0`, then this is ignored.
     */
    var estimatedMinutes: Int { get }
    
    /**
     An icon image that can be used for displaying the task.
     
     @param size        The size of the image to return.
     @param callback    The callback with the image, run on the main thread.
     */
    func fetchIcon(for size: CGSize, callback: @escaping ((UIImage?) -> Void))
}

/**
 This is a light-weight interface for schema information used to upload the results of a task.
 */
public protocol RSDSchemaInfo {
    
    /**
     A short string that uniquely identifies the associated result schema. If nil, then the `taskIdentifier` is used.
     */
    var schemaIdentifier: String? { get }
    
    /**
     A revision number associated with the result schema. If `0`, then this is ignored.
     */
    var schemaRevision: Int { get }
    
}

/**
 This is the interface for running a task. It includes information about how to calculate progress, validation, and the order of display for the steps.
 */
public protocol RSDTask {
    
    /**
     A short string that uniquely identifies the task.
     */
    var identifier: String { get }
    
    /**
     Additional information about the task.
     */
    var taskInfo: RSDTaskInfo? { get }
    
    /**
     Additional information about the result schema.
     */
    var schemaInfo: RSDSchemaInfo? { get }
    
    /**
     The step navigator for this task.
     */
    var stepNavigator: RSDStepNavigator { get }
    
    /**
     A list of asyncronous actions to run on the task.
     */
    var asyncActions: [RSDAsyncAction]? { get }

    /**
     Validate the task to check for any model configuration that should throw an error.
     */
    func validate() throws
}
