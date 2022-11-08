//
//  CodableTaskObjectTests.swift
//  ResearchTests
//

import XCTest
@testable import Research
import JsonModel

class CodableTaskObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
            XCTAssertEqual(object.schemaVersion, 5)
            
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

    
    @available(*,deprecated, message: "Will be deleted in a future version.")
    func testTaskInfoObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "title": "Hello World!",
            "detail": "This is a test.",
            "estimatedMinutes": 5,
            "icon": "foobar"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDTaskInfoObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.title, "Hello World!")
            XCTAssertEqual(object.detail, "This is a test.")
            XCTAssertEqual(object.estimatedMinutes, 5)
            XCTAssertEqual(object.imageData?.imageIdentifier, "foobar")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }

    
    @available(*,deprecated, message: "Will be deleted in a future version.")
    func testTaskGroupObject_Decodable() {
        
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
            XCTAssertEqual(object.imageData?.imageIdentifier, "foobarGroup")
            XCTAssertEqual(object.tasks.count, 2, "\(object.tasks)")
            
            guard let firstTask = object.tasks.first as? RSDTaskInfoObject else {
                XCTFail("Encoded object is not expected type")
                return
            }
            
            XCTAssertEqual(firstTask.identifier, "foo")
            XCTAssertEqual(firstTask.title, "Hello World!")
            XCTAssertEqual(firstTask.detail, "This is a test.")
            XCTAssertEqual(firstTask.estimatedMinutes, 5)
            XCTAssertEqual(firstTask.imageData?.imageIdentifier, "foobar")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
