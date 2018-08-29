//
//  NavigationTests.swift
//  ResearchTests
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
import Research
import UIKit

public struct TestStep : RSDStep, RSDNavigationRule, RSDNavigationSkipRule {

    public let identifier: String
    public var stepType: RSDStepType = .instruction
    public var result: RSDResult?
    public var validationError: Error?
    public var nextStepIdentifier: String?
    public var showBeforeIdentifier: String?
    
    public func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        if shouldSkipStep(with: result, isPeeking: isPeeking) {
            // Only use the next identifier if this step wasn't just skipped.
            return nil
        }
        return self.nextStepIdentifier
    }
    
    
    public func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        if let loopId = showBeforeIdentifier, result?.findResult(with: loopId) == nil {
            // Skip this step if another step isn't yet in the result set.
            return true
        }
        return false
    }
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public static func steps(from identifiers: [String]) -> [TestStep] {
        return identifiers.map { TestStep(identifier: $0) }
    }
    
    public static func steps(from range: [Int]) -> [TestStep] {
        return range.map { TestStep(identifier: "step\($0)") }
    }
    
    public func instantiateStepResult() -> RSDResult {
        guard result == nil else { return result! }
        return RSDAnswerResultObject(identifier: identifier, answerType: .string)
    }
    
    public func validate() throws {
        if let err = validationError {
            throw err
        }
    }
    
    public func copy(with identifier: String) -> TestStep {
        var copy = TestStep(identifier: identifier)
        copy.stepType = stepType
        copy.result = result
        copy.validationError = validationError
        return copy
    }
}

public struct TestConditionalNavigator: RSDConditionalStepNavigator {
    
    public let steps: [RSDStep]
    public var progressMarkers: [String]?
    
    public init(steps: [RSDStep]) {
        self.steps = steps
    }
}

public class TestSubtaskStep : RSDTaskInfoStep, RSDTaskTransformer {

    public let task: RSDTask
    
    public let taskInfo: RSDTaskInfo
    
    public init(task: RSDTask) {
        self.task = task
        var taskInfo = RSDTaskInfoObject(with: task.identifier)
        taskInfo.schemaInfo = task.schemaInfo
        self.taskInfo = taskInfo
    }
    
    public var taskTransformer: RSDTaskTransformer! {
        return self
    }
    
    public var identifier: String {
        return self.task.identifier
    }
    
    public var stepType: RSDStepType {
        return .taskInfo
    }
    
    public func instantiateStepResult() -> RSDResult {
        return task.instantiateTaskResult()
    }
    
    public func validate() throws {
        // Do nothing
    }
    
    public var estimatedFetchTime: TimeInterval {
        return 0
    }
    
    public func fetchTask(with factory: RSDFactory, taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        DispatchQueue.main.async {
            callback(taskIdentifier, self.task, nil)
        }
    }
}

public struct TestTask : RSDTask {
    
    public let identifier: String
    public let stepNavigator: RSDStepNavigator
    public var copyright: String?
    public var schemaInfo: RSDSchemaInfo?
    public var asyncActions: [RSDAsyncActionConfiguration]?
    
    public var taskResult: RSDTaskResult?
    public var validationError: Error?
    
    public init(identifier: String, stepNavigator: RSDStepNavigator) {
        self.identifier = identifier
        self.stepNavigator = stepNavigator
    }
    
    public func instantiateTaskResult() -> RSDTaskResult {
        return taskResult ?? RSDTaskResultObject(identifier: identifier, schemaInfo: schemaInfo)
    }
    
    public func validate() throws {
        if let err = validationError {
            throw err
        }
    }
    
    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
}

public class TestStepController: NSObject, RSDStepController {

    public var taskController: RSDTaskController!
    public var step: RSDStep!
    public var hasStepBefore: Bool = true
    public var hasStepAfter: Bool = true
    public var isForwardEnabled: Bool = true
    
