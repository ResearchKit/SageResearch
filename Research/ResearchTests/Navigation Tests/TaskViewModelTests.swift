//
//  TaskViewModelTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research
@testable import Research_UnitTest
import JsonModel
import ResultModel

class TaskViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchTask() {
        let steps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3", "step4"])
        let navigator = TestConditionalNavigator(steps: steps)
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        let taskInfo = TestTaskInfo(task: task)
        let taskViewModel = TestTaskViewModel(taskInfo: taskInfo)
        let runUUID = taskViewModel.taskRunUUID ?? UUID()
        let startDate = taskViewModel.taskResult.startDate
        
        let expect = expectation(description: "Fetch Task \(taskInfo.identifier)")
        
        // setup completion handlers
        taskViewModel.completion_handleTaskLoaded = {
            expect.fulfill()
        }
        taskViewModel.completion_handleTaskFailure = { error in
            XCTFail("Fetching the task was not expected to fail. \(error)")
            expect.fulfill()
        }
        
        // call method under test
        taskViewModel.fetchTask()

        waitForExpectations(timeout: 2) { (err) in
            print(String(describing: err))
        }
        
        // The task run UUID should be the same but the task result should have been replaced with a new
        // instance that has a different start date.
        XCTAssertEqual(taskViewModel.taskRunUUID, runUUID)
        XCTAssertNotEqual(taskViewModel.taskResult.startDate, startDate)
    }
    
    func testFetchTask_Error() {
        let steps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3", "step4"])
        let navigator = TestConditionalNavigator(steps: steps)
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        let fetchError = RSDValidationError.invalidType("foo") as Error
        let taskInfo = TestTaskInfo(task: task, fetchError: fetchError)
        let taskViewModel = TestTaskViewModel(taskInfo: taskInfo)
        
        let expect = expectation(description: "Fetch Task \(taskInfo.identifier)")
        
        // setup completion handlers
        taskViewModel.completion_handleTaskLoaded = {
            XCTFail("Fetching the task was expected to fail.")
            expect.fulfill()
        }
        taskViewModel.completion_handleTaskFailure = { error in
            XCTAssertEqual(fetchError.localizedDescription, error.localizedDescription)
            expect.fulfill()
        }
        
        // call method under test
        taskViewModel.fetchTask()
        
        waitForExpectations(timeout: 2) { (err) in
            print(String(describing: err))
        }
    }

    func testFetchTask_AsyncResults() {
        let steps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3", "step4"])
        let navigator = TestConditionalNavigator(steps: steps)
        var task = TestTask(identifier: "test", stepNavigator: navigator)
        
        // Create an answer result to add to the final task result.
        let taskResult = RSDTaskResultObject(identifier: "test")
        let answerResultBlu = AnswerResultObject(identifier: "blu", value: .string("goo"))
        taskResult.appendAsyncResult(with: answerResultBlu)
        task.taskResult = taskResult
        
        let taskInfo = TestTaskInfo(task: task)
        let taskViewModel = TestTaskViewModel(taskInfo: taskInfo)
        
        let runUUID = taskViewModel.taskRunUUID ?? UUID()
        let startDate = taskViewModel.taskResult.startDate
        
        // Create an answer result to add to the temporary task result.
        let answerResultFoo = AnswerResultObject(identifier: "foo", value: .string("bar"))
        taskViewModel.taskResult.appendAsyncResult(with: answerResultFoo)
        
        let expect = expectation(description: "Fetch Task \(taskInfo.identifier)")
        
        // setup completion handlers
        taskViewModel.completion_handleTaskLoaded = {
            expect.fulfill()
        }
        taskViewModel.completion_handleTaskFailure = { error in
            XCTFail("Fetching the task was not expected to fail. \(error)")
            expect.fulfill()
        }
        
        // call method under test
        taskViewModel.fetchTask()
        
        waitForExpectations(timeout: 2) { (err) in
            print(String(describing: err))
        }
        
        // The task run UUID should be the same but the task result should have been replaced with a new
        // instance that has a different start date.
        XCTAssertEqual(taskViewModel.taskRunUUID, runUUID)
        XCTAssertNotEqual(taskViewModel.taskResult.startDate, startDate)
        
        // The async results should include both blu and goo
        guard let asyncResults = taskViewModel.taskResult.asyncResults
            else {
                XCTFail("The async results should not be nil")
                return
        }
        
        let identifiers = Set(asyncResults.map { $0.identifier })
        let expected = Set(["foo", "blu"])
        XCTAssertEqual(identifiers, expected)
    }
}

class TestTaskViewModel : RSDTaskViewModel {
    
    var completion_handleTaskLoaded: (() -> Void)?
    var completion_handleTaskFailure: ((Error) -> Void)?
    var stepToSkip: String?
    
    override func pathComponent(for step: RSDStep) -> (node: RSDNodePathComponent, stepController: RSDStepController?)? {
        if step.identifier == stepToSkip {
            taskResult.appendAsyncResult(with: AnswerResultObject(identifier: stepToSkip!, value: .string("foo")))
            return nil
        }
        else {
            return super.pathComponent(for: step)
        }
    }
    
    override func handleTaskLoaded() {
        completion_handleTaskLoaded?()
    }
    
    override func handleTaskFailure(with error: Error) {
        completion_handleTaskFailure?(error)
    }
}
