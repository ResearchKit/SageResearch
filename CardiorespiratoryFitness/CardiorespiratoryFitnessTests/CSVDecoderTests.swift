//
//  CSVDecoderTests.swift
//  CardiorespiratoryFitnessTests
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
@testable import CardiorespiratoryFitness

class CSVDecoderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCSV_AllFieldsIncluded() {
        let requiredKeys = RequiredKeys.allCases.map { "\"\($0.stringValue)\"" }.joined(separator: ",")
        let optionalKeys = OptionalKeys.allCases.map { "\"\($0.stringValue)\"" }.joined(separator: ",")
        let values = "1, 8, 16, 32, 64, 1, 8, 16, 32, 64, 1.5, 3.14, true, \"foo\", \"apple\""
        let empty = ",,,,,,,,,,,,,,"
        let header = "\(requiredKeys),\(optionalKeys)"
        let row1 = "\(values),\(values)"
        let row2 = "\(values),\(empty)"
        let cvs = "\(header)\n\(row1)\n\(row2)\n\n".data(using: .utf8)!
        
        let decoder = CSVDecoder()
        do {
            let results = try decoder.decodeArray(TestCSV.self, from: cvs)
            XCTAssertEqual(results.count, 2)
            if let result = results.first {
                XCTAssertEqual(result.requiredInt, 1)
                XCTAssertEqual(result.requiredInt8, 8)
                XCTAssertEqual(result.requiredInt16, 16)
                XCTAssertEqual(result.requiredInt32, 32)
                XCTAssertEqual(result.requiredInt64, 64)
                XCTAssertEqual(result.requiredUInt, 1)
                XCTAssertEqual(result.requiredUInt8, 8)
                XCTAssertEqual(result.requiredUInt16, 16)
                XCTAssertEqual(result.requiredUInt32, 32)
                XCTAssertEqual(result.requiredUInt64, 64)
                XCTAssertEqual(result.requiredBool, true)
                XCTAssertEqual(result.requiredFloat, 3.14)
                XCTAssertEqual(result.requiredDouble, 1.5)
                XCTAssertEqual(result.requiredString, "foo")
                XCTAssertEqual(result.requiredFruit, .apple)
                
                XCTAssertEqual(result.optionalInt, 1)
                XCTAssertEqual(result.optionalInt8, 8)
                XCTAssertEqual(result.optionalInt16, 16)
                XCTAssertEqual(result.optionalInt32, 32)
                XCTAssertEqual(result.optionalInt64, 64)
                XCTAssertEqual(result.optionalUInt, 1)
                XCTAssertEqual(result.optionalUInt8, 8)
                XCTAssertEqual(result.optionalUInt16, 16)
                XCTAssertEqual(result.optionalUInt32, 32)
                XCTAssertEqual(result.optionalUInt64, 64)
                XCTAssertEqual(result.optionalBool, true)
                XCTAssertEqual(result.optionalFloat, 3.14)
                XCTAssertEqual(result.optionalDouble, 1.5)
                XCTAssertEqual(result.optionalString, "foo")
                XCTAssertEqual(result.optionalFruit, .apple)
            }
            if let result = results.last {
                XCTAssertEqual(result.requiredInt, 1)
                XCTAssertEqual(result.requiredInt8, 8)
                XCTAssertEqual(result.requiredInt16, 16)
                XCTAssertEqual(result.requiredInt32, 32)
                XCTAssertEqual(result.requiredInt64, 64)
                XCTAssertEqual(result.requiredUInt, 1)
                XCTAssertEqual(result.requiredUInt8, 8)
                XCTAssertEqual(result.requiredUInt16, 16)
                XCTAssertEqual(result.requiredUInt32, 32)
                XCTAssertEqual(result.requiredUInt64, 64)
                XCTAssertEqual(result.requiredBool, true)
                XCTAssertEqual(result.requiredFloat, 3.14)
                XCTAssertEqual(result.requiredDouble, 1.5)
                XCTAssertEqual(result.requiredString, "foo")
                XCTAssertEqual(result.requiredFruit, .apple)
                
                XCTAssertNil(result.optionalInt)
                XCTAssertNil(result.optionalInt8)
                XCTAssertNil(result.optionalInt16)
                XCTAssertNil(result.optionalInt32)
                XCTAssertNil(result.optionalInt64)
                XCTAssertNil(result.optionalUInt)
                XCTAssertNil(result.optionalUInt8)
                XCTAssertNil(result.optionalUInt16)
                XCTAssertNil(result.optionalUInt32)
                XCTAssertNil(result.optionalUInt64)
                XCTAssertNil(result.optionalBool)
                XCTAssertNil(result.optionalFloat)
                XCTAssertNil(result.optionalDouble)
                XCTAssertNil(result.optionalString)
                XCTAssertNil(result.optionalFruit)
            }
        }
        catch let err {
            XCTFail("Failed to decode the csv data. \(err)")
        }
    }
}

enum RequiredKeys : String, CodingKey, CaseIterable {
    case requiredInt, requiredInt8, requiredInt16, requiredInt32, requiredInt64
    case requiredUInt, requiredUInt8, requiredUInt16, requiredUInt32, requiredUInt64
    case requiredDouble, requiredFloat, requiredBool, requiredString, requiredFruit
}

enum OptionalKeys : String, CodingKey, CaseIterable {
    case optionalInt, optionalInt8, optionalInt16, optionalInt32, optionalInt64
    case optionalUInt, optionalUInt8, optionalUInt16, optionalUInt32, optionalUInt64
    case optionalDouble, optionalFloat, optionalBool, optionalString, optionalFruit
}

struct TestCSV : Codable, Equatable {
    
    enum Fruit : String, Codable {
        case apple, orange, peach
    }
    
    let requiredInt : Int
    let requiredInt8 : Int8
    let requiredInt16 : Int16
    let requiredInt32 : Int32
    let requiredInt64 : Int64
    let requiredUInt : UInt
    let requiredUInt8 : UInt8
    let requiredUInt16 : UInt16
    let requiredUInt32 : UInt32
    let requiredUInt64 : UInt64
    let requiredDouble : Double
    let requiredFloat : Float
    let requiredBool : Bool
    let requiredString : String
    let requiredFruit : Fruit
    
    let optionalInt : Int?
    let optionalInt8 : Int8?
    let optionalInt16 : Int16?
    let optionalInt32 : Int32?
    let optionalInt64 : Int64?
    let optionalUInt : UInt?
    let optionalUInt8 : UInt8?
    let optionalUInt16 : UInt16?
    let optionalUInt32 : UInt32?
    let optionalUInt64 : UInt64?
    let optionalDouble : Double?
    let optionalFloat : Float?
    let optionalBool : Bool?
    let optionalString : String?
    let optionalFruit : Fruit?
}
