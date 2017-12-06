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
        let pageDirection: UIPageViewControllerNavigationDirection = (direction == .reverse) ? .reverse : .forward
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
    @objc optional
    func taskViewController(_ taskViewController: UIViewController, viewControllerFor step: Any) -> UIViewController?
    
    
    /// Asks the delegate whether or not the task should show a view controller for the  `RSDTaskInfoStep`
    /// while the initial task is being fetched.
    ///
    /// If defined, then:
    ///     * If this function returns `true` then a view controller specific to the `RSDTaskInfoStep` will be displayed.
    ///     * If this function returns `false` then `showLoadingView()` will be called and the task will automatically
    ///       forward to the first step once the task is fetched.
    ///
    /// If not defined, then:
    ///     * If and only if the task is a subtask where `estimatedFetchTime == 0`, then `showLoadingView()` will be called
    ///       and the task will automatically forward to the first step once the task is fetched.
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
public protocol RSDStepViewControllerVendor : RSDUIStep {

    /// Returns the view controller vended by the step.
    /// - parameter taskPath: The current task path to use to instantiate the view controller
    /// - returns: The instantiated view controller or `nil` if there isn't one.
    func instantiateViewController(with taskPath: RSDTaskPath) -> (UIViewController & RSDStepController)?
}

/// `RSDTaskViewController` is the default implementation of task view controller that is suitable to the iPhone or iPad.
/// The default implementation will display a series of steps using a `UIPageViewController`. This controller will also handle
/// starting and stoping async actions and vending the appropriate step view controller for each step.
open class RSDTaskViewController: UIViewController, RSDTaskController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, RSDAsyncActionControllerDelegate {

    /// The delegate for the task view controller.
    ///
    /// - precondition: The delegate must support completion. When the task view controller completes its task, it is
    /// the delegate's responsibility to dismiss it.
    /// - seealso: `RSDTaskControllerDelegate.taskViewController(:,didFinishWith reason:,error:)`.
    open weak var delegate: RSDTaskViewControllerDelegate?
    
    // MARK: View controller vending
    
