//
//  CodableStepObjectTests.swift
//  ResearchSuiteTests
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
import ResearchSuite

class CodableStepObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()
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
            "imageBefore": "before",
            "imageAfter": "after",
            "nextStepIdentifier": "boo",
            "actions": { "goForward": { "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "iconName" : "closeX" }
                        },
            "shouldHideActions": ["goBackward", "learnMore", "skip"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.footnote, "This is a footnote.")
            XCTAssertEqual(object.imageBefore?.imageName, "before")
            XCTAssertEqual(object.imageAfter?.imageName, "after")
            XCTAssertEqual(object.nextStepIdentifier, "boo")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward), on: object) ?? false)
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.learnMore), on: object) ?? false)
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.skip), on: object) ?? false)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["title"] as? String, "Hello World!")
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["detail"] as? String, "This is a test.")
            XCTAssertEqual(dictionary["imageBefore"] as? String, "before")
            XCTAssertEqual(dictionary["imageAfter"] as? String, "after")
            XCTAssertEqual(dictionary["nextStepIdentifier"] as? String, "boo")
            
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
            "spokenInstructions" : { "0": "Start moving",
                                     "10": "Keep going",
                                     "halfway": "Halfway there",
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
            XCTAssertEqual(object.spokenInstruction(at: 30), "Stop moving")
            XCTAssertEqual(object.spokenInstruction(at: Double.infinity), "Stop moving")
            
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["title"] as? String, "Hello World!")
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["duration"] as? Double, 30)
            XCTAssertEqual((dictionary["spokenInstructions"] as? [String: String])?.count ?? 0, 4)
            if let commands = dictionary["commands"] as? [String] {
                XCTAssertEqual(commands, ["playSoundOnStart", "vibrateOnFinish"])
            }
            else {
                XCTFail("Failed to encode the default commands")
            }
            
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
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["duration"] as? Double, 0)
            
            
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
                          "dataType": "date",
                          "uiHint": "picker",
                          "prompt": "Foo",
                          "range" : { "minimumDate" : "2017-02-20",
                                      "maximumDate" : "2017-03-20",
                                      "codingFormat" : "yyyy-MM-dd" }
                          },
                          {
                          "identifier": "bar",
                          "dataType": "integer",
                          "prompt": "Bar"
                          },
                          {
                           "identifier": "goo",
                           "dataType": "multipleChoice",
                           "choices" : ["never", "sometimes", "often", "always"]
                          }]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "step3")
            XCTAssertEqual(object.title, "Step 3")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.inputFields.count, 3)
            
            if object.inputFields.count == 3 {
                XCTAssertEqual(object.inputFields[0].dataType, .base(.date))
                XCTAssertEqual(object.inputFields[1].dataType, .base(.integer))
                XCTAssertEqual(object.inputFields[2].dataType, .collection(.multipleChoice, .string))
                XCTAssertNotNil(object.inputFields[2] as? RSDChoiceInputFieldObject)
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "step3")
            XCTAssertEqual(dictionary["title"] as? String, "Step 3")
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual((dictionary["inputFields"] as? [[String : Any]])?.count ?? 0, 3)
            
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
          "dataType": "multipleChoice",
          "choices" : ["never", "sometimes", "often", "always"]
          }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDFormUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "step3")
            XCTAssertEqual(object.title, "Step 3")
            XCTAssertEqual(object.inputFields.count, 1)
            XCTAssertEqual(object.inputFields.first?.dataType, .collection(.multipleChoice, .string))
            XCTAssertNotNil(object.inputFields.first as? RSDChoiceInputFieldObject)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTaskStepObject_Decodable() {
        
        let json = """
        {
            "identifier": "foobar",
            "type": "subtask",
            "title": "Hello World!",
            "detail": "This is a test.",
            "copyright": "This is a copyright string.",
            "estimatedMinutes": 5,
            "icon": "foobar"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDTaskStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foobar")
            
            guard let task = object.subtaskInfo as? RSDTaskInfoObject else {
                XCTFail("Encoded object is not expected type")
                return
            }
            
            XCTAssertEqual(task.identifier, "foobar")
            XCTAssertEqual(task.title, "Hello World!")
            XCTAssertEqual(task.detail, "This is a test.")
            XCTAssertEqual(task.copyright, "This is a copyright string.")
            XCTAssertEqual(task.estimatedMinutes, 5)
            XCTAssertEqual(task.icon?.imageName, "foobar")
            
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
            XCTAssertEqual(object.type, "section")
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
            XCTAssertEqual(object.userInfo?["title"] as? String, "Hello World!")
            XCTAssertEqual(object.userInfo?["detail"] as? String, "This is a test.")
            XCTAssertEqual(object.userInfo?["copyright"] as? String, "This is a copyright string.")
            XCTAssertEqual(object.userInfo?["estimatedMinutes"] as? Int, 5)
            XCTAssertEqual(object.userInfo?["icon"] as? String, "foobar")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
}
