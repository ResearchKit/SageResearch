//
//  CodableResultObjectTests.swift
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

class CodableResultObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResultObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "base",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, .base)
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "base")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testFileResultObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "file",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "relativePath": "temp.json",
            "contentType": "application/json"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            var object = try decoder.decode(RSDFileResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "file")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertEqual(object.relativePath, "temp.json")
            XCTAssertEqual(object.contentType, "application/json")
            
            // set the url
            let tempDir = NSTemporaryDirectory()
            let path = (tempDir as NSString).appendingPathComponent(UUID().uuidString)
            let baseURL = URL(fileURLWithPath: path, isDirectory: true)
            object.url = URL(fileURLWithPath: "foo.json", relativeTo: baseURL)
            let expectedPath = (path as NSString).appendingPathComponent("foo.json")
            XCTAssertEqual(object.url?.path, expectedPath)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "file")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["relativePath"] as? String, "foo.json")
            XCTAssertEqual(dictionary["contentType"] as? String, "application/json")
            XCTAssertNil(dictionary["url"])
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_String_NilValue_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "string"}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeString, "\(String(describing: object.jsonAnswerType))")
            XCTAssertNil(object.jsonValue)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_String_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "string"},
            "value": "hello"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeString, "\(String(describing: object.jsonAnswerType))")
            XCTAssertEqual(object.jsonValue, .string("hello"))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "hello")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "string")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Bool_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "boolean"},
            "value": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeBoolean, "\(String(describing: object.jsonAnswerType))")
            XCTAssertEqual(object.jsonValue, .boolean(true))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Bool, true)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "boolean")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Int_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "integer"},
            "value": 12
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeInteger, "\(String(describing: object.jsonAnswerType))")
            XCTAssertEqual(object.jsonValue, .integer(12))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Int, 12)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "integer")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Double_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "number"},
            "value": 12.5
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeNumber, "\(String(describing: object.jsonAnswerType))")
            XCTAssertEqual(object.jsonValue, .number(12.5))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Double, 12.5)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "number")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Date_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "date-time", "codingFormat" : "yyyy-MM-dd"},
            "value": "2016-02-20",
            "skipToIdentifier": "baloo"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertEqual(object.skipToIdentifier, "baloo")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            if let answerType = object.jsonAnswerType as? AnswerTypeDateTime {
                XCTAssertEqual(answerType.codingFormat, "yyyy-MM-dd")
            }
            else {
                XCTFail("Failed to decode answerType as a AnswerTypeDateTime")
            }
            XCTAssertEqual(object.jsonValue, .string("2016-02-20"))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "2016-02-20")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "date-time")
                XCTAssertEqual(answerType["codingFormat"] as? String, "yyyy-MM-dd")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_StringArray_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "integer", "type" : "array"},
            "value": [1, 3, 5]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            if let answerType = object.jsonAnswerType as? AnswerTypeArray {
                XCTAssertEqual(answerType.baseType, .integer)
            }
            else {
                XCTFail("Failed to decode \(String(describing: object.jsonAnswerType)) as a AnswerTypeArray")
            }
            XCTAssertEqual(object.jsonValue, .array([1, 3, 5]))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [Int] {
                XCTAssertEqual(values, [1, 3, 5])
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "array")
                XCTAssertEqual(answerType["baseType"] as? String, "integer")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }

    func testAnswerResultObject_IntegerArray_StringSeparator_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "integer", "type" : "array", "sequenceSeparator" : "-"},
            "value": "206-555-1212"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            if let answerType = object.jsonAnswerType as? AnswerTypeArray {
                XCTAssertEqual(answerType.baseType, .integer)
                XCTAssertEqual(answerType.sequenceSeparator, "-")
            }
            else {
                XCTFail("Failed to decode answerType as a AnswerTypeDateTime")
            }
            XCTAssertEqual(object.jsonValue, .array([206, 555, 1212]))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "206-555-1212")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "integer")
                XCTAssertEqual(answerType["type"] as? String, "array")
                XCTAssertEqual(answerType["sequenceSeparator"] as? String, "-")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }

    func testAnswerResultObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "answer",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"type" : "object"},
            "value": { "breakfast": "08:20", "lunch": "12:40", "dinner": "19:10" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(AnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "answer")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            XCTAssertTrue(object.jsonAnswerType is AnswerTypeObject, "\(String(describing: object.jsonAnswerType))")
            XCTAssertEqual(object.jsonValue, .object(["breakfast": "08:20", "lunch": "12:40", "dinner": "19:10"]))
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "answer")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [String : String] {
                XCTAssertEqual(values["breakfast"], "08:20")
                XCTAssertEqual(values["lunch"], "12:40")
                XCTAssertEqual(values["dinner"], "19:10")
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["type"] as? String, "object")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testStepCollectionResultObject_Codable() {
        var stepResult = RSDCollectionResultObject(identifier: "foo")
        let answerResult1 = AnswerResultObject(identifier: "input1", value: .boolean(true))
        let answerResult2 = AnswerResultObject(identifier: "input2", value: .integer(42))
        stepResult.inputResults = [answerResult1, answerResult2]
        
        do {
            let jsonData = try encoder.encode(stepResult)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertNotNil(dictionary["startDate"])
            XCTAssertNotNil(dictionary["endDate"])
            if let results = dictionary["inputResults"] as? [[String : Any]] {
                XCTAssertEqual(results.count, 2)
                if let result1 = results.first {
                    XCTAssertEqual(result1["identifier"] as? String, "input1")
                }
            } else {
                XCTFail("Failed to encode the input results.")
            }
            
            let object = try decoder.decode(RSDCollectionResultObject.self, from: jsonData)
            
            XCTAssertEqual(object.identifier, stepResult.identifier)
            XCTAssertEqual(object.startDate.timeIntervalSinceNow, stepResult.startDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.endDate.timeIntervalSinceNow, stepResult.endDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.inputResults.count, 2)
            
            if let result1 = object.inputResults.first as? AnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                let expected = AnswerTypeBoolean()
                XCTAssertEqual(expected, answerResult1.jsonAnswerType as? AnswerTypeBoolean)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.jsonValue, answerResult1.jsonValue)
            } else {
                XCTFail("\(object.inputResults) did not decode the results as expected")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testTaskResultObject_Codable() {
        var taskResult = RSDTaskResultObject(identifier: "foo")
        let answerResult1 = AnswerResultObject(identifier: "step1", value: .boolean(true))
        let answerResult2 = AnswerResultObject(identifier: "step2", value: .integer(42))
        taskResult.stepHistory = [answerResult1, answerResult2]
        
        taskResult.schemaInfo = RSDSchemaInfoObject(identifier: "bar", revision: 3)
        
        do {
            let jsonData = try encoder.encode(taskResult)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertNotNil(dictionary["startDate"])
            XCTAssertNotNil(dictionary["endDate"])

            if let results = dictionary["stepHistory"] as? [[String : Any]] {
                XCTAssertEqual(results.count, 2)
                if let result1 = results.first {
                    XCTAssertEqual(result1["identifier"] as? String, "step1")
                }
            }
            else {
                XCTFail("Failed to encode the step history.")
            }
            
            if let schemaInfo = dictionary["schemaInfo"] as? [String : Any] {
                XCTAssertEqual(schemaInfo["identifier"] as? String, "bar")
                XCTAssertEqual(schemaInfo["revision"] as? Int, 3)
            }
            else {
                XCTFail("Failed to encode the schemaInfo.")
            }
            
            let object = try decoder.decode(RSDTaskResultObject.self, from: jsonData)
            
            XCTAssertEqual(object.identifier, taskResult.identifier)
            XCTAssertEqual(object.startDate.timeIntervalSinceNow, taskResult.startDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.endDate.timeIntervalSinceNow, taskResult.endDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.stepHistory.count, 2)
            
            if let result1 = object.stepHistory.first as? AnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                let expected = AnswerTypeBoolean()
                XCTAssertEqual(expected, answerResult1.jsonAnswerType as? AnswerTypeBoolean)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.jsonValue, answerResult1.jsonValue)
            } else {
                XCTFail("\(object.stepHistory) did not decode the results as expected")
            }
            
            if let schemaInfo = object.schemaInfo {
                XCTAssertEqual(schemaInfo.schemaIdentifier, "bar")
                XCTAssertEqual(schemaInfo.schemaVersion, 3)
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
}
