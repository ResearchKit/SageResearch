//
//  TaskControllerTests.swift
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

class TaskControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNavigation_BackFrom5X() {
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
        taskController.goBack()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepC")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.reverse)
        
        guard let currentNode = taskController.taskViewModel.currentNode else {
            XCTFail("The current node should be non-nil")
            return
        }
        
        XCTAssertEqual(currentNode.stepPath, "stepA, stepB, stepC")
        
        // check that the path parent has the correct current step
        let currentParentStep = currentNode.parent
        XCTAssertNotNil(currentParentStep)
        XCTAssertEqual(currentParentStep?.identifier, "step4")
    }
    
    func testNavigation_BackFrom5Z() {
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
        let _ = taskController.test_stepTo("stepZ")
        taskController.goBack()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepY")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.reverse)
        
        guard let currentNode = taskController.taskViewModel.currentNode else {
            XCTFail("The current node should be non-nil")
            return
        }
        
        XCTAssertEqual(currentNode.stepPath, "stepX, stepY")
        
        // check that the path parent has the correct current step
        let currentParentStep = currentNode.parent
        XCTAssertNotNil(currentParentStep)
        XCTAssertEqual(currentParentStep?.identifier, "step5")
    }
    
    func testNavigation_BackFrom3() {
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
        let _ = taskController.test_stepTo("step3")
        
        // Check assumptions to see that the test controller is adding expected results to the step history.
        guard let beforeStepHistory = taskController.taskViewModel.currentNode?.taskResult.stepHistory
            else {
              XCTFail("Failed to set up current node. Expecting non-nil value.")
                return
        }
        
        let beforeResult = beforeStepHistory.last
        XCTAssertNotNil(beforeResult)
        XCTAssertEqual(beforeResult?.identifier, "step3")
        
        let beforeResult2 = beforeStepHistory.first(where: { $0.identifier == "step2" })
        XCTAssertNotNil(beforeResult2)
        let beforeAnswerResult2 = beforeResult2 as? RSDAnswerResult
        XCTAssertNotNil(beforeAnswerResult2)
        XCTAssertEqual(beforeAnswerResult2?.value as? String, "step2")
        
        let beforeResult3 = beforeStepHistory.first(where: { $0.identifier == "step3" })
        XCTAssertNotNil(beforeResult3)
        let beforeAnswerResult3 = beforeResult3 as? RSDAnswerResult
        XCTAssertNotNil(beforeAnswerResult3)
        XCTAssertEqual(beforeAnswerResult3?.value as? String, "step3")
        
        // Now go back one step. The expectation is that the state tracking will move back to step2 and the
        // previous answers to both step2 and step3 will be stored in the previous results.
        taskController.goBack()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "step2")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.reverse)
        
        XCTAssertEqual(taskController.taskViewModel.stepPath, "introduction, step1, step2")
        
        let currentResult = taskController.taskViewModel.currentNode?.taskResult.stepHistory.last
        XCTAssertNotNil(currentResult)
        XCTAssertEqual(currentResult?.identifier, "step2")
        
        let previousResult2 = taskController.taskViewModel.previousResults?.first(where: { $0.identifier == "step2" })
        XCTAssertNotNil(previousResult2)
        let answerResult2 = previousResult2 as? RSDAnswerResult
        XCTAssertNotNil(answerResult2)
        XCTAssertEqual(answerResult2?.value as? String, "step2")

        let previousResult3 = taskController.taskViewModel.previousResults?.first(where: { $0.identifier == "step3" })
        XCTAssertNotNil(previousResult3)
        let answerResult3 = previousResult3 as? RSDAnswerResult
        XCTAssertNotNil(answerResult3)
        XCTAssertEqual(answerResult3?.value as? String, "step3")
    }
    
    
    func testNavigation_ForwardFrom5X() {
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
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepY")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.forward)
        
        guard let currentNode = taskController.taskViewModel.currentNode else {
            XCTFail("The current node should be non-nil")
            return
        }
        
        XCTAssertEqual(currentNode.stepPath, "stepX, stepY")
        
        // check that the path parent has the correct current step
        let currentParentStep = currentNode.parent
        XCTAssertNotNil(currentParentStep)
        XCTAssertEqual(currentParentStep?.identifier, "step5")
    }
    
    func testNavigation_ForwardFrom5Z() {
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
        let _ = taskController.test_stepTo("stepZ")
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepA")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.forward)
        
        guard let currentNode = taskController.taskViewModel.currentNode else {
            XCTFail("The current node should be non-nil")
            return
        }
        
        XCTAssertEqual(currentNode.stepPath, "stepA")
        
        // check that the path parent has the correct current step
        let currentParentStep = currentNode.parent
        XCTAssertNotNil(currentParentStep)
        XCTAssertEqual(currentParentStep?.identifier, "step6")
    }
    
    func testNavigation_ForwardFrom2() {
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
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "step3")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction ?? RSDStepDirection.none, RSDStepDirection.forward)
        
        XCTAssertEqual(taskController.taskViewModel.stepPath, "introduction, step1, step2, step3")
    }
    
    
    func testJumpBackward() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        
        var sectionSteps = TestStep.steps(from: ["stepA", "stepB", "stepC"])
        var stepB = sectionSteps[1]
        stepB.nextStepIdentifier = "stepA"
        sectionSteps.remove(at: 1)
        sectionSteps.insert(stepB, at: 1)
        
        steps.append(RSDSectionStepObject(identifier: "step4", steps: sectionSteps))
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
        let _ = taskController.test_stepTo("stepB")
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepA")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction, .reverse)
    }
    
    func testJumpBackward_OutOfSection() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        
        var sectionSteps = TestStep.steps(from: ["stepA", "stepB", "stepC"])
        var stepB = sectionSteps[1]
        stepB.nextStepIdentifier = "step1"
        sectionSteps.remove(at: 1)
        sectionSteps.insert(stepB, at: 1)
        
        steps.append(RSDSectionStepObject(identifier: "step4", steps: sectionSteps))
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
        let _ = taskController.test_stepTo("stepB")
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "step1")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction, .reverse)
    }
    
    func testJumpBackward_OutOfSection_ToPriorSection() {
        var steps: [RSDStep] = []
        let beforeSteps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3"])
        steps.append(contentsOf: beforeSteps)
        
        var sectionSteps = TestStep.steps(from: ["stepA", "stepB", "stepC"])
        var stepB = sectionSteps[1]
        stepB.nextStepIdentifier = "step4"
        sectionSteps.remove(at: 1)
        sectionSteps.insert(stepB, at: 1)
        
        steps.append(RSDSectionStepObject(identifier: "step4", steps: TestStep.steps(from: ["stepX", "stepY", "stepZ"])))
        steps.append(RSDSectionStepObject(identifier: "step5", steps: sectionSteps))
        steps.append(RSDSectionStepObject(identifier: "step6", steps: TestStep.steps(from: ["stepL","stepM", "stepN", "stepO"])))
        let afterSteps: [RSDStep] = TestStep.steps(from: ["step7", "completion"])
        steps.append(contentsOf: afterSteps)
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["step1", "step2", "step3", "step4", "step5", "step6", "step7"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("stepB")
        taskController.goForward()
        
        let stepTo = taskController.show_calledTo
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo?.stepViewModel?.identifier, "stepZ")
        
        let direction = taskController.show_calledDirection
        XCTAssertNotNil(direction)
        XCTAssertEqual(direction, .reverse)
    }
    
    /// Test the case where skip and navigation rules are being used to show the steps in a different order
    /// from their order in the steps array.
    func testCustomOrder() {
        var steps: [RSDStep] = TestStep.steps(from: ["introduction", "step1", "step2", "step3", "step4"])
        var step2 = steps[2] as! TestStep
        step2.nextStepIdentifier = "step1"
        var step1 = steps[1] as! TestStep
        step1.showBeforeIdentifier = "step2"
        step1.nextStepIdentifier = "step3"
        steps.replaceSubrange(1...2, with: [step1, step2])
        
        let navigator = TestConditionalNavigator(steps: steps)
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        let taskController = TestTaskController()
        taskController.task = task
        
        // set up for the step controller
        let _ = taskController.test_stepTo("introduction")
        taskController.goForward()
        
        let stepToFirst = taskController.show_calledTo
        XCTAssertNotNil(stepToFirst)
        XCTAssertEqual(stepToFirst?.stepViewModel?.identifier, "step2")
        
        let directionFirst = taskController.show_calledDirection
        XCTAssertNotNil(directionFirst)
        XCTAssertEqual(directionFirst, .forward)
        
        taskController.show_calledTo = nil
        taskController.show_calledDirection = nil
        
        taskController.goForward()
        
        let stepToSecond = taskController.show_calledTo
        XCTAssertNotNil(stepToSecond)
        XCTAssertEqual(stepToSecond?.stepViewModel?.identifier, "step1")
        
        let directionSecond = taskController.show_calledDirection
        XCTAssertNotNil(directionSecond)
        XCTAssertEqual(directionSecond, .forward)
        
        taskController.show_calledTo = nil
        taskController.show_calledDirection = nil
        
        taskController.goForward()
        
        let stepToThird = taskController.show_calledTo
        XCTAssertNotNil(stepToThird)
        XCTAssertEqual(stepToThird?.stepViewModel?.identifier, "step3")
        
        let directionThird = taskController.show_calledDirection
        XCTAssertNotNil(directionThird)
        XCTAssertEqual(directionThird, .forward)
    }
    
    func testCohortNavigation_SkipFirstStep() {
        let step1 = RSDUIStepObject(identifier: "step1")
        let step2 = RSDUIStepObject(identifier: "step2")
        
        let trackingRule = TestTrackingRule(skipTo: ["step1" : "step2"], next: [:], nextAfterNil: nil)
        RSDFactory.shared.trackingRules = [trackingRule]
        
        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: "test")
        let navigator = RSDConditionalStepNavigatorObject(with: [step1, step2])
        let nextStep = navigator.step(after: nil, with: &taskResult)
        XCTAssertEqual(nextStep.step?.identifier, "step2")
        XCTAssertEqual(nextStep.direction, .forward)
        
        RSDFactory.shared.trackingRules = []
    }
}

class TestTrackingRule : RSDTrackingRule {
    
    let skipTo: [String : String]
    let nextAfterNil: String?
    let next: [String : String]
    
    init(skipTo: [String : String], next: [String : String], nextAfterNil: String?) {
        self.skipTo = skipTo
        self.next = next
        self.nextAfterNil = nextAfterNil
    }
    
    func skipToStepIdentifier(before step: RSDStep, with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        return skipTo[step.identifier]
    }
    
    func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        if let identifier = step?.identifier {
            return next[identifier]
        }
        else {
            return nextAfterNil
        }
    }
}
