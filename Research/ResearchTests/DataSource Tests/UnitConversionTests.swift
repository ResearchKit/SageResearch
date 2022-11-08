//
//  UnitConversionTests.swift
//  Research
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