    public var didFinishLoading_called: Bool = false
    public var goForward_called: Bool = false
    public var goBack_called: Bool = false
    public var skipForward_called: Bool = false
    public var cancel_called: Bool = false
    
    public func didFinishLoading() {
        didFinishLoading_called = true
    }
    
    public func goForward() {
        goForward_called = true
    }
    
    public func goBack() {
        goBack_called = true
    }
    
    public func skipForward() {
        skipForward_called = true
    }
    
    public func cancel() {
        cancel_called = true
    }
}

public class TestAsyncActionController: NSObject, RSDAsyncActionController {
    
    public var delegate: RSDAsyncActionControllerDelegate?
    public var status: RSDAsyncActionStatus = .idle
    public var isPaused: Bool = false
    public var result: RSDResult?
    public var error: Error?
    public let configuration: RSDAsyncActionConfiguration
    public let taskPath: RSDTaskPath
    
    public var moveTo_called = false
    public var moveTo_step: RSDStep?
    public var moveTo_taskPath: RSDTaskPath?
    
    public init(with configuration: RSDAsyncActionConfiguration, at taskPath: RSDTaskPath) {
        self.configuration = configuration
        self.taskPath = taskPath
        super.init()
    }

    public func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        status = .permissionGranted
    }
    
    public func start(_ completion: RSDAsyncActionCompletionHandler?) {
        status = .running
        completion?(self, nil, nil)
    }
    
    public func pause() {
        isPaused = true
    }
    
    public func resume() {
        isPaused = false
    }
    
    public func stop(_ completion: RSDAsyncActionCompletionHandler?) {
        status = .finished
        completion?(self, nil, nil)
    }
    
    public func cancel() {
        status = .cancelled
    }
    
    public func moveTo(step: RSDStep, taskPath: RSDTaskPath) {
        moveTo_called = true
        moveTo_step = step
        moveTo_taskPath = taskPath
    }
}

public class TestTaskController: NSObject, RSDTaskUIController {

    public var taskPath: RSDTaskPath!
    public var factory: RSDFactory?
    public var currentStepController: RSDStepController?
    public var canSaveTaskProgress: Bool = false
    public var shouldFetchSubtask: Bool = true
    public var shouldPageSectionSteps: Bool = true
    
    public var currentAsyncControllers: [RSDAsyncActionController] = []
    
    public var shouldFetchSubtask_calledFor: RSDTaskInfoStep?
    public var shouldPageSectionSteps_calledFor: RSDSectionStep?
    public var showLoading_calledFor: RSDTaskInfoStep?
    public var handleFinishedLoading_called = false
    public var hideLoadingIfNeeded_called = false
    public var navigate_calledTo: RSDStep?
    public var navigate_calledFrom: RSDStep?
    public var navigate_calledDirection: RSDStepDirection?
    public var handleTaskFailure_calledWith: Error?
    public var handleTaskCompleted_called = false
    public var handleTaskResultReady_calledWith: RSDTaskPath?
    public var handleTaskCancelled_called = false
    public var handleTaskCancelled_shouldSave: Bool?
    public var addAsyncActions_called = false
    public var addAsyncActions_calledWith: [RSDAsyncActionConfiguration]?
    public var startAsyncActions_called = false
    public var startAsyncActions_calledWith: [RSDAsyncActionController]?
    public var stopAsyncActions_called = false
    public var stopAsyncActions_calledWith: [RSDAsyncActionController]?
    
    public func shouldFetchSubtask(for step: RSDTaskInfoStep) -> Bool {
        shouldFetchSubtask_calledFor = step
        return shouldFetchSubtask
    }
    
    public func shouldPageSectionSteps(for step: RSDSectionStep) -> Bool {
        shouldPageSectionSteps_calledFor = step
        return shouldPageSectionSteps
    }
    
    public func showLoading(for taskInfo: RSDTaskInfoStep) {
        showLoading_calledFor = taskInfo
    }
    
