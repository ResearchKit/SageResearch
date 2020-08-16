//
//  RSDAsyncActionConfiguration.swift
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

/// `RSDAsyncActionConfiguration` defines general configuration for an asynchronous background action that
/// should be run in the background. Depending upon the parameters and how the action is set up, this could
/// be something that is run continuously or else is paused or reset based on a timeout interval.
///
/// The configuration is intended to be a serializable object and does not call services, record data, or
/// anything else. It does include a step identifier that can be used to let the `RSDTaskController` know when
/// to trigger the async action.
///
/// - seealso: `RSDTaskController` and `RSDAsyncAction`.
///
public protocol RSDAsyncActionConfiguration : RSDPermissionsConfiguration {
    
    /// A short string that uniquely identifies the asynchronous action within the task. If started asynchronously,
    /// then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    var identifier : String { get }
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    var startStepIdentifier: String? { get }
    
    /// Validate the async action to check for any configuration that should throw an error.
    func validate() throws
}
