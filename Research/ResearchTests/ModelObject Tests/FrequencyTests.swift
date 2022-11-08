//
//  FrequencyTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research

class FrequencyTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFrequency_withinDuration_always() {
        let frequency = RSDFrequencyType.always
        let now = Date()
        let previous = now.addingTimeInterval(-5 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_daily_True() {
        let frequency = RSDFrequencyType.daily
        let now = Date()
        let previous = now.addingTimeInterval(-5 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_daily_False() {
        let frequency = RSDFrequencyType.daily
        let now = Date()
        let previous = now.addingTimeInterval(-1 * 28 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_weekly_True() {
        let frequency = RSDFrequencyType.weekly
        let now = Date()
        let previous = now.addingTimeInterval(-1 * 28 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_weekly_False() {
        let frequency = RSDFrequencyType.weekly
        let now = Date()
        let previous = now.addingTimeInterval(-8 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_monthly_True() {
        let frequency = RSDFrequencyType.monthly
        let now = Date()
        let previous = now.addingTimeInterval(-8 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_monthly_False() {
        let frequency = RSDFrequencyType.monthly
        let now = Date()
        let previous = now.addingTimeInterval(-32 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_quarterly_True() {
        let frequency = RSDFrequencyType.quarterly
        let now = Date()
        let previous = now.addingTimeInterval(-32 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_quarterly_False() {
        let frequency = RSDFrequencyType.quarterly
        let now = Date()
        let previous = now.addingTimeInterval(-100 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_biannual_True() {
        let frequency = RSDFrequencyType.biannual
        let now = Date()
        let previous = now.addingTimeInterval(-100 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_biannual_False() {
        let frequency = RSDFrequencyType.biannual
        let now = Date()
        let previous = now.addingTimeInterval(-200 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
    
    func testFrequency_withinDuration_annual_True() {
        let frequency = RSDFrequencyType.annual
        let now = Date()
        let previous = now.addingTimeInterval(-200 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertTrue(withinDuration)
    }
    
    func testFrequency_withinDuration_annual_False() {
        let frequency = RSDFrequencyType.annual
        let now = Date()
        let previous = now.addingTimeInterval(-370 * 24 * 60 * 60)
        let withinDuration = frequency.withinDuration(between: previous, and: now)
        XCTAssertFalse(withinDuration)
    }
}
