//
//  RSDAsyncActionController.swift
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

public protocol RSDAsyncActionControllerDelegate : class {
    
    /**
     Method called when the controller fails. The delegate is responsible for handling the failure.
     */
    func asyncActionController(_ controller: RSDAsyncActionController, didFailWith error: Error)
}

public typealias RSDAsyncActionCompletionHandler = (RSDAsyncActionController, RSDResult?, Error?) -> Void

/**
 A controller for an async action configuration.
 */
public protocol RSDAsyncActionController : class {
    
    /**
     Delegate callback for handling action completed.
     */
    weak var delegate: RSDAsyncActionControllerDelegate? { get set }
    
    /**
     Is the action currently running?
     */
    var isRunning: Bool { get }
    
    /**
     Is the action currently paused?
     */
    var isPaused: Bool { get }
    
    /**
     Was the action cancelled?
     */
    var isCancelled: Bool { get }
    
    /**
     Results for this action controller.
     */
    var result: RSDResult? { get }
    
    /**
     The configuration used to set up the controller.
     */
    var configuration: RSDAsyncActionConfiguration { get }
    
    /**
     Start the asynchronous action with the given completion handler. Note: The handler may be called on a background thread.
     */
    func start(at taskPath: RSDTaskPath?, completion: RSDAsyncActionCompletionHandler?)
    
    /**
     Pause the action. Ignored if not applicable.
     */
    func pause()
    
    /**
     Resume the action. Ignored if not applicable.
     */
    func resume()
    
    /**
     Stop the action with the given completion handler. Note: The handler may be called on a background thread.
     */
    func stop(_ completion: RSDAsyncActionCompletionHandler?)
    
    /**
     Cancel the action. If called, the completion handler will be called with a `nil` result.
     */
    func cancel()
    
    /**
     Let the controller know that the task has moved to the given step.
     */
    func moveTo(step: RSDStep, taskPath: RSDTaskPath)
}


