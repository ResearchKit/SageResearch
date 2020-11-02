//
//  CopyStepTests.swift
//  Research
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
@testable import Research
@testable import Research_UnitTest

class CopyStepTests: XCTestCase {
    
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
        let step = RSDActiveUIStepObject(identifier: "foo", nextStepIdentifier: "bar", type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
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
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
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
    
    func testCopyDefaultDecodable_ActiveUIStepObject() {
        let step = RSDActiveUIStepObject(identifier: "foo", nextStepIdentifier: "bar", type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        step.duration = 5
        step.commands = [.continueOnFinish]
        step.spokenInstructions = [0 : "start"]
        step.requiresBackgroundAudio = true
        step.beforeCohortRules = [RSDCohortNavigationRuleObject(requiredCohorts: ["boo"], cohortOperator: nil, skipToIdentifier: nil)]
        step.afterCohortRules = [RSDCohortNavigationRuleObject(requiredCohorts: ["goo"], cohortOperator: nil, skipToIdentifier: nil)]
        
        let json = """
        {
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let copy = self.copy(step: step, with: json) as? RSDActiveUIStepObject else {
            XCTFail("Failed to copy decodable")
            return
        }
        
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
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
    
    @available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
    func testCopy_FormUIStepObject() {
        let inputField = RSDInputFieldObject(identifier: "goo", dataType: .base(.boolean))
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField], type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
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
    
    @available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
    func testCopyDefaultDecodable_FormUIStepObject() {
        let inputField = RSDInputFieldObject(identifier: "goo", dataType: .base(.boolean))
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField], type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let json = """
        {
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let copy = self.copy(step: step, with: json) as? RSDFormUIStepObject else {
            XCTFail("Failed to copy decodable")
            return
        }
        
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
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
    
    func testCopy_ResultSummaryStepObject() {
        let step = RSDResultSummaryStepObject(identifier: "foo", resultIdentifier: "boo", unitText: "lala",
                                              stepResultIdentifier: "goo")
        step.title = "title"
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.resultIdentifier, "boo")
        XCTAssertEqual(copy.stepResultIdentifier, "goo")
        XCTAssertEqual(copy.unitText, "lala")
    }
    
    func testCopyDefaultDecodable_ResultSummaryStepObject() {
        let step = RSDResultSummaryStepObject(identifier: "foo", resultIdentifier: "boo", unitText: "lala", stepResultIdentifier: "goo")
        step.title = "title"
        
        let json = """
        {
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let copy = self.copy(step: step, with: json) as? RSDResultSummaryStepObject else {
            XCTFail("Failed to copy decodable")
            return
        }
        
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.resultIdentifier, "boo")
        XCTAssertEqual(copy.unitText, "lala")
        XCTAssertEqual(copy.stepResultIdentifier, "goo")
    }
    
    func testCopy_SectionStepObject() {
        let uiStep = RSDUIStepObject(identifier: "goo", type: "boo")

        var step = RSDSectionStepObject(identifier: "foo", steps: [uiStep])
        step.progressMarkers = ["goo"]
        step.asyncActions = [RSDStandardAsyncActionConfiguration(identifier: "location", type: .distance, startStepIdentifier: nil, stopStepIdentifier: nil)]

        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, step.stepType)
        XCTAssertEqual(copy.steps.count, 1)
        XCTAssertEqual(copy.steps.first?.identifier, "goo")
        if let progressMarkers = copy.progressMarkers {
            XCTAssertEqual(progressMarkers, ["goo"])
        } else {
            XCTAssertNotNil(copy.progressMarkers)
        }
        XCTAssertEqual((copy.asyncActions?.first as? RSDStandardAsyncActionConfiguration)?.identifier, "location")
    }
    
    func testCopyDefaultDecodable_SectionStepObject() {
        let uiStep = RSDUIStepObject(identifier: "goo", type: "boo")
        
        var step = RSDSectionStepObject(identifier: "foo", steps: [uiStep])
        step.progressMarkers = ["goo"]
        step.asyncActions = [RSDStandardAsyncActionConfiguration(identifier: "location", type: .distance, startStepIdentifier: nil, stopStepIdentifier: nil)]
        
        let json = """
        {
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let copy = self.copy(step: step, with: json) as? RSDSectionStepObject else {
            XCTFail("Failed to copy decodable")
            return
        }
        
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, step.stepType)
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
        let step = RSDUIStepObject(identifier: "foo", nextStepIdentifier: "bar", type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
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
    
    func testCopyDefaultDecodable_UIStepObject() {
        let step = RSDUIStepObject(identifier: "foo", nextStepIdentifier: "bar", type: "boo")
        step.title = "title"
        step.subtitle = "text"
        step.detail = "detail"
        step.footnote = "footnote"
        step.viewTheme = RSDViewThemeElementObject(viewIdentifier: "fooView")
        step.colorMapping = RSDSingleColorThemeElementObject(colorStyle: .primary)
        step.imageTheme = RSDResourceImageDataObject(imageName: "fooIcon")
        step.actions = [.navigation(.learnMore) : RSDWebViewUIActionObject(url: "fooFile", buttonTitle: "tap foo"), .custom("moreInformation"): RSDVideoViewUIActionObject(url: "video.mp4", buttonTitle: "See this in action")]
        step.shouldHideActions = [.navigation(.skip)]
        
        let json = """
        {
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let copy = self.copy(step: step, with: json) as? RSDUIStepObject else {
            XCTFail("Failed to copy decodable")
            return
        }
        
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.stepType, "boo")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "text")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.footnote, "footnote")
        XCTAssertEqual(copy.viewTheme?.viewIdentifier, "fooView")
        XCTAssertEqual((copy.colorMapping as? RSDSingleColorThemeElementObject)?.colorStyle, .primary)
        XCTAssertEqual(copy.imageTheme?.imageName, "fooIcon")
        XCTAssertEqual(copy.nextStepIdentifier, "bar")
        if let learnAction = copy.actions?[.navigation(.learnMore)] as? RSDWebViewUIActionObject {
            XCTAssertEqual(learnAction.url, "fooFile")
            XCTAssertEqual(learnAction.buttonTitle, "tap foo")
        } else {
            XCTFail("\(String(describing: copy.actions)) does not include expected learn more action")
        }
        if let moreInformationAction = copy.actions?[.custom("moreInformation")] as? RSDVideoViewUIActionObject {
            XCTAssertEqual(moreInformationAction.url, "video.mp4")
            XCTAssertEqual(moreInformationAction.buttonTitle, "See this in action")
        } else {
            XCTFail("\(String(describing: copy.actions)) does not include expected more information action")
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
        taskInfo.schemaInfoObject = RSDSchemaInfoObject(identifier: "bar", revision: 6)
        let step = RSDTaskInfoStepObject(with: taskInfo)

        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.taskInfo.title, "title")
        XCTAssertEqual(copy.taskInfo.subtitle, "subtitle")
        XCTAssertEqual(copy.taskInfo.detail, "detail")
        XCTAssertEqual(copy.taskInfo.schemaInfo?.schemaIdentifier, "bar")
        XCTAssertEqual(copy.taskInfo.schemaInfo?.schemaVersion, 6)
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
    
    func testCopy_ConditionalStepNavigator_RemoveSteps() {
        let steps = TestStep.steps(from: [1, 2, 3, 4, 5, 6, 7])
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = steps.map { $0.identifier }
        
        let copy = navigator.copyAndRemove(["step2", "step4"])
        
        let order = copy.steps.map { $0.identifier }
        XCTAssertEqual(order, ["step1", "step3", "step5", "step6", "step7"])
        if let markers = copy.progressMarkers {
            XCTAssertEqual(markers, ["step1", "step3", "step5", "step6", "step7"])
        } else {
            XCTFail("Failed to copy the progress markers")
        }
    }
    
    // MARK: Test decodable copy.

    func copy(step: RSDCopyStep, with json: Data) -> RSDCopyStep? {
        var ret: RSDCopyStep? = nil
        CopyStepTests.unboxQueue.sync {
            do {
                _DecodableStepWrapper._unboxStep = step
                let obj = try decoder.decode(_DecodableStepWrapper.self, from: json)
                ret = obj.step
            }
            catch let err {
                XCTFail("Failed to decode/copy the step. \(err)")
            }
        }
        return ret
    }
    
    static let unboxQueue = DispatchQueue(label: "org.sagebase.Research.CopyStepTests.unbox")
    
    fileprivate struct _DecodableStepWrapper : Decodable {
        static var _unboxStep: RSDCopyStep!
        
        let step: RSDCopyStep
        
        init(from decoder: Decoder) throws {
            self.step = try _DecodableStepWrapper._unboxStep.copy(with: "bar", decoder: decoder)
        }
    }
}
