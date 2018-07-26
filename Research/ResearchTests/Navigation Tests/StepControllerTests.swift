//
//  StepControllerTests.swift
//  ResearchTests
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

import XCTest
@testable import Research

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
        
        let taskController = TestTaskController()
        taskController.topLevelTask = task
        taskController.taskPath.appendStepHistory(with: steps[0].instantiateStepResult())
        taskController.taskPath.appendStepHistory(with: steps[1].instantiateStepResult())
        
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = steps[1]
        
        guard let progress = stepController.progress() else {
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("introduction")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        // For the instruction step (which isn't in the markers and is *before* the markers)
        // the progress should be nil
        let progress = stepController.progress()
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("step2")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        guard let progress = stepController.progress() else {
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("step7")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        guard let progress = stepController.progress() else {
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
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepA", "stepB", "stepC"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("stepB")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        guard let progress = stepController.progress() else {
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("stepX")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        guard let progress = stepController.progress() else {
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("stepX")
        let step = taskController.test_stepTo("stepC")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        guard let progress = stepController.progress() else {
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
        taskController.topLevelTask = task
        
        // set up for the step controller
        let step = taskController.test_stepTo("completion")
        let stepController = TestStepController()
        stepController.taskController = taskController
        stepController.step = step
        
        let hasStepAfter = navigator.hasStep(after: step, with: taskController.taskResult)
        XCTAssertFalse(hasStepAfter)
        
        // For the completion step (which isn't in the markers and is *after* the markers)
        // the progress should be nil
        let progress = stepController.progress()
        XCTAssertNil(progress)
    }
    
}
