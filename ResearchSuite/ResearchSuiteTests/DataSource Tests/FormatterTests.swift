//
//  FormatterTests.swift
//  ResearchSuite
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
@testable import ResearchSuite

class FormatterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        NSLocale.setCurrentTest(nil)
        super.tearDown()
    }
    
    func testLocaleSwizzle() {
        NSLocale.setCurrentTest(Locale(identifier: "fr_CA"))
        
        let currentLocale = Locale.current
        XCTAssertTrue(currentLocale.usesMetricSystem)
        XCTAssertEqual(currentLocale.identifier, "fr_CA")
    }
    
    func testLengthFormatter_20in_medium() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDLengthFormatter()
        formatter.isForChildHeightUse = true
        
        formatter.unitStyle = .medium
        let inputString = "20 in"
        
        let measurement = Measurement(value: 20, unit: UnitLength.inches)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitLength> {
            let inches = output.converted(to: .inches)
            XCTAssertEqual(inches, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testLengthFormatter_20in_short() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDLengthFormatter()
        formatter.isForChildHeightUse = true
        
        formatter.unitStyle = .short
        let inputString = "20″"

        let measurement = Measurement(value: 20, unit: UnitLength.inches)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)

        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitLength> {
            let inches = output.converted(to: .inches)
            XCTAssertEqual(inches, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testLengthFormatter_5ft_6in_medium() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDLengthFormatter()
        formatter.isForPersonHeightUse = true
        
        formatter.unitStyle = .medium
        let inputString = "5 ft, 6 in"
        
        let measurement = Measurement(value: 5 * 12 + 6, unit: UnitLength.inches)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitLength> {
            let inches = output.converted(to: .inches)
            XCTAssertEqual(inches, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testLengthFormatter_5ft_6in_short() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDLengthFormatter()
        formatter.isForPersonHeightUse = true
        
        formatter.unitStyle = .short
        let inputString = "5′ 6″"
        
        let measurement = Measurement(value: 5 * 12 + 6, unit: UnitLength.inches)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitLength> {
            let inches = output.converted(to: .inches)
            XCTAssertEqual(inches, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testLengthFormatter_5ft_6in_colloquial() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let formatter = RSDLengthFormatter()
        formatter.isForPersonHeightUse = true
        formatter.toStringUnit = .centimeters
        formatter.fromStringUnit = .inches
        
        formatter.unitStyle = .short
        let inputString = "5 foot 6"
        
        let measurement = Measurement(value: 5 * 12 + 6, unit: UnitLength.inches)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitLength> {
            let inches = output.converted(to: .inches)
            XCTAssertEqual(inches, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testMassFormatter_5lb_6oz_medium() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDMassFormatter()
        formatter.isForInfantMassUse = true
        
        formatter.unitStyle = .medium
        let inputString = "5 lb, 6 oz"
        
        let measurement = Measurement(value: 5 * 16 + 6, unit: UnitMass.ounces)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitMass> {
            let ounces = output.converted(to: .ounces)
            XCTAssertEqual(ounces, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testMassFormatter_120lb_medium() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDMassFormatter()
        formatter.isForPersonMassUse = true
        
        formatter.unitStyle = .medium
        let inputString = "120 lb"
        
        let measurement = Measurement(value: 120, unit: UnitMass.pounds)
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitMass> {
            let pounds = output.converted(to: .pounds)
            XCTAssertEqual(pounds, measurement)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testMassFormatter_120lb_medium_converted() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = RSDMassFormatter()
        formatter.isForPersonMassUse = true
        formatter.toStringUnit = .pounds
        formatter.fromStringUnit = .pounds
        formatter.unitStyle = .medium
        
        let text = formatter.string(for: 120)
        XCTAssertEqual(text, "120 lb")
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: "120", errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitMass> {
            let pounds = output.converted(to: .pounds)
            XCTAssertEqual(pounds.value, 120)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
}