    public func handleFinishedLoading() {
        handleFinishedLoading_called = true
    }
    
    public func hideLoadingIfNeeded() {
        hideLoadingIfNeeded_called = true
    }
    
    public func navigate(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?) {
        navigate_calledTo = step
        navigate_calledFrom = previousStep
        navigate_calledDirection = direction
        DispatchQueue.main.async {
            completion?(true)
        }
    }
    
    public func handleTaskFailure(with error: Error) {
        handleTaskFailure_calledWith = error
    }
    
    public func handleTaskCompleted() {
        handleTaskCompleted_called = true
    }
    
    public func handleTaskResultReady(with taskPath: RSDTaskPath) {
        handleTaskResultReady_calledWith = taskPath
    }
    
    public func handleTaskCancelled(shouldSave: Bool) {
        handleTaskCancelled_called = true
        handleTaskCancelled_shouldSave = shouldSave
    }
    
    public func test_stepTo(_ stepIdentifier: String) -> RSDStep {
        var loopCount: Int = 0
        var nextStep: RSDStep? = taskPath.currentStep
        while nextStep?.identifier != stepIdentifier {
            loopCount += 1
            if loopCount > 30 {
                fatalError("Your test is in an infinite loop of Wacky madness.")
            }
            let navigation = taskPath.task!.stepNavigator.step(after: nextStep, with: &taskPath.result)
            nextStep = navigation.step
            if nextStep == nil {
                if let parentPath = taskPath.parentPath {
                    parentPath.appendStepHistory(with: taskPath.result)
                    self.taskPath = parentPath
                    nextStep = parentPath.currentStep
                } else {
                    fatalError("Failed to step to \(stepIdentifier)")
                }
            } else {
                taskPath.currentStep = nextStep
                if let subtaskStep = nextStep as? TestSubtaskStep {
                    self.taskPath = RSDTaskPath(task: subtaskStep.task, parentPath: self.taskPath)
                    nextStep = nil
                }
                else if let sectionStep = nextStep as? RSDSectionStep {
                    self.taskPath = RSDTaskPath(task: sectionStep, parentPath: self.taskPath)
                    nextStep = nil
                }
                else {
                    let stepResult = nextStep!.instantiateStepResult()
                    if let answerResult = stepResult as? RSDAnswerResultObject,
                        answerResult.value == nil, answerResult.answerType == .string {
                        var aResult = answerResult
                        aResult.value = nextStep!.identifier
                        taskPath.appendStepHistory(with: aResult)
                    } else {
                        taskPath.appendStepHistory(with: stepResult)
                    }
                }
            }
        }
        return nextStep!
    }
    
    public func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (([RSDAsyncActionController]) -> Void)) {
        addAsyncActions_called = true
        addAsyncActions_calledWith = configurations
        DispatchQueue.main.async {
            let controllers: [RSDAsyncActionController] = configurations.map {
                return TestAsyncActionController(with: $0, at: self.taskPath)
            }
            self.currentAsyncControllers.append(contentsOf: controllers)
            completion(controllers)
        }
    }
    
    public func startAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void)) {
        startAsyncActions_called = true
        startAsyncActions_calledWith = controllers
        DispatchQueue.main.async {
            for controller in controllers {
                controller.start(nil)
            }
            let set = NSMutableSet(array: self.currentAsyncControllers)
            set.union(Set(controllers as! [TestAsyncActionController]))
            self.currentAsyncControllers = set.allObjects as! [TestAsyncActionController]
            completion()
        }
    }
    
    public func stopAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void)) {
        stopAsyncActions_called = true
        stopAsyncActions_calledWith = controllers
        DispatchQueue.main.async {
            for controller in controllers {
                controller.stop(nil)
            }
            let set = NSMutableSet(array: self.currentAsyncControllers)
            set.minus(Set(controllers as! [TestAsyncActionController]))
            self.currentAsyncControllers = set.allObjects as! [TestAsyncActionController]
            completion()
        }
    }
}
