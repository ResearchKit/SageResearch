//
//  MeasurementDurationTests.swift
//  Research
//


import XCTest

@testable import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
class MeasurementDurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMeasurementDuration_ValueAndUnit_3h_15m() {
        let expectedHours = 3
        let expectedMinutes = 15
        let expectedSeconds = 0
        let timeInterval: TimeInterval  = TimeInterval(expectedHours * 3600 + expectedMinutes * 60 + expectedSeconds)
        let ti = Measurement(value: timeInterval, unit: UnitDuration.seconds)
        
        XCTAssertEqual(ti.hours, expectedHours)
        XCTAssertEqual(ti.minutes, expectedMinutes)
        XCTAssertEqual(ti.seconds, expectedSeconds)
        XCTAssertEqual(ti.component(of: .hours), expectedHours)
        XCTAssertEqual(ti.component(of: .minutes), expectedMinutes)
        XCTAssertEqual(ti.component(of: .seconds), expectedSeconds)
        XCTAssertEqual(ti.timeInterval, timeInterval)
    }
    
    func testTimeInterval_ValueAndUnit_2h_15m_20s() {
        let expectedHours = 2
        let expectedMinutes = 15
        let expectedSeconds = 20
        let timeInterval: TimeInterval  = TimeInterval(expectedHours * 3600 + expectedMinutes * 60 + expectedSeconds)
        let ti = Measurement(value: timeInterval, unit: UnitDuration.seconds)
        
        XCTAssertEqual(ti.hours, expectedHours)
        XCTAssertEqual(ti.minutes, expectedMinutes)
        XCTAssertEqual(ti.seconds, expectedSeconds)
        XCTAssertEqual(ti.component(of: .hours), expectedHours)
        XCTAssertEqual(ti.component(of: .minutes), expectedMinutes)
        XCTAssertEqual(ti.component(of: .seconds), expectedSeconds)
        XCTAssertEqual(ti.timeInterval, timeInterval)
    }
    
    func testTimeInterval_ValueAndUnit_10m_20s() {
        let expectedHours = 0
        let expectedMinutes = 10
        let expectedSeconds = 20
        let timeInterval: TimeInterval  = TimeInterval(expectedHours * 3600 + expectedMinutes * 60 + expectedSeconds)
        let ti = Measurement(value: timeInterval, unit: UnitDuration.seconds)
        
        XCTAssertEqual(ti.hours, expectedHours)
        XCTAssertEqual(ti.minutes, expectedMinutes)
        XCTAssertEqual(ti.seconds, expectedSeconds)
        XCTAssertEqual(ti.component(of: .hours), expectedHours)
        XCTAssertEqual(ti.component(of: .minutes), expectedMinutes)
        XCTAssertEqual(ti.component(of: .seconds), expectedSeconds)
        XCTAssertEqual(ti.timeInterval, timeInterval)
    }
    
    func testTimeIntervalUnit_MaxTimeValue() {
        XCTAssertEqual(UnitDuration.hours.maxTimeValue(), 24)
        XCTAssertEqual(UnitDuration.minutes.maxTimeValue(), 60)
        XCTAssertEqual(UnitDuration.seconds.maxTimeValue(), 60)
    }
    
    func testTimeIntervalUnit_Comparable() {
        XCTAssertGreaterThan(UnitDuration.hours, UnitDuration.minutes)
        XCTAssertGreaterThan(UnitDuration.minutes, UnitDuration.seconds)
        XCTAssertGreaterThan(UnitDuration.hours, UnitDuration.seconds)
    }
    
    func testDurationUnitConvertion() {
        XCTAssertEqual(UnitDuration(fromSymbol: "s"), UnitDuration.seconds)
        XCTAssertEqual(UnitDuration(fromSymbol: "seconds"), UnitDuration.seconds)
        XCTAssertEqual(UnitDuration(fromSymbol: "min"), UnitDuration.minutes)
        XCTAssertEqual(UnitDuration(fromSymbol: "minutes"), UnitDuration.minutes)
        XCTAssertEqual(UnitDuration(fromSymbol: "hr"), UnitDuration.hours)
        XCTAssertEqual(UnitDuration(fromSymbol: "hours"), UnitDuration.hours)
    }
}
