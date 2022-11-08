//
//  StepControllerTests.swift
//  ResearchTests
//

import XCTest
@testable import Research
@testable import Research_UnitTest

class StepControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProgress_NoMarkers_FlatHierarchy() {
        let steps = TestStep.steps(from: [1, 2, 3, 4])
        let navigator = TestConditionalNavigator(steps: steps)
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskViewModel = RSDTaskViewModel(task: task)
        taskViewModel.taskResult.appendStepHistory(with: steps[0].instantiateStepResult())
        taskViewModel.taskResult.appendStepHistory(with: steps[1].instantiateStepResult())
        
        let step = steps[1]
        let stepViewModel = RSDStepViewModel(step: step, parent: taskViewModel)
        
        guard let progress = stepViewModel.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 2)
        XCTAssertEqual(progress.total, 4)
        XCTAssertTrue(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_Introduction() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)

        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]

        let task = TestTask(identifier: "test", stepNavigator: navigator)
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("introduction")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        
        // For the instruction step (which isn't in the markers and is *before* the markers)
        // the progress should be nil
        let progress = stepViewModel?.progress()
        XCTAssertNil(progress)
    }
    
    func testProgress_MarkersAndSections_Step2() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("step2")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        
        guard let progress = stepViewModel?.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 2)
        XCTAssertEqual(progress.total, 7)
        XCTAssertFalse(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_Step7() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("step7")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)

        guard let progress = stepViewModel?.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 7)
        XCTAssertEqual(progress.total, 7)
        XCTAssertFalse(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_Step4B() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        let step4 = RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"]))
        steps.append(step4)
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // Test set up
        let path = taskController.taskViewModel.pathComponent(for: step4)
        XCTAssertNotNil(path)
        XCTAssertNil(path?.stepController)
        XCTAssertNotNil(path?.node.parent)
        
        // set up for the step controller
        let _ = taskController.test_stepTo("stepB")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        
        guard let progress = stepViewModel?.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 4)
        XCTAssertEqual(progress.total, 7)
        XCTAssertFalse(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_Step5X() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("stepX")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        
        guard let progress = stepViewModel?.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 5)
        XCTAssertEqual(progress.total, 7)
        XCTAssertFalse(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_Step6C() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("stepX")
        let _ = taskController.test_stepTo("stepC")
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        
        guard let progress = stepViewModel?.progress() else {
            XCTFail("unexpected nil progress")
            return
        }
        
        XCTAssertEqual(progress.current, 6)
        XCTAssertEqual(progress.total, 7)
        XCTAssertFalse(progress.isEstimated)
    }
    
    func testProgress_MarkersAndSections_completion() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("completion")
        
        let hasStepAfter = navigator.hasStep(after: step, with: taskController.taskViewModel.taskResult)
        XCTAssertFalse(hasStepAfter)
        
        // For the completion step (which isn't in the markers and is *after* the markers)
        // the progress should be nil
        let stepViewModel = taskController.taskViewModel.currentNode as? RSDStepViewModel
        XCTAssertNotNil(stepViewModel)
        let progress = stepViewModel?.progress()
        XCTAssertNil(progress)
    }
    
}
