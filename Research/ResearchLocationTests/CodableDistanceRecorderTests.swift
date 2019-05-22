//
//  CodableDistanceRecorderTests.swift
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
import Research
@testable import ResearchLocation

class CodableDistanceRecorderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        rsd_ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDistanceRecorderConfiguration() {
        let json = """
             {
                "identifier": "foo",
                "type": "distance",
                "motionStepIdentifier": "run",
                "startStepIdentifier": "countdown",
                "stopStepIdentifier": "rest"
            }
            """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDDistanceRecorderConfiguration.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.type, "distance")
            XCTAssertEqual(object.startStepIdentifier, "countdown")
            XCTAssertEqual(object.stopStepIdentifier, "rest")
            XCTAssertEqual(object.motionStepIdentifier, "run")
            XCTAssertTrue(object.requiresBackgroundAudio)
            if let permissions = object.permissionTypes as? [RSDStandardPermissionType] {
                XCTAssertEqual(permissions, [.location, .motion])
            } else {
                
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "distance")
            XCTAssertEqual(dictionary["startStepIdentifier"] as? String, "countdown")
            XCTAssertEqual(dictionary["stopStepIdentifier"] as? String, "rest")
            XCTAssertEqual(dictionary["motionStepIdentifier"] as? String, "run")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testDistanceRecord_Marker() {
        let json = """
        {
            "uptime" : 37246.68689429167,
            "timestamp" : 1.2498140833340585,
            "stepPath" : "Cardio Stair Step/heartRate.after/heartRate",
            "timestampDate" : "2018-01-30T15:13:20.597-02:30"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDDistanceRecord.self, from: json)
            
            XCTAssertEqual(object.uptime, 37246.68689429167)
            XCTAssertEqual(object.timestamp, 1.2498140833340585)
            XCTAssertEqual(object.stepPath, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertNotNil(object.timestampDate)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["uptime"] as? Double, 37246.68689429167)
            XCTAssertEqual(dictionary["timestamp"] as? Double, 1.2498140833340585)
            XCTAssertEqual(dictionary["stepPath"] as? String, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertEqual(dictionary["timestampDate"] as? String, "2018-01-30T15:13:20.597-02:30")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testDistanceRecord_Moving() {
     let json = """
                {
                 "uptime" : 99652.677386361029,
                 "relativeDistance" : 2.1164507282484935,
                 "verticalAccuracy" : 3,
                 "horizontalAccuracy" : 6,
                 "stepPath" : "Cardio 12MT/run/runDistance",
                 "course" : 76.873546882061802,
                 "totalDistance" : 63.484948023273581,
                 "speed" : 1.0289180278778076,
                 "timestampDate" : "2018-01-04T23:49:34.135-02:30",
                 "timestamp" : 210.47070598602295,
                 "altitude" : 23.375564581136974
                }
                """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDDistanceRecord.self, from: json)
            
            XCTAssertEqual(object.uptime, 99652.677386361029)
            XCTAssertEqual(object.timestamp, 210.47070598602295)
            XCTAssertEqual(object.stepPath, "Cardio 12MT/run/runDistance")
            XCTAssertNotNil(object.timestampDate)
            XCTAssertEqual(object.relativeDistance, 2.1164507282484935)
            XCTAssertEqual(object.horizontalAccuracy, 6)
            XCTAssertNil(object.latitude)
            XCTAssertNil(object.longitude)
            XCTAssertEqual(object.altitude, 23.375564581136974)
            XCTAssertEqual(object.verticalAccuracy, 3)
            XCTAssertEqual(object.course, 76.873546882061802)
            XCTAssertEqual(object.speed, 1.0289180278778076)
            XCTAssertEqual(object.totalDistance, 63.484948023273581)

            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["uptime"] as? Double, 99652.677386361029)
            XCTAssertEqual(dictionary["timestamp"] as? Double, 210.47070598602295)
            XCTAssertEqual(dictionary["stepPath"] as? String, "Cardio 12MT/run/runDistance")
            XCTAssertEqual(dictionary["timestampDate"] as? String, "2018-01-04T23:49:34.135-02:30")
            XCTAssertEqual(dictionary["relativeDistance"] as? Double, 2.1164507282484935)
            XCTAssertEqual(dictionary["horizontalAccuracy"] as? Int, 6)
            XCTAssertEqual(dictionary["altitude"] as? Double, 23.375564581136974)
            XCTAssertEqual(dictionary["verticalAccuracy"] as? Int, 3)
            XCTAssertEqual(dictionary["course"] as? Double, 76.873546882061802)
            XCTAssertEqual(dictionary["speed"] as? Double, 1.0289180278778076)
            XCTAssertEqual(dictionary["totalDistance"] as? Double, 63.484948023273581)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
