//
//  RSDRequestConfiguration.swift
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


/// `RSDRequestConfiguration` is used to start an asynchronous service such as a url request or fetching
/// from core data.
///
/// - note: This configuration type is stubbed out for future work. This is not currently implemented in
/// either `RSDTaskController` or `RSDTaskViewController`. (syoung 11/15/2017)
///
public protocol RSDRequestConfiguration : RSDAsyncActionConfiguration {
    
    /// An identifier marking a step to wait to display until the action is completed. This is only valid
    /// for actions that are single result actions and not continuous recorders.
    var waitStepIdentifier: String? { get }
    
    /// A time interval after which the action should be reset. For example, if the action queries a
    /// weather service and the user backgrounds the app for more than the reset time, then the weather
    /// service should be queried again. If `0`, then the action will never reset.
    var resetTimeInterval: TimeInterval { get }
    
    /// A time interval after which the action should be cancelled. If `0`, then the action will not
    /// timeout and will wait indefinitely. This is not recommended UI.
    var timeoutTimeInterval: TimeInterval { get }
}
