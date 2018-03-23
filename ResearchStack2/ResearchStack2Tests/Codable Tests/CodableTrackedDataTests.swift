//
//  CodableTrackedDataTests.swift
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

class CodableTrackedDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Cohort
    
    func testCohortNavigationRuleObject_Codable() {
        let json = """
        {
            "requiredCohorts": ["foo","goo"],
            "operator": "all",
            "skipToIdentifier": "end"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDCohortNavigationRuleObject.self, from: json)
            
            XCTAssertEqual(object.requiredCohorts, ["foo","goo"])
            XCTAssertEqual(object.cohortOperator, .all)
            XCTAssertEqual(object.skipToIdentifier, "end")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["operator"] as? String, "all")
            XCTAssertEqual(dictionary["skipToIdentifier"] as? String, "end")
            if let requiredCohorts = dictionary["requiredCohorts"] as? [String] {
                XCTAssertEqual(Set(requiredCohorts), Set(["foo","goo"]))
            } else {
                XCTFail("Failed to encode the required cohorts: \(String(describing: dictionary["requiredCohorts"]))")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testCohortNavigationRuleObject_Codable_Default() {
        let json = """
        {
            "requiredCohorts": ["foo","goo"],
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDCohortNavigationRuleObject.self, from: json)
            
            XCTAssertEqual(object.requiredCohorts, ["foo","goo"])
            XCTAssertNil(object.cohortOperator)
            XCTAssertNil(object.skipToIdentifier)
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    // WeeklyScheduleItem

    func testWeeklyScheduleItem_Codable() {
        let json = """
        {
            "daysOfWeek": [1,3,5],
            "timeOfDay": "08:15"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDWeeklyScheduleObject.self, from: json)
            
            XCTAssertEqual(object.daysOfWeek, [.sunday, .tuesday, .thursday])
            XCTAssertEqual(object.timeComponents?.hour, 8)
            XCTAssertEqual(object.timeComponents?.minute, 15)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["timeOfDay"] as? String, "08:15")
            if let daysOfWeek = dictionary["daysOfWeek"] as? [Int] {
                XCTAssertEqual(Set(daysOfWeek), Set([1,3,5]))
            } else {
                XCTFail("Failed to encode the daysOfWeek: \(String(describing: dictionary["daysOfWeek"]))")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testWeeklyScheduleItem_Codable_HourOnly() {
        let json = """
        {
            "daysOfWeek": [1,3,5],
            "timeOfDay": "08:00"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDWeeklyScheduleObject.self, from: json)
            
            XCTAssertEqual(object.daysOfWeek, [.sunday, .tuesday, .thursday])
            XCTAssertEqual(object.timeComponents?.hour, 8)
            XCTAssertEqual(object.timeComponents?.minute, 0)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["timeOfDay"] as? String, "08:00")
            if let daysOfWeek = dictionary["daysOfWeek"] as? [Int] {
                XCTAssertEqual(Set(daysOfWeek), Set([1,3,5]))
            } else {
                XCTFail("Failed to encode the daysOfWeek: \(String(describing: dictionary["daysOfWeek"]))")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testWeeklyScheduleItem_Codable_Default() {
        let json = """
        {
            "daysOfWeek": [1,3,5]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDWeeklyScheduleObject.self, from: json)
            
            XCTAssertEqual(object.daysOfWeek, [.sunday, .tuesday, .thursday])
            XCTAssertNil(object.timeOfDay)
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTrackedSectionObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "text": "Text",
            "detail" : "Detail"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDTrackedSectionObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.text, "Text")
            XCTAssertEqual(object.detail, "Detail")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["text"] as? String, "Text")
            XCTAssertEqual(dictionary["detail"] as? String, "Detail")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTrackedItem_Codable() {
        let json = """
        {
            "identifier": "advil-ibuprofen",
            "sectionIdentifier": "pain",
            "title": "Advil",
            "shortText": "Adv",
            "detail": "(Ibuprofen)",
            "isExclusive": true,
            "icon": "pill",
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDTrackedItemObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "advil-ibuprofen")
            XCTAssertEqual(object.sectionIdentifier, "pain")
            XCTAssertEqual(object.text, "Advil")
            XCTAssertEqual(object.shortText, "Adv")
            XCTAssertEqual(object.detail, "(Ibuprofen)")
            XCTAssertEqual(object.isExclusive, true)
            XCTAssertEqual(object.icon?.imageName, "pill")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "advil-ibuprofen")
            XCTAssertEqual(dictionary["sectionIdentifier"] as? String, "pain")
            XCTAssertEqual(dictionary["title"] as? String, "Advil")
            XCTAssertEqual(dictionary["shortText"] as? String, "Adv")
            XCTAssertEqual(dictionary["detail"] as? String, "(Ibuprofen)")
            XCTAssertEqual(dictionary["icon"] as? String, "pill")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTrackedItem_Codable_Default() {
        let json = """
        {
            "identifier": "Ibuprofen"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDTrackedItemObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "Ibuprofen")
            XCTAssertEqual(object.text, "Ibuprofen")
            XCTAssertNil(object.sectionIdentifier)
            XCTAssertNil(object.title)
            XCTAssertNil(object.shortText)
            XCTAssertNil(object.detail)
            XCTAssertFalse(object.isExclusive)
            XCTAssertNil(object.icon)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMedicationItem_Codable() {
        let json = """
        {
            "identifier": "advil-ibuprofen",
            "sectionIdentifier": "pain",
            "title": "Advil",
            "shortText": "Adv",
            "detail": "(Ibuprofen)",
            "isExclusive": true,
            "icon": "pill",
            "injection": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDMedicationItem.self, from: json)
            
            XCTAssertEqual(object.identifier, "advil-ibuprofen")
            XCTAssertEqual(object.sectionIdentifier, "pain")
            XCTAssertEqual(object.text, "Advil")
            XCTAssertEqual(object.shortText, "Adv")
            XCTAssertEqual(object.detail, "(Ibuprofen)")
            XCTAssertEqual(object.isExclusive, true)
            XCTAssertEqual(object.icon?.imageName, "pill")
            XCTAssertEqual(object.isContinuousInjection, true)

            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "advil-ibuprofen")
            XCTAssertEqual(dictionary["sectionIdentifier"] as? String, "pain")
            XCTAssertEqual(dictionary["title"] as? String, "Advil")
            XCTAssertEqual(dictionary["shortText"] as? String, "Adv")
            XCTAssertEqual(dictionary["detail"] as? String, "(Ibuprofen)")
            XCTAssertEqual(dictionary["icon"] as? String, "pill")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)
            XCTAssertEqual(dictionary["injection"] as? Bool, true)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }

    func testMedicationItem_Codable_Default() {
        let json = """
        {
            "identifier": "Ibuprofen"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDMedicationItem.self, from: json)
            
            XCTAssertEqual(object.identifier, "Ibuprofen")
            XCTAssertEqual(object.text, "Ibuprofen")
            XCTAssertNil(object.sectionIdentifier)
            XCTAssertNil(object.title)
            XCTAssertNil(object.shortText)
            XCTAssertNil(object.detail)
            XCTAssertFalse(object.isExclusive)
            XCTAssertNil(object.icon)
            XCTAssertNil(object.isContinuousInjection)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMedicationAnswer_Codable() {
        let json = """
        {
            "identifier": "ibuprofen",
            "dosage": "10/100 mg",
            "scheduleItems" : [ { "daysOfWeek": [1,3,5], "timeOfDay" : "8:00" }],
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMedicationAnswer.self, from: json)
            
            XCTAssertEqual(object.identifier, "ibuprofen")
            XCTAssertEqual(object.dosage, "10/100 mg")
            XCTAssertEqual(object.scheduleItems?.count, 1)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "ibuprofen")
            XCTAssertEqual(dictionary["dosage"] as? String, "10/100 mg")
            if let items = dictionary["scheduleItems"] as? [[String : Any]] {
                XCTAssertEqual(items.count, 1)
            } else {
                XCTFail("Failed to encode the scheduled items")
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMedicationAnswer_Codable_Default() {
        let json = """
        {
            "identifier": "ibuprofen",
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDMedicationAnswer.self, from: json)
            
            XCTAssertEqual(object.identifier, "ibuprofen")
            XCTAssertNil(object.dosage)
            XCTAssertNil(object.scheduleItems)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTrackedItemsStepNavigator_Codable() {
        
        let json = """
        {
            "items": [
                        { "identifier": "itemA1", "sectionIdentifier" : "a" },
                        { "identifier": "itemA2", "sectionIdentifier" : "a" },
                        { "identifier": "itemB1", "sectionIdentifier" : "b" },
                        { "identifier": "itemB2", "sectionIdentifier" : "b" },
                        { "identifier": "itemC1", "sectionIdentifier" : "c" }
                    ],
            "sections": [{ "identifier": "a" }, { "identifier": "b" }, { "identifier": "c" }]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDTrackedItemsStepNavigator.self, from: json)
            XCTAssertEqual(object.items.count, 5)
            XCTAssertEqual(object.sections?.count ?? 0, 3)

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMedicationTrackingStepNavigator_Codable() {
        
        let json = """
        {
            "items": [
                        { "identifier": "itemA1", "sectionIdentifier" : "a" },
                        { "identifier": "itemA2", "sectionIdentifier" : "a" },
                        { "identifier": "itemB1", "sectionIdentifier" : "b" },
                        { "identifier": "itemB2", "sectionIdentifier" : "b" },
                        { "identifier": "itemC1", "sectionIdentifier" : "c" }
                    ],
            "sections": [{ "identifier": "a" }, { "identifier": "b" }, { "identifier": "c" }]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDMedicationTrackingStepNavigator.self, from: json)
            XCTAssertEqual(object.items.count, 5)
            XCTAssertEqual(object.sections?.count ?? 0, 3)
            XCTAssertNotNil(object.items as? [RSDMedicationItem])
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTriggerTrackingStepNavigator_Codable() {
        
        let json = """
            {
                "identifier": "logging",
                "type" : "tracking",
                "items": [
                            { "identifier": "itemA1", "sectionIdentifier" : "a" },
                            { "identifier": "itemA2", "sectionIdentifier" : "a" },
                            { "identifier": "itemA3", "sectionIdentifier" : "a" },
                            { "identifier": "itemB1", "sectionIdentifier" : "b" },
                            { "identifier": "itemB2", "sectionIdentifier" : "b" },
                            { "identifier": "itemC1", "sectionIdentifier" : "c" },
                            { "identifier": "itemC2", "sectionIdentifier" : "c" },
                            { "identifier": "itemC3", "sectionIdentifier" : "c" }
                        ],
                "selection": { "title": "What items would you like to track?",
                                "detail": "Select all that apply",
                                "colorTheme" : { "colorStyle" : { "header" : "darkBackground",
                                                "body" : "darkBackground",
                                                "footer" : "lightBackground" }}
                            },
                "logging": { "title": "Your logged items",
                             "actions": { "addMore": { "buttonTitle" : "Edit Logged Items" }}
                            }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDTaskObject.self, from: json)
            XCTAssertEqual(object.identifier, "logging")
            guard let navigator = object.stepNavigator as? RSDTrackedItemsStepNavigator else {
                XCTFail("Failed to decode the step navigator. Exiting.")
                return
            }
            XCTAssertEqual(navigator.items.count, 8)
            XCTAssertNil(navigator.sections)
            XCTAssertEqual((navigator.selectionStep as? RSDUIStep)?.title, "What items would you like to track?")
            XCTAssertEqual((navigator.selectionStep as? RSDUIStep)?.detail, "Select all that apply")
            if let colorTheme = (navigator.selectionStep as? RSDThemedUIStep)?.colorTheme {
                XCTAssertEqual(colorTheme.colorStyle(for: .footer), .lightBackground)
            } else {
                XCTFail("Failed to decode the color Theme")
            }
            
            XCTAssertEqual((navigator.loggingStep as? RSDUIStep)?.title, "Your logged items")
            XCTAssertEqual((navigator.loggingStep as? RSDUIStepObject)?.actions?[.navigation(.addMore)]?.buttonTitle, "Edit Logged Items")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
