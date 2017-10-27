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

public typealias RSDAsyncActionCompletionHandler = (RSDAsyncActionController, RSDResult?, Error?) -> Void

/**
 A controller for an async action configuration.
 */
public protocol RSDAsyncActionController : class {
    
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
     If the action has completed, what was the result?
     */
    var result: RSDResult? { get }
    
    /**
     The configuration used to set up the controller.
     */
    var configuration: RSDAsyncActionConfiguration { get }
    
    /**
     A required initializer.
     
     @param configuration       The configuration for this controller.
     @param outputDirectory     An output directory for where to save file results (if applicable)
     */
    init(configuration: RSDAsyncActionConfiguration, outputDirectory: URL?)
    
    /**
     Start the asyncronous action with the given completion handler.
     */
    func start(_ completion: RSDAsyncActionCompletionHandler)
    
    /**
     Pause the action. Ignored if not applicable.
     */
    func pause()
    
    /**
     Resume the action. Ignored if not applicable.
     */
    func resume()
    
    /**
     Stop the action.
     */
    func stop()
    
    /**
     Cancel the action. If called, the completion handler will be called with a `nil` result.
     */
    func cancel()
}


