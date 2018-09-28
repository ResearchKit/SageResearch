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
@testable import Research
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

public class TestSubtaskStep : RSDSubtaskStep {

    public let task: RSDTask
    
    public init(task: RSDTask) {
        self.task = task
    }
    
    public var identifier: String {
        return self.task.identifier
    }
    
    public var stepType: RSDStepType {
        return .subtask
    }
    
    public func instantiateStepResult() -> RSDResult {
        return task.instantiateTaskResult()
    }
    
    public func validate() throws {
        try self.task.validate()
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

    public var stepViewModel: RSDStepViewPathComponent!
    
    public var didFinishLoading_called: Bool = false
    
    public func didFinishLoading() {
        didFinishLoading_called = true
    }
    
    public func goForward() {
        self.stepViewModel.perform(actionType: .navigation(.goForward))
    }
    
    public func goBack() {
        self.stepViewModel.perform(actionType: .navigation(.goBackward))
    }
}

public class TestAsyncActionController: NSObject, RSDAsyncAction {

    public var delegate: RSDAsyncActionDelegate?
    public var status: RSDAsyncActionStatus = .idle
    public var isPaused: Bool = false
    public var result: RSDResult?
    public var error: Error?
    public let configuration: RSDAsyncActionConfiguration
    public let taskViewModel: RSDPathComponent
    
    public var moveTo_called = false
    public var moveTo_step: RSDStep?
    public var moveTo_taskPath: RSDPathComponent?
    
    public init(with configuration: RSDAsyncActionConfiguration, at taskViewModel: RSDPathComponent) {
        self.configuration = configuration
        self.taskViewModel = taskViewModel
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
    
    public func moveTo(step: RSDStep, taskViewModel: RSDPathComponent) {
        moveTo_called = true
        moveTo_step = step
        moveTo_taskPath = taskViewModel
    }
}

public class TestTaskController: NSObject, RSDTaskController {

    public var taskViewModel: RSDTaskViewModel! {
        didSet {
            self.taskViewModel.taskController = self
        }
    }
    
    public var currentAsyncControllers: [RSDAsyncAction] = []
    
    public var show_calledTo: RSDStepController?
    public var show_calledFrom: RSDStep?
    public var show_calledDirection: RSDStepDirection?
    public var handleTaskDidFinish_calledWith: RSDTaskFinishReason?
    public var handleTaskDidFinish_calledError: Error?
    public var showLoading_calledFor: RSDTaskInfo?
    public var handleFinishedLoading_called = false
    public var hideLoadingIfNeeded_called = false
    public var handleTaskFailure_calledWith: Error?
    public var handleTaskResultReady_calledWith: RSDTaskViewModel?
    public var addAsyncActions_called = false
    public var addAsyncActions_calledWith: [RSDAsyncActionConfiguration]?
    public var startAsyncActions_called = false
    public var startAsyncActions_calledWith: [RSDAsyncAction]?
    public var stopAsyncActions_called = false
    public var stopAsyncActions_calledWith: [RSDAsyncAction]?
    
    public var handleTaskDidFinish_completionBlock: (() -> Void)?
    
    public func stepController(for step: RSDStep, with parent: RSDPathComponent?) -> RSDStepController? {
        let stepController = TestStepController()
        stepController.stepViewModel = RSDStepViewModel(step: step, parent: parent)
        return stepController
    }
    
    public func show(_ stepController: RSDStepController, from previousStep: RSDStep?, direction: RSDStepDirection, completion: ((Bool) -> Void)?) {
        show_calledTo = stepController
        show_calledFrom = previousStep
        show_calledDirection = direction
        DispatchQueue.main.async {
            completion?(true)
        }
    }
    
    public func handleTaskDidFinish(with reason: RSDTaskFinishReason, error: Error?) {
        handleTaskDidFinish_calledWith = reason
        handleTaskDidFinish_calledError = error
        handleTaskDidFinish_completionBlock?()
        handleTaskDidFinish_completionBlock = nil
    }
    
    public func showLoading(for taskInfo: RSDTaskInfo) {
        showLoading_calledFor = taskInfo
    }
    
    public func handleFinishedLoading() {
        handleFinishedLoading_called = true
    }
    
    public func hideLoadingIfNeeded() {
        hideLoadingIfNeeded_called = true
    }
    
    public func handleTaskFailure(with error: Error) {
        handleTaskFailure_calledWith = error
    }
    
    public func handleTaskResultReady(with taskViewModel: RSDTaskViewModel) {
        handleTaskResultReady_calledWith = taskViewModel
    }

    public func addAsyncActions(with configurations: [RSDAsyncActionConfiguration], path: RSDPathComponent, completion: @escaping (([RSDAsyncAction]) -> Void)) {
        addAsyncActions_called = true
        addAsyncActions_calledWith = configurations
        DispatchQueue.main.async {
            let controllers: [RSDAsyncAction] = configurations.map {
                return TestAsyncActionController(with: $0, at: path)
            }
            self.currentAsyncControllers.append(contentsOf: controllers)
            completion(controllers)
        }
    }
    
    public func startAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void)) {
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
    
    public func stopAsyncActions(for controllers: [RSDAsyncAction], showLoading: Bool, completion: @escaping (() -> Void)) {
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
    
    public func goForward() {
        self.taskViewModel.perform(actionType: .navigation(.goForward))
        
        // Add an answer result to the task path where the value is set equal to the step identifier. This is
        // used to test forward/backward navigation.
        if let node = self.taskViewModel.currentNode {
            let stepResult = node.step.instantiateStepResult()
            if let answerResult = stepResult as? RSDAnswerResultObject,
                answerResult.value == nil, answerResult.answerType == .string {
                var aResult = answerResult
                aResult.value = node.identifier
                node.taskResult.appendStepHistory(with: aResult)
            } else {
                node.taskResult.appendStepHistory(with: stepResult)
            }
        }
    }
    
    public func goBack() {
        self.taskViewModel.perform(actionType: .navigation(.goBackward))
    }
    
    public func test_stepTo(_ stepIdentifier: String) -> RSDStep {
        var loopCount: Int = 0
        if self.taskViewModel.currentNode == nil {
            self.goForward()
        }
        while let node = self.taskViewModel.currentNode, node.identifier != stepIdentifier {
            loopCount += 1
            if loopCount > 30 {
                fatalError("Your test is in an infinite loop of Wacky madness.")
            }
            self.goForward()
        }
        return self.taskViewModel.currentNode!.step
    }
}