    /// Main entry for vending an appropriate step view controller for a given step.
    ///
    /// This method will look for a step view controller in the following order:
    /// 1. Call the delegate method `taskViewController(:, viewControllerFor step:)` and return the view controller
    ///    supplied by that method. This will throw an exception if the delegate does not return a view controller
    ///    that conforms to the `RSDStepController` protocol and inherits from `UIViewController`.
    /// 2. If the given step implements the `RSDStepViewControllerVendor` protocol and returns a non-nil instance of
    ///    a view controller, then that will be returned.
    /// 3. If the given step implements the `RSDThemedUIStep` protocol and returns a `viewTheme`, then call
    ///    `instantiateViewController(with viewTheme:)` to instantiate a view controller for this step.
    /// 4. If none of the functions listed above returns a view controller then return the view controller instantiated
    ///    by calling `vendDefaultViewController(for step:)`.
    ///
    /// - parameter step: The step to display.
    /// - returns: The view controller to use when displaying a given step.
    open func viewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        // Exit early if the delegate, step or storyboard returns a view controller
        if let vc = delegate?.taskViewController?(self, viewControllerFor: step) {
            return vc as! (UIViewController & RSDStepController)
        }
        if let vc = (step as? RSDStepViewControllerVendor)?.instantiateViewController(with: self.taskPath) {
            return vc
        }
        if let viewTheme = (step as? RSDThemedUIStep)?.viewTheme, let vc = instantiateViewController(with: viewTheme) {
            if vc.step == nil {
                vc.step = step
            }
            return vc
        }
        return self.vendDefaultViewController(for: step)
    }
    
    /// Instantiate a step view controller using the given view theme element.
    /// - parameters:
    ///     - viewTheme: The view theme element with the nib or storyboard identifier.
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
    /// 2. If the step implements the `RSDActiveUIStep` protocol, and the `duration > 0`, and the
    ///    step includes the command for `RSDActiveUIStepCommand.transitionAutomatically`, then:
    ///    * if the `step.type == .countdown` then instantiate a `RSDCountdownStepViewController`.
    ///    * else instantiate a `RSDActiveStepViewController`.
    /// 3. If `RSDGenericStepViewController.doesSupport()` returns `true` then instantiate a `RSDGenericStepViewController`
    /// 4. Otherwise, instantiate a `DebugStepViewController` to be used during development as a placeholder.
    ///
    /// - parameter step: The step to display.
    /// - returns: The base class implementation of a step view controller or `DebugStepViewController`
    ///            if undefined.
    open func vendDefaultViewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        if let taskInfo = step as? RSDTaskInfoStep {
            return RSDTaskInfoStepViewController(taskInfo: taskInfo)
        }
        else if let activeStep = step as? RSDActiveUIStep,
            activeStep.duration > 0,
            activeStep.commands.contains(.transitionAutomatically) {
            // If this is an active step with automatic transitions and a duration, then use the most appropriate
            // step view controller for the step type.
            if activeStep.type == .countdown {
                return RSDCountdownStepViewController(step: step)
            } else {
                return RSDActiveStepViewController(step: step)
            }
        }
        else if RSDGenericStepViewController.doesSupport(step) {
            // If this step *can* be displayed using the generic step view controller, then default to that
            // rather than the using the debug step.
            return RSDGenericStepViewController(step: step)
        }
        else {
            // If no default is set the use the debug controller
            return DebugStepViewController(step: step)
        }
    }
    
    // MARK: Async action vending
    
    public private(set) var idleTimerDisabled: Bool = false
    public private(set) var audioSession: AVAudioSession?
    
    open func asyncActionController(for configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        if let controller = self.delegate?.taskController(self, asyncActionControllerFor: configuration) {
            return controller
        } else if let vender = configuration as? RSDAsyncActionControllerVendor {
            return vender.instantiateController(with: self.taskPath)
        } else {
            return vendDefaultAsyncActionController(for: configuration)
        }
    }
    
    open func vendDefaultAsyncActionController(for configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        return nil
    }
    
    /// Handle failure of the async action controller.
    open func asyncActionController(_ controller: RSDAsyncActionController, didFailWith error: Error) {
        DispatchQueue.main.async {
            self._removeAsyncActionController(controller)
            // TODO: syoung 11/06/2017 Handle recording the failure.
        }
    }
    
    open func shouldContinueOnFailure(with controller: RSDAsyncActionController, error: Error) -> Bool {
        return true
    }
    
    private func _startAsyncActionController(_ controller: RSDAsyncActionController) {
        self._addAsyncActionController(controller)
        controller.start(at: self.taskPath) { [weak self] (controller, result, error) in
            DispatchQueue.main.async {
                // TODO: syoung 11/02/2017 handle errors (Add a result to the result set?)
                // TODO: syoung 11/02/2017 Handle action controllers that are not recorders and might return a result on start.
                if error != nil || !controller.isRunning {
                    debugPrint("Failed to start recorder \(controller.configuration.identifier). \(String(describing: error))")
                    self?._removeAsyncActionController(controller)
                }
            }
        }
    }
    
    private func _addAsyncActionController(_ controller: RSDAsyncActionController) {
        self.currentAsyncControllers.append(controller)
        if let recorder = controller.configuration as? RSDRecorderConfiguration {
            if recorder.requiresBackgroundAudio && audioSession == nil {
                let session = AVAudioSession()
                audioSession = session
            }
        }
    }
    
    private func _removeAsyncActionController(_ controller: RSDAsyncActionController) {
        guard let idx = self.currentAsyncControllers.index(where: { $0.configuration.identifier == controller.configuration.identifier })
            else {
                return
        }
        self.currentAsyncControllers.remove(at: idx)
    }
    
    private func _startBackgroundAudioSession() {
        guard audioSession == nil else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
            audioSession = session
        }
        catch let err {
            debugPrint("Failed to start AV session. \(err)")
        }
    }
    
    private func _stopAudioSession() {
        do {
            try audioSession?.setActive(false)
            audioSession = nil
        } catch let err {
            debugPrint("Failed to stop AV session. \(err)")
        }
    }
    
    
    // MARK: `RSDTaskController` protocol implementation
    
    open var factory: RSDFactory?
    
    public var taskPath: RSDTaskPath!
    
    public private(set) var currentAsyncControllers: [RSDAsyncActionController] = []
    
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
        // If loading a resource for a subtask or delegate overrides then do not show the task info.
        // Instead, show the loading screen and return
        let showLoading: Bool = {
            if let autoForward = self.delegate?.taskViewController?(self, shouldShowTaskInfoFor: taskInfo) {
                return !autoForward
            } else {
                return (self.taskPath.parentPath != nil) && (taskInfo.estimatedFetchTime == 0)
            }
        }()
        if showLoading {
            self.showLoadingView()
            return
        }
        
        // Show the loading step
        let vc = viewController(for: taskInfo)
        vc.taskController = self
        let animated = (taskPath.parentPath != nil)
        let direction: RSDStepDirection = animated ? .forward : .none
        pageViewController.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
    }
    
    open func handleFinishedLoading() {
        // Forward the finished loading message to the RSDTaskInfoStepUIController (if present)
        // Otherwise, just go forward.
        if let _ = self.currentStepController?.step as? RSDTaskInfoStep {
            self.currentStepController?.didFinishLoading()
        } else {
            self.goForward()
        }
    }
    
    open func showLoadingView() {
        // TODO: syoung 11/02/2017 Add a standard non-step loading view.
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
        _stopAudioSession()
        cancelAllAsyncActions()
        delegate?.taskController(self, didFinishWith: .failed, error: error)
    }
    
    open func handleTaskCompleted() {
        _stopAudioSession()
        delegate?.taskController(self, didFinishWith: .completed, error: nil)
    }
    
    open func handleTaskCancelled() {
        // TODO: syoung 12/04/2017 Confirm exit if this is not the first step.
        _stopAudioSession()
        cancelAllAsyncActions()
        delegate?.taskController(self, didFinishWith: .discarded, error: nil)
    }

    open func handleTaskResultReady(with taskPath: RSDTaskPath) {
        delegate?.taskController(self, readyToSave: taskPath)
    }
    
    /// Instantiate the appropriate controller for each configuration, request any authorizations and start the controller.
    /// Then call the completion once forward navigation can continue.
    public func startAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (() -> Void)) {
        
        // Get the controller for each configuration
        let controllers = configurations.rsd_mapAndFilter { (configuration) -> RSDAsyncActionController? in
            guard let asyncController = self.asyncActionController(for: configuration) else {
                debugPrint("Did not create controller for async config \(configuration)")
                return nil
            }
            if asyncController.delegate == nil {
                asyncController.delegate = self
            }
            return asyncController
        }

        // Handle requesting permissions. This must be done by requesting each permission serially. Otherwise, if you just
        // ask for them all at once then some of them get swallowed.
        DispatchQueue.main.async  {
            
            // Recursively step thorough each controller and request any authorizations required for that controller.
            var index: Int = 0
            
            func enumerateRequest() {
                
                // When each controller has been started then return
                guard index < controllers.count else {
                    completion()
                    return
                }
                
                // Get the next controller in the list.
                let asyncController = controllers[index]
                index += 1
                
                // Request permission
                asyncController.requestPermissions(on: self) { [weak self] (controller, _, error) in
                    DispatchQueue.main.async {  // Completion should be called on main but... just in case.
                        guard let strongSelf = self else {
                            // If the task view controller is disposed, then the task has finished.
                            return
                        }
                        
                        // If there was an error, pass on the failure message. Otherwise, start the controller
                        if let err = error {
                            debugPrint("Failed to start recorder \(controller.configuration.identifier). \(err)")
                            strongSelf.asyncActionController(controller, didFailWith: err)
                        } else {
                            strongSelf._startAsyncActionController(controller)
                        }
                    
                        // If there wasn't an error, or if the controller should continue on failure to start
                        // the async action, then start the next controller. Otherwise, the completion is swallowed
                        // because calling the completion will normally result in continuing to the next step.
                        // If the default implementation of `shouldContinueOnFailure` is overriden to return `true`
                        // then either that method *or* `asyncActionController(didFailWith error:)` should finish
                        // the task with an error.
                        if error == nil || strongSelf.shouldContinueOnFailure(with: controller, error: error!) {
                            enumerateRequest()
                        }
                    }
                }
            }
            
            // Call the serialized enumerator to start the first controller.
            enumerateRequest()
        }
    }
    
    public func stopAsyncActions(for controllers: [RSDAsyncActionController], completion: @escaping (() -> Void)) {
        
        // Start on the main queue
        DispatchQueue.main.async {
            
            // Show the loading view while stoping controllers.
            self.showLoadingView()
            
            // Remove the controllers from the list
            for controller in controllers {
                self._removeAsyncActionController(controller)
            }
            
            // After removing the controllers and showing a loading view on the main queue
            // move to a background queue to stop each and wait for all the results (or a timeout)
            // before continuing.
            DispatchQueue.global().async {
            
                // Create a dispatch group
                let dispatchGroup = DispatchGroup()
                
                // Stop each controller and add the result
                var results: [RSDResult] = []
                for controller in controllers {
                    if (controller.isRunning) {
                        dispatchGroup.enter()
                        controller.stop({ (_, result, error) in
                            if result != nil {
                                results.append(result!)
                            }
                            // TODO: syoung 11/02/2017 handle errors (Add a result to the result set?)
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
                    // Add the results and call the completion
                    for result in results {
                        self.taskPath.result.appendAsyncResult(with: result)
                    }
                    self.hideLoadingIfNeeded()
                    completion()
                }
            }
        }
    }
    
    public func cancelAllAsyncActions() {
        for controller in self.currentAsyncControllers {
           controller.cancel()
        }
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
        pageVC.view.rsd_alignAllToSuperview(padding: 0)
        pageVC.didMove(toParentViewController: self)
        return pageVC
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the page view controller. By default, this will load a UIPageViewController if it does not
        // find one amongst its children.
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
