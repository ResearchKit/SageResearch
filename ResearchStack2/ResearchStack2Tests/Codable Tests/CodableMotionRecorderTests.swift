//
//  CodableMotionRecorderTests.swift
//  ResearchSuiteTests_iOS
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
@testable import ResearchSuite

class CodableMotionRecorderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMotionRecorderConfiguration() {
        let json = """
        {
            "identifier": "foo",
            "type": "motion",
            "startStepIdentifier": "start",
            "stopStepIdentifier": "stop",
            "requiresBackgroundAudio": true,
            "recorderTypes": ["accelerometer", "gyro", "magnetometer"],
            "frequency": 50
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMotionRecorderConfiguration.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.startStepIdentifier, "start")
            XCTAssertEqual(object.stopStepIdentifier, "stop")
            XCTAssertTrue(object.requiresBackgroundAudio)
            XCTAssertEqual(object.frequency, 50)
            if let recorderTypes = object.recorderTypes {
                XCTAssertEqual(recorderTypes, [.accelerometer, .gyro, .magnetometer])
            } else {
                XCTAssertNotNil(object.recorderTypes)
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["startStepIdentifier"] as? String, "start")
            XCTAssertEqual(dictionary["stopStepIdentifier"] as? String, "stop")
            XCTAssertEqual(dictionary["requiresBackgroundAudio"] as? Bool, true)
            XCTAssertEqual(dictionary["frequency"] as? Double, 50)
            if let recorderTypes = dictionary["recorderTypes"] as? [String] {
                XCTAssertEqual(Set(recorderTypes), Set(["accelerometer", "gyro", "magnetometer"]))
            } else {
                XCTFail("Failed to encode the recorder types: \(String(describing: dictionary["recorderTypes"]))")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMotionRecorderConfiguration_Defaults() {
        let json = """
        {
            "identifier": "foo",
            "type": "motion"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDMotionRecorderConfiguration.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertNil(object.startStepIdentifier)
            XCTAssertNil(object.stopStepIdentifier)
            XCTAssertFalse(object.requiresBackgroundAudio)
            XCTAssertNil(object.frequency)
            XCTAssertNil(object.recorderTypes)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMotionRecord_Marker() {
        let json = """
        {
            "uptime" : 37246.68689429167,
            "timestamp" : 1.2498140833340585,
            "stepPath" : "Cardio Stair Step/heartRate.after/heartRate",
            "timestampDate" : "2018-01-30T15:13:20.597-08:00"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMotionRecord.self, from: json)
            
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
            XCTAssertEqual(dictionary["timestampDate"] as? String, "2018-01-30T15:13:20.597-08:00")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMotionRecord_Gyro() {
        let json = """
        {
            "uptime" : 37246.68689429167,
            "timestamp" : 1.2498140833340585,
            "stepPath" : "Cardio Stair Step/heartRate.after/heartRate",
            "sensorType" : "gyro",
            "x" : 0.064788818359375,
            "y" : -0.1324615478515625,
            "z" : -0.9501953125,
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMotionRecord.self, from: json)
            
            XCTAssertEqual(object.uptime, 37246.68689429167)
            XCTAssertEqual(object.timestamp, 1.2498140833340585)
            XCTAssertEqual(object.stepPath, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertNil(object.timestampDate)
            XCTAssertEqual(object.sensorType, .gyro)
            XCTAssertEqual(object.x, 0.064788818359375)
            XCTAssertEqual(object.y, -0.1324615478515625)
            XCTAssertEqual(object.z, -0.9501953125)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["uptime"] as? Double, 37246.68689429167)
            XCTAssertEqual(dictionary["timestamp"] as? Double, 1.2498140833340585)
            XCTAssertEqual(dictionary["stepPath"] as? String, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertEqual(dictionary["sensorType"] as? String, "gyro")
            XCTAssertEqual(dictionary["x"] as? Double, 0.064788818359375)
            XCTAssertEqual(dictionary["y"] as? Double, -0.1324615478515625)
            XCTAssertEqual(dictionary["z"] as? Double, -0.9501953125)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    
    func testMotionRecord_Attitude() {
        let json = """
        {
            "uptime" : 37246.68689429167,
            "timestamp" : 1.2498140833340585,
            "stepPath" : "Cardio Stair Step/heartRate.after/heartRate",
            "sensorType" : "attitude",
            "referenceCoordinate" : "North-West-Up",
            "heading" : 270.25,
            "eventAccuracy" : 4,
            "x" : 0.064788818359375,
            "y" : -0.1324615478515625,
            "z" : -0.9501953125,
            "w" : 1
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMotionRecord.self, from: json)
            
            XCTAssertEqual(object.uptime, 37246.68689429167)
            XCTAssertEqual(object.timestamp, 1.2498140833340585)
            XCTAssertEqual(object.stepPath, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertNil(object.timestampDate)
            XCTAssertEqual(object.sensorType, .attitude)
            XCTAssertEqual(object.referenceCoordinate, .xMagneticNorthZVertical)
            XCTAssertEqual(object.eventAccuracy, 4)
            XCTAssertEqual(object.heading, 270.25)
            XCTAssertEqual(object.x, 0.064788818359375)
            XCTAssertEqual(object.y, -0.1324615478515625)
            XCTAssertEqual(object.z, -0.9501953125)
            XCTAssertEqual(object.w, 1)

            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["uptime"] as? Double, 37246.68689429167)
            XCTAssertEqual(dictionary["timestamp"] as? Double, 1.2498140833340585)
            XCTAssertEqual(dictionary["stepPath"] as? String, "Cardio Stair Step/heartRate.after/heartRate")
            XCTAssertEqual(dictionary["sensorType"] as? String, "attitude")
            XCTAssertEqual(dictionary["referenceCoordinate"] as? String, "North-West-Up")
            XCTAssertEqual(dictionary["eventAccuracy"] as? Int, 4)
            XCTAssertEqual(dictionary["heading"] as? Double,270.25)
            XCTAssertEqual(dictionary["x"] as? Double, 0.064788818359375)
            XCTAssertEqual(dictionary["y"] as? Double, -0.1324615478515625)
            XCTAssertEqual(dictionary["z"] as? Double, -0.9501953125)
            XCTAssertEqual(dictionary["w"] as? Double, 1)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
