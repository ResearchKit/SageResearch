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
import JsonModel
import UIKit
import ResearchUI

func setupPlatformContext() {
    resourceLoader = ResourceLoader()
    LocalizationBundle.registerDefaultBundlesIfNeeded()
}

public struct TestStep : RSDStep, RSDNavigationRule, RSDNavigationSkipRule, RSDOptionalStep {
    
    public let identifier: String
    public var stepType: RSDStepType = .instruction
    public var result: RSDResult?
    public var validationError: Error?
    public var nextStepIdentifier: String?
    public var showBeforeIdentifier: String?
    public var fullInstructionsOnly: Bool = false
    
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
        return AnswerResultObject(identifier: identifier, answerType: AnswerTypeString())
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
    
    public var stepType: RSDStepType {
        return .subtask
    }
}

public final class TestTaskInfo : RSDTaskInfo, RSDTaskTransformer {
    
    public init(task: TestTask, fetchError: Error? = nil) {
        self.task = task
        self.fetchError = fetchError
    }
    
    private let task: TestTask
    private let fetchError: Error?
    
    public var identifier: String {
        return task.identifier
    }
    
    public var title: String?
    
    public var subtitle: String?
    
    public var detail: String?
    
    public var footnote: String?
    
    public var estimatedMinutes: Int = 2
    
    public var imageData: RSDImageData?
    
    public var schemaInfo: RSDSchemaInfo? {
        return self.task.schemaInfo
    }
    
    public let resourceTransformer: RSDTaskTransformer? = nil
    
    public func copy(with identifier: String) -> TestTaskInfo {
        let copy =  TestTaskInfo(task: self.task, fetchError: self.fetchError)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.estimatedMinutes = self.estimatedMinutes
        copy.imageData = self.imageData
        return copy
    }
    
    public let estimatedFetchTime: TimeInterval = 0
    
    public func fetchTask(with taskIdentifier: String, schemaInfo: RSDSchemaInfo?, callback: @escaping RSDTaskFetchCompletionHandler) {
        callback(task, fetchError)
    }
}

public struct TestTask : RSDTask, RSDTrackingTask {

    public let identifier: String
    public let stepNavigator: RSDStepNavigator
    public var schemaInfo: RSDSchemaInfo?
    public var asyncActions: [RSDAsyncActionConfiguration]?
    
    public var taskResult: RSDTaskResult?
    public var validationError: Error?
    public var tracker: RSDTrackingTask?
    
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
    
    public func taskData(for taskResult: RSDTaskResult) -> RSDTaskData? {
        return tracker?.taskData(for: taskResult)
    }
    
    public func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent) {
        tracker?.setupTask(with: data, for: path)
    }
    
    public func shouldSkipStep(_ step: RSDStep) -> (shouldSkip: Bool, stepResult: RSDResult?) {
        return tracker?.shouldSkipStep(step) ?? (false, nil)
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
    
    func requestPermission() {
        status = .permissionGranted
    }

    public func requestPermissions(on viewController: Any, _ completion: @escaping RSDAsyncActionCompletionHandler) {
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
    public var requestPermissionsForAsyncActions_called = false
    public var requestPermissionsForAsyncActions_calledWith: [RSDAsyncAction]?
    public var stopAsyncActions_called = false
    public var stopAsyncActions_calledWith: [RSDAsyncAction]?
    
    public var handleTaskDidFinish_completionBlock: (() -> Void)?
    public var handleTaskResultReady_completionBlock: (() -> Void)?
    
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
        handleTaskResultReady_completionBlock?()
        handleTaskResultReady_completionBlock = nil
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
    
    public func requestPermission(for controllers: [RSDAsyncAction], completion: @escaping (() -> Void)) {
        requestPermissionsForAsyncActions_called = true
        requestPermissionsForAsyncActions_calledWith = controllers
        DispatchQueue.main.async {
            for controller in controllers {
                (controller as? TestAsyncActionController)?.requestPermission()
            }
            let set = NSMutableSet(array: self.currentAsyncControllers)
            set.union(Set(controllers as! [TestAsyncActionController]))
            self.currentAsyncControllers = set.allObjects as! [TestAsyncActionController]
            completion()
        }
    }
    
    public func startAsyncActionsIfNeeded() {
        assertionFailure("Not implemented")
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
            if let answerResult = stepResult as? AnswerResultObject,
                answerResult.jsonValue == nil,
                answerResult.jsonAnswerType is AnswerTypeString {
                answerResult.jsonValue = .string(node.identifier)
                node.taskResult.appendStepHistory(with: answerResult)
            } else {
                node.taskResult.appendStepHistory(with: stepResult)
            }
        }
    }
    
    public func goBack() {
        self.taskViewModel.perform(actionType: .navigation(.goBackward))
    }
    
    /// This is a convenience method that cannot be used to go forward if there are async actions being
    /// being started because they would end up on the next run loop.
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

public class TestDataStoreManager : NSObject, RSDDataStorageManager {
    
    public var previous: [RSDIdentifier : RSDTaskData] = [:]
    public var saveTaskData_called: [(data: RSDTaskData, taskResult: RSDTaskResult?)] = []
    
    public func previousTaskData(for taskIdentifier: RSDIdentifier) -> RSDTaskData? {
        return previous[taskIdentifier]
    }
    
    public func saveTaskData(_ data: RSDTaskData, from taskResult: RSDTaskResult?) {
        saveTaskData_called.append((data, taskResult))
    }
}

public struct TestData : RSDTaskData {
    public let identifier: String
    public let timestampDate: Date?
    public let json: JsonSerializable
    
    public init(identifier: String, timestampDate: Date?, json: JsonSerializable) {
        self.identifier = identifier
        self.timestampDate = timestampDate
        self.json = json
    }
}
