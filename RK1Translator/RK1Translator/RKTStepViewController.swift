//
//  RKTStepViewController.swift
//  RK1Translator
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

import UIKit
import ResearchStack2UI

/// `RKTStepViewController` extends `UINavigationController` with a pass-through implementation of
/// `ORKStepViewController`. This can be used with the ResearchStack2UI implementation of `RSDTaskViewController`
/// to wrap an `ORKStepViewController` for use as a view controller presented by the `RSDTaskViewController`.
///
/// - seealso: `RSDStepViewControllerVendor`, `RSDTaskViewController`
open class RKTStepViewController:  UINavigationController, RSDStepController, RSDCancelActionController, ORKStepViewControllerDelegate {
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootStepViewController)
        (rootViewController as! ORKStepViewController).delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// The root view controller is assumed to be an `ORKStepViewController`.
    open var rootStepViewController : ORKStepViewController! {
        return self.childViewControllers.first as! ORKStepViewController
    }
    
    /// The task controller for this step view controller wrapper.
    public var taskController: RSDTaskController!
    
    /// Return the `ORKStep` if it conforms to the `RSDStep` protocol; otherwise, this will look to
    /// see if an `RSDStep` has been set for this property and ensure that the private step is copied
    /// to a step with a matching step identifier.
    public var step: RSDStep! {
        get {
            if let rsdStep = self.rootStepViewController.step as? RSDStep {
                return rsdStep
            } else if let orkStep = self.rootStepViewController.step, ((_step == nil) || (_step!.identifier != orkStep.identifier)) {
                _step = ((_step as? RSDCopyWithIdentifier)?.copy(with: orkStep.identifier) as? RSDStep) ??
                    RSDGenericStepObject(identifier: orkStep.identifier, stepType: RSDStepType(rawValue: NSStringFromClass(type(of: orkStep)) as String), userInfo: [:])
            }
            return _step
        }
        set {
            if let orkStep = newValue as? ORKStep {
                self.rootStepViewController.step = orkStep
            } else {
                _step = newValue
            }
        }
    }
    private var _step: RSDStep?
    
    /// If this is a wait step view controller then call `goForward()` otherwise, do nothing.
    open func didFinishLoading() {
        if let vc = self.rootStepViewController as? ORKWaitStepViewController {
            vc.goForward()
        }
    }
    
    /// Is forward navigation enabled? The default implementation will check the task controller.
    open var isForwardEnabled: Bool {
        return taskController.isForwardEnabled
    }
    
    /// Call `rootStepViewController.goForward()`
    open func goForward() {
        rootStepViewController.goForward()
    }
    
    /// Call `rootStepViewController.goBackward()`
    open func goBack() {
        rootStepViewController.goBackward()
    }
    
    /// Call `rootStepViewController.skipForward()`
    open func skipForward() {
        rootStepViewController.skipForward()
    }
    
    /// Calls `confirmCancel()`
    open func cancel() {
        self.confirmCancel()
    }
    
    /// Should confirm cancel if not the first step.
    open func shouldConfirmCancel() -> Bool {
        return !self.taskController.taskPath.isFirstStep
    }
    
    /// Calls `taskController.handleTaskCancelled()`
    open func cancelTask(shouldSave: Bool) {
        self.taskController.handleTaskCancelled(shouldSave: shouldSave)
    }

    /// Calls `rootStepViewController.hasPreviousStep()`
    public var hasStepBefore: Bool {
        return rootStepViewController.hasPreviousStep()
    }
    
    /// Calls `rootStepViewController.hasNextStep()`
    public var hasStepAfter: Bool {
        return rootStepViewController.hasNextStep()
    }
    
    /// Either go forward or go backward.
    open func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
        // Mark the step view controller as finished
        if direction == .forward {
            if let stepResult = stepViewController.result {
                self.taskController.taskPath.appendStepHistory(with: stepResult)
            }
            self.taskController.goForward()
        } else {
            self.taskController.goBack()
        }
    }
    
    /// Base class implementation does nothing.
    open func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
        // do nothing
    }
    
    /// Call through to the task controller `handleTaskFailure()` method
    open func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
        guard let err = error else { return }
        self.taskUIController?.handleTaskFailure(with: err)
    }
    
    /// Base class implementation does nothing.
    open func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: Error) {
        // do nothing
    }
}
