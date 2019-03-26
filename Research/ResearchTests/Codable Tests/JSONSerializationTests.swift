//
//  JSONSerializationTests.swift
//  ResearchTests_iOS
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

class JSONSerializationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNSString_jsonObject() {
        let obj = NSString(string: "foo")
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "foo")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testString_jsonObject() {
        let obj = "foo"
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "foo")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSNumber_jsonObject() {
        let obj = NSNumber(value: 4)
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testInt_jsonObject() {
        let obj: Int = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testInt8_jsonObject() {
        let obj: Int8 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testInt16_jsonObject() {
        let obj: Int16 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testInt32_jsonObject() {
        let obj: Int32 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testInt64_jsonObject() {
        let obj: Int64 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testUInt_jsonObject() {
        let obj: UInt = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testUInt8_jsonObject() {
        let obj: UInt8 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testUInt16_jsonObject() {
        let obj: UInt16 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testUInt32_jsonObject() {
        let obj: UInt32 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testUInt64_jsonObject() {
        let obj: UInt64 = 4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.intValue, 4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testBool_jsonObject() {
        let obj: Bool = true
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.boolValue, true)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }

    func testDouble_jsonObject() {
        let obj: Double = 1.4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.doubleValue, 1.4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testFloat_jsonObject() {
        let obj: Float = 1.4
        let json = obj.jsonObject()
        XCTAssertEqual((json as? NSNumber)?.floatValue, 1.4)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSNull_jsonObject() {
        let obj: NSNull = NSNull()
        let json = obj.jsonObject()
        XCTAssertNotNil(json as? NSNull)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSDate_jsonObject() {
        let now = Date()
        let obj: NSDate = now as NSDate
        let json = obj.jsonObject()
        XCTAssertNotNil(json as? String)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testDate_jsonObject() {
        let now = Date()
        let obj: Date = now
        let json = obj.jsonObject()
        XCTAssertNotNil(json as? String)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testData_jsonObject() {
        let data = Data(base64Encoded: "ABC4")!
        let obj: Data = data
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "ABC4")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSData_jsonObject() {
        let data = Data(base64Encoded: "ABC4")!
        let obj: NSData = data as NSData
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "ABC4")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testUUID_jsonObject() {
        let uuid = UUID()
        let obj: UUID = uuid
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, uuid.uuidString)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSUUID_jsonObject() {
        let uuid = UUID()
        let obj: NSUUID = uuid as NSUUID
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, uuid.uuidString)
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testURL_jsonObject() {
        let url = URL(string: "https://foo.org")!
        let obj: URL = url
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "https://foo.org")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSURL_jsonObject() {
        let url = URL(string: "https://foo.org")!
        let obj: NSURL = url as NSURL
        let json = obj.jsonObject()
        XCTAssertEqual(json as? String, "https://foo.org")
        XCTAssertTrue(JSONSerialization.isValidJSONObject([json]))
    }
    
    func testNSDictionary_jsonObject() {
        let date = Date()
        let url = URL(string: "https://foo.org")!
        let data = Data(base64Encoded: "ABC4")!
        let uuid = UUID()
        let barUUID = UUID()
        let gooUUID = UUID()
        
        let dictionary: [Int : Any ] = [
            0 : [ ["identifier" : "bar",
                   "items" : [ ["index" : NSNumber(value: 0)],
                               ["index" : NSNumber(value: 1)],
                               ["index" : NSNumber(value: 2)]]],
                  ["identifier" : "goo"]
            ],
            1 : [ "date" : date, "url" : url, "data" : data, "uuid" : uuid, "null" : NSNull()],
            2 : [ ["item" : "bar", "uuid" : barUUID], ["item" : "goo", "uuid" : gooUUID]],
        ]
    
        let ns_json = (dictionary as NSDictionary).jsonObject()
        let json = dictionary.jsonObject()
        
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json))
        XCTAssertTrue(JSONSerialization.isValidJSONObject(ns_json))
        
        let expectedDate = rsd_ISO8601TimestampFormatter.string(from: date)
        let expectedJSON: NSDictionary = [
            "0" : [ ["identifier" : "bar",
                   "items" : [ ["index" : NSNumber(value: 0)],
                               ["index" : NSNumber(value: 1)],
                               ["index" : NSNumber(value: 2)]]],
                  ["identifier" : "goo"]
            ],
            "1" : [ "date" : expectedDate, "url" : "https://foo.org", "data" : "ABC4", "uuid" : uuid.uuidString, "null" : NSNull()],
            "2" : [ ["item" : "bar", "uuid" : barUUID.uuidString,], ["item" : "goo", "uuid" : gooUUID.uuidString,]],
        ]
        
        XCTAssertEqual(ns_json as? NSDictionary, expectedJSON)
        XCTAssertEqual(json as? NSDictionary, expectedJSON)
    }
    
    func testSet_jsonObject() {
        let uuid1 = UUID()
        let uuid2 = UUID()
        let uuid3 = UUID()
        
        let obj = Set([uuid1, uuid2, uuid3])
        let json = obj.jsonObject()
        XCTAssertEqual((json as? [String])?.count, 3)
        XCTAssertTrue(JSONSerialization.isValidJSONObject(json))
    }
}
