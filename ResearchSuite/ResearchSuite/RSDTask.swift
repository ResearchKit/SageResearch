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
     
     @param rect    The size of the image view used to display the image.
     
     @return        The image to display.
     */
    func icon(in rect: CGRect) -> UIImage?
}

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
     Additional information about the result schema
     */
    var schemaInfo: RSDSchemaInfo? { get }
    
    /**
     A list of asyncronous actions to run on the task.
     */
    var asyncActions: [RSDAsyncAction]? { get }
    
    /**
     Returns the step associated with a given identifier.
     
     @param identifier  The identifier for the step.
     
     @return            The step with this identifier or nil if not found.
     */
    func step(with identifier: String) -> RSDStep?
    
    /**
     Return the step to go to before the given step.
     
     @param step    The current step.
     @param result  The current result set for this task.
     
     @return        The previous step or nil if the task does not support backward navigation.
     */
    func stepBefore(_ step: RSDStep, with result: RSDTaskResult?) -> RSDStep?
    
    /**
     Return the step to go to after completing the given step.
     
     @param step    The previous step or nil if this is the first step.
     @param result  The current result set for this task.
     
     @return        The next step to display or nil if this is the end of the task.
     */
    func stepAfter(_ step: RSDStep?, with result: RSDTaskResult?) -> RSDStep?
    
    /**
     Return the progress through the task for a given step with the current result.
     
     @param step    The current step.
     @param result  The current result set for this task.
     
     @return current        The current progress. This indicates progress within the task.
     @return total          The total number of steps.
     @return isEstimated    Whether or not the progress is an estimate (if the task has variable navigation)
     */
    func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)
    
    /**
     Validate the task to check for any model configuration that should throw an error.
     */
    func validate() throws
}
