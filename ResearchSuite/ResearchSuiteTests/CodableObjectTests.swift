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
            
            let object = try JSONDecoder().decode(RSDTaskInfoObject.self, from: json)
        
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.copyright, "This is a copyright string.")
            XCTAssertEqual(object.estimatedMinutes, 5)
            XCTAssertEqual(object.icon?.imageName, "foobar")

            let jsonData = try JSONEncoder().encode(object)
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
            
            let object = try JSONDecoder().decode(RSDSchemaInfoObject.self, from: json)
            
            XCTAssertEqual(object.schemaIdentifier, "foo")
            XCTAssertEqual(object.schemaRevision, 5)
            
            let jsonData = try JSONEncoder().encode(object)
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
            
            let object = try JSONDecoder().decode(RSDTaskGroupObject.self, from: json)

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
            
            let jsonData = try JSONEncoder().encode(object)
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
            
            let object = try JSONDecoder().decode(RSDUIStepObject.self, from: json)
            
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
            
            let jsonData = try JSONEncoder().encode(object)
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
            
            let object = try JSONDecoder().decode(RSDActiveUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.duration, 30)
            
            XCTAssertEqual(object.spokenInstruction(at: 0), "Start moving")
            XCTAssertEqual(object.spokenInstruction(at: 10), "Keep going")
            XCTAssertEqual(object.spokenInstruction(at: 15), "Halfway there")
            XCTAssertEqual(object.spokenInstruction(at: 30), "Stop moving")
            XCTAssertEqual(object.spokenInstruction(at: Double.infinity), "Stop moving")

            
            let jsonData = try JSONEncoder().encode(object)
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
    
}
