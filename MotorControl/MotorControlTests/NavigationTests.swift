//
//  NavigationTests.swift
//  MotorControlTests
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

@testable import MotorControl
import XCTest

class TestHandStepController: NSObject, MCTHandStepController {

    var stepViewModel: RSDStepViewPathComponent!
    
    init(step: RSDStep, parent: RSDPathComponent) {
        stepViewModel = RSDStepViewModel(step: step, parent: parent)
    }
    
    var isFirstAppearance: Bool = true
    
    var imageView: UIImageView?
    
    var stepTitleLabel: UILabel?
    
    var stepTextLabel: UILabel?
    
    var stepDetailLabel: UILabel?
    
    var uiStep: RSDUIStep?

    func didFinishLoading() {
        //
    }
    
    func goForward() {
        self.stepViewModel.perform(actionType: .navigation(.goForward))
    }
    
    func goBack() {
        self.stepViewModel.perform(actionType: .navigation(.goBackward))
    }
}

class NavigationTests: XCTestCase {
    
    var taskController : TestTaskController!
    var steps : [RSDStep]!
    var handSelection : [String]!
    
    
    override func setUp() {
        self.steps = []
        let firstSteps : [RSDStep] = TestStep.steps(from: ["overview", "instruction"])
        self.steps.append(contentsOf: firstSteps)
        let leftSectionSteps : [RSDStep] = TestStep.steps(from: ["leftInstruction", "leftActive"])
        let leftSection : RSDSectionStepObject = RSDSectionStepObject(identifier: "left", steps: leftSectionSteps)
        self.steps.append(leftSection)
        let rightSectionSteps : [RSDStep] = TestStep.steps(from: ["rightInstruction", "rightActive"])
        let rightSection : RSDSectionStepObject = RSDSectionStepObject(identifier: "right", steps: rightSectionSteps)
        self.steps.append(rightSection)
        let finalSteps : [RSDStep] = TestStep.steps(from: ["completion"])
        self.steps.append(contentsOf: finalSteps)
        self.taskController = TestTaskController()
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["overview", "instruction", "left", "right", "completion"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        self.taskController = TestTaskController()
        self.taskController.task = task
        super.setUp()
    }
    
    override func tearDown() {
        self.taskController = nil
        self.steps = nil
        super.tearDown()
    }
    
    private func _insertHandSelectionResult(for taskController: TestTaskController) {
        var collectionResult = RSDCollectionResultObject(identifier: "handSelection")
        var answerResult = RSDAnswerResultObject(identifier: "handSelection", answerType: .string)
        if self.handSelection.count == 2 {
            answerResult.value = "both"
        } else {
            answerResult.value = self.handSelection.first!
        }
        
        collectionResult.appendInputResults(with: answerResult)
        let answerType = RSDAnswerResultType(baseType: .string, sequenceType: .array)
        var handOrderResult = RSDAnswerResultObject(identifier: MCTHandSelectionDataSource.handOrderKey, answerType: answerType)
        handOrderResult.value = self.handSelection
        collectionResult.appendInputResults(with: handOrderResult)
        self.taskController.taskViewModel.taskResult.appendStepHistory(with: collectionResult)
    }
    
    private func _insertIsFirstRunResult(for taskController: TestTaskController, isFirstRun: Bool) {
        var answerResult = RSDAnswerResultObject(identifier: "isFirstRun", answerType: .boolean)
        answerResult.value = isFirstRun
        self.taskController.taskViewModel.taskResult.appendAsyncResult(with: answerResult)
    }
    
    private func _setupInstructionStepTest() {
        self.steps = []
        let firstSteps : [RSDStep] = TestStep.steps(from: ["first"])
        self.steps.append(contentsOf: firstSteps)
        let firstRunOnly = MCTInstructionStepObject(identifier: "instructionFirstRunOnly", type: .instruction)
        firstRunOnly.isFirstRunOnly = true
        self.steps.append(firstRunOnly)
        self.steps.append(MCTInstructionStepObject(identifier: "instructionNotFirstRunOnly", type: .instruction))
        let finalSteps : [RSDStep] = TestStep.steps(from: ["completion"])
        self.steps.append(contentsOf: finalSteps)
        self.taskController = TestTaskController()
        
        var navigator = TestConditionalNavigator(steps: steps)
        navigator.progressMarkers = ["overview", "instructionFirstRunOnly", "instructionNotFirstRunOnly", "completion"]
        
        let task = TestTask(identifier: "test", stepNavigator: navigator)
        
        self.taskController = TestTaskController()
        self.taskController.task = task
        super.setUp()
    }
    
    private func _whichHand(step: RSDStep) -> String? {
        return TestHandStepController(step: step, parent: self.taskController.taskViewModel.currentTaskPath).whichHand()?.rawValue
    }
    
    public func testSkippableSection_Left() {
        self.handSelection = ["left"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testSkippableSection_Right() {
        self.handSelection = ["right"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }

    public func testSkippableSection_LeftThenRight() {
        self.handSelection = ["left", "right"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testSkippableSection_RightThenLeft() {
        self.handSelection = ["right", "left"]
        _insertHandSelectionResult(for: self.taskController)
        let _ = self.taskController.test_stepTo("instruction")
        // Go forward to the rightInstruction step
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward into the rightActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "rightActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "right")
        // Go forward to the leftInstruction step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftInstruction")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward into the leftActive step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "leftActive")
        XCTAssertEqual(_whichHand(step: stepTo!), "left")
        // Go forward to the completion step
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testInstructionStep_firstRun() {
        _setupInstructionStepTest()
        _insertIsFirstRunResult(for: self.taskController, isFirstRun: true)
        let _ = self.taskController.test_stepTo("first")
        // Go forward, shouldn't skip the instructionFirstRunOnly
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionFirstRunOnly")
        // Go forward, shouldn't skip the instructionNotFirstRunOnly step either
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionNotFirstRunOnly")
        // Go forward should proceed from instructionNotFirstRunOnly to completion
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
    
    public func testInstructionStep_notFirstRun() {
        _setupInstructionStepTest()
        _insertIsFirstRunResult(for: self.taskController, isFirstRun: false)
        let _ = self.taskController.test_stepTo("first")
        // Go forward, should skip the instructionFirstRunOnly
        self.taskController.goForward()
        var stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "instructionNotFirstRunOnly")
        // Go forward should proceed from instructionNotFirstRunOnly to completion
        self.taskController.goForward()
        stepTo = self.taskController.show_calledTo?.stepViewModel.step
        XCTAssertNotNil(stepTo)
        XCTAssertEqual(stepTo!.identifier, "completion")
    }
}
