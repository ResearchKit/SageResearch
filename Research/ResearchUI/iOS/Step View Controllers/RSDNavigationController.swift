//
//  RSDNavigationController.swift
//  ResearchUI (iOS)
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
@available(*,deprecated, message: "Will be deleted in a future version.")
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
