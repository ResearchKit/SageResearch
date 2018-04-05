//
//  NavigationTests.swift
//  ResearchStack2Tests
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
import ResearchStack2

struct TestStep : RSDStep, RSDNavigationRule {
    
    let identifier: String
    var stepType: RSDStepType = .instruction
    var result: RSDResult?
    var validationError: Error?
    var nextStepIdentifier: String?
    
    func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> String? {
        return self.nextStepIdentifier
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    static func steps(from identifiers: [String]) -> [TestStep] {
        return identifiers.map { TestStep(identifier: $0) }
    }
    
    static func steps(from range: [Int]) -> [TestStep] {
        return range.map { TestStep(identifier: "step\($0)") }
    }
    
    func instantiateStepResult() -> RSDResult {
        guard result == nil else { return result! }
        return RSDAnswerResultObject(identifier: identifier, answerType: .string)
    }
    
    func validate() throws {
        if let err = validationError {
            throw err
        }
    }
    
    func copy(with identifier: String) -> TestStep {
        var copy = TestStep(identifier: identifier)
        copy.stepType = stepType
        copy.result = result
        copy.validationError = validationError
        return copy
    }
}

struct TestConditionalNavigator: RSDConditionalStepNavigator {
    
    let steps: [RSDStep]
    var progressMarkers: [String]?
    var conditionalRule: RSDConditionalRule?
    
    init(steps: [RSDStep]) {
        self.steps = steps
    }
}

struct TestTask : RSDTask {
    
    let identifier: String
    let stepNavigator: RSDStepNavigator
    var copyright: String?
    var schemaInfo: RSDSchemaInfo?
    var asyncActions: [RSDAsyncActionConfiguration]?
    
    var taskResult: RSDTaskResult?
    var validationError: Error?
    
    init(identifier: String, stepNavigator: RSDStepNavigator) {
        self.identifier = identifier
        self.stepNavigator = stepNavigator
    }
    
    func instantiateTaskResult() -> RSDTaskResult {
        return taskResult ?? RSDTaskResultObject(identifier: identifier, schemaInfo: schemaInfo)
    }
    
    func validate() throws {
        if let err = validationError {
            throw err
        }
    }
    
    func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
}

class TestStepController: NSObject, RSDStepController {

    var taskController: RSDTaskController!
    var step: RSDStep!
    var hasStepBefore: Bool = true
    var hasStepAfter: Bool = true
    var isForwardEnabled: Bool = true
    
    var didFinishLoading_called: Bool = false
    var goForward_called: Bool = false
    var goBack_called: Bool = false
    var skipForward_called: Bool = false
    var cancel_called: Bool = false
    
    func didFinishLoading() {
        didFinishLoading_called = true
    }
    
