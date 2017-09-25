//
//  RSDAsyncAction.swift
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

/**
 `RSDAsyncAction` defines general configuration for an asyncronous background action that should be run in the background. Depending upon the parameters and how the action is setup, this could be something that is run continuously or else is paused or reset based on a timeout interval.
 */
public protocol RSDAsyncAction {
    
    /**
     A short string that uniquely identifies the asyncronous action within the task. The identifier is reproduced in the results of a async results.
     */
    var identifier : String { get }
    
    /**
     An identifier marking the step to start the action. If `nil`, then the action will be started when the task is started.
     */
    var startStepIdentifier: String? { get }
    
    /**
     An identifier marking the step at which to stop the action. If `nil`, then the action will be stopped when the task is stopped.
     */
    var stopStepIdentifier: String? { get }
    
    /**
     An identifier marking a step to wait to display until the action is completed. This is only valid for actions that are single result actions and not continuous recorders.
     */
    var waitStepIdentifier: String? { get }
    
    /**
     A time interval after which the action should be reset. For example, if the action queries a weather service and the user backgrounds the app for more than the reset time, then the weather service should be queried again.
     */
    var resetTimeInterval: TimeInterval { get }
    
    /**
     A time interval after which the action should be stopped.
     */
    var timeoutTimeInterval: TimeInterval { get }
}
