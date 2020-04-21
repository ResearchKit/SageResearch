//
//  RecordSampleLoggerTests.swift
//  Research
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
import JsonModel

struct TestRecord : RSDSampleRecord, RSDDelimiterSeparatedEncodable {
    let uptime: TimeInterval
    let stepPath: String
    let label: String?
    let x: Double?
    let y: Double?
    let z: Double?
    
    var timestampDate: Date? {
        return nil
    }
    
    var timestamp: TimeInterval? {
        return nil
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case uptime, stepPath, x, y, z, label
    }
    
    private static func _codingKeys() -> [CodingKeys] {
        return [.uptime, .stepPath, .x, .y, .z, .label]
    }
    
    static func codingKeys() -> [CodingKey] {
        return _codingKeys()
    }
}

struct TestRecordCollection : Codable {
    let items: [TestRecord]
    let startDate: Date
}

class RecordSampleLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRecordSampleLogger_JSON_WithRoot() {

        do {
            let url = try createTempFile("foo")
            let recorder = try RSDRecordSampleLogger(identifier: "foo", url: url, usesRootDictionary: true)
            let startDate = Date()
            try recorder.writeSample(RSDRecordMarker(uptime: 0.0, timestamp: 0.0, date: startDate, stepPath: "Task/step1"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.01, stepPath: "Task/step1", label: "booRa", x: 1.2, y: 3.4, z: 5.6),
                TestRecord(uptime: 0.1, stepPath: "Task/step1", label: "barRa", x: 1.3, y: 3.5, z: 5.7)
                ])
            try recorder.writeSample(RSDRecordMarker(uptime: 0.15, timestamp: 0.15, date: Date(), stepPath: "Task/step2"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.2, stepPath: "Task/step2", label: "gooRa", x: 1.4, y: 3.6, z: 5.8)
                ])
            try recorder.close()
        
            let fileURL = recorder.url
            let data = try Data(contentsOf: fileURL)
            let decoder = RSDFactory.shared.createJSONDecoder()
            let recordCollection = try decoder.decode(TestRecordCollection.self, from: data)
            
            let items = recordCollection.items
            let expectedCount = 5
            XCTAssertEqual(items.count, expectedCount, "\(items)")
            guard items.count == expectedCount else {
                XCTFail("Failed to decode the items")
                return
            }
            
            XCTAssertEqual(items[0].uptime, 0.0)
            XCTAssertEqual(items[0].stepPath, "Task/step1")
            
            XCTAssertEqual(items[1].uptime, 0.01)
            XCTAssertEqual(items[1].stepPath, "Task/step1")
            XCTAssertEqual(items[1].label, "booRa")
            XCTAssertEqual(items[1].x, 1.2)
            XCTAssertEqual(items[1].y, 3.4)
            XCTAssertEqual(items[1].z, 5.6)
        
        } catch let err {
            XCTFail("Error encoding/decoding samples: \(err)")
        }
    }
    
    func testRecordSampleLogger_JSON_WithoutRoot() {
        
        do {
            let url = try createTempFile("foo")
            let recorder = try RSDRecordSampleLogger(identifier: "foo", url: url, usesRootDictionary: false)
            let startDate = Date()
            try recorder.writeSample(RSDRecordMarker(uptime: 0.0, timestamp: 0.0, date: startDate, stepPath: "Task/step1"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.01, stepPath: "Task/step1", label: "booRa", x: 1.2, y: 3.4, z: 5.6),
                TestRecord(uptime: 0.1, stepPath: "Task/step1", label: "barRa", x: 1.3, y: 3.5, z: 5.7)
                ])
            try recorder.writeSample(RSDRecordMarker(uptime: 0.15, timestamp: 0.15, date: Date(), stepPath: "Task/step2"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.2, stepPath: "Task/step2", label: "gooRa", x: 1.4, y: 3.6, z: 5.8)
                ])
            try recorder.close()
            
            let fileURL = recorder.url
            let data = try Data(contentsOf: fileURL)
            let decoder = RSDFactory.shared.createJSONDecoder()
            let items = try decoder.decode([TestRecord].self, from: data)
            
            let expectedCount = 5
            XCTAssertEqual(items.count, expectedCount, "\(items)")
            guard items.count == expectedCount else {
                XCTFail("Failed to decode the items")
                return
            }
            
            XCTAssertEqual(items[0].uptime, 0.0)
            XCTAssertEqual(items[0].stepPath, "Task/step1")
            
            XCTAssertEqual(items[1].uptime, 0.01)
            XCTAssertEqual(items[1].stepPath, "Task/step1")
            XCTAssertEqual(items[1].label, "booRa")
            XCTAssertEqual(items[1].x, 1.2)
            XCTAssertEqual(items[1].y, 3.4)
            XCTAssertEqual(items[1].z, 5.6)
            
        } catch let err {
            XCTFail("Error encoding/decoding samples: \(err)")
        }
    }
    
    func testRecordSampleLogger_CSV() {
        
        do {
            let url = try createTempFile("foo")
            let format = CSVEncodingFormat<TestRecord>()
            let recorder = try RSDRecordSampleLogger(identifier: "foo", url: url, usesRootDictionary: true, stringEncodingFormat: format)
            let startDate = Date()
            try recorder.writeSample(RSDRecordMarker(uptime: 0.0, timestamp: 0.0, date: startDate, stepPath: "Task/step1"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.01, stepPath: "Task/step1", label: "booRa", x: 1.2, y: 3.4, z: 5.6),
                TestRecord(uptime: 0.1, stepPath: "Task/step1", label: "barRa", x: 1.3, y: 3.5, z: 5.7)
                ])
            try recorder.writeSample(RSDRecordMarker(uptime: 0.15, timestamp: 0.15, date: Date(), stepPath: "Task/step2"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.2, stepPath: "Task/step2", label: "gooRa", x: 1.4, y: 3.6, z: 5.8)
                ])
            try recorder.close()
            
            let fileURL = recorder.url
            let data = try Data(contentsOf: fileURL)
            guard let string = String(data: data, encoding: .utf8) else {
                XCTFail("Failed to build CSV string from data")
                return
            }
            print(string)

            let items = string.components(separatedBy: "\n")
            
            let expectedCount = 6
            XCTAssertEqual(items.count, expectedCount, "\(items)")
            guard items.count == expectedCount else {
                XCTFail("Failed to decode the items")
                return
            }
            
            XCTAssertEqual(items[0], "uptime,stepPath,x,y,z,label")
            XCTAssertEqual(items[1], "0,Task/step1,,,,")
            XCTAssertEqual(items[2], "0.01,Task/step1,1.2,3.4,5.6,booRa")
            
        } catch let err {
            XCTFail("Error encoding/decoding samples: \(err)")
        }
    }
    
    func testRecordSampleLogger_CSV_NoHeader() {
        
        do {
            let url = try createTempFile("foo")
            var format = CSVEncodingFormat<TestRecord>()
            format.includesHeader = false
            let recorder = try RSDRecordSampleLogger(identifier: "foo", url: url, usesRootDictionary: true, stringEncodingFormat: format)
            let startDate = Date()
            try recorder.writeSample(RSDRecordMarker(uptime: 0.0, timestamp: 0.0, date: startDate, stepPath: "Task/step1"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.01, stepPath: "Task/step1", label: "booRa", x: 1.2, y: 3.4, z: 5.6),
                TestRecord(uptime: 0.1, stepPath: "Task/step1", label: "barRa", x: 1.3, y: 3.5, z: 5.7)
                ])
            try recorder.writeSample(RSDRecordMarker(uptime: 0.15, timestamp: 0.15, date: Date(), stepPath: "Task/step2"))
            try recorder.writeSamples([
                TestRecord(uptime: 0.2, stepPath: "Task/step2", label: "gooRa", x: 1.4, y: 3.6, z: 5.8)
                ])
            try recorder.close()
            
            let fileURL = recorder.url
            let data = try Data(contentsOf: fileURL)
            guard let string = String(data: data, encoding: .utf8) else {
                XCTFail("Failed to build CSV string from data")
                return
            }
            
            let items = string.components(separatedBy: "\n")
            
            let expectedCount = 5
            XCTAssertEqual(items.count, expectedCount, "\(items)")
            guard items.count == expectedCount else {
                XCTFail("Failed to decode the items")
                return
            }
            
            XCTAssertEqual(items[0], "0,Task/step1,,,,")
            XCTAssertEqual(items[1], "0.01,Task/step1,1.2,3.4,5.6,booRa")
            
        } catch let err {
            XCTFail("Error encoding/decoding samples: \(err)")
        }
    }
    
    
    // helper methods
    
    func createTempFile(_ identifier: String) throws -> URL {
        let tempDir = NSTemporaryDirectory()
        let dir = UUID().uuidString
        let path = (tempDir as NSString).appendingPathComponent(dir)
        if !FileManager.default.fileExists(atPath: path) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [ .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication ])
        }
        let outputDirectory = URL(fileURLWithPath: path, isDirectory: true)
        return try RSDFileResultUtility.createFileURL(identifier: identifier, ext: "json", outputDirectory: outputDirectory)
    }
}
