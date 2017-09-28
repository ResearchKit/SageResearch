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
            XCTFail("Failed to decode/encode task info object: \(err)")
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
            XCTFail("Failed to decode/encode task info object: \(err)")
            return
        }
    }
    
}
