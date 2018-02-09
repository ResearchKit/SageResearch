//
//  StepTests.swift
//  ResearchSuite
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
@testable import ResearchSuite

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
        if let shouldHideActions = step.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(step.shouldHideActions)
        }
        XCTAssertEqual(copy.duration, 5)
        XCTAssertEqual(copy.commands, [.continueOnFinish])
        if let spokenInstructions = step.spokenInstructions {
            XCTAssertEqual(spokenInstructions, [0 : "start"])
        } else {
            XCTAssertNotNil(step.spokenInstructions)
        }
        XCTAssertTrue(copy.requiresBackgroundAudio)
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
        if let shouldHideActions = step.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(step.shouldHideActions)
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
        if let shouldHideActions = step.shouldHideActions {
            XCTAssertEqual(shouldHideActions, [.navigation(.skip)])
        } else {
            XCTAssertNotNil(step.shouldHideActions)
        }
    }
    
    func testCopy_TaskInfoStepObject() {
        var step = RSDTaskInfoStepObject(with: "foo")
        step.title = "title"
        step.subtitle = "subtitle"
        step.detail = "detail"
        step.copyright = "copyright"
        step.estimatedMinutes = 5
        
        let copy = step.copy(with: "bar")
        XCTAssertEqual(copy.identifier, "bar")
        XCTAssertEqual(copy.title, "title")
        XCTAssertEqual(copy.subtitle, "subtitle")
        XCTAssertEqual(copy.detail, "detail")
        XCTAssertEqual(copy.copyright, "copyright")
        XCTAssertEqual(copy.estimatedMinutes, 5)
    }
}
