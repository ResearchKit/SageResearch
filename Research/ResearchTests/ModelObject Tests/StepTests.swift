//
//  StepTests.swift
//  ResearchStack2
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

import XCTest
@testable import ResearchStack2

class StepTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: `copy(with:)`
    
    func testCopy_ActiveUIStepObject() {
        let step = RSDActiveUIStepObject(identifier: "foo", type: "boo")
        step.title = "title"
        step.text = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorTheme = RSDColorThemeElementObject(backgroundColorName: "fooBlue")
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "fooIcon")
        step.nextStepIdentifier = "bar"
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        step.duration = 5
        step.commands = [.continueOnFinish]
        step.spokenInstructions = [0 : "start"]
        step.requiresBackgroundAudio = true
        step.beforeCohortRules = [RSDCohortNavigationRuleObject(requiredCohorts: ["boo"], cohortOperator: nil, skipToIdentifier: nil)]
        step.afterCohortRules = [RSDCohortNavigationRuleObject(requiredCohorts: ["goo"], cohortOperator: nil, skipToIdentifier: nil)]
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.text, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorTheme as? RSDColorThemeElementObject)?._backgroundColorName, "fooBlue")
        XCTAssertEqual((copy.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "fooIcon")
        XCTAssertEqual(copy.nextStepIdentifier, "bar")
        if let learnAction = copy.actions?[.navigation(.learnMore)] as? RSDWebViewUIActionObject {
            XCTAssertEqual(learnAction.url, "fooFile")
            XCTAssertEqual(learnAction.buttonTitle, "tap foo")
        } else {
            XCTFail("\(String(describing: copy.actions)) does not include expected learn more action")
        }
        if let shouldHideActions = copy.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(copy.shouldHideActions)
        }
        XCTAssertEqual(copy.duration, 5)
        XCTAssertEqual(copy.commands, [.continueOnFinish])
        if let spokenInstructions = copy.spokenInstructions {
            XCTAssertEqual(spokenInstructions, [0 : "start"])
        } else {
            XCTAssertNotNil(copy.spokenInstructions)
        }
        XCTAssertTrue(copy.requiresBackgroundAudio)
        if let cohort = copy.beforeCohortRules?.first {
            XCTAssertEqual(cohort.requiredCohorts, ["boo"])
        } else {
            XCTAssertNotNil(copy.beforeCohortRules?.first)
        }
        if let cohort = copy.afterCohortRules?.first {
            XCTAssertEqual(cohort.requiredCohorts, ["goo"])
        } else {
            XCTAssertNotNil(copy.beforeCohortRules?.first)
        }
    }
    
    func testCopy_FormUIStepObject() {
        let inputField = RSDInputFieldObject(identifier: "goo", dataType: .base(.boolean))
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField], type: "boo")
        step.title = "title"
        step.text = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorTheme = RSDColorThemeElementObject(backgroundColorName: "fooBlue")
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "fooIcon")
        step.nextStepIdentifier = "bar"
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.text, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorTheme as? RSDColorThemeElementObject)?._backgroundColorName, "fooBlue")
        XCTAssertEqual((copy.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "fooIcon")
        XCTAssertEqual(copy.nextStepIdentifier, "bar")
        if let learnAction = copy.actions?[.navigation(.learnMore)] as? RSDWebViewUIActionObject {
            XCTAssertEqual(learnAction.url, "fooFile")
            XCTAssertEqual(learnAction.buttonTitle, "tap foo")
        } else {
            XCTFail("\(String(describing: copy.actions)) does not include expected learn more action")
        }
        if let shouldHideActions = copy.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(copy.shouldHideActions)
        }
        
        XCTAssertEqual(copy.inputFields.count, 1)
        XCTAssertEqual(copy.inputFields.first?.identifier, "goo")
        XCTAssertEqual(copy.inputFields.first?.dataType, .base(.boolean))
    }
    
    func testCopy_SectionStepObject() {
        let uiStep = RSDUIStepObject(identifier: "goo", type: "boo")

        var step = RSDSectionStepObject(identifier: "foo", steps: [uiStep], type: "boo")
        step.progressMarkers = ["goo"]
        step.asyncActions = [RSDStandardAsyncActionConfiguration(identifier: "location", type: .distance, startStepIdentifier: nil, stopStepIdentifier: nil)]

        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.steps.count, 1)
        XCTAssertEqual(copy.steps.first?.identifier, "goo")
        if let progressMarkers = copy.progressMarkers {
            XCTAssertEqual(progressMarkers, ["goo"])
        } else {
            XCTAssertNotNil(copy.progressMarkers)
        }
        XCTAssertEqual((copy.asyncActions?.first as? RSDStandardAsyncActionConfiguration)?.identifier, "location")
    }
    
    func testCopy_UIStepObject() {
        let step = RSDUIStepObject(identifier: "foo", type: "boo")
        step.title = "title"
        step.text = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorTheme = RSDColorThemeElementObject(backgroundColorName: "fooBlue")
        step.imageTheme = RSDFetchableImageThemeElementObject(imageName: "fooIcon")
        step.nextStepIdentifier = "bar"
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.text, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorTheme as? RSDColorThemeElementObject)?._backgroundColorName, "fooBlue")
        XCTAssertEqual((copy.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "fooIcon")
        XCTAssertEqual(copy.nextStepIdentifier, "bar")
        if let learnAction = copy.actions?[.navigation(.learnMore)] as? RSDWebViewUIActionObject {
            XCTAssertEqual(learnAction.url, "fooFile")
            XCTAssertEqual(learnAction.buttonTitle, "tap foo")
        } else {
            XCTFail("\(String(describing: copy.actions)) does not include expected learn more action")
        }
        if let shouldHideActions = copy.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(copy.shouldHideActions)
        }
    }
    
    func testCopy_TaskInfoObject() {
        var taskInfo = RSDTaskInfoObject(with: "foo")
        taskInfo.title = "title"
        taskInfo.subtitle = "subtitle"
        taskInfo.detail = "detail"
        taskInfo.schemaInfo = RSDSchemaInfoObject(identifier: "bar", revision: 6)
        var step = RSDTaskInfoStepObject(with: taskInfo)
        step.taskTransformer = RSDResourceTransformerObject(resourceName: "FactoryTest_TaskFoo", bundleIdentifier: "org.sagebase.ResearchStack2Tests", classType: nil)

        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.taskInfo.title, "title")
        XCTAssertEqual(copy.taskInfo.subtitle, "subtitle")
        XCTAssertEqual(copy.taskInfo.detail, "detail")
        XCTAssertEqual(copy.taskInfo.schemaInfo?.schemaIdentifier, "bar")
        XCTAssertEqual(copy.taskInfo.schemaInfo?.schemaVersion, 6)
        if let transformer = copy.taskTransformer as? RSDResourceTransformerObject {
            XCTAssertEqual(transformer.resourceName, "FactoryTest_TaskFoo")
        } else {
            XCTFail("Failed to copy the task transformer.")
        }
    }
    
    func testCopy_ConditionalStepNavigator_NilInsertAfter() {
        let steps = TestStep.steps(from: [1, 2, 3, 4])
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = steps.map { $0.identifier }
        
        let sectionSteps = TestStep.steps(from: ["A", "B", "C"])
        let section = RSDSectionStepObject(identifier: "section", steps: sectionSteps)
        
        let copy = navigator.copyAndInsert(section)
        
        XCTAssertEqual(copy.steps.count, 5)
        let order = copy.steps.map { $0.identifier }
        XCTAssertEqual(order, ["step1", "section", "step2", "step3", "step4"])
        XCTAssertEqual(copy.insertAfterIdentifier, "section")
        if let markers = copy.progressMarkers {
            XCTAssertEqual(markers, ["step1", "section", "step2", "step3", "step4"])
        } else {
            XCTFail("Failed to copy the progress markers")
        }
    }
    
    func testCopy_ConditionalStepNavigator_MarkerBeforeNotIncluded() {
        let steps = TestStep.steps(from: [1, 2, 3, 4])
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = Array(steps.map { $0.identifier }[1...])
        
        let sectionSteps = TestStep.steps(from: ["A", "B", "C"])
        let section = RSDSectionStepObject(identifier: "section", steps: sectionSteps)
        
        let copy = navigator.copyAndInsert(section)
        
        XCTAssertEqual(copy.steps.count, 5)
        let order = copy.steps.map { $0.identifier }
        XCTAssertEqual(order, ["step1", "section", "step2", "step3", "step4"])
        XCTAssertEqual(copy.insertAfterIdentifier, "section")
        if let markers = copy.progressMarkers {
            XCTAssertEqual(markers, ["section", "step2", "step3", "step4"])
        } else {
            XCTFail("Failed to copy the progress markers")
        }
    }
    
    func testCopy_ConditionalStepNavigator_NonNilInsertAfter() {
        let steps = TestStep.steps(from: [1, 2, 3, 4])
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = steps.map { $0.identifier }
        navigator.insertAfterIdentifier = "step2"
        
        let sectionSteps = TestStep.steps(from: ["A", "B", "C"])
        let section = RSDSectionStepObject(identifier: "section", steps: sectionSteps)
        
        let copy = navigator.copyAndInsert(section)
        
        XCTAssertEqual(copy.steps.count, 5)
        let order = copy.steps.map { $0.identifier }
        XCTAssertEqual(order, ["step1", "step2", "section", "step3", "step4"])
        XCTAssertEqual(copy.insertAfterIdentifier, "section")
        if let markers = copy.progressMarkers {
            XCTAssertEqual(markers, ["step1", "step2", "section", "step3", "step4"])
        } else {
            XCTFail("Failed to copy the progress markers")
        }
    }
}
