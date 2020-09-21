//
//  CopyTaskTests.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

class CopyTaskTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCopyTask() {
        let step1 = RSDInstructionStepObject(identifier: "step1")
        step1.title = "Step 1"
        let asyncAction = RSDMotionRecorderConfiguration(identifier: "motion", recorderTypes: nil)
        let task = AssessmentTaskObject(identifier: "foo",
                                        steps: [step1],
                                        usesTrackedData: true,
                                        asyncActions: [asyncAction],
                                        progressMarkers: ["step1"],
                                        resultIdentifier: "baroo",
                                        versionString: "2",
                                        estimatedMinutes: 3)
        let copy = task.copy(with: "nu")
        XCTAssertEqual("nu", copy.identifier)
        XCTAssertEqual(true, copy.usesTrackedData)
        XCTAssertEqual(["step1"], copy.progressMarkers)
        XCTAssertEqual("baroo", copy.schemaIdentifier)
        XCTAssertEqual("2", copy.versionString)
        XCTAssertEqual(3, copy.estimatedMinutes)
        XCTAssertEqual(1, copy.steps.count)
        XCTAssertEqual("step1", copy.steps.first?.identifier)
        XCTAssertEqual("Step 1", (copy.steps.first as? RSDUIStep)?.title)
        XCTAssertEqual(1, copy.asyncActions?.count)
        XCTAssertEqual("motion", copy.asyncActions?.first?.identifier)
    }
    
    func testCopyTask_SchemaInfo() {
        let step1 = RSDInstructionStepObject(identifier: "step1")
        step1.title = "Step 1"
        let asyncAction = RSDMotionRecorderConfiguration(identifier: "motion", recorderTypes: nil)
        let task = AssessmentTaskObject(identifier: "foo",
                                        steps: [step1],
                                        usesTrackedData: true,
                                        asyncActions: [asyncAction],
                                        progressMarkers: ["step1"],
                                        resultIdentifier: "baroo",
                                        versionString: "2",
                                        estimatedMinutes: 3)
        let schemaInfo = RSDSchemaInfoObject(identifier: "boo", revision: 3)
        let copy = task.copy(with: "nu", schemaInfo: schemaInfo)
        XCTAssertEqual("nu", copy.identifier)
        XCTAssertEqual(true, copy.usesTrackedData)
        XCTAssertEqual(["step1"], copy.progressMarkers)
        XCTAssertEqual("baroo", copy.schemaIdentifier)
        XCTAssertEqual("2", copy.versionString)
        XCTAssertEqual(3, copy.estimatedMinutes)
        XCTAssertEqual(1, copy.steps.count)
        XCTAssertEqual("step1", copy.steps.first?.identifier)
        XCTAssertEqual("Step 1", (copy.steps.first as? RSDUIStep)?.title)
        XCTAssertEqual(1, copy.asyncActions?.count)
        XCTAssertEqual("motion", copy.asyncActions?.first?.identifier)
        XCTAssertEqual("boo", copy.schemaInfo?.schemaIdentifier)
        XCTAssertEqual(3, copy.schemaInfo?.schemaVersion)
    }
}
