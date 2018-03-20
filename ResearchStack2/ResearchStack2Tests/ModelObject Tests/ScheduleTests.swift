//
//  TrackingTests.swift
//  ResearchStack2
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
@testable import ResearchStack2

class TrackingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // WeeklyScheduleObject
    
    /// This test takes 13 seconds to run and it's just a sanity check. I added it to check that for any
    /// combination of locale and calendar, that the components for time and day of the week do not change.
    /// Leaving the disabled test in place in order to answer the question "But what about different
    /// calendars and locals?" syoung 02/22/2018
    func disable_testWeeklyScheduleItem_CalendarAssumptions() {
        // Check the assumption that current Calendar will not influence the day of the week or time of day.
        let now = Date()
        let weekday = Calendar.iso8601.component(.weekday, from: now)
        let hour = Calendar.iso8601.component(.hour, from: now)
        let minute = Calendar.iso8601.component(.minute, from: now)
        for identifier in Calendar.Identifier.all {
            var calendar = Calendar(identifier: identifier)
            for localeCode in Locale.availableIdentifiers {
                calendar.locale = Locale(identifier: localeCode)
                XCTAssertEqual(calendar.component(.weekday, from: now), weekday, "\(calendar)")
                XCTAssertEqual(calendar.component(.hour, from: now), hour, "\(calendar)")
                XCTAssertEqual(calendar.component(.minute, from: now), minute, "\(calendar)")
                XCTAssertEqual(calendar.weekdaySymbols.count, 7, "\(calendar)")
            }
        }
    }
    
    func testWeeklyScheduleItem_WeekdayOrdinal() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        // Check assumptions for this Locale
        XCTAssertEqual(Locale.current.calendar.firstWeekday, 1)
        
        let weekdays = RSDWeekday.all.sorted()
        let weekdayOrder = weekdays.map { $0.rawValue }
        XCTAssertEqual(weekdayOrder, Array(1...7))
        
        let names = weekdays.rsd_mapAndFilter { $0.text }
        XCTAssertEqual(names, ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
        
        let shortNames = weekdays.rsd_mapAndFilter { $0.shortText }
        XCTAssertEqual(shortNames, ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
    }
    
    func testWeeklyScheduleItem_WeekdayOrdinal_France() {
        NSLocale.setCurrentTest(Locale(identifier: "fr_FR"))
        
        // Check assumptions for this Locale
        XCTAssertEqual(Locale.current.calendar.firstWeekday, 2)
        
        let weekdays = RSDWeekday.all.sorted()
        let weekdayOrder = weekdays.map { $0.rawValue }
        XCTAssertEqual(weekdayOrder, [2,3,4,5,6,7,1])
        
        let names = weekdays.rsd_mapAndFilter { $0.text }
        XCTAssertEqual(names, ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"])
    }
    
    func testWeeklyScheduleItem_WeekdayOrdinal_Uzbec() {
        NSLocale.setCurrentTest(Locale(identifier: "uz_Arab"))
        
        // Check assumptions for this Locale
        XCTAssertEqual(Locale.current.calendar.firstWeekday, 7)
        
        let weekdays = RSDWeekday.all.sorted()
        let weekdayOrder = weekdays.map { $0.rawValue }
        XCTAssertEqual(weekdayOrder, [7,1,2,3,4,5,6])
    }
    
    func testWeeklyScheduleItem_TimeOfDay() {
        var item = RSDWeeklyScheduleObject()
        XCTAssertNil(item.timeOfDayString)
        
        var timeComponents = DateComponents()
        timeComponents.hour = 8
        timeComponents.minute = 0
        item.timeComponents = timeComponents
        XCTAssertEqual(item.timeOfDayString, "08:00")
        XCTAssertEqual(item.timeComponents, timeComponents)
        
        item.timeOfDay = Date()
        XCTAssertNotNil(item.timeOfDayString)
        XCTAssertNotNil(item.timeOfDay)
        XCTAssertNotNil(item.timeComponents)
    }
    
    func testWeeklyScheduleItem_NotificationTriggers() {
        var item = RSDWeeklyScheduleObject()
        item.timeOfDayString = "08:00"
        item.daysOfWeek = [.monday, .wednesday, .friday]
        
        let triggers = item.notificationTriggers()
        XCTAssertEqual(triggers.count, 3)
        for trigger in triggers {
            XCTAssertEqual(trigger.hour, 8, "\(trigger)")
            XCTAssertEqual(trigger.minute, 0, "\(trigger)")
            XCTAssertNil(trigger.year)
            XCTAssertNil(trigger.month)
            XCTAssertNil(trigger.day)
            XCTAssertNil(trigger.weekdayOrdinal)
        }
        let weekdays = triggers.rsd_mapAndFilterSet { $0.weekday}
        XCTAssertEqual(weekdays, [2,4,6])
    }
    
    func testWeeklyScheduleFormatter_Daily() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        var item1 = RSDWeeklyScheduleObject()
        item1.timeOfDayString = "08:00"
        
        var item2 = RSDWeeklyScheduleObject()
        item2.timeOfDayString = "20:30"
        
        let items = [item1, item2]
        let formatter = RSDWeeklyScheduleFormatter()
        
        formatter.style = .long
        XCTAssertEqual(formatter.string(from: items), "Every day at 8:00 AM and 8:30 PM")
        
        formatter.style = .medium
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, 8:30 PM\nEvery day")
        
        formatter.style = .short
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, 8:30 PM, Every day")
    }
    
    func testWeeklyScheduleFormatter_SameDays() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        var item1 = RSDWeeklyScheduleObject()
        item1.timeOfDayString = "08:00"
        item1.daysOfWeek = [.monday, .wednesday, .friday]
        
        var item2 = RSDWeeklyScheduleObject()
        item2.timeOfDayString = "20:30"
        item2.daysOfWeek = [.monday, .wednesday, .friday]
        
        let items = [item1, item2]
        let formatter = RSDWeeklyScheduleFormatter()
        
        formatter.style = .long
        XCTAssertEqual(formatter.string(from: items), "Monday, Wednesday, and Friday at 8:00 AM and 8:30 PM")
        
        formatter.style = .medium
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, 8:30 PM\nMonday, Wednesday, Friday")
        
        formatter.style = .short
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, 8:30 PM, Mon, Wed, Fri")
    }
    
    func testWeeklyScheduleFormatter_DifferentDays() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        var item1 = RSDWeeklyScheduleObject()
        item1.timeOfDayString = "08:00"
        
        var item2 = RSDWeeklyScheduleObject()
        item2.timeOfDayString = "20:30"
        item2.daysOfWeek = [.tuesday, .thursday]
        
        let items = [item1, item2]
        let formatter = RSDWeeklyScheduleFormatter()
        
        formatter.style = .long
        XCTAssertEqual(formatter.string(from: items), "Every day at 8:00 AM\nTuesday and Thursday at 8:30 PM")
        
        formatter.style = .medium
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, Every day\n8:30 PM, Tue, Thu")
        
        formatter.style = .short
        XCTAssertEqual(formatter.string(from: items), "8:00 AM, Every day\n8:30 PM, Tue, Thu")
    }
}

extension Calendar.Identifier {

    public static var all: Set<Calendar.Identifier> {
        return [.gregorian, .buddhist, .chinese, .coptic, .ethiopicAmeteMihret, .ethiopicAmeteAlem, .hebrew, .iso8601, .indian, .islamic, .islamicCivil, .japanese, .persian, .republicOfChina, .islamicTabular, .islamicUmmAlQura]
    }
}

