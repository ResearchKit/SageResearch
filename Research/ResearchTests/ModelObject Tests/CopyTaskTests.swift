//
//  CopyTaskTests.swift
//  Research
//

import XCTest
@testable import Research
import MobilePassiveData

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
        let asyncAction = MotionRecorderConfigurationObject(identifier: "motion", recorderTypes: nil)
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
        let asyncAction = MotionRecorderConfigurationObject(identifier: "motion", recorderTypes: nil)
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
