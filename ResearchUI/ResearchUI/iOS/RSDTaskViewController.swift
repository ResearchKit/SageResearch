//
//  RSDTaskViewController.swift
//  ResearchUI
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
import AVFoundation

/// `RSDPageViewControllerProtocol` allows replacing the `UIPageViewController` in the base class with a different
/// view controller implementation. It is assumed that the implementation is for a view controller appropriate to
/// the current device.
public protocol RSDPageViewControllerProtocol {
    
    /// Set the view controllers.
    ///
    /// - note: The default implementation of `RSDTaskViewController` will use a page view controller
    /// and will present one view at a time.
    ///
    /// - parameters:
    ///     - viewControllers: The view controllers to add to page view.
    ///     - direction: The direction of navigation.
    ///     - animated: Whether or not adding the child view controllers should be animated.
    ///     - completion: The animation completion handler.
    func setViewControllers(_ viewControllers: [UIViewController]?, direction: RSDStepDirection, animated: Bool, completion: ((Bool) -> Swift.Void)?)
}

extension UIPageViewController : RSDPageViewControllerProtocol {
    public func setViewControllers(_ viewControllers: [UIViewController]?, direction: RSDStepDirection, animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        let pageDirection: UIPageViewController.NavigationDirection = (direction == .reverse) ? .reverse : .forward
        self.setViewControllers(viewControllers, direction: pageDirection, animated: animated && (direction != .none), completion: completion)
    }
}

/// `RSDOptionalTaskViewControllerDelegate` is a delegate protocol defined as `@objc` to allow the methods to be optionally
/// implemented. As such, these methods cannot take Swift protocols as their paramenters.
@objc
public protocol RSDOptionalTaskViewControllerDelegate : class, NSObjectProtocol {
    
    /// Asks the delegate for a custom view controller for the specified step.
    ///
    /// If this method is implemented, the task view controller calls it to obtain a step view controller for the step.
    ///
    /// In most circumstances, the task view controller can determine which view controller to instantiate for a step.
    /// However, if you want to provide a specific view controller instance, you can call this method to do so.
    ///
    /// The delegate should provide a step view controller implementation for any custom step that does not implement
    /// either the `RSDStepViewControllerVendor` protocol or the `RSDThemedUIStep` protocol where the `viewTheme` is
    /// non-nil.
    ///
    /// - parameters:
    ///     - taskViewController: The calling `(UIViewController & RSDTaskController)` instance.
    ///     - step: The step for which a view controller is requested. This will be an object that conforms to
    ///             the `RSDStep` protocol.
    /// - returns: A custom view controller, or `nil` to request the default step controller for this step.
    @available(*, deprecated)
    @objc optional
    func taskViewController(_ taskViewController: UIViewController, viewControllerFor step: Any) -> UIViewController?
    
    /// Asks the delegate for a custom view controller for the specified step.
    ///
    /// If this method is implemented, the task view controller calls it to obtain a step view controller for the step.
    ///
    /// In most circumstances, the task view controller can determine which view controller to instantiate for a step.
    /// However, if you want to provide a specific view controller instance, you can call this method to do so.
    ///
    /// The delegate should provide a step view controller implementation for any custom step that does not implement
    /// either the `RSDStepViewControllerVendor` protocol or the `RSDThemedUIStep` protocol where the `viewTheme` is
    /// non-nil.
    ///
    /// - parameters:
    ///     - taskViewController: The calling `(UIViewController & RSDTaskController)` instance.
    ///     - stepModel: The step and parent path component for this step.
    /// - returns: A custom view controller, or `nil` to request the default step controller for this step.
    @objc optional
    func taskViewController(_ taskViewController: UIViewController, viewControllerForStep stepModel: RSDStepViewModel) -> UIViewController?
    
