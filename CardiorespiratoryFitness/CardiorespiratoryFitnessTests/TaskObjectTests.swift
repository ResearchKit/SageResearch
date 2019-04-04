//
//  TaskObjectTests.swift
//  CardiorespiratoryFitnessTests
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
@testable import CardiorespiratoryFitness
@testable import Research_UnitTest

import XCTest

class TaskObjectTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTaskNavigation_PreviousDemographics() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let task = CRFTaskInfo(.stairStep).task
        let taskController = TestTaskController()
        taskController.task = task
        
        let dataStore = TestDataStoreManager()
        let previousRunTimestamp = Date(timeIntervalSinceNow: -1 * 60 * 60)
        let json: [String : RSDJSONSerializable] = ["birthYear" : 1956,
                                         "sex" : "female",
                                         "hr_resting" : 62]
        dataStore.previous[RSDIdentifier(rawValue: task.identifier)] =
            TestData(identifier: task.identifier,
                     timestampDate: previousRunTimestamp,
                     json: json )
        taskController.taskViewModel.dataManager = dataStore
        
        let _ = taskController.test_stepTo("heartRisk")
        
        // check that the previous run data is being set properly
        XCTAssertEqual(task.birthYear, 1956)
        XCTAssertEqual(task.sex, .female)
        
        taskController.goForward()
        
        guard let node = taskController.taskViewModel.currentNode else {
            XCTFail("Unexpected null task step node.")
            return
        }
        
        XCTAssertEqual(node.identifier, "volumeUp")
        
        guard let taskData = task.taskData(for: taskController.taskViewModel.taskResult) else {
            XCTFail("Unexpected null task run data")
            return
        }
        
        XCTAssertNotNil(taskData.timestampDate)
        XCTAssertEqual(taskData.identifier, task.identifier)
        
        guard let answers = taskData.json as? [String : RSDJSONSerializable] else {
            XCTFail("\(taskData.json) not a dictionary")
            return
        }
        
        XCTAssertEqual(answers["birthYear"] as? Int, 1956)
        XCTAssertEqual(answers["sex"] as? String, "female")
    }
    
    func testTaskNavigation_SetDemographics() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let task = CRFTaskInfo(.stairStep).task
        task.birthYear = 1956
        task.sex = .female
        
        XCTAssertEqual(task.birthYear, 1956)
        XCTAssertEqual(task.sex, .female)
    }
    
    func testTaskNavigation_NoDemographics() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let task = CRFTaskInfo(.stairStep).task
        let taskController = TestTaskController()
        taskController.task = task
        
        let _ = taskController.test_stepTo("heartRisk")
        
        // check that the previous run data is being set properly
        XCTAssertNil(task.birthYear)
        XCTAssertNil(task.sex)
        
        taskController.goForward()
        
        guard let node = taskController.taskViewModel.currentNode else {
            XCTFail("Unexpected null task step node.")
            return
        }
        
        XCTAssertEqual(node.identifier, "demographics")
    }
    
    func testTaskCameraSettings() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let task = CRFTaskInfo(.resting).task
        guard let settings = task.cameraSettings else {
            XCTFail("Unexpected null camera settings.")
            return
        }
        
        var cameraSettings = settings
        cameraSettings.exposureDuration = 20
        task.cameraSettings = cameraSettings
        
        guard let hr1 = task.stepNavigator.step(with: "hr1") as? CRFHeartRateStep else {
            XCTFail("Could not find first heart rate step")
            return
        }
        
        guard let hr = task.stepNavigator.step(with: "hr") as? CRFHeartRateStep else {
            XCTFail("Could not find second heart rate step")
            return
        }

        XCTAssertEqual(hr.cameraSettings, hr1.cameraSettings)
        XCTAssertEqual(hr.cameraSettings, cameraSettings)
    }
}
