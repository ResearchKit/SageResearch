//
//  FrequencyTests.swift
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
