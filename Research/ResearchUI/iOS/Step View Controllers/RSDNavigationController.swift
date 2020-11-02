//
//  RSDNavigationController.swift
//  ResearchUI (iOS)
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
import Research

/// `RSDNavigationController` extends `UINavigationController` with a pass-through implementation of
/// `RSDStepController`.
///
/// This allows step controllers to be wrapped in a navigation controller for UI implementations that use the
/// features of a navigation controller, while passing control of the step to the step controller.
///
/// - note: For applications that customize the navigation controller with their own subclass implementation,
///         this implementation can be copy/pasted and used to extend that custom implementation. This
///         framework does *not* force using this implementation by extending `UINavigationController`
///         directly.
open class RSDNavigationController : UINavigationController, RSDStepController {

    /// The root view controller is assumed to be a `RSDStepController`.
    open var rootStepViewController : (UIViewController & RSDStepController)! {
        return (self.children.first as! (UIViewController & RSDStepController))
    }
    
    /// get/set `rootStepViewController.step`
    public var stepViewModel: RSDStepViewPathComponent! {
        get {
            return rootStepViewController.stepViewModel
        }
        set(newValue) {
            rootStepViewController.stepViewModel = newValue
        }
    }
    
    /// calls `rootStepViewController.didFinishLoading()`
    public func didFinishLoading() {
        rootStepViewController.didFinishLoading()
    }
    
    public func goForward() {
        rootStepViewController.goForward()
    }
    
    public func goBack() {
        rootStepViewController.goBack()
    }
}