    func goForward() {
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

class TestAsyncActionController: NSObject, RSDAsyncActionController {
    
    var delegate: RSDAsyncActionControllerDelegate?
    var status: RSDAsyncActionStatus = .idle
    var isPaused: Bool = false
    var result: RSDResult?
    var error: Error?
    let configuration: RSDAsyncActionConfiguration
    let taskPath: RSDTaskPath
    
    var moveTo_called = false
    var moveTo_step: RSDStep?
    var moveTo_taskPath: RSDTaskPath?
    
    init(with configuration: RSDAsyncActionConfiguration, at taskPath: RSDTaskPath) {
        self.configuration = configuration
        self.taskPath = taskPath
        super.init()
    }

    func requestPermissions(on viewController: UIViewController, _ completion: @escaping RSDAsyncActionCompletionHandler) {
        status = .permissionGranted
    }
    
    func start(_ completion: RSDAsyncActionCompletionHandler?) {
        status = .running
        completion?(self, nil, nil)
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    func stop(_ completion: RSDAsyncActionCompletionHandler?) {
        status = .finished
        completion?(self, nil, nil)
    }
    
    func cancel() {
        status = .cancelled
    }
    
    func moveTo(step: RSDStep, taskPath: RSDTaskPath) {
        moveTo_called = true
        moveTo_step = step
        moveTo_taskPath = taskPath
    }
}

class TestTaskController: NSObject, RSDTaskUIController {

    var taskPath: RSDTaskPath!
    var factory: RSDFactory?
    var currentStepController: RSDStepController?
    var canSaveTaskProgress: Bool = false
    var shouldFetchSubtask: Bool = true
    var shouldPageSectionSteps: Bool = true
    
    var currentAsyncControllers: [RSDAsyncActionController] = []
    
    var shouldFetchSubtask_calledFor: RSDTaskInfoStep?
    var shouldPageSectionSteps_calledFor: RSDSectionStep?
    var showLoading_calledFor: RSDTaskInfoStep?
    var handleFinishedLoading_called = false
    var hideLoadingIfNeeded_called = false
    var navigate_calledTo: RSDStep?
    var navigate_calledFrom: RSDStep?
    var navigate_calledDirection: RSDStepDirection?
    var handleTaskFailure_calledWith: Error?
    var handleTaskCompleted_called = false
    var handleTaskResultReady_calledWith: RSDTaskPath?
    var handleTaskCancelled_called = false
    var handleTaskCancelled_shouldSave: Bool?
    var addAsyncActions_called = false
    var addAsyncActions_calledWith: [RSDAsyncActionConfiguration]?
    var startAsyncActions_called = false
    var startAsyncActions_calledWith: [RSDAsyncActionController]?
    var stopAsyncActions_called = false
    var stopAsyncActions_calledWith: [RSDAsyncActionController]?
    
    func shouldFetchSubtask(for step: RSDTaskInfoStep) -> Bool {
        shouldFetchSubtask_calledFor = step
        return shouldFetchSubtask
    }
    
    func shouldPageSectionSteps(for step: RSDSectionStep) -> Bool {
        shouldPageSectionSteps_calledFor = step
        return shouldPageSectionSteps
    }
    
    func showLoading(for taskInfo: RSDTaskInfoStep) {
        showLoading_calledFor = taskInfo
    }
    
    func handleFinishedLoading() {
        handleFinishedLoading_called = true
    }
    
    func hideLoadingIfNeeded() {
        hideLoadingIfNeeded_called = true
    }
    
    func navigate(to step: RSDStep, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?) {
        navigate_calledTo = step
        navigate_calledFrom = previousStep
        navigate_calledDirection = direction
        DispatchQueue.main.async {
            completion?(true)
        }
    }
    
    func handleTaskFailure(with error: Error) {
        handleTaskFailure_calledWith = error
    }
    
    func handleTaskCompleted() {
        handleTaskCompleted_called = true
    }
    
    func handleTaskResultReady(with taskPath: RSDTaskPath) {
        handleTaskResultReady_calledWith = taskPath
    }
    
    func handleTaskCancelled(shouldSave: Bool) {
        handleTaskCancelled_called = true
        handleTaskCancelled_shouldSave = shouldSave
    }
    
    func test_stepTo(_ stepIdentifier: String) -> RSDStep {
        var loopCount: Int = 0
        var nextStep: RSDStep? = taskPath.currentStep
        while nextStep?.identifier != stepIdentifier {
            loopCount += 1
            if loopCount > 30 {
                fatalError("Your test is in an infinite loop of Wacky madness.")
            }
            nextStep = taskPath.task!.stepNavigator.step(after: nextStep, with: &taskPath.result)
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
                if let sectionStep = nextStep as? RSDSectionStep {
                    self.taskPath = RSDTaskPath(task: sectionStep, parentPath: self.taskPath)
                    nextStep = nil
                } else {
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
    
    func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], completion: @escaping (([RSDAsyncActionController]) -> Void)) {
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
    
    func startAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void)) {
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
    
    func stopAsyncActions(for controllers: [RSDAsyncActionController], showLoading: Bool, completion: @escaping (() -> Void)) {
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
