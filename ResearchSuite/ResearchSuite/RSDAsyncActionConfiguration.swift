//
//  RSDAsyncActionConfiguration.swift
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

/// `RSDPermissionType` is a generic configuration object with information about a given permission.
/// The permission type can be used by the app to handle gracefully requesting authorization from
/// the user for access to sensors and hardware required by the app.
public protocol RSDPermissionType {
    
    /// An identifier for the permission.
    var identifier: String { get }
}

/// `RSDAsyncActionConfiguration` defines general configuration for an asynchronous background action that
/// should be run in the background. Depending upon the parameters and how the action is set up, this could
/// be something that is run continuously or else is paused or reset based on a timeout interval.
///
/// The configuration is intended to be a serializable object and does not call services, record data, or
/// anything else. It does include a step identifier that can be used to let the `RSDTaskController` know when
/// to trigger the async action.
///
/// - seealso: `RSDTaskController` and `RSDAsyncActionController`.
///
public protocol RSDAsyncActionConfiguration {
    
    /// A short string that uniquely identifies the asynchronous action within the task. If started asynchronously,
    /// then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    var identifier : String { get }
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    var startStepIdentifier: String? { get }
    
    /// List of the permissions required for this action.
    var permissions: [RSDPermissionType] { get }
    
    /// Validate the async action to check for any configuration that should throw an error.
    func validate() throws
}

/// `RSDAsyncActionControllerVendor` is an extension of the configuration protocol for configurations that
/// know how to vend a new controller.
///
public protocol RSDAsyncActionControllerVendor : RSDAsyncActionConfiguration {
    
    /// Instantiate a controller appropriate to this configuration.
    /// - parameter taskPath: The current task path to use to initialize the controller.
    /// - returns: An async action controller or nil if the async action is not supported on this device.
    func instantiateController(with taskPath: RSDTaskPath) -> RSDAsyncActionController?
}

/// `RSDRecorderConfiguration` is used to configure a recorder. For example, recording accelerometer data
/// or video.
public protocol RSDRecorderConfiguration : RSDAsyncActionConfiguration {
    
    /// An identifier marking the step at which to stop the action. If `nil`, then the action will be
    /// stopped when the task is stopped.
    var stopStepIdentifier: String? { get }
    
    /// Whether or not the recorder requires background audio.
    var requiresBackgroundAudio: Bool { get }
}

/// `RSDJSONRecorderConfigureation` is used to configure a recorder to record JSON samples.
/// - seealso: `RSDSampleRecorder`
public protocol RSDJSONRecorderConfiguration : RSDRecorderConfiguration {
    
    /// Should the logger use a dictionary as the root element?
    ///
    /// If `true` then the logger will open the file with the samples included in an array with the key
    /// of "items". If `false` then the file will use an array as the root elemenent and the samples will
    /// be added to that array. Default = `false`
    ///
    /// - example:
    ///
    /// If the log file uses a dictionary as the root element then
    /// ```
    ///    {
    ///    "startDate" : "2017-10-16T22:28:09.000-07:00",
    ///    "items"     : [
    ///                     {
    ///                     "uptime": 1234.56,
    ///                     "stepPath": "/Foo Task/sectionA/step1",
    ///                     "timestampDate": "2017-10-16T22:28:09.000-07:00",
    ///                     "timestamp": 0
    ///                     },
    ///                     // ... more samples ... //
    ///                 ]
    ///     }
    /// ```
    ///
    /// If the log file uses an array as the root element then
    /// ```
    ///    [
    ///     {
    ///     "uptime": 1234.56,
    ///     "stepPath": "/Foo Task/sectionA/step1",
    ///     "timestampDate": "2017-10-16T22:28:09.000-07:00",
    ///     "timestamp": 0
    ///     },
    ///     // ... more samples ... //
    ///     ]
    /// ```
    ///
    var usesRootDictionary: Bool { get }
}

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
