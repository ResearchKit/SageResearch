//
//  RSDAsyncAction.swift
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

/// `RSDAsyncActionVendor` is an extension of the configuration protocol for configurations that
/// know how to vend a new controller.
///
public protocol RSDAsyncActionVendor : RSDAsyncActionConfiguration {
    
    /// Instantiate a controller appropriate to this configuration.
    /// - parameter taskViewModel: The current task path to use to initialize the controller.
    /// - returns: An async action controller or nil if the async action is not supported on this device.
    func instantiateController(with taskViewModel: RSDPathComponent) -> RSDAsyncAction?
}

/// `RSDAsyncActionDelegate` is the delegate protocol for `RSDAsyncAction`.
public protocol RSDAsyncActionDelegate : class {
    
    /// Method called when the controller fails. The delegate is responsible for handling the failure.
    func asyncAction(_ controller: RSDAsyncAction, didFailWith error: Error)
}

/// `RSDAsyncActionStatus` is an enum used to track the status of a `RSDAsyncAction`.
@objc
public enum RSDAsyncActionStatus : Int {
    
    /// Initial state before the controller has been started.
    case idle = 0
    
    /// Status if the controller is currently requesting authorization. Once in this state and until the controller
    /// is `starting`, the UI should be blocked from any view transitions.
    case requestingPermission
    
    /// Status if the controller has granted permission, but not yet been started.
    case permissionGranted
    
    /// The controller is starting up. This is the state once `RSDAsyncAction.start()` has been called
    /// but before the recorder or request is running.
    case starting
    
    /// The action is running. For `RSDRecorderConfiguration` controllers, this means that the recording is open.
    /// For `RSDRequestConfiguration` controllers, this means that the request is in-flight.
    case running
    
    /// Waiting for in-flight buffers to be appended and ready to close.
    case waitingToStop
    
    /// Cleaning up by closing any buffers or file handles and processing any results that are returned by this
    /// controller.
    case processingResults
    
    /// Stopping any sensor managers. The controller should move to this state **after** any results are processed.
    /// - note: Once in this state, the async action should **not** be changing the results associated with this action.
    case stopping
    
    /// The controller is finished running and ready to `dealloc`.
    case finished
    
    /// The recorder or request was cancelled and any results may be invalid.
    case cancelled
    
    /// The recorder or request failed and any results may be invalid.
    case failed
}

extension RSDAsyncActionStatus : Comparable {
    public static func <(lhs: RSDAsyncActionStatus, rhs: RSDAsyncActionStatus) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension RSDAsyncActionStatus : CustomStringConvertible {
    public var description: String {
        switch self {
        case .idle:
            return "idle"
        case .requestingPermission:
            return "requestingPermission"
        case .permissionGranted:
            return "permissionGranted"
        case .starting:
            return "starting"
        case .running:
            return "running"
        case .waitingToStop:
            return "waitingToStop"
        case .processingResults:
            return "processingResults"
        case .stopping:
            return "stopping"
        case .finished:
            return "finished"
        case .cancelled:
            return "cancelled"
        case .failed:
            return "failed"
        }
    }
}

/// The completion handler for starting and stopping an async action.
public typealias RSDAsyncActionCompletionHandler = (RSDAsyncAction, RSDResult?, Error?) -> Void

/// A controller for an async action configuration.
public protocol RSDAsyncAction : class {
    
    /// Object equality.
    func isEqual(_ object: Any?) -> Bool
    
    /// Delegate callback for handling action completed or failed.
    var delegate: RSDAsyncActionDelegate? { get set }
    
    /// The status of the controller.
    var status: RSDAsyncActionStatus { get }
    
    /// Is the action currently paused?
    var isPaused: Bool { get }
    
    /// The last error on the action controller.
    /// - note: Under certain circumstances, getting an error will not result in a terminal failure of the controller.
    /// For example, if a controller is both processing motion and camera sensors and only the motion sensors failed
    /// but using them is a secondary action.
    var error: Error? { get }
    
    /// Results for this action controller.
    var result: RSDResult? { get }
    
    /// The configuration used to set up the controller.
    var configuration: RSDAsyncActionConfiguration { get }
    
    /// The associated task path to which the result should be attached.
    var taskViewModel: RSDPathComponent { get }
    
    /// This method should be called on the main thread with the completion handler also called on the main
    /// thread. This method is intended to allow the controller to request any permissions associated with
    /// this controller *before* the step change happens.
    ///
    /// It is the responsibility of the controller to manage the display of any alerts that are not controlled
    /// by the OS. The `viewController` parameter is the view controler that should be used to present any modal
    /// dialogs.
    ///
    /// - note: The calling view controller or application delegate should block any UI presentation changes
    /// until *after* the completion handler is called to ensure that any modals presented by the async
    /// controller or the OS aren't swallowed by other UI events.
    ///
    /// - remark: The controller should call the completion handler with an `Error` if authorization failed.
    /// Whether or not the completion handler includes a non-nil result that includes the authorization status,
    /// is up to the developers and researchers using this controller as a tool for gathering information for
    /// their study.
    ///
    /// - parameters:
    ///     - viewController: The view controler that should be used to present any modal dialogs.
    ///     - completion: The completion handler.
    func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler)
    
    /// Start the asynchronous action with the given completion handler.
    /// - note: The handler may be called on a background thread.
    /// - parameter completion: The completion handler to call once the controller is started.
    func start(_ completion: RSDAsyncActionCompletionHandler?)
    
    /// Pause the action. Ignored if not applicable.
    func pause()
    
    /// Resume the action. Ignored if not applicable.
    func resume()
    
    /// Stop the action with the given completion handler.
    /// - note: The handler may be called on a background thread.
    /// - parameter completion: The completion handler to call once the controller has processed its results.
    func stop(_ completion: RSDAsyncActionCompletionHandler?)
    
    /// Cancel the action.
    func cancel()
    
    /// Let the controller know that the task will move to the given step.
    /// - parameters:
    ///     - step: The step that will be presented.
    ///     - taskViewModel: The current state of the task.
    func moveTo(step: RSDStep, taskViewModel: RSDPathComponent)
}
