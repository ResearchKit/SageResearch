//
//  RSDTaskViewController.swift
//  ResearchSuiteUI
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

/**
 `RSDPageViewControllerProtocol` allows replacing the `UIPageViewController` in the base class with a different view controller implementation. It is assumed that the implementation is for a view controller appropriate to the current device.
 */
public protocol RSDPageViewControllerProtocol {
    func setViewControllers(_ viewControllers: [UIViewController]?, direction: RSDStepDirection, animated: Bool, completion: ((Bool) -> Swift.Void)?)
}

extension UIPageViewController : RSDPageViewControllerProtocol {
    public func setViewControllers(_ viewControllers: [UIViewController]?, direction: RSDStepDirection, animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        let pageDirection: UIPageViewControllerNavigationDirection = (direction == .reverse) ? .reverse : .forward
        self.setViewControllers(viewControllers, direction: pageDirection, animated: animated && (direction != .none), completion: completion)
    }
}

public enum RSDTaskFinishReason : Int {
    case completed, cancelled, failed
}

public protocol RSDTaskViewControllerDelegate : class {
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), didFinishWith reason: RSDTaskFinishReason, error: Error?)
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), viewControllerFor step: RSDStep) -> (UIViewController & RSDStepController)?
}

/**
 Optional protocol that can be used to get the step view controller from the step rather than from the task view controller or delegate.
 */
public protocol RSDStepViewControllerVendor : RSDUIStep {

    /**
     Returns the view controller vended by the step.
     
     @param taskPath    The current task path to use to instantiate the view controller
     
     @return            The instantiated view controller or `nil` if there isn't one.
     */
    func instantiateViewController(with taskPath: RSDTaskPath) -> (UIViewController & RSDStepController)?
}

/**
 `RSDTaskViewController` is an implementation of task view controller that is suitable to the iPhone or iPad. To use this view controller, the
 */
