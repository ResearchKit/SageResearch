//
//  CodableStepObjectTests.swift
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
import JsonModel

class CodableStepObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testInstructionStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "image": {    "type": "fetchable",
                          "imageName": "before",
                          "placementType": "iconBefore" },
            "nextStepIdentifier": "boo",
            "actions": { "goForward": { "type" : "default",
                                        "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "type" : "default",
                                     "iconName" : "closeX" },
                         "learnMore": { "type" : "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" },
                         "skip": {  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"},
                         "moreInformation": {
                                    "type": "videoView",
                                    "buttonTitle" : "See this in action",
                                    "url": "video.mp4"}
                        },
            "shouldHideActions": ["goBackward", "skip"],

        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDInstructionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual(object.imageTheme?.imageName, "before")
            XCTAssertEqual(object.nextStepIdentifier, "boo")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.iconName, "infoIcon")
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.url, "fooInfo")
            
            let moreInformationAction = object.action(for: .custom("moreInformation"), on: object)
            XCTAssertNotNil(moreInformationAction)
            XCTAssertEqual((moreInformationAction as? RSDVideoViewUIActionObject)?.buttonTitle, "See this in action")
            XCTAssertEqual((moreInformationAction as? RSDVideoViewUIActionObject)?.url, "video.mp4")
            
            let skipAction = object.action(for: .navigation(.skip), on: object)
            XCTAssertNotNil(skipAction)
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.buttonTitle, "not applicable")
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.skipToIdentifier, "boo")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward), on: object) ?? false)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testAbstractStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "image": {    "type": "fetchable",
                          "imageName": "before",
                          "placementType": "iconBefore" },
            "actions": { "goForward": { "type" : "default",
                                        "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "type" : "default",
                                     "iconName" : "closeX" },
                         "learnMore": { "type" : "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" },
                         "skip": {  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"},
                         "moreInformation": {
                                    "type": "videoView",
                                    "buttonTitle" : "See this in action",
                                    "url": "video.mp4"}
                        },
            "shouldHideActions": ["goBackward", "skip"],

        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AbstractUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual(object.imageTheme?.imageName, "before")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.iconName, "infoIcon")
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.url, "fooInfo")
            
            let moreInformationAction = object.action(for: .custom("moreInformation"), on: object)
            XCTAssertNotNil(moreInformationAction)
            XCTAssertEqual((moreInformationAction as? RSDVideoViewUIActionObject)?.buttonTitle, "See this in action")
            XCTAssertEqual((moreInformationAction as? RSDVideoViewUIActionObject)?.url, "video.mp4")
            
            let skipAction = object.action(for: .navigation(.skip), on: object)
            XCTAssertNotNil(skipAction)
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.buttonTitle, "not applicable")
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.skipToIdentifier, "boo")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward), on: object) ?? false)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testUIStepObject_DeviceType_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "watch" : {
                "subtitle": "Watch: Some text.",
                "detail": "Watch: This is a test.",
                "footnote": "Watch: This is a footnote."
            }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let factory = RSDFactory()
            factory.deviceType = .watch
            let decoder = factory.createJSONDecoder()
            
            let wrapper = try decoder.decode(StepWrapper<RSDInstructionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Watch: Some text.")
            XCTAssertEqual(object.detail, "Watch: This is a test.")
            XCTAssertEqual(object.footnote, "Watch: This is a footnote.")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testUIStepObjectWithThemes_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "nextStepIdentifier": "boo",
            "actions": { "goForward": { "type": "default",
                                        "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "type": "default", "iconName" : "closeX" },
                         "learnMore": { "type": "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" },
                         "skip": {  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"}
                        },
            "shouldHideActions": ["goBackward"],
            "image"  : {    "type": "animated",
                            "imageNames" : ["foo1", "foo2", "foo3", "foo4"],
                            "placementType" : "topBackground",
                            "animationDuration" : 2,
                               },
            "colorMapping"     : {  "type" : "singleColor",
                                    "customColor" : {
                                            "color": "sky",
                                            "usesLightStyle" : true}
                                },
            "viewTheme"      : { "type": "default",
                                 "viewIdentifier": "ActiveInstruction",
                                 "storyboardIdentifier": "ActiveTaskSteps" },
            "beforeCohortRules" : [{ "requiredCohorts" : ["goo"],
                                    "skipToIdentifier" : "blueGu",
                                    "operator" : "any" }],
            "afterCohortRules" : [{ "requiredCohorts" : ["baloo"],
                                    "skipToIdentifier" : "foomanchu",
                                    "operator" : "all" }]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDInstructionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual(object.nextStepIdentifier, "boo")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.iconName, "infoIcon")
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.url, "fooInfo")
            
            let skipAction = object.action(for: .navigation(.skip), on: object)
            XCTAssertNotNil(skipAction)
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.buttonTitle, "not applicable")
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.skipToIdentifier, "boo")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward), on: object) ?? false)
            
            if let images = object.imageTheme as? RSDAnimatedImageThemeElementObject {
                XCTAssertEqual(images.animationDuration, 2)
                XCTAssertEqual(images.imageNames, ["foo1", "foo2", "foo3", "foo4"])
                XCTAssertEqual(images.placementType, .topBackground)
            } else {
                XCTFail("Failed to decode images")
            }
            
            if let color = object.colorMapping as? RSDSingleColorThemeElementObject {
                XCTAssertTrue(color.customColor?.usesLightStyle ?? false)
                XCTAssertEqual(color.customColor?.colorIdentifier, "sky")
            } else {
                XCTFail("Failed to decode color theme")
            }
            
            XCTAssertEqual(object.viewTheme?.storyboardIdentifier, "ActiveTaskSteps")
            XCTAssertEqual(object.viewTheme?.viewIdentifier, "ActiveInstruction")
            
            if let cohortRule = object.beforeCohortRules?.first {
                XCTAssertEqual(cohortRule.requiredCohorts, ["goo"])
                XCTAssertEqual(cohortRule.skipToIdentifier, "blueGu")
                XCTAssertEqual(cohortRule.cohortOperator, .any)
            } else {
                XCTFail("Failed to decode before cohort rules")
            }
            
            if let cohortRule = object.afterCohortRules?.first {
                XCTAssertEqual(cohortRule.requiredCohorts, ["baloo"])
                XCTAssertEqual(cohortRule.skipToIdentifier, "foomanchu")
                XCTAssertEqual(cohortRule.cohortOperator, .all)
            } else {
                XCTFail("Failed to decode before cohort rules")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any]
                else {
                    XCTFail("input json not a dictionary")
                    return
            }
            
            expectedDictionary.forEach { (pair) in
                let encodedValue = dictionary[pair.key]
                XCTAssertNotNil(encodedValue, "\(pair.key)")
                if let str = pair.value as? String {
                    XCTAssertEqual(str, encodedValue as? String, "\(pair.key)")
                }
                else if let num = pair.value as? NSNumber {
                    XCTAssertEqual(num, encodedValue as? NSNumber, "\(pair.key)")
                }
                else if let arr = pair.value as? NSArray {
                    XCTAssertEqual(arr, encodedValue as? NSArray, "\(pair.key)")
                }
                else if let dict = pair.value as? NSDictionary {
                    XCTAssertEqual(dict, encodedValue as? NSDictionary, "\(pair.key)")
                }
                else {
                    XCTFail("Failed to match \(pair.key)")
                }
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testActiveUIStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "active",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "duration": 30,
            "commands": ["playSoundOnStart", "vibrateOnFinish"],
            "spokenInstructions" : { "start": "Start moving",
                                     "10": "Keep going",
                                     "halfway": "Halfway there",
                                     "countdown": "5",
                                     "end": "Stop moving"}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDActiveUIStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.duration, 30)
            
            XCTAssertEqual(object.spokenInstruction(at: 0), "Start moving")
            XCTAssertEqual(object.spokenInstruction(at: 10), "Keep going")
            XCTAssertEqual(object.spokenInstruction(at: 15), "Halfway there")
            XCTAssertEqual(object.spokenInstruction(at: 25), "five")
            XCTAssertEqual(object.spokenInstruction(at: 26), "four")
            XCTAssertEqual(object.spokenInstruction(at: 27), "three")
            XCTAssertEqual(object.spokenInstruction(at: 28), "two")
            XCTAssertEqual(object.spokenInstruction(at: 29), "one")
            XCTAssertEqual(object.spokenInstruction(at: 30), "Stop moving")
            XCTAssertEqual(object.spokenInstruction(at: Double.infinity), "Stop moving")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testActiveUIStepObject_Codable_Defaults() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "active"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDActiveUIStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.duration, 0)
            XCTAssertEqual(object.commands, .defaultCommands)
            XCTAssertNil(object.spokenInstructions)
            
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    @available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
    func testFormUIStepObject_Codable() {
        
        let json = """
          {
          "identifier": "step3",
          "type": "form",
          "title": "Step 3",
          "nextStepIdentifier": "blu",
          "inputFields": [
                          {
                          "identifier": "foo",
                          "type": "date",
                          "uiHint": "picker",
                          "prompt": "Foo",
                          "range" : { "minimumDate" : "2017-02",
                                      "maximumDate" : "2017-03",
                                      "codingFormat" : "yyyy-MM" }
                          },
                          {
                          "identifier": "bar",
                          "type": "integer",
                          "prompt": "Bar"
                          }
                    ]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            let converted = try object.convertToQuestion(using: QuestionConvertionFactory())
            
            XCTAssertEqual(converted.identifier, "step3")
            XCTAssertEqual(converted.title, "Step 3")
            guard let question = converted as? MultipleInputQuestionStepObject else {
                XCTFail("Did not convert to expected type.")
                return
            }
            
            XCTAssertEqual(question.nextStepIdentifier, "blu")
            XCTAssertEqual(question.inputItems.count, 2)
            guard let dateItem = question.inputItems.first as? DateInputItemObject,
                let intItem = question.inputItems.last as? IntegerTextInputItemObject
                else {
                    XCTFail("Did not convert to expected type.")
                    return
            }
            
            XCTAssertEqual(dateItem.identifier, "foo")
            XCTAssertEqual(dateItem.inputUIHint, .picker)
            XCTAssertEqual(dateItem.fieldLabel, "Foo")
            if let range = dateItem.formatOptions {
                XCTAssertNotNil(range.maximumDate)
                XCTAssertNotNil(range.minimumDate)
                XCTAssertEqual(range.dateCoder?.inputFormatter.dateFormat, "yyyy-MM")
            }
            else {
                XCTFail("Did not convert to expected type.")
                return
            }
            
            XCTAssertEqual(intItem.identifier, "bar")
            XCTAssertEqual(intItem.fieldLabel, "Bar")
            
            let jsonData = try encoder.encode(question)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }

            XCTAssertEqual(dictionary["type"] as? String, "multipleInputQuestion")
            XCTAssertEqual(dictionary["identifier"] as? String, "step3")

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    @available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
    func testFormUIStepObject_Codable_SingleQuestion() {
        
        let json = """
          {
          "identifier": "step3",
          "type": "form",
          "title": "Step 3",
          "inputFields": [{
            "type": "multipleChoice",
            "choices" : ["never", "sometimes", "often", "always"],
            "surveyRules": [{ "matchingAnswer": "never"}]
            }]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            
            let converted = try object.convertToQuestion(using: QuestionConvertionFactory())
            
            XCTAssertEqual(converted.identifier, "step3")
            XCTAssertEqual(converted.title, "Step 3")
            guard let choiceQuestion = converted as? ChoiceQuestionStepObject else {
                XCTFail("Did not convert to expected type.")
                return
            }
            
            XCTAssertEqual(choiceQuestion.baseType, .string)
            XCTAssertFalse(choiceQuestion.isSingleAnswer)
            XCTAssertEqual(choiceQuestion.jsonChoices.count, 4)
            XCTAssertEqual(choiceQuestion.surveyRules.count, 1)
            
            let jsonData = try encoder.encode(choiceQuestion)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }

            XCTAssertEqual(dictionary["type"] as? String, "choiceQuestion")
            XCTAssertEqual(dictionary["identifier"] as? String, "step3")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testOverviewStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "overview",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "image": {  "type": "fetchable",
                        "imageName": "before",
                        "placementType": "iconBefore" },
            "nextStepIdentifier": "boo",
            "actions": { "goForward": { "type":"default", "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "type":"default", "iconName" : "closeX" },
                         "learnMore": { "type": "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" },
                         "skip": {  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"}
                        },
            "shouldHideActions": ["goBackward", "skip"],
            "permissions" : [{ "permissionType": "location", "reason": "How far you will go!"}]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDOverviewStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual(object.imageTheme?.imageName, "before")
            XCTAssertEqual(object.nextStepIdentifier, "boo")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.iconName, "infoIcon")
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.url, "fooInfo")
            
            let skipAction = object.action(for: .navigation(.skip), on: object)
            XCTAssertNotNil(skipAction)
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.buttonTitle, "not applicable")
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.skipToIdentifier, "boo")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward), on: object) ?? false)
            
            if let permission = object.standardPermissions?.first {
                XCTAssertEqual(permission.reason, "How far you will go!")
                XCTAssertEqual(permission.permissionType, .location)
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testCompletionStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "completion",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "unitText": "foos",
            "resultIdentifier": "bar",
            "stepResultIdentifier": "goo",
            "formatter" : {"maximumDigits" : 3 }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDCompletionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.unitText, "foos")
            XCTAssertEqual(object.resultIdentifier, "bar")
            XCTAssertEqual(object.stepResultIdentifier, "goo")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testResultSummaryStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "feedback",
            "title": "Hello World!",
            "subtitle": "Some text.",
            "unitText": "foos",
            "resultIdentifier": "bar",
            "stepResultIdentifier": "goo",
            "formatter" : {"maximumDigits" : 3 }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDResultSummaryStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.subtitle, "Some text.")
            XCTAssertEqual(object.unitText, "foos")
            XCTAssertEqual(object.resultIdentifier, "bar")
            XCTAssertEqual(object.stepResultIdentifier, "goo")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    
    func testSectionStepObject_Decodable() {
        let json = """
        {
            "identifier": "foobar",
            "type": "section",
            "steps": [
                {
                    "identifier": "step1",
                    "type": "instruction",
                    "title": "Step 1"
                },
                {
                    "identifier": "step2",
                    "type": "instruction",
                    "title": "Step 2"
                },
            ]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<RSDSectionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual(object.identifier, "foobar")
            XCTAssertEqual(object.stepType, "section")
            XCTAssertEqual(object.steps.count, 2, "\(object.steps)")
            
            guard let firstStep = object.steps.first as? RSDUIStep else {
                XCTFail("Encoded object is not expected type")
                return
            }
            
            XCTAssertEqual(firstStep.identifier, "step1")
            XCTAssertEqual(firstStep.title, "Step 1")
            
            guard let lastStep = object.steps.last as? RSDUIStep else {
                XCTFail("Encoded object is not expected type")
                return
            }
            
            XCTAssertEqual(lastStep.identifier, "step2")
            XCTAssertEqual(lastStep.title, "Step 2")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testStepTransform() {
        let json = """
        {
            "identifier": "foobar",
            "type": "transform",
            "resourceTransformer" : { "resourceName": "FactoryTest_StepTransform.json"}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        let resourceInfo = FactoryResourceInfo(factoryBundle: Bundle.module,
                                               packageName: nil)
        let decoder = RSDFactory.shared.createJSONDecoder(resourceInfo: resourceInfo)
        
        do {
            
            let wrapper = try decoder.decode(StepWrapper<SimpleQuestionStepObject>.self, from: json)
            let object = wrapper.step
            
            XCTAssertEqual("foobar", object.identifier)

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    struct StepWrapper<Value : RSDStep> : Decodable {
        let step : Value
        init(from decoder: Decoder) throws {
            let objStep = try decoder.factory.decodePolymorphicObject(RSDStep.self, from: decoder)
            guard let step = objStep as? Value else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode the expected step type. Decoded \(type(of: objStep))")
                throw DecodingError.typeMismatch(Value.self, context)
            }
            self.step = step
        }
    }
}

extension RSDUIStepObject : Encodable {
}
