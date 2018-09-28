//
//  UnitConversionTests.swift
//  Research
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

class UnitConversionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUnitLengthForSymbol() {
        XCTAssertEqual(UnitLength(fromSymbol: "ft"), UnitLength.feet)
        XCTAssertEqual(UnitLength(fromSymbol: "in"), UnitLength.inches)
        XCTAssertEqual(UnitLength(fromSymbol: "yd"), UnitLength.yards)
        XCTAssertEqual(UnitLength(fromSymbol: "mm"), UnitLength.millimeters)
        XCTAssertEqual(UnitLength(fromSymbol: "cm"), UnitLength.centimeters)
        XCTAssertEqual(UnitLength(fromSymbol: "m"), UnitLength.meters)
        XCTAssertEqual(UnitLength(fromSymbol: "km"), UnitLength.kilometers)
    }
    
    func testUnitMassForSymbol() {
        XCTAssertEqual(UnitMass(fromSymbol: "lb"), UnitMass.pounds)
        XCTAssertEqual(UnitMass(fromSymbol: "kg"), UnitMass.kilograms)
        XCTAssertEqual(UnitMass(fromSymbol: "oz"), UnitMass.ounces)
        XCTAssertEqual(UnitMass(fromSymbol: "lb"), UnitMass.pounds)
    }
    
    func testFeetAndInchesConverter() {
        let converter = RSDUnitConverter.feetAndInches
        
        if let imperialValue = converter.toTupleValue(from: 167.64) {
            XCTAssertEqual(Int(imperialValue.largeValue), 5)
            XCTAssertEqual(Int(imperialValue.smallValue), 6)
        } else {
            XCTFail("Failed to decode the answer from the selected rows")
        }
        
        let measurement = converter.measurement(fromLargeValue: 5, smallValue: 6)
        XCTAssertEqual(measurement.converted(to: .inches).value, 66.0, accuracy: 0.001)
    }
    
    func testPoundAndOunceConverter() {
        let converter = RSDUnitConverter.poundAndOunces
        
        if let imperialValue = converter.toTupleValue(from: 3.97) {
            XCTAssertEqual(Int(imperialValue.largeValue), 8)
            XCTAssertEqual(Int(imperialValue.smallValue), 12)
        } else {
            XCTFail("Failed to decode the answer from the selected rows")
        }
        
        let measurement = converter.measurement(fromLargeValue: 8, smallValue: 12)
        XCTAssertEqual(measurement.converted(to: .kilograms).value, 3.97, accuracy: 0.01)
    }
}