open class RSDTaskViewController: UIViewController, RSDTaskController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    open weak var delegate: RSDTaskViewControllerDelegate?
    
    
    // MARK: View controller vending
    
    open var currentStoryboard: UIStoryboard? {
        if let storyboardInfo = self.taskPath.taskInfo?.storyboardInfo {
            return UIStoryboard(name: storyboardInfo.storyboardIdentifier, bundle: storyboardInfo.storyboardBundle)
        }
        return self.storyboard
    }
    
    open func viewControllerIdentifier(for step: RSDStep) -> String? {
        return self.taskPath.taskInfo?.storyboardInfo?.viewControllerIdentifier(for: step)
    }
    
    open func viewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        // Exit early if the delegate, step or storyboard returns a view controller
        if let vc = delegate?.taskViewController(self, viewControllerFor: step) {
            return vc
        }
        if let vc = (step as? RSDStepViewControllerVendor)?.instantiateViewController(with: self.taskPath) {
            return vc
        }
        if let vcIdentifier = viewControllerIdentifier(for: step),
            let vc = self.currentStoryboard?.instantiateViewController(withIdentifier: vcIdentifier) {
            if let stepVC = vc as? (UIViewController & RSDStepController) {
                stepVC.step = step
                return stepVC
            } else {
                assertionFailure("View Controller \(vc) does not conform to the RSDStepController protocol.")
            }
        }
        return self.vendDefaultViewController(for: step)
    }
    
    open func vendDefaultViewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        if let taskInfo = step as? RSDTaskInfoStep {
            return RSDTaskInfoStepViewController(taskInfo: taskInfo)
        } else if RSDGenericStepViewController.doesSupport(step) {
            return RSDGenericStepViewController(step: step)
        } else {
            return DebugStepViewController(step: step)
        }
    }
    
    // MARK: RSDTaskController
    
    open var factory: RSDFactory?
    
    public var taskPath: RSDTaskPath!
    
    public var currentStepController: RSDStepController? {
        return pageViewController.childViewControllers.first as? RSDStepController
    }
    
    /// Default implementation is to always fetch subtasks.
    open func shouldFetchSubtask(for step: RSDTaskInfoStep) -> Bool {
        return true
    }
    
    /// Default implementation is to always page the section steps.
    open func shouldPageSectionSteps(for step: RSDSectionStep) -> Bool {
        return true
    }
    
    open func showLoading(for taskInfo: RSDTaskInfoStep) {
        let vc = viewController(for: taskInfo)
        vc.taskController = self
        let animated = (taskPath.parentPath != nil)
        let direction: RSDStepDirection = animated ? .forward : .none
        pageViewController.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
    }
    
    public func handleFinishedLoading() {
        // Forward the finished loading message to the RSDTaskInfoStepUIController (if present)
        self.currentStepController?.didFinishLoading()
    }
    
    open func hideLoadingIfNeeded() {
        // TODO: syoung 10/11/2017 Implement
    }
    
    open func navigate(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection) {
        let vc = viewController(for: step)
        // Set the step view controller delegate if appropriate
        if let stepDelegate = delegate as? RSDStepViewControllerDelegate,
            let stepVC = vc as? RSDStepViewControllerProtocol, stepVC.delegate == nil {
            stepVC.delegate = stepDelegate
        }
        vc.taskController = self
        pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    }
    
    open func handleTaskFailure(with error: Error) {
        delegate?.taskViewController(self, didFinishWith: .failed, error: error)
    }
    
    public func handleTaskCompleted() {
        delegate?.taskViewController(self, didFinishWith: .completed, error: nil)
    }
    
    public func handleTaskCancelled() {
        delegate?.taskViewController(self, didFinishWith: .cancelled, error: nil)
    }

    
    // MARK: Initializers
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(task: RSDTask) {
        super.init(nibName: nil, bundle: nil)
        self.topLevelTask = task
    }
    
    public init(taskInfo: RSDTaskInfoStep) {
        super.init(nibName: nil, bundle: nil)
        self.topLevelTaskInfo = taskInfo
    }
    
    
    // MARK: View management
    
    public private(set) var pageViewController: (UIViewController & RSDPageViewControllerProtocol)!
    
    /**
     This is a work-around to not being able to hook up child view controllers via the storyboard IBOutlet. The method is called in `viewDidLoad` to see if there is already a view controller of the expected type that is included in the storyboard or nib that was used to create this view controller.
     
     @return    If found, returns a view controller that conforms to `RSDPageViewControllerProtocol`.
     */
    open func findPageViewController() -> (UIViewController & RSDPageViewControllerProtocol)? {
        guard let vc = self.childViewControllers.first(where: { $0 is RSDPageViewControllerProtocol })
            else {
                return nil
        }
        return vc as? (UIViewController & RSDPageViewControllerProtocol)
    }
    
    /**
     This method will add a page view controller in the instance where this view controller was loaded without one. The method is called in `viewDidLoad` if `findPageViewController` returns nil. This method should instantiate a view controller and add it to this view controller as a child view controller.
     
     @return    A view controller that conforms to `RSDPageViewControllerProtocol`.
     */
    open func addPageViewController() -> (UIViewController & RSDPageViewControllerProtocol) {
        // Set up the page view controller
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.addChildViewController(pageVC)
        pageVC.view.frame = self.view.bounds
        self.view.addSubview(pageVC.view)
        pageVC.view.alignAllToSuperview(padding: 0)
        pageVC.didMove(toParentViewController: self)
        return pageVC
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the page view controller. By default, this will load a UIPageViewController if it does not
        // find one amongst it's children.
        self.pageViewController = findPageViewController() ?? addPageViewController()
        self.pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the task if needed.
        self.startTaskIfNeeded()
    }
    
    
    // MARK: UIPageViewControllerDataSource
    
    open var currentStepViewController: (UIViewController & RSDStepController)? {
        return self.currentStepController as? (UIViewController & RSDStepController)
    }
    
    /// Respond to a gesture to go back. Always returns `nil` but will call `goBack()` if appropriate.
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard self.hasStepBefore else { return nil }
        self.currentStepController?.goBack()
        return nil
    }
    
    /// Respond to a gesture to go forward. Always returns `nil` but will call `goForward()` if appropriate.
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard self.hasStepAfter && (currentStepController?.isForwardEnabled ?? false) else { return nil }
        self.currentStepController?.goForward()
        return nil
    }
}
