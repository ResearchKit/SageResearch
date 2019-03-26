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

class CodableResultObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        rsd_ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResultObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "string"}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .string)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNil(object.value)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "string"},
            "value": "hello"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .string)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertEqual(object.value as? String, "hello")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "hello")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "string")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Data_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "data"},
            "value": "abcd"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType.data
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            // check assumptions
            let expectedData = Data(base64Encoded: "abcd")
            XCTAssertEqual(expectedData?.base64EncodedString().lowercased(), "abcd")
            XCTAssertEqual(object.value as? Data, expectedData)
            
            let jsonData = try encoder.encode(object)
            
            let jsonString = String(data: jsonData, encoding: .utf8)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertNotNil(dictionary["value"])
            XCTAssertEqual(dictionary["value"] as? String, "abcd")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "data")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testEncodedData() {
    
        let expectedData = Data(base64Encoded: "abcd")
        let json = ["value": expectedData]
        do {
            let jsonData = try encoder.encode(json)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not an dictionary")
                    return
            }
            
            let value = dictionary["value"]
            XCTAssertNotNil(value)
            XCTAssertEqual(value as? String, "abcd")
        }
        catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_Bool_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "boolean"},
            "value": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .boolean)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertEqual(object.value as? Bool, true)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Bool, true)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "boolean")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "integer"},
            "value": 12
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .integer)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertEqual(object.value as? Int, 12)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Int, 12)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "integer")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "decimal"},
            "value": 12.5
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .decimal)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertEqual(object.value as? Double, 12.5)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? Double, 12.5)
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "decimal")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "date", "dateFormat" : "yyyy-MM-dd"},
            "value": "2016-02-20"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "yyyy-MM-dd")
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let date = object.value as? Date {
                let calendar = Calendar(identifier: .iso8601)
                let calendarComponents: Set<Calendar.Component> = [.year, .month, .day]
                let comp = calendar.dateComponents(calendarComponents, from: date)
                XCTAssertEqual(comp.year, 2016)
                XCTAssertEqual(comp.month, 2)
                XCTAssertEqual(comp.day, 20)
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "2016-02-20")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "date")
                XCTAssertEqual(answerType["dateFormat"] as? String, "yyyy-MM-dd")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "string", "sequenceType" : "array"},
            "value": ["alpha", "beta", "gamma"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .string, sequenceType: .array)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [String] {
                XCTAssertEqual(array, ["alpha", "beta", "gamma"])
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [String] {
                XCTAssertEqual(values, ["alpha", "beta", "gamma"])
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "string")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_IntegerArray_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "integer", "sequenceType" : "array"},
            "value": [65, 47, 99]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .integer, sequenceType: .array)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [Int] {
                XCTAssertEqual(array.count, 3)
                XCTAssertEqual(array.first, 65)
                XCTAssertEqual(array.last, 99)
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [Int] {
                XCTAssertEqual(values, [65, 47, 99])
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "integer")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_DoubleArray_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "decimal", "sequenceType" : "array"},
            "value": [65.3, 47.2, 99.8]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .decimal, sequenceType: .array)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [Double] {
                XCTAssertEqual(array.count, 3)
                XCTAssertEqual(array.first, 65.3)
                XCTAssertEqual(array.last, 99.8)
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [Double] {
                XCTAssertEqual(values, [65.3, 47.2, 99.8])
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "decimal")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_DateArray_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "date", "sequenceType" : "array", "dateFormat" : "MM/yyyy"},
            "value": ["07/2013", "05/2017", "01/1999"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .date, sequenceType: .array, formDataType: nil, dateFormat: "MM/yyyy")
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [Date] {
                XCTAssertEqual(array.count, 3)
                
                let calendar = Calendar(identifier: .iso8601)
                let calendarComponents: Set<Calendar.Component> = [.year, .month]
                let comp = calendar.dateComponents(calendarComponents, from: array[0])
                XCTAssertEqual(comp.year, 2013)
                XCTAssertEqual(comp.month, 7)
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [String] {
                XCTAssertEqual(values, ["07/2013", "05/2017", "01/1999"])
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "date")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
                XCTAssertEqual(answerType["dateFormat"] as? String, "MM/yyyy")
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
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "integer", "sequenceType" : "array", "sequenceSeparator" : "-"},
            "value": "206-555-1212"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .integer, sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: "-")
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [Int] {
                XCTAssertEqual(array, [206, 555, 1212])
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "206-555-1212")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "integer")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
                XCTAssertEqual(answerType["sequenceSeparator"] as? String, "-")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_DateArray_StringSeparator_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "date", "sequenceType" : "array", "sequenceSeparator" : ","},
            "value": "2017-10-16T22:28:09.000-02:30,2017-10-16T22:30:09.000-02:30"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .date, sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: ",")
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let array = object.value as? [Date] {
                var calendar = Calendar(identifier: .iso8601)
                calendar.timeZone = rsd_ISO8601TimestampFormatter.timeZone
                let calendarComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
                let comp = calendar.dateComponents(calendarComponents, from: array[0])
                XCTAssertEqual(comp.year, 2017)
                XCTAssertEqual(comp.month, 10)
                XCTAssertEqual(comp.day, 16)
                XCTAssertEqual(comp.hour, 22)
                XCTAssertEqual(comp.minute, 28)
            }
            else {
                XCTFail("Failed to decode the array value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            XCTAssertEqual(dictionary["value"] as? String, "2017-10-16T22:28:09.000-02:30,2017-10-16T22:30:09.000-02:30")
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "date")
                XCTAssertEqual(answerType["sequenceType"] as? String, "array")
                XCTAssertEqual(answerType["sequenceSeparator"] as? String, ",")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }

    func testAnswerResultObject_DateDictionary_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "date", "sequenceType" : "dictionary", "dateFormat" : "HH:mm"},
            "value": { "breakfast": "08:20", "lunch": "12:40", "dinner": "19:10" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .date, sequenceType: .dictionary, formDataType: nil, dateFormat: "HH:mm")
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let dictionary = object.value as? [String : Date] {
                XCTAssertEqual(dictionary.count, 3)
                
                let calendar = Calendar(identifier: .iso8601)
                let calendarComponents: Set<Calendar.Component> = [.hour, .minute]
                
                if let date = dictionary["breakfast"] {
                    let comp = calendar.dateComponents(calendarComponents, from: date)
                    XCTAssertEqual(comp.hour, 8)
                    XCTAssertEqual(comp.minute, 20)
                }
                else {
                    XCTFail("Failed to decode dictionary \(String(describing: object.value))")
                }
            }
            else {
                XCTFail("Failed to decode the dictionary value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
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
                XCTAssertEqual(answerType["baseType"] as? String, "date")
                XCTAssertEqual(answerType["sequenceType"] as? String, "dictionary")
                XCTAssertEqual(answerType["dateFormat"] as? String, "HH:mm")
            }
            else {
                XCTFail("Encoded object does not include the answerType")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testAnswerResultObject_StringDictionary_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "bar",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30",
            "answerType": {"baseType" : "string", "sequenceType" : "dictionary"},
            "value": { "breakfast": "oatmeal", "lunch": "soup", "dinner": "spaghetti" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDAnswerResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "bar")
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let expectedAnswerType = RSDAnswerResultType(baseType: .string, sequenceType: .dictionary)
            XCTAssertEqual(object.answerType, expectedAnswerType)
            
            XCTAssertNotNil(object.value)
            if let dictionary = object.value as? [String : String] {
                XCTAssertEqual(dictionary.count, 3)
                XCTAssertEqual(dictionary["breakfast"], "oatmeal")
                XCTAssertEqual(dictionary["lunch"], "soup")
                XCTAssertEqual(dictionary["dinner"], "spaghetti")
            }
            else {
                XCTFail("Failed to decode the dictionary value \(String(describing: object.value))")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "bar")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")
            if let values = dictionary["value"] as? [String : String] {
                XCTAssertEqual(values["breakfast"], "oatmeal")
                XCTAssertEqual(values["lunch"], "soup")
                XCTAssertEqual(values["dinner"], "spaghetti")
            }
            else {
                XCTFail("Failed to encode the values. \(dictionary)")
            }
            if let answerType = dictionary["answerType"] as? [String:Any] {
                XCTAssertEqual(answerType["baseType"] as? String, "string")
                XCTAssertEqual(answerType["sequenceType"] as? String, "dictionary")
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
        var answerResult1 = RSDAnswerResultObject(identifier: "input1", answerType: RSDAnswerResultType(baseType: .boolean))
        answerResult1.value = true
        var answerResult2 = RSDAnswerResultObject(identifier: "input2", answerType: RSDAnswerResultType(baseType: .integer))
        answerResult2.value = 42
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
            
            if let result1 = object.inputResults.first as? RSDAnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                XCTAssertEqual(result1.answerType, answerResult1.answerType)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.value as? Bool, answerResult1.value as? Bool)
            } else {
                XCTFail("\(object.inputResults) did not decode the results as expected")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testTaskResultObject_Codable() {
        var taskResult = RSDTaskResultObject(identifier: "foo")
        
        var answerResult1 = RSDAnswerResultObject(identifier: "step1", answerType: RSDAnswerResultType(baseType: .boolean))
        answerResult1.value = true
        var answerResult2 = RSDAnswerResultObject(identifier: "step2", answerType: RSDAnswerResultType(baseType: .integer))
        answerResult2.value = 42
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
            
            if let result1 = object.stepHistory.first as? RSDAnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                XCTAssertEqual(result1.answerType, answerResult1.answerType)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.value as? Bool, answerResult1.value as? Bool)
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
