//
//  RSDModalStepTaskController.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

/// The delegate for a `RSDModalStepTaskController`.
public protocol RSDModalStepTaskControllerDelegate : class {
    
    /// The `goForward()` method was called.
    func goForward(with taskController: RSDModalStepTaskController)
    
    /// The `goBack()` method was called.
    func goBack(with taskController: RSDModalStepTaskController)
}

/// A `RSDModalStepTaskController` can be used as the task controller for a modally displayed step view
/// controller where the results of the step are not managed as a step in a larger task. The purpose of this
/// class is to include a responder to the `goForward()` and `goBack()` functions that **also** includes a
/// task path that is different from the task path pointer on the controlling data source. For example, if
/// the data source includes a "edit" button that displays a modal step view controller that edits the
/// results on the data source, but is described using a different step (and thus requires a different task
/// path).
open class RSDModalStepTaskController : NSObject, RSDTaskController {
    
    /// The task path - this needs to be set before the step controller is displayed.
    open var taskPath: RSDTaskPath!
    
    /// The step controller managed by this task controller.
    open var stepController: RSDStepController!
    
    /// The delegate for the task controller.
    public weak var delegate: RSDModalStepTaskControllerDelegate?
    
    public override init() {
        super.init()
    }
    
    /// Returns `true`.
    open var isForwardEnabled: Bool {
        return true
    }
    
    /// Returns `false`.
    open var hasStepAfter: Bool {
        return false
    }
    
    /// Returns `false`.
    open var hasStepBefore: Bool {
        return false
    }
    
    /// Returns `false`.
    open var canSaveTaskProgress: Bool {
        return false
    }
    
    /// Calls the delegate `goForward(with:)` method.
    open func goForward() {
        self.delegate?.goForward(with: self)
    }
    
    /// Calls the delegate `goBack(with:)` method.
    open func goBack() {
        self.delegate?.goBack(with: self)
    }
    
    /// Calls `goBack()`.
    open func handleTaskCancelled(shouldSave: Bool) {
        goBack()
    }
}
