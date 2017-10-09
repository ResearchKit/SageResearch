//
//  CodableObjectTests.swift
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

// MARK: Example codeable subclasses

class BaseClass : RSDCodableObject {
    @objc dynamic var identifier : String = UUID().uuidString
    
    init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
    
    required init(dictionaryRepresentation dictionary: [AnyHashable : Any]) {
        super.init(dictionaryRepresentation: dictionary)
    }
    
    override var dictionaryRepresentationKeys: [RSDKeyMap] {
        return [RSDKeyMap(rawValue: #keyPath(identifier))!]
    }
}

class ClassA : BaseClass {
}

class ClassB : BaseClass {
}

class ClassC : BaseClass {
    @objc dynamic var count: Int = 0
    
    override var dictionaryRepresentationKeys: [RSDKeyMap] {
        var superKeys = super.dictionaryRepresentationKeys
        superKeys.append(RSDKeyMap(rawValue: #keyPath(count))!)
        return superKeys
    }
}

struct TestImageWrapperDelegate : RSDImageWrapperDelegate {
    func fetchImage(for size: CGSize, with imageName: String, callback: @escaping ((UIImage?) -> Void)) {
        DispatchQueue.main.async {
            callback(nil)
        }
    }
}


// MARK: Tests

class CodableObjectTests: XCTestCase {
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    override func setUp() {
        super.setUp()
        
        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassEquality() {
        let objACat1 = ClassA(identifier: "cat")
        let objACat2 = ClassA(identifier: "cat")
        let objADog = ClassA(identifier: "dog")
        let objBCat = ClassB(identifier: "cat")
        
        XCTAssertEqual(objACat1, objACat2)
        XCTAssertNotEqual(objACat1, objADog)
        XCTAssertNotEqual(objACat1, objBCat)
    }
    
    func testOverrideEquality() {
        let objCat1 = ClassC(identifier: "cat")
        objCat1.count = 1
        
        let objCat2 = ClassC(identifier: "cat")
        objCat2.count = 2
        
        let objCat2_2 = ClassC(identifier: "cat")
        objCat2_2.count = 2
        
        let objDog1 = ClassC(identifier: "dog")
        objDog1.count = 1
        
        XCTAssertEqual(objCat2, objCat2_2)
        XCTAssertNotEqual(objCat1, objCat2)
        XCTAssertNotEqual(objCat1, objDog1)
    }
    
    func testDictionaryRepresentation() {
        let objCat2 = ClassC(identifier: "cat")
        objCat2.count = 2
        
        let dictionary = objCat2.dictionaryRepresentation() as NSDictionary
        let expected: NSDictionary = ["identifier" : "cat", "count" :2]
        XCTAssertEqual(dictionary, expected)
        
        guard let copy = objCat2.copy() as? ClassC else {
            XCTFail("Failed to copy class instance")
            return
        }
        
        XCTAssertEqual(objCat2.identifier, copy.identifier)
        XCTAssertEqual(objCat2.count, copy.count)
    }
    
    // MARK : Model objects
    
    func testTaskInfoObject_Codable() {
        
        var taskInfo = RSDTaskInfoObject(with: "bar")
        taskInfo.title = "yo"
        
        let json = """
        {
            "identifier": "foo",
            "title": "Hello World!",
            "detail": "This is a test.",
            "copyright": "This is a copyright string.",
            "estimatedMinutes": 5,
            "icon": "foobar"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDTaskInfoObject.self, from: json)
        
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.copyright, "This is a copyright string.")
            XCTAssertEqual(object.estimatedMinutes, 5)
            XCTAssertEqual(object.icon?.imageName, "foobar")

            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["title"] as? String, "Hello World!")
            XCTAssertEqual(dictionary["detail"] as? String, "This is a test.")
            XCTAssertEqual(dictionary["copyright"] as? String, "This is a copyright string.")
            XCTAssertEqual(dictionary["estimatedMinutes"] as? Int, 5)
            XCTAssertEqual(dictionary["icon"] as? String, "foobar")
        
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testSchemaInfoObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "revision": 5,
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDSchemaInfoObject.self, from: json)
            
            XCTAssertEqual(object.schemaIdentifier, "foo")
            XCTAssertEqual(object.schemaRevision, 5)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["revision"] as? Int, 5)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTaskGroupObject_Codable() {
        
        let json = """
        {
            "identifier": "foobar.group",
            "title": "Foo and Bar",
            "detail": "This is a test of the task group.",
            "icon": "foobarGroup",
            "tasks": [
                {
                    "identifier": "foo",
                    "title": "Hello World!",
                    "detail": "This is a test.",
                    "copyright": "This is a copyright string.",
                    "estimatedMinutes": 5,
                    "icon": "foobar"
                },
                {
                    "identifier": "bar",
                    "title": "Barbaloot",
                    "estimatedMinutes": 3,
                    "icon": "suit"
                }
            ]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDTaskGroupObject.self, from: json)

            XCTAssertEqual(object.identifier, "foobar.group")
            XCTAssertEqual(object.title, "Foo and Bar")
            XCTAssertEqual(object.detail, "This is a test of the task group.")
            XCTAssertEqual(object.icon?.imageName, "foobarGroup")
            XCTAssertEqual(object.tasks.count, 2, "\(object.tasks)")
            
            guard let firstTask = object.tasks.first as? RSDTaskInfoObject else {
                XCTFail("Encoded object is not expected type")
                return
            }
            
            XCTAssertEqual(firstTask.identifier, "foo")
            XCTAssertEqual(firstTask.title, "Hello World!")
            XCTAssertEqual(firstTask.detail, "This is a test.")
            XCTAssertEqual(firstTask.copyright, "This is a copyright string.")
            XCTAssertEqual(firstTask.estimatedMinutes, 5)
            XCTAssertEqual(firstTask.icon?.imageName, "foobar")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foobar.group")
            XCTAssertEqual(dictionary["title"] as? String, "Foo and Bar")
            XCTAssertEqual(dictionary["detail"] as? String, "This is a test of the task group.")
            XCTAssertEqual(dictionary["icon"] as? String, "foobarGroup")
            XCTAssertEqual((dictionary["tasks"] as? [[String:Any]])?.count ?? 0, 2)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testUIStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "title": "Hello World!",
            "text": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "imageBefore": "before",
            "imageAfter": "after",
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
            
            let goForwardAction = object.action(for: .navigation(.goForward))
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel))
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.goBackward)))
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.learnMore)))
            XCTAssertTrue(object.shouldHideAction(for: .navigation(.skip)))
            
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
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testActiveUIStepObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "title": "Hello World!",
            "text": "Some text.",
            "duration": 30,
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
    
    func testRSDChoiceObject_Codable_Dictionary_StringValue() {
        
        let json = """
        {
            "value": "foo",
            "text": "Some text.",
            "detail": "A detail about the object",
            "icon": "fooImage",
            "isExclusive": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDChoiceObject<String>.self, from: json)
            
            XCTAssertEqual(object.value as? String, "foo")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "A detail about the object")
            XCTAssertEqual(object.icon?.imageName, "fooImage")
            XCTAssertTrue(object.isExclusive)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? String, "foo")
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["detail"] as? String, "A detail about the object")
            XCTAssertEqual(dictionary["icon"] as? String, "fooImage")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testRSDChoiceObject_Codable_Dictionary_IntValue() {
        
        let json = """
        {
            "value": 3,
            "text": "Some text.",
            "detail": "A detail about the object",
            "icon": "fooImage",
            "isExclusive": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDChoiceObject<Int>.self, from: json)
            
            XCTAssertEqual(object.value as? Int, 3)
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "A detail about the object")
            XCTAssertEqual(object.icon?.imageName, "fooImage")
            XCTAssertTrue(object.isExclusive)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? Int, 3)
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["detail"] as? String, "A detail about the object")
            XCTAssertEqual(dictionary["icon"] as? String, "fooImage")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testRSDChoiceObject_Codable_Dictionary_TextValue() {
        
        let json = """
        ["alpha", "beta"]
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let objects = try decoder.decode([RSDChoiceObject<String>].self, from: json)
            
            XCTAssertEqual(objects.count, 2)
            XCTAssertEqual(objects.first?.value as? String, "alpha")
            XCTAssertEqual(objects.last?.value as? String, "beta")
            
            guard let object = objects.first else {
                return
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? String, "alpha")
            XCTAssertEqual(dictionary["text"] as? String, "alpha")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testChoiceInputFieldObject_Codable_String() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "multipleChoice",
            "choices" : ["never", "sometimes", "often", "always"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDChoiceInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .collection(.multipleChoice, .string))
            XCTAssertFalse(object.optional)
            XCTAssertFalse(object.allowOther)
            XCTAssertEqual(object.choices.count, 4)
            XCTAssertEqual(object.choices.last?.text, "always")
            XCTAssertEqual(object.choices.last?.value as? String, "always")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "multipleChoice.string")
            XCTAssertEqual(dictionary["optional"] as? Bool, false)
            XCTAssertEqual(dictionary["allowOther"] as? Bool, false)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 4)

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testChoiceInputFieldObject_Codable_Int() {
        
        let json = """
        {
            "identifier": "foo",
            "prompt": "Text",
            "placeholderText": "enter text",
            "dataType": "singleChoice.integer",
            "uiHint": "picker",
            "optional": true,
            "allowOther": true,
            "choices" : [{  "value" : 0,
                            "text" : "never"},
                         {  "value" : 1,
                            "text" : "sometimes"},
                         {  "value" : 2,
                            "text" : "often"},
                         {  "value" : 3,
                            "text" : "always"}]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDChoiceInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.prompt, "Text")
            XCTAssertEqual(object.placeholderText, "enter text")
            XCTAssertEqual(object.dataType, .collection(.singleChoice, .integer))
            XCTAssertEqual(object.uiHint, .standard(.picker))
            XCTAssertTrue(object.optional)
            XCTAssertTrue(object.allowOther)
            XCTAssertEqual(object.choices.count, 4)
            XCTAssertEqual(object.choices.last?.text, "always")
            XCTAssertEqual(object.choices.last?.value as? Int, 3)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["prompt"] as? String, "Text")
            XCTAssertEqual(dictionary["placeholderText"] as? String, "enter text")
            XCTAssertEqual(dictionary["dataType"] as? String, "singleChoice.integer")
            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
            XCTAssertEqual(dictionary["optional"] as? Bool, true)
            XCTAssertEqual(dictionary["allowOther"] as? Bool, true)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 4)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMultipleComponentInputFieldObject_Codable_String() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "multipleComponent",
            "choices" : [["blue", "red", "green", "yellow"], ["dog", "cat", "rat"]]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMultipleComponentInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .collection(.multipleComponent, .string))
            XCTAssertFalse(object.optional)
            XCTAssertEqual(object.choices.count, 2)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "multipleComponent.string")
            XCTAssertEqual(dictionary["optional"] as? Bool, false)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 2)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Integer() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "integer",
            "uiHint": "slider",
            "range" : { "minimumValue" : -2,
                        "maximumValue" : 3,
                        "stepInterval" : 1,
                        "unit" : "feet" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.integer))
            XCTAssertEqual(object.uiHint, .standard(.slider))
            if let range = object.range as? RSDIntegerRange {
                XCTAssertEqual(range.minimumValue, -2)
                XCTAssertEqual(range.maximumValue, 3)
                XCTAssertEqual(range.stepInterval, 1)
                XCTAssertEqual(range.unit, "feet")
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "integer")
            XCTAssertEqual(dictionary["uiHint"] as? String, "slider")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumValue"] as? Int, -2)
                XCTAssertEqual(range["maximumValue"] as? Int, 3)
                XCTAssertEqual(range["stepInterval"] as? Int, 1)
                XCTAssertEqual(range["unit"] as? String, "feet")
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Decimal() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "decimal",
            "uiHint": "slider",
            "range" : { "minimumValue" : -2.5,
                        "maximumValue" : 3,
                        "stepInterval" : 0.1,
                        "unit" : "feet",
                        "maximumDigits" : 3 }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.decimal))
            XCTAssertEqual(object.uiHint, .standard(.slider))
            if let range = object.range as? RSDDecimalRangeObject {
                XCTAssertEqual(range.minimumValue, -2.5)
                XCTAssertEqual(range.maximumValue, 3)
                XCTAssertEqual(range.stepInterval, 0.1)
                XCTAssertEqual(range.unit, "feet")
                XCTAssertEqual((range.formatter as? NumberFormatter)?.maximumFractionDigits ?? 0, 3)
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "decimal")
            XCTAssertEqual(dictionary["uiHint"] as? String, "slider")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumValue"] as? Double, -2.5)
                XCTAssertEqual(range["maximumValue"] as? Double, 3)
                XCTAssertEqual(range["stepInterval"] as? Double, 0.1)
                XCTAssertEqual(range["unit"] as? String, "feet")
                XCTAssertEqual(range["maximumDigits"] as? Int, 3)
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Date() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "date",
            "uiHint": "picker",
            "range" : { "minimumDate" : "2017-02-20",
                        "maximumDate" : "2017-03-20",
                        "codingFormat" : "yyyy-MM-dd" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.date))
            XCTAssertEqual(object.uiHint, .standard(.picker))
            if let range = object.range as? RSDDateRange {
                
                let calendar = Calendar(identifier: .gregorian)
                let calendarComponents = range.calendarComponents
                XCTAssertEqual(calendarComponents, [.year, .month, .day])
                
                XCTAssertNotNil(range.minimumDate)
                if let date = range.minimumDate {
                    let min = calendar.dateComponents(calendarComponents, from: date)
                    XCTAssertEqual(min.year, 2017)
                    XCTAssertEqual(min.month, 2)
                    XCTAssertEqual(min.day, 20)
                }
                
                XCTAssertNotNil(range.maximumDate)
                if let date = range.maximumDate {
                    let max = calendar.dateComponents(calendarComponents, from: date)
                    XCTAssertEqual(max.year, 2017)
                    XCTAssertEqual(max.month, 3)
                    XCTAssertEqual(max.day, 20)
                }
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "date")
            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumDate"] as? String, "2017-02-20")
                XCTAssertEqual(range["maximumDate"] as? String, "2017-03-20")
                XCTAssertEqual(range["codingFormat"] as? String, "yyyy-MM-dd")
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_String() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "string",
            "uiHint": "textfield",
            "textFieldOptions" : {
                        "validationRegex" : "[A:C]",
                        "invalidMessage" : "You know me",
                        "maximumLength" : 10,
                        "autocapitalizationType" : "words",
                        "keyboardType" : "asciiCapable",
                        "isSecureTextEntry" : true }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.string))
            XCTAssertEqual(object.uiHint, .standard(.textfield))
            if let textFieldOptions = object.textFieldOptions  {
                XCTAssertEqual(textFieldOptions.validationRegex, "[A:C]")
                XCTAssertEqual(textFieldOptions.invalidMessage, "You know me")
                XCTAssertEqual(textFieldOptions.maximumLength, 10)
                XCTAssertEqual(textFieldOptions.autocapitalizationType, .words)
                XCTAssertEqual(textFieldOptions.keyboardType, .asciiCapable)
                XCTAssertTrue(textFieldOptions.isSecureTextEntry)
            }
            else{
                XCTFail("Failed to decode textFieldOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["dataType"] as? String, "string")
            XCTAssertEqual(dictionary["uiHint"] as? String, "textfield")
            
            if let textFieldOptions = dictionary["textFieldOptions"] as? [String: Any] {
                XCTAssertEqual(textFieldOptions["validationRegex"] as? String, "[A:C]")
                XCTAssertEqual(textFieldOptions["invalidMessage"] as? String, "You know me")
                XCTAssertEqual(textFieldOptions["maximumLength"] as? Int, 10)
                XCTAssertEqual(textFieldOptions["autocapitalizationType"] as? String, "words")
                XCTAssertEqual(textFieldOptions["keyboardType"] as? String, "asciiCapable")
            }
            else {
                XCTFail("Failed to encode textFieldOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_String_DefaultOptions() {
        
        let json = """
        {
            "identifier": "foo",
            "dataType": "string",
            "uiHint": "textfield",
            "textFieldOptions" : {}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.string))
            XCTAssertEqual(object.uiHint, .standard(.textfield))
            if let textFieldOptions = object.textFieldOptions  {
                XCTAssertNil(textFieldOptions.validationRegex)
                XCTAssertNil(textFieldOptions.invalidMessage)
                XCTAssertEqual(textFieldOptions.maximumLength, 0)
                XCTAssertEqual(textFieldOptions.autocapitalizationType, .none)
                XCTAssertEqual(textFieldOptions.keyboardType, .default)
                XCTAssertFalse(textFieldOptions.isSecureTextEntry)
            }
            else{
                XCTFail("Failed to decode textFieldOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode object: \(err)")
            return
        }
    }
}