    /// Asks the delegate whether or not the task should show a view controller for the  `RSDTaskInfoStep`
    /// while the initial task is being fetched.
    ///
    /// If defined, then:
    ///     * If this function returns `true` then a view controller specific to the `RSDTaskInfoStep` will be displayed.
    ///     * If this function returns `false` then `showLoadingView()` will be called and the task will automatically
    ///       forward to the first step once the task is fetched.
    ///
    /// If not defined, then:
    ///     * `showLoadingView()` will be called and the task will automatically forward to the first step once the task
    ///       is fetched.
    ///
    /// - parameters:
    ///     - taskViewController: The calling `(UIViewController & RSDTaskController)` instance.
    ///     - step: The step for which a view controller is requested. This will be an object that conforms to
    ///             the `RSDTaskInfoStep` protocol.
    /// - returns: A `Bool` value indicating whether or not the task controller should show the task info step.
    @objc optional
    func taskViewController(_ taskViewController: UIViewController, shouldShowTaskInfoFor step: Any) -> Bool
}

/// `RSDTaskViewControllerDelegate` is an extension of the `RSDTaskControllerDelegate` protocol that also
/// implements optional methods defined by `RSDOptionalTaskViewControllerDelegate`.
public protocol RSDTaskViewControllerDelegate : RSDOptionalTaskViewControllerDelegate, RSDTaskControllerDelegate {
}

/// Optional protocol that can be used to get the step view controller from the step rather than from the
/// task view controller or delegate.
public protocol RSDStepViewControllerVendor : RSDStep {

    /// Returns the view controller vended by the step.
    /// - parameter taskViewModel: The current task path to use to instantiate the view controller
    /// - returns: The instantiated view controller or `nil` if there isn't one.
    func instantiateViewController(with parent: RSDPathComponent?) -> (UIViewController & RSDStepController)?
}

/// `RSDTaskViewController` is the default implementation of task view controller that is suitable to the iPhone or iPad.
/// The default implementation will display a series of steps using a `UIPageViewController`. This controller will also handle
/// starting and stoping async actions and vending the appropriate step view controller for each step.
open class RSDTaskViewController: UIViewController, RSDTaskController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, RSDAsyncActionDelegate, RSDLoadingViewControllerProtocol {

    /// The delegate for the task view controller.
    ///
    /// - precondition: The delegate must support completion. When the task view controller completes its task, it is
    /// the delegate's responsibility to dismiss it.
    /// - seealso: `RSDTaskControllerDelegate.taskViewController(:,didFinishWith reason:,error:)`.
    open weak var delegate: RSDTaskViewControllerDelegate?
    
    // MARK: Initializers
    
    /// Initializer for initializing using a XIB file.
    /// - parameters:
    ///     - nibNameOrNil: The name of the XIB file or `nil`.
    ///     - nibBundleOrNil: The name of the bundle or `nil`.
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Initializer for initializing from a storyboard or restoring from shutdown by the OS.
    /// - parameter aDecoder: The decoder used to create the view controller.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Initializer for initializing a view controller that is not associated with a storyboard or nib.
    /// - parameter task: The task to run using this controller.
    public init(task: RSDTask) {
        super.init(nibName: nil, bundle: nil)
        self.task = task
        self.taskViewModel.taskController = self
    }
    
    /// Initializer for initializing a view controller that is not associated with a storyboard or nib.
    /// - parameter taskInfo: The task info (first step) to use to fetch the task to be run using this controller.
    public init(taskInfo: RSDTaskInfo) {
        super.init(nibName: nil, bundle: nil)
        self.taskInfo = taskInfo
        self.taskViewModel.taskController = self
    }
    
    /// Initializer for initializing a view controller that is not associated with a storyboard or nib.
    /// - parameter task: The task to run using this controller.
    public init(taskViewModel: RSDTaskViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.taskViewModel = taskViewModel
        self.taskViewModel.taskController = self
    }
    
    // MARK: View controller vending
    
