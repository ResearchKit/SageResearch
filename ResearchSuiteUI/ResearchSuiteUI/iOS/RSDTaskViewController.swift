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

public protocol RSDTaskViewControllerDelegate : class, NSObjectProtocol {
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), didFinishWith reason: RSDTaskFinishReason, error: Error?)
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), viewControllerFor step: RSDStep) -> (UIViewController & RSDStepController)?
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), asyncActionControllerFor configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController?
    
    func taskViewController(_ taskViewController: (UIViewController & RSDTaskController), readyToSave taskPath: RSDTaskPath)
    
    func taskViewControllerShouldAutomaticallyForward(_ taskViewController: (UIViewController & RSDTaskController)) -> Bool
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
open class RSDTaskViewController: UIViewController, RSDTaskController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, RSDAsyncActionControllerDelegate {

    open weak var delegate: RSDTaskViewControllerDelegate?
    
    // MARK: View controller vending
    
    open func viewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        // Exit early if the delegate, step or storyboard returns a view controller
        if let vc = delegate?.taskViewController(self, viewControllerFor: step) {
            return vc
        }
        if let vc = (step as? RSDStepViewControllerVendor)?.instantiateViewController(with: self.taskPath) {
            return vc
        }
        if let viewTheme = (step as? RSDThemedUIStep)?.viewTheme, let vc = instantiateViewController(with: viewTheme) {
            vc.step = step
            return vc
        }
        return self.vendDefaultViewController(for: step)
    }
    
    open func instantiateViewController(with viewTheme: RSDViewThemeElement) -> (UIViewController & RSDStepController)? {
        if let storyboardIdentifier = viewTheme.storyboardIdentifier {
            let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: viewTheme.bundle)
            return storyboard.instantiateViewController(withIdentifier: viewTheme.viewIdentifier) as? (UIViewController & RSDStepController)
        }
        else {
            return RSDStepViewController(nibName: viewTheme.viewIdentifier, bundle: viewTheme.bundle)
        }
    }
    
    open func vendDefaultViewController(for step: RSDStep) -> (UIViewController & RSDStepController) {
        if let taskInfo = step as? RSDTaskInfoStep {
            return RSDTaskInfoStepViewController(taskInfo: taskInfo)
        }
        else if let activeStep = step as? RSDActiveUIStep,
            activeStep.duration > 0,
            activeStep.commands.contains(.transitionAutomatically) {
            // If this is an active step with automatic transitions and a duration, then use the most appropriate
            // step view controller for the step type.
            if activeStep.type == RSDFactory.StepType.countdown.rawValue {
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
    
    public func asyncActionController(for configuration: RSDAsyncActionConfiguration) -> RSDAsyncActionController? {
        if let controller = self.delegate?.taskViewController(self, asyncActionControllerFor: configuration) {
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
    
    open func asyncActionController(_ controller: RSDAsyncActionController, didFailWith error: Error) {
        DispatchQueue.main.async {
            self._removeAsyncActionController(controller)
            // TODO: syoung 11/06/2017 Handle recording the failure.
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
    
    
    // MARK: RSDTaskController
    
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
        // If loading a resource for a subtask or delegate overrides then do not show the loading step
        let shouldAutoForward: Bool = self.delegate?.taskViewControllerShouldAutomaticallyForward(self) ?? (self.taskPath.parentPath != nil)
        if shouldAutoForward, taskInfo.estimatedFetchTime == 0 {
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
        delegate?.taskViewController(self, didFinishWith: .failed, error: error)
    }
    
    open func handleTaskCompleted() {
        _stopAudioSession()
        delegate?.taskViewController(self, didFinishWith: .completed, error: nil)
    }
    
    open func handleTaskCancelled() {
        _stopAudioSession()
        cancelAllAsyncActions()
        delegate?.taskViewController(self, didFinishWith: .cancelled, error: nil)
    }

    open func handleTaskResultReady(with taskPath: RSDTaskPath) {
        delegate?.taskViewController(self, readyToSave: taskPath)
    }
    
    public func startAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (() -> Void)) {
       
        // TODO: syoung 11/06/2017 Handle requesting permissions. This must be done by requesting each permission serially.
        // Otherwise, if you just ask for them all at once then some of them get swallowed.  For now, in order to keep
        // making progress on CRF, just assume that all permissionswere requested before we get to this point.

        // Start each controller
        for configuration in configurations {
            guard let asyncController = self.asyncActionController(for: configuration) else {
                debugPrint("Did not create controller for async config \(configuration)")
                continue
            }
            if asyncController.delegate == nil {
                asyncController.delegate = self
            }
            asyncController.start(at: self.taskPath) { [weak self] (controller, result, error) in
                DispatchQueue.main.async {
                    // TODO: syoung 11/02/2017 handle errors (Add a result to the result set?)
                    // TODO: syoung 11/02/2017 Handle action controllers that are not recorders and might return a result on start.
                    if error == nil, controller.isRunning {
                        self?._addAsyncActionController(controller)
                    } else {
                        debugPrint("Failed to start recorder \(controller.configuration.identifier). \(String(describing: error))")
                    }
                }
            }
        }
        
        // Call the completion.
        // TODO: syoung 11/06/2017 As part of permission handling, will need to implement async callback
        completion()
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
