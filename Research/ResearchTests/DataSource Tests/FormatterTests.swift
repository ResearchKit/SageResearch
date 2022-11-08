//
//  FormatterTests.swift
//  Research
//

import XCTest
@testable import Research
@testable import Formatters
import NSLocaleSwizzle

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
    
    func testFractionFormatter_threeFourths() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let numerator = 3
        let denominator = 4
        let inputString = "3/4"
        let doubleValue = 0.75
        
        let formatter = RSDFractionFormatter()
        let fractionString = formatter.string(for: NSNumber(value: doubleValue))
        XCTAssertEqual(fractionString, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = (obj as? NSNumber)?.fractionalValue() {
            XCTAssertEqual(output.numerator, numerator)
            XCTAssertEqual(output.denominator, denominator)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    
    func testFractionFormatter_twoThirds() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let numerator = 2
        let denominator = 3
        let inputString = "2/3"
        let doubleValue = 0.66666666666666667
        
        let formatter = RSDFractionFormatter()
        let fractionString = formatter.string(for: NSNumber(value: doubleValue))
        XCTAssertEqual(fractionString, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = (obj as? NSNumber)?.fractionalValue() {
            XCTAssertEqual(output.numerator, numerator)
            XCTAssertEqual(output.denominator, denominator)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testFractionFormatter_Infinity() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let inputString = "2/0"
        let doubleValue = Double.infinity
        
        let formatter = RSDFractionFormatter()
        let fractionString = formatter.string(for: NSNumber(value: doubleValue))
        XCTAssertNil(fractionString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertFalse(success)
    }
    
    func testDurationFormatter_1hour_2minute_full() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let inputString = "1 hour, 30 minutes"
        let expectedValue = Double(90)
        let measurement = NSNumber(value: expectedValue)
        
        let formatter = RSDDurationFormatter()
        formatter.toStringUnit = .minutes
        formatter.fromStringUnit = .minutes
        formatter.unitsStyle = .full
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitDuration> {
            let value = output.converted(to: .minutes).value
            XCTAssertEqual(value, expectedValue)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testDurationFormatter_1hour_2minute_positional() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputString = "1:30"
        let expectedValue = Double(90)
        let measurement = NSNumber(value: expectedValue)
        
        let formatter = RSDDurationFormatter()
        formatter.toStringUnit = .minutes
        formatter.fromStringUnit = .minutes
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute]
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitDuration> {
            let value = output.converted(to: .minutes).value
            XCTAssertEqual(value, expectedValue)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testDurationFormatter_2minute_30second_full() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputString = "2 minutes, 30 seconds"
        let expectedValue = Double(150)
        let measurement = NSNumber(value: expectedValue)
        
        let formatter = RSDDurationFormatter()
        formatter.toStringUnit = .seconds
        formatter.fromStringUnit = .seconds
        formatter.unitsStyle = .full
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitDuration> {
            let value = output.converted(to: .seconds).value
            XCTAssertEqual(value, expectedValue)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
    
    func testDurationFormatter_2minute_30second_positional() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputString = "2:30"
        let expectedValue = Double(150)
        let measurement = NSNumber(value: expectedValue)
        
        let formatter = RSDDurationFormatter()
        formatter.toStringUnit = .seconds
        formatter.fromStringUnit = .seconds
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        
        let text = formatter.string(for: measurement)
        XCTAssertEqual(text, inputString)
        
        var obj: AnyObject?
        var err: NSString?
        let success = formatter.getObjectValue(&obj, for: inputString, errorDescription: &err)
        XCTAssertTrue(success)
        XCTAssertNil(err)
        if let output = obj as? Measurement<UnitDuration> {
            let value = output.converted(to: .seconds).value
            XCTAssertEqual(value, expectedValue)
        } else {
            XCTFail("Failed to convert string to inches")
        }
    }
}