    @available(*, unavailable)
    open func viewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        fatalError("This method is no longer available.")
    }
    
    /// Main entry for vending an appropriate step view controller for a given step.
    ///
    /// This method will look for a step view controller in the following order:
    /// 1. Call the delegate method `taskViewController(:, viewControllerForStep stepModel:)` and return the
    ///    view controller supplied by that method. This will throw an exception if the delegate does not
    ///    return a view controller that conforms to the `RSDStepController` protocol and inherits from
    ///    `UIViewController`.
    /// 2. If the given step implements the `RSDThemedUIStep` protocol and returns a `viewTheme`, then call
    ///    `instantiateViewController(with viewTheme:)` to instantiate a view controller for this step.
    /// 3. If the given step implements the `RSDStepViewControllerVendor` protocol and returns a non-nil
    ///    instance of a view controller, then that will be returned.
    /// 4. If none of the functions listed above returns a view controller then return the view controller
    ///    instantiated by calling `vendDefaultViewController(for step:, with parent:)`.
    ///
    /// - parameter step: The step to display.
    /// - returns: The view controller to use when displaying a given step.
    open func stepController(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepController? {
        guard let controller = _stepController(for: step, with: parent) else { return nil }
        if controller.stepViewModel == nil {
            controller.stepViewModel = RSDStepViewModel(step: step, parent: parent)
        }
        return controller
    }
    
    private func _stepController(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepController? {
        // Exit early if the delegate, step or storyboard returns a view controller
        if let vc = delegate?.taskViewController?(self, viewControllerForStep: RSDStepViewModel(step: step, parent: parent)) {
            return (vc as! RSDStepController)
        }
        // TODO: syoung 09/07/2018 remove the deprecated method once refactor is completed.
        if let vc = delegate?.taskViewController?(self, viewControllerFor: step) {
            let stepVC = vc as! RSDStepController
            if stepVC.stepViewModel?.parent == nil, let stepViewModel = stepVC.stepViewModel as? RSDStepViewModel {
                stepViewModel.parent = parent
            }
            return stepVC
        }
        if let viewTheme = (step as? RSDThemedUIStep)?.viewTheme, let vc = instantiateViewController(with: viewTheme) {
            return vc
        }
        if let vc = (step as? RSDStepViewControllerVendor)?.instantiateViewController(with: parent) {
            return vc
        }
        return self.vendDefaultViewController(for: step, with: parent)
    }
    
    /// Instantiate a step view controller using the given view theme element.
    ///
    /// - parameter viewTheme: The view theme element with the nib or storyboard identifier.
    /// - returns: A view controller instantiated with the given view theme element.
    open func instantiateViewController(with viewTheme: RSDViewThemeElement) -> (UIViewController & RSDStepController)? {
        if let storyboardIdentifier = viewTheme.storyboardIdentifier {
            let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: viewTheme.bundle)
            return storyboard.instantiateViewController(withIdentifier: viewTheme.viewIdentifier) as? (UIViewController & RSDStepController)
        }
        else {
            return RSDStepViewController(nibName: viewTheme.viewIdentifier, bundle: viewTheme.bundle)
        }
    }
    
    /// This is the default factory method for vending a view controller appropriate to a given step.
    /// This method is the fall-through for `viewController(for step:)`.
    ///
    /// The view controller vended is a drop-through with the following conditions:
    /// 1. If the step implements the `RSDTaskInfoStep` protocol then instantiate a `RSDTaskInfoStepViewController`.
    /// 2. If `step.stepType == .countdown` then instantiate a `RSDCountdownStepViewController`.
    /// 3. If the step implements the `RSDActiveUIStep` protocol, `duration > 0`, and the step includes the command for
    ///    `RSDActiveUIStepCommand.transitionAutomatically` then instantiate a `RSDActiveStepViewController`.
    /// 4. If `RSDTableStepViewController.doesSupport()` returns `true` then instantiate a `RSDTableStepViewController`
    /// 5. Otherwise, instantiate a `DebugStepViewController` to be used during development as a placeholder.
    ///
    /// - parameter step: The step to display.
    /// - returns: The base class implementation of a step view controller or `DebugStepViewController`
    ///            if undefined.
    open func vendDefaultViewController(for step: RSDStep, with parent: RSDPathComponent?) -> (UIViewController & RSDStepController) {
        if step.stepType == .overview {
            return RSDOverviewStepViewController(step: step, parent: parent)
        }
        else if let taskInfo = step as? RSDTaskInfoStep {
            return RSDTaskInfoStepViewController(taskInfo: taskInfo, parent: parent)
        }
        else if step.stepType == .countdown {
            // If this is a countdown step then the step type is 
            return RSDCountdownStepViewController(step: step, parent: parent)
        }
        else if let activeStep = step as? RSDActiveUIStep,
            activeStep.duration > 0,
            activeStep.commands.contains(.transitionAutomatically) {
            return RSDActiveStepViewController(step: step, parent: parent)
        }
        else if RSDTableStepViewController.doesSupport(step) {
            // If this step *can* be displayed using the generic step view controller, then default to that
            // rather than the using the debug step.
            return RSDTableStepViewController(step: step, parent: parent)
        }
        else {
            // If no default is set the use the debug controller
            return DebugStepViewController(step: step, parent: parent)
        }
    }
    
    
    // MARK: Async action vending
    
    /// Main entry for vending an appropriate async action controller for a given configuration.
    ///
    /// This method will look for an async action controller in the following order:
    /// 1. Call the delegate method `taskViewController(:, asyncActionFor configuration:)` and
    ///    return the controller supplied by that method.
    /// 2. If the given configuration implements the `RSDAsyncActionVendor` protocol and returns
    ///    a non-nil instance of a controller, then that will be returned.
    /// 3. Otherwise, return the controller instantiated by calling `vendDefaultAsyncActionController(for step:)`.
    ///
    /// - parameter configuration: The configuration for this async action.
    /// - returns: The async action controller for this confguration, or `nil` if the action is not supported
    ///            by this platform.
    open func asyncAction(for configuration: RSDAsyncActionConfiguration, path: RSDPathComponent) -> RSDAsyncAction? {
        if let vender = configuration as? RSDAsyncActionVendor {
            return vender.instantiateController(with: path)
        } else {
            return vendDefaultAsyncActionController(for: configuration)
        }
    }
    
    /// This is the default factory method for vending an async action controller appropriate to a given configuration.
    /// This method is the fall-through for `asyncAction(for configuration:)`.
    ///
    /// The base class will return `nil`, but this is provided to allow a subclass of `RSDTaskViewController` to vend
    /// an async action controller.
    ///
    /// - parameter configuration: The configuration for this async action.
    /// - returns: The async action controller for this confguration, or `nil` if the action is not supported
    ///            by this platform.
    open func vendDefaultAsyncActionController(for configuration: RSDAsyncActionConfiguration) -> RSDAsyncAction? {
        return nil
    }
    
    /// Handle a failure of the async action controller.
    ///
    /// The default implementation will record an error result to the task results and then remove
    /// the controller from the list of controllers being managed by the task view controller.
    ///
    /// - parameters:
    ///     - controller: The controller that has failed.
    ///     - error: The failure error.
    open func asyncAction(_ controller: RSDAsyncAction, didFailWith error: Error) {
        DispatchQueue.main.async {
            self._addErrorResult(for: controller, error: error)
            self._removeAsyncActionController(controller)
        }
    }
    
    /// Cancel all the async action controllers being managed by this task controller.
    public func cancelAllAsyncActions() {
        for controller in self.currentAsyncControllers {
            controller.cancel()
        }
    }
    

    // MARK: `RSDTaskController` protocol implementation
    
    /// A mutable path object used to track the current state of a running task.
    public var taskViewModel: RSDTaskViewModel! {
        didSet {
            self.taskViewModel.taskController = self
        }
    }
    
    /// Returns a list of the async action controllers that are currently active. This includes controllers
    /// that are requesting permissions, starting, running, *and* stopping.
    public var currentAsyncControllers: [RSDAsyncAction] {
        return _asyncControllers.allObjects as! [RSDAsyncAction]
    }
    
    /// Show a loading state while fetching the given task from the task info.
    ///
    /// - parameter taskInfo: The task info for the task being fetched.
    open func showLoading(for taskInfo: RSDTaskInfo) {
        // Only if the delegate specifically says to show the task info view, then do so. Otherwise, show loading
        // and exit.
        let step = (taskInfo as? RSDTaskInfoStep) ?? RSDTaskInfoStepObject(with: taskInfo)
        guard let showTaskInfo = self.delegate?.taskViewController?(self, shouldShowTaskInfoFor: step), showTaskInfo,
            let stepController = stepController(for: step, with: self.taskViewModel.currentTaskPath),
            let vc = stepController as? UIViewController
            else {
                self.showLoadingView()
                return
        }
        
        // Show the loading step
        let animated = (taskViewModel.currentChild != nil)
        let direction: RSDStepDirection = animated ? .forward : .none
        pageViewController.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
    }
    
    /// Fired when the task controller is ready to go forward. This method must invoke the `goForward()`
    /// method either to go forward automatically or else go forward after a user action.
    open func handleFinishedLoading() {
        // Forward the finished loading message to the RSDTaskInfoStepUIController (if present)
        // Otherwise, just go forward.
        if let _ = self.currentStepViewController?.stepViewModel.step as? RSDTaskInfoStep {
            self.currentStepViewController?.didFinishLoading()
        } else {
            self.taskViewModel.goForward()
        }
    }
    
    /// Hide the loading state if currently showing it.
    open func hideLoadingIfNeeded() {
        hideStandardLoadingView()
    }
    
    /// Navigate to the next step from the previous step in the given direction.
    ///
    /// - parameters:
    ///     - step: The step to show.
    ///     - previousStep: The previous step. This is either the step currently being displayed or
    ///                     else the `RSDSectionStep` or `RSDTaskStep` if the previous step was the
    ///                     last step in a paged section or fetched subtask.
    ///     - direction: The direction in which to show the animation change.
    ///     - completion: The completion to call once the navigation animation has completed.
    public func show(_ stepController: RSDStepController, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?) {
        let vc = stepController as! UIViewController
        pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: completion)
    }
    
    /// Failed to fetch the task from the current task path. Handle the error. A retry can be fired
    /// by calling `goForward()`.
    ///
    /// - parameter error:   The error returned by the failed task fetch.
    open func handleTaskFailure(with error: Error) {
        _stopAudioSession()
        cancelAllAsyncActions()
        delegate?.taskController(self, didFinishWith: .failed, error: error)
    }
    
    /// The task has completed, either as a result of all the steps being completed or because of an
    /// early exit.
    public func handleTaskDidFinish(with reason: RSDTaskFinishReason, error: Error?) {
        _stopAudioSession()
        cancelAllAsyncActions()
        delegate?.taskController(self, didFinishWith: reason, error: error)
    }
    
    /// This method is called when a task result is "ready" for upload, save, archive, etc. This method
    /// will be called when either (a) the task is ready to dismiss or (b) when the task is displaying
    /// the *last* completion step.
    open func handleTaskResultReady(with taskViewModel: RSDTaskViewModel) {
        delegate?.taskController(self, readyToSave: taskViewModel)
    }
    
    /// Add async action controllers to the shared queue for the given configuations. It is up to the task
    /// controller to decide how to create the controllers and how to manage adding them to the `currentStepController`
    /// array.
    ///
    /// The async actions should *not* be started. Instead they should be returned with `idle` status.
    ///
    /// - note: If creating the recorder might take time, the task controller should move creation to a
    /// background thread so that the main thread is not blocked.
    ///
    /// - parameters:
    ///     - configurations: The configurations to start.
    ///     - path: The path component that is currently being navigated.
    ///     - completion: The completion to call with the instantiated controllers.
    public func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], path: RSDPathComponent, completion: @escaping (([RSDAsyncAction]) -> Void)) {
        // Get the controller for each configuration
        let controllers = configurations.compactMap { (configuration) -> RSDAsyncAction? in
            guard let asyncController = self.asyncAction(for: configuration, path: path) else {
                debugPrint("Did not create controller for async config \(configuration)")
                return nil
            }
            return asyncController
        }
        DispatchQueue.main.async {
            self._addAsyncActionControllersIfNeeded(controllers)
            completion(controllers)
        }
    }

    /// Start the async action controllers. The protocol extension calls this method when an async action
    /// should be started directly *after* the step is presented.
    ///
    /// The task controller needs to handle blocking any navigation changes until the async controllers are
    /// ready to proceed. Otherwise, the modal popup alert can be swallowed by the step change.
    ///
    public func startAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void)) {

        // Return if nothing to start
        guard controllers.count > 0 else {
            DispatchQueue.main.async  {
                completion()
            }
            return
        }
        
        // Add the controllers if needed
        self._addAsyncActionControllersIfNeeded(controllers)

        // Start on the main queue
        DispatchQueue.main.async {
            
            // Show the loading view while stoping controllers.
            if showLoading {
                self.showLoadingView()
            }
            
            // After showing a loading view on the main queue, move to a background queue to stop each and wait for all the
            // results (or a timeout) before continuing.
            DispatchQueue.global().async {
                
                // Create a dispatch group
                let dispatchGroup = DispatchGroup()
                
                // Stop each controller and add the result
                for controller in controllers {
                    guard controller.status == RSDAsyncActionStatus.idle else { continue }
                    dispatchGroup.enter()
                    self._startAsyncActionControllerPart1(for: controller, completion: {
                        dispatchGroup.leave()
                    })
                }
                
                let timeout = DispatchTime.now() + .milliseconds(2 * 60 * 1000)
                let waitResult = dispatchGroup.wait(timeout: timeout)
                if waitResult == .timedOut {
                    assertionFailure("Failed to stop all recorders.")
                }
                DispatchQueue.main.async {
                    self.hideLoadingIfNeeded()
                    completion()
                }
            }
        }
    }
    
    /// Stop the async action controllers. The protocol extension does not directly implement stopping the
    /// async actions to allow customization of how the results are added to the task and whether or not
    /// forward navigation should be blocked until the completion handler is called. When the stop action
    /// is called, the view controller needs to handle stopping the controllers, adding the results, and
    /// showing a loading state until ready to move forward in the task navigation.
    public func stopAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void)) {
    
        // Start on the main queue
        DispatchQueue.main.async {
            
            // Show the loading view while stoping controllers.
            if showLoading {
                self.showLoadingView()
            }
            
            // After showing a loading view on the main queue, move to a background queue to stop each and wait for all the
            // results (or a timeout) before continuing.
            DispatchQueue.global().async {
            
                // Create a dispatch group
                let dispatchGroup = DispatchGroup()
                
                // Stop each controller and add the result
                for controller in controllers {
                    if (controller.status <= RSDAsyncActionStatus.running) {
                        dispatchGroup.enter()
                        controller.stop({ [weak self] (controller, result, error) in
                            self?._removeAsyncActionController(controller)
                            if let asyncResult = result {
                                controller.taskViewModel.taskResult.appendAsyncResult(with: asyncResult)
                            }
                            if error != nil {
                                self?._addErrorResult(for: controller, error: error!)
                            }
                            dispatchGroup.leave()
                        })
                    }
                }
            
                let timeout = DispatchTime.now() + .milliseconds(2 * 60 * 1000)
                let waitResult = dispatchGroup.wait(timeout: timeout)
                if waitResult == .timedOut {
                    assertionFailure("Failed to stop all recorders.")
                }
                DispatchQueue.main.async {
                    self.hideLoadingIfNeeded()
                    completion()
                }
            }
        }
    }
    
    
    // MARK: `RSDLoadingViewControllerProtocol` implementation

    /// The container view for the loading indicator.
    open var loadingContainerView: UIView! {
        return self.view
    }
    
    /// Show a loading view. Default implementation calls `showStandardLoadingView()` on the
    /// `RSDLoadingViewControllerProtocol` extension.
    open func showLoadingView() {
        showStandardLoadingView()
    }
    
    
    // MARK: View management
    
    /// The page view controller used to control the view controller navigation.
    public private(set) var pageViewController: (UIViewController & RSDPageViewControllerProtocol)!
    
    /// This is a work-around to not being able to hook up child view controllers via the storyboard IBOutlet.
    /// The method is called in `viewDidLoad` to see if there is already a view controller of the expected type
    /// that is included in the storyboard or nib that was used to create this view controller.
    ///
    /// - returns: If found, returns a view controller that conforms to `RSDPageViewControllerProtocol`.
    open func findPageViewController() -> (UIViewController & RSDPageViewControllerProtocol)? {
        guard let vc = self.children.first(where: { $0 is RSDPageViewControllerProtocol })
            else {
                return nil
        }
        return vc as? (UIViewController & RSDPageViewControllerProtocol)
    }
    
    /// This method will add a page view controller in the instance where this view controller was loaded without
    /// one. The method is called in `viewDidLoad` if `findPageViewController` returns nil. This method should
    /// instantiate a view controller and add it to this view controller as a child view controller.
    ///
    /// - returns: A view controller that conforms to `RSDPageViewControllerProtocol`.
    open func addPageViewController() -> (UIViewController & RSDPageViewControllerProtocol) {
        // Set up the page view controller
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.addChild(pageVC)
        pageVC.view.frame = self.view.bounds
        self.view.addSubview(pageVC.view)
        pageVC.view.rsd_alignAllToSuperview(padding: 0)
        pageVC.didMove(toParent: self)
        return pageVC
    }

    /// Override `viewDidLoad()` to set up the page view controller.
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the page view controller. By default, this will load a UIPageViewController if it does not
        // find one amongst its children.
        self.pageViewController = findPageViewController() ?? addPageViewController()
        self.pageViewController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
    }
    
    /// Override `viewWillAppear()` to start the task if needed.
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start the task if needed.
        self.taskViewModel.startTaskIfNeeded()
    }
    
    
    // MARK: UIPageViewControllerDataSource
    
    /// Returns the currently active step controller (if any).
    public var currentStepViewController: (RSDStepController & UIViewController)? {
        return pageViewController.children.first as? (RSDStepController & UIViewController)
    }
    
    /// Respond to a gesture to go back. Always returns `nil` but will call `goBack()` if appropriate.
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let stepViewController = self.currentStepViewController, let stepViewModel = stepViewController.stepViewModel,
            stepViewModel.canNavigateBackward, stepViewModel.rootPathComponent.hasStepBefore
            else {
                return nil
        }
        stepViewController.goBack()
        return nil
    }
    
    /// Respond to a gesture to go forward. Always returns `nil` but will call `goForward()` if appropriate.
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let stepViewController = self.currentStepViewController, let stepViewModel = stepViewController.stepViewModel,
            stepViewModel.isForwardEnabled, stepViewModel.rootPathComponent.hasStepAfter
            else {
                return nil
        }
        stepViewController.goForward()
        return nil
    }
    
    
    // MARK: Audio session management
    
    /// The audio session is a shared pointer to the current audio session (if running). This is used to
    /// allow background audio. Background audio is required in order for an active step to play sound
    /// such as voice commands to a participant who make not be looking at their screen.
    ///
    /// For example, a "Walk and Balance" task that measures gait and balance by having the participant
    /// walk back and forth followed by having them turn in a circle would require turning on background
    /// audio in order to play spoken instructions even if the screen is locked before putting the phone
    /// in the participant's pocket.
    ///
    /// - note: The application settings will need to include setting capabilities appropriate for
    /// background audio if this feature is used.
    ///
    public private(set) var audioSession: AVAudioSession?
    
    /// Start the background audio session if needed. This will look to see if `audioSession` is already started
    /// and if not, will start a new session.
    public func startBackgroundAudioSessionIfNeeded() {
        guard audioSession == nil else { return }
        
        // Start the background audio session
        do {
            let session = AVAudioSession.sharedInstance()
            if #available(iOS 12.0, *) {
                try session.setCategory(.playback, mode: .voicePrompt, options: .interruptSpokenAudioAndMixWithOthers)
            } else {
                try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            }
            try session.setActive(true)
            audioSession = session
        }
        catch let err {
            debugPrint("Failed to start AV session. \(err)")
        }
    }
    
    /// Start a background audio session.
    private func _startBackgroundAudioSessionIfNeeded(for controller: RSDAsyncAction) {
        guard let recorder = controller.configuration as? RSDRecorderConfiguration, recorder.requiresBackgroundAudio
            else {
                return
        }
        startBackgroundAudioSessionIfNeeded()
    }
    
    /// Stop the audio session.
    private func _stopAudioSession() {
        do {
            audioSession = nil
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch let err {
            debugPrint("Failed to stop AV session. \(err)")
        }
    }
    
    
    // MARK: Async action management
    
    private let controllerQueue = DispatchQueue(label: "org.sagebase.Research.Controllers.\(UUID())")
    private var _asyncControllers = NSMutableSet()
    
    /// Part 1 of starting an async action controller.
    private func _startAsyncActionControllerPart1(for controller: RSDAsyncAction, completion: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            if controller.delegate == nil {
                controller.delegate = self
            }
            controller.requestPermissions(on: self, { [weak self] (controller, _, error) in
                DispatchQueue.main.async {
                    guard let strongSelf = self, error == nil, controller.status < .starting else {
                        if error != nil {
                            self?._addErrorResult(for: controller, error: error!)
                        }
                        self?._removeAsyncActionController(controller)
                        completion()
                        return
                    }
                    strongSelf._startAsyncActionControllerPart2(controller, completion: completion)
                }
            })
        }
    }
    
    /// Part 2 of starting an async action controller.
    private func _startAsyncActionControllerPart2(_ controller: RSDAsyncAction, completion: @escaping (() -> Void)) {
        controller.start() { [weak self] (controller, result, error) in
            
            if error != nil {
                // Add the error result if there was an error.
                debugPrint("Failed to start recorder \(controller.configuration.identifier). status=\(controller.status) error=\(String(describing: error)) ")
                self?._addErrorResult(for: controller, error: error!)
            }
            else if (controller.status == .finished), let asyncResult = result {
                // If the async has returned with a result and the status is finished then add the result
                // to the result set.
                controller.taskViewModel.taskResult.appendAsyncResult(with: asyncResult)
            }
            
            // If not running then remove from the managed list.
            let started = (error == nil) && (controller.status <= .running)
            if !started {
                self?._removeAsyncActionController(controller)
            }
            
            DispatchQueue.main.async {
                if started {
                    self?._startBackgroundAudioSessionIfNeeded(for: controller)
                }
                completion()
            }
        }
    }
    
    /// Add an async action controller to the controllers list on the controller queue.
    private func _addAsyncActionControllersIfNeeded(_ controllers: [RSDAsyncAction]) {
        controllerQueue.sync {
            _asyncControllers.addObjects(from: controllers)
        }
    }
    
    /// Remove an async action controller from the managed list on the controller queue.
    private func _removeAsyncActionController(_ controller: RSDAsyncAction) {
        controllerQueue.sync {
            _asyncControllers.remove(controller)
        }
    }
    
    /// Add an error result for the given async action controller.
    private func _addErrorResult(for controller: RSDAsyncAction, error: Error) {
        // Add error result to the task results.
        let identifier = "\(controller.configuration.identifier)_error"
        let errorResult = RSDErrorResultObject(identifier: identifier, error: error)
        controller.taskViewModel.taskResult.appendAsyncResult(with: errorResult)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
