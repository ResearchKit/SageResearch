//
//  CodableTrackedDataTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
class CodableTrackedDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
            "daysOfWeek": ["Sunday","Tuesday","Thursday"],
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
            if let daysOfWeek = dictionary["daysOfWeek"] as? [String] {
                XCTAssertEqual(Set(daysOfWeek), Set(["Sunday","Tuesday","Thursday"]))
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
            "daysOfWeek": ["Sunday","Tuesday","Thursday"],
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
            if let daysOfWeek = dictionary["daysOfWeek"] as? [String] {
                XCTAssertEqual(Set(daysOfWeek), Set(["Sunday","Tuesday","Thursday"]))
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
            "daysOfWeek": ["Sunday","Tuesday","Thursday"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDWeeklyScheduleObject.self, from: json)
            
            XCTAssertEqual(object.daysOfWeek, [.sunday, .tuesday, .thursday])
            let timeOfDay = object.timeOfDay(on: Date())
            XCTAssertNil(timeOfDay)
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testWeeklyScheduleItem_Codable_Default_String() {
        let json = """
        {
            "daysOfWeek": ["Sunday","Tuesday","Thursday"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDWeeklyScheduleObject.self, from: json)
            
            XCTAssertEqual(object.daysOfWeek, [.sunday, .tuesday, .thursday])
            let timeOfDay = object.timeOfDay(on: Date())
            XCTAssertNil(timeOfDay)
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
