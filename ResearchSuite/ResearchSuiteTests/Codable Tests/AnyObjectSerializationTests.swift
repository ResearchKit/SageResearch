//
//  AnyObjectSerializationTests.swift
//  ResearchSuite
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
@testable import ResearchSuite

class AnyObjectSerializationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDictionary_Encodable() {
        
        let now = Date()
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.month = 6
        let data = Data(base64Encoded: "ABCD")!
        let uuid = UUID()
        let url = URL(string: "http://test.example.org")!
        
        let input: [String : Any] = ["string" : "String",
                                          "number" : NSNumber(value: 23),
                                          "infinity" : Double.infinity,
                                          "integer" : Int(34),
                                          "double" : Double(1.234),
                                          "bool" : true,
                                          "null" : NSNull(),
                                          "date" : now,
                                          "dateComponents" : dateComponents,
                                          "data" : data,
                                          "uuid" : uuid,
                                          "url" : url,
                                          "array" : ["cat", "dog", "duck"],
                                          "dictionary" : ["a" : 1, "b" : "bat", "c" : true]
                                          ]
        do {
            
            let encoder = RSDFactory.shared.createJSONEncoder()
            encoder.dataEncodingStrategy = .base64
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "NaN")
            let jsonData = try encoder.encode(input)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }

            XCTAssertEqual(dictionary["string"] as? String, "String")
            XCTAssertEqual(dictionary["number"] as? Int, 23)
            XCTAssertEqual(dictionary["infinity"] as? String, "+inf")
            XCTAssertEqual(dictionary["integer"] as? Int, 34)
            XCTAssertEqual(dictionary["double"] as? Double, 1.234)
            XCTAssertEqual(dictionary["bool"] as? Bool, true)
            XCTAssertNotNil(dictionary["null"] as? NSNull)
            XCTAssertEqual(dictionary["date"] as? String, now.jsonObject() as? String)
            if let components = dictionary["dateComponents"] as? [String : Int] {
                XCTAssertEqual(components, ["day" : 1, "month" : 6])
            } else {
                XCTFail("Failed to encode dateComponents. \(String(describing: dictionary["dateComponents"]))")
            }
            XCTAssertEqual(dictionary["data"] as? String, data.base64EncodedString())
            XCTAssertEqual(dictionary["uuid"] as? String, uuid.uuidString)
            if let array = dictionary["array"] as? [String] {
                XCTAssertEqual(array, ["cat", "dog", "duck"])
            } else {
                XCTFail("Failed to encode array. \(String(describing: dictionary["array"]))")
            }
            if let subd = dictionary["dictionary"] as? [String : Any] {
                XCTAssertEqual(subd["a"] as? Int, 1)
                XCTAssertEqual(subd["b"] as? String, "bat")
                XCTAssertEqual(subd["c"] as? Bool, true)
            } else {
                XCTFail("Failed to encode dictionary. \(String(describing: dictionary["dictionary"]))")
            }
            
            // Test convert to object
            let object = try dictionary.decode(TestDecodable.self)
            
            XCTAssertEqual(object.string, "String")
            XCTAssertEqual(object.integer, 34)
            XCTAssertEqual(object.bool, true)
            XCTAssertEqual(object.date.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.01)
            XCTAssertEqual(object.uuid, uuid)
            XCTAssertEqual(object.array, ["cat", "dog", "duck"])
            XCTAssertNil(object.null)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testArray_Encodable() {
        
        let now = Date()
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.month = 6
        let uuid = UUID()
        
        let input: [Any] = [["string" : "String",
                             "integer" : NSNumber(value: 34),
                             "bool" : NSNumber(value:true),
                             "date" : now.jsonObject(),
                             "uuid" : uuid.uuidString,
                             "array" : ["cat", "dog", "duck"]]]
        do {
            guard let object = try input.decode([TestDecodable].self).first
                else {
                    XCTFail("Failed to decode object")
                    return
            }
            
            XCTAssertEqual(object.string, "String")
            XCTAssertEqual(object.integer, 34)
            XCTAssertEqual(object.bool, true)
            XCTAssertEqual(object.date.timeIntervalSinceReferenceDate, now.timeIntervalSinceReferenceDate, accuracy: 0.01)
            XCTAssertEqual(object.uuid, uuid)
            XCTAssertEqual(object.array, ["cat", "dog", "duck"])
            XCTAssertNil(object.null)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}

struct TestDecodable : Codable {
    let string: String
    let integer: Int
    let uuid: UUID
    let date: Date
    let bool: Bool
    let array: [String]
    let null: String?
}
