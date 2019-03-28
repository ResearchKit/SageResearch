//
//  ModelTests.swift
//  CardiorespiratoryFitnessTests
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
@testable import CardiorespiratoryFitness

class ModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTraining() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let taskInfo = CRFTaskInfo(.training)

        XCTAssertEqual(taskInfo.identifier, "Heartrate Training")
        XCTAssertEqual(taskInfo.title, "Heart Snapshot")
        XCTAssertEqual(taskInfo.subtitle, "Your phone's camera can measure your heartbeat.")
        XCTAssertNil(taskInfo.detail)
        XCTAssertEqual(taskInfo.estimatedMinutes, 2)
    }
    
    func testResting() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let taskInfo = CRFTaskInfo(.resting)
        
        XCTAssertEqual(taskInfo.identifier, "Resting Heartrate")
        XCTAssertEqual(taskInfo.title, "Resting heart rate")
        XCTAssertEqual(taskInfo.subtitle, "Your heart rate while you are at rest is a marker of your health. The more relaxed you are, the better. Let's measure your resting heart rate.")
        XCTAssertNil(taskInfo.detail)
        XCTAssertEqual(taskInfo.estimatedMinutes, 1)
    }
    
    func testDecodeTasks() {
        // Check that the JSON is decoding properly.
        for taskIdentifier in CRFTaskIdentifier.allCases {
            let factory = CRFFactory()
            do {
                let taskTransformer = CRFTaskTransformer(taskIdentifier)
                let _ = try factory.decodeTask(with: taskTransformer)
            } catch let err {
                XCTFail("Failed to decode \(taskIdentifier): \(err)")
            }
        }
    }

}
