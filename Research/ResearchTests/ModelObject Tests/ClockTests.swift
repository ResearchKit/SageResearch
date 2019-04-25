//
//  ClockTests.swift
//  ResearchTests_iOS
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

@testable import Research

class ClockTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSleepOffset_BeforeSleep() {
        let start: TimeInterval = -10 * 60
        let date = Date().addingTimeInterval(start)
        let clockTime = RSDClock.uptime()
        let systemTime = ProcessInfo.processInfo.systemUptime
        
        let clock = RSDClock(clock: clockTime, system: systemTime, date: date)
        
        let sleepOffset: TimeInterval = 5 * 60
        let wakeAt: TimeInterval = 8 * 60
        let wakeClock = clockTime + wakeAt
        let wakeSystem = systemTime + wakeAt - sleepOffset
        clock.addTimeMarkers(wakeClock, wakeSystem)
        
        let offset: TimeInterval = 60
        let testTimeExpected = clockTime + offset
        let testTime = systemTime + offset
        let testTimeActual = clock.relativeUptime(to: testTime)
        XCTAssertEqual(testTimeExpected, testTimeActual, accuracy:0.0001)
        
        let zeroTimeActual = clock.zeroRelativeTime(to: testTime)
        let zeroTimeEspected = testTimeActual - clockTime
        XCTAssertEqual(zeroTimeEspected, zeroTimeActual, accuracy:0.0001)
    }
    
    func testSleepOffset_BeforeStart() {
        let start: TimeInterval = -10 * 60
        let date = Date().addingTimeInterval(start)
        let clockTime = RSDClock.uptime()
        let systemTime = ProcessInfo.processInfo.systemUptime
        
        let clock = RSDClock(clock: clockTime, system: systemTime, date: date)
        
        let sleepOffset: TimeInterval = 5 * 60
        let wakeAt: TimeInterval = 8 * 60
        let wakeClock = clockTime + wakeAt
        let wakeSystem = systemTime + wakeAt - sleepOffset
        clock.addTimeMarkers(wakeClock, wakeSystem)
        
        let offset: TimeInterval = -60
        let testTimeExpected = clockTime + offset
        let testTime = systemTime + offset
        let testTimeActual = clock.relativeUptime(to: testTime)
        XCTAssertEqual(testTimeExpected, testTimeActual, accuracy:0.0001)
        
        let zeroTimeActual = clock.zeroRelativeTime(to: testTime)
        let zeroTimeEspected = testTimeActual - clockTime
        XCTAssertEqual(zeroTimeEspected, zeroTimeActual, accuracy:0.0001)
    }
    
    func testSleepOffset_AfterSleep() {
        
        let start: TimeInterval = -10 * 60
        let date = Date().addingTimeInterval(start)
        let clockTime = RSDClock.uptime()
        let systemTime = ProcessInfo.processInfo.systemUptime
        
        let clock = RSDClock(clock: clockTime, system: systemTime, date: date)
        
        let sleepOffset: TimeInterval = 5 * 60
        let wakeAt: TimeInterval = 8 * 60
        let wakeClock = clockTime + wakeAt
        let wakeSystem = systemTime + wakeAt - sleepOffset
        clock.addTimeMarkers(wakeClock, wakeSystem)
        
        let offsetAfter: TimeInterval = 10 * 60
        let testTimeExpected = clockTime + offsetAfter
        let testTime = systemTime + offsetAfter - sleepOffset
        let testTimeActual = clock.relativeUptime(to: testTime)
        XCTAssertEqual(testTimeExpected, testTimeActual, accuracy:0.0001)
        
        let zeroTimeActual = clock.zeroRelativeTime(to: testTime)
        let zeroTimeEspected = testTimeActual - clockTime
        XCTAssertEqual(zeroTimeEspected, zeroTimeActual, accuracy:0.0001)
    }
    
    func testSleepOffset_AfterSleepX2() {
        
        let start: TimeInterval = -10 * 60
        let date = Date().addingTimeInterval(start)
        let clockTime = RSDClock.uptime()
        let systemTime = ProcessInfo.processInfo.systemUptime
        
        let clock = RSDClock(clock: clockTime, system: systemTime, date: date)
        
        let sleepOffset1: TimeInterval = 5 * 60
        let wakeAt1: TimeInterval = 8 * 60
        let wakeClock1 = clockTime + wakeAt1
        let wakeSystem1 = systemTime + wakeAt1 - sleepOffset1
        clock.addTimeMarkers(wakeClock1, wakeSystem1)
        
        let sleepOffset2: TimeInterval = 2 * 60
        let wakeAt2: TimeInterval = 3 * 60
        let wakeClock2 = wakeClock1 + wakeAt2
        let wakeSystem2 = wakeSystem1 + wakeAt2 - sleepOffset2
        clock.addTimeMarkers(wakeClock2, wakeSystem2)
        
        let offsetAfter: TimeInterval = 10 * 60
        let testTimeExpected = wakeClock2 + offsetAfter
        let testTime = wakeSystem2 + offsetAfter
        let testTimeActual = clock.relativeUptime(to: testTime)
        XCTAssertEqual(testTimeExpected, testTimeActual, accuracy:0.0001)
        
        let zeroTimeActual = clock.zeroRelativeTime(to: testTime)
        let zeroTimeEspected = testTimeActual - clockTime
        XCTAssertEqual(zeroTimeEspected, zeroTimeActual, accuracy:0.0001)
    }
}
