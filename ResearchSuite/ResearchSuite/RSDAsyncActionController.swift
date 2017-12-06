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
import UIKit

/// `RSDAsyncActionControllerDelegate` is the delegate protocol for `RSDAsyncActionController`.
public protocol RSDAsyncActionControllerDelegate : class {
    
    /// Method called when the controller fails. The delegate is responsible for handling the failure.
    func asyncActionController(_ controller: RSDAsyncActionController, didFailWith error: Error)
}

/// The completion handler for starting and stopping an async action.
public typealias RSDAsyncActionCompletionHandler = (RSDAsyncActionController, RSDResult?, Error?) -> Void

/// A controller for an async action configuration.
public protocol RSDAsyncActionController : class {
    
    /// Delegate callback for handling action completed or failed.
    weak var delegate: RSDAsyncActionControllerDelegate? { get set }
    
    /// Is the action currently running?
    var isRunning: Bool { get }
    
    /// Is the action currently paused?
    var isPaused: Bool { get }
    
    /// Was the action cancelled?
    var isCancelled: Bool { get }
    
    /// Results for this action controller.
    var result: RSDResult? { get }
    
    /// The configuration used to set up the controller.
    var configuration: RSDAsyncActionConfiguration { get }
    
    #if os(watchOS)
    
    /// **Available** for watchOS.
    ///
    /// This method should be called on the main thread with the completion handler also called on the main
    /// thread. This method is intended to allow the controller to request any permissions associated with
    /// this controller *before* the step change happens.
    ///
    /// On an Apple watch, authorization handling is managed by using a handshake request that requires opening
    /// the paired phone and responding to the authorization on the phone. This is a cumbersome UX that must be
    /// handled using the app delegate so it is recommended that the architecture for apps that use the watch
    /// include authorization handling though the iPhone app prior to running a task on the watch.
    ///
    /// - remark: The controller should call the completion handler with an `Error` if authorization failed.
    /// Whether or not the completion handler includes a non-nil result that includes the authorization status,
    /// is up to the developers and researchers using this controller as a tool for gathering information for
    /// their study.
    ///
    /// - parameters:
    ///     - completion: The completion handler.
    func requestPermissions(_ completion: RSDAsyncActionCompletionHandler)
    
    #else
    /// **Available** for iOS and tvOS.
    ///
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
    func requestPermissions(on viewController: UIViewController, _ completion: RSDAsyncActionCompletionHandler)
    #endif
    
    /// Start the asynchronous action with the given completion handler.
    /// - note: The handler may be called on a background thread.
    /// - parameter taskPath: The current state of the task.
    func start(at taskPath: RSDTaskPath, _ completion: RSDAsyncActionCompletionHandler?)
    
    /// Pause the action. Ignored if not applicable.
    func pause()
    
    /// Resume the action. Ignored if not applicable.
    func resume()
    
    /// Stop the action with the given completion handler.
    /// - note: The handler may be called on a background thread.
    func stop(_ completion: RSDAsyncActionCompletionHandler?)
    
    /// Cancel the action.
    func cancel()
    
    /// Let the controller know that the task will move to the given step.
    /// - parameters:
    ///     - step: The step that will be presented.
    ///     - taskPath: The current state of the task.
    func moveTo(step: RSDStep, taskPath: RSDTaskPath)
}
