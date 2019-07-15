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

class CodableStepObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()
        
        // Use a statically defined timezone.
        rsd_ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testUIStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "text": "Some text.",
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
            
            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual((object.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "before")
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
    
    func testUIStepObject_DeviceType_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "text": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "watch" : {
                "text": "Watch: Some text.",
                "detail": "Watch: This is a test.",
                "footnote": "Watch: This is a footnote."
            }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let factory = RSDFactory()
            factory.deviceType = .watch
            let decoder = factory.createJSONDecoder()
            
            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Watch: Some text.")
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
            "text": "Some text.",
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
            "viewTheme"      : { "viewIdentifier": "ActiveInstruction",
                                 "storyboardIdentifier": "ActiveTaskSteps" },
            "beforeCohortRules" : [{ "requiredCohorts" : ["boo", "goo"],
                                    "skipToIdentifier" : "blueGu",
                                    "operator" : "any" }],
            "afterCohortRules" : [{ "requiredCohorts" : ["foo", "baloo"],
                                    "skipToIdentifier" : "foomanchu",
                                    "operator" : "all" }]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
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
                XCTAssertEqual(color.customColor?.color, "sky")
            } else {
                XCTFail("Failed to decode color theme")
            }
            
            XCTAssertEqual(object.viewTheme?.storyboardIdentifier, "ActiveTaskSteps")
            XCTAssertEqual(object.viewTheme?.viewIdentifier, "ActiveInstruction")
            
            if let cohortRule = object.beforeCohortRules?.first {
                XCTAssertEqual(cohortRule.requiredCohorts, ["boo", "goo"])
                XCTAssertEqual(cohortRule.skipToIdentifier, "blueGu")
                XCTAssertEqual(cohortRule.cohortOperator, .any)
            } else {
                XCTFail("Failed to decode before cohort rules")
            }
            
            if let cohortRule = object.afterCohortRules?.first {
                XCTAssertEqual(cohortRule.requiredCohorts, ["foo", "baloo"])
                XCTAssertEqual(cohortRule.skipToIdentifier, "foomanchu")
                XCTAssertEqual(cohortRule.cohortOperator, .all)
            } else {
                XCTFail("Failed to decode before cohort rules")
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
            "text": "Some text.",
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
            
            let object = try decoder.decode(RSDActiveUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
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
            
            let object = try decoder.decode(RSDActiveUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.duration, 0)
            XCTAssertEqual(object.commands, .defaultCommands)
            XCTAssertNil(object.spokenInstructions)
            
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testFormUIStepObject_Codable() {
        
        let json = """
          {
          "identifier": "step3",
          "type": "form",
          "title": "Step 3",
          "text": "Some text.",
          "inputFields": [
                          {
                          "identifier": "foo",
                          "type": "date",
                          "uiHint": "picker",
                          "prompt": "Foo",
                          "range" : { "minimumDate" : "2017-02-20",
                                      "maximumDate" : "2017-03-20",
                                      "codingFormat" : "yyyy-MM-dd" }
                          },
                          {
                          "identifier": "bar",
                          "type": "integer",
                          "prompt": "Bar"
                          },
                          {
                           "identifier": "goo",
                           "type": "multipleChoice",
                           "choices" : ["never", "sometimes", "often", "always"]
                          },
                          {
                            "identifier": "detail",
                            "type": "detail",
                            "inputFields": [{
                                "identifier": "fieldA",
                                "type": "string"
                            },
                            {
                                "identifier": "fieldB",
                                "type": "integer"
                            }]
                          }
                    ]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "step3")
            XCTAssertEqual(object.title, "Step 3")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.inputFields.count, 4)
            
            if object.inputFields.count == 4 {
                XCTAssertEqual(object.inputFields[0].dataType, .base(.date))
                XCTAssertEqual(object.inputFields[1].dataType, .base(.integer))
                XCTAssertEqual(object.inputFields[2].dataType, .collection(.multipleChoice, .string))
                XCTAssertNotNil(object.inputFields[2] as? RSDCodableChoiceInputFieldObject<String>)
            }
            
            if let detail = object.inputFields.last as? RSDDetailInputFieldObject {
                XCTAssertEqual(detail.dataType, .detail(.codable))
            }
            else {
                XCTFail("Failed to decode the detail input field type.")
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testFormUIStepObject_Codable_SingleQuestion() {
        
        let json = """
          {
          "identifier": "step3",
          "type": "form",
          "title": "Step 3",
          "inputFields": [{
            "type": "multipleChoice",
            "choices" : ["never", "sometimes", "often", "always"]
            }]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "step3")
            XCTAssertEqual(object.title, "Step 3")
            XCTAssertEqual(object.inputFields.count, 1)
            XCTAssertEqual(object.inputFields.first?.dataType, .collection(.multipleChoice, .string))
            XCTAssertNotNil(object.inputFields.first as? RSDCodableChoiceInputFieldObject<String>)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testOverviewStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "text": "Some text.",
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
            
            let object = try decoder.decode(RSDOverviewStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual((object.imageTheme as? RSDFetchableImageThemeElementObject)?.imageName, "before")
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
    
    func testResultSummaryStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "completion",
            "title": "Hello World!",
            "text": "Some text.",
            "unitText": "foos",
            "resultIdentifier": "bar",
            "stepResultIdentifier": "goo",
            "formatter" : {"maximumDigits" : 3 }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDResultSummaryStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
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
            
            let object = try decoder.decode(RSDSectionStepObject.self, from: json)
            
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
    
    func testGenericStepObject_Decodable() {
        
        let json = """
        {
            "identifier": "foobar",
            "type": "foo",
            "title": "Hello World!",
            "detail": "This is a test.",
            "copyright": "This is a copyright string.",
            "estimatedMinutes": 5,
            "icon": "foobar"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDGenericStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foobar")
            
            XCTAssertEqual(object.identifier, "foobar")
            XCTAssertEqual(object.userInfo["title"] as? String, "Hello World!")
            XCTAssertEqual(object.userInfo["detail"] as? String, "This is a test.")
            XCTAssertEqual(object.userInfo["copyright"] as? String, "This is a copyright string.")
            XCTAssertEqual(object.userInfo["estimatedMinutes"] as? Int, 5)
            XCTAssertEqual(object.userInfo["icon"] as? String, "foobar")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
