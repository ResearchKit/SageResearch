//
//  FactoryTests.swift
//  ResearchTests
//

import XCTest
@testable import Research
import JsonModel

@available(*,deprecated, message: "Will be deleted in a future version.")
class FactoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
                
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateTaskGroup() {
        guard let taskGroup = getTaskGroup(resourceName: "FactoryTest_TaskGroup") else {
            XCTFail("Failed to get task group")
            return
        }
        
        XCTAssertEqual(taskGroup.identifier, "foobar")
        XCTAssertEqual(taskGroup.title, "Foobarific")
        XCTAssertEqual(taskGroup.detail, "This is a task group containing foo and bar")
        XCTAssertEqual(taskGroup.imageData?.imageIdentifier, "foobarIcon")
        XCTAssertEqual(taskGroup.tasks.count, 2)
        
        guard let fooTaskInfo = taskGroup.tasks.first as? RSDTaskInfoObject,
            let barTaskInfo = taskGroup.tasks.last as? RSDTaskInfoObject
        else {
            XCTFail("Failed to decode task info objects")
            return
        }
        
        XCTAssertEqual(fooTaskInfo.identifier, "foo")
        XCTAssertEqual(fooTaskInfo.title, "Hello Foo!")
        XCTAssertEqual(fooTaskInfo.detail, "This is a test of foo.")
        XCTAssertEqual(fooTaskInfo.estimatedMinutes, 5)
        XCTAssertEqual(fooTaskInfo.imageData?.imageIdentifier, "fooIcon")
        
        XCTAssertEqual(barTaskInfo.identifier, "bar")
        XCTAssertEqual(barTaskInfo.title, "Hello Bar!")
        XCTAssertEqual(barTaskInfo.detail, "This is a test of bar.")
        XCTAssertEqual(barTaskInfo.estimatedMinutes, 7)
        XCTAssertEqual(barTaskInfo.imageData?.imageIdentifier, "barIcon")
    }
    
    func testFetchTask() {
        
        let taskIdentifier = "foo"
        let schemaInfo = RSDSchemaInfoObject(identifier: "bar", revision: 3)
        let resourceTransformer = RSDResourceTransformerObject(resourceName: "FactoryTest_TaskFoo", bundleIdentifier: BundleWrapper.bundleIdentifier!)
        
        let expect = expectation(description: "Fetch Task \(taskIdentifier)")
        resourceTransformer.fetchTask(with: taskIdentifier, schemaInfo: schemaInfo) { (task, err)  in
            if let task = task {
                
                // Check identifiers
                XCTAssertEqual(task.identifier, "foo")
                XCTAssertEqual(task.schemaInfo?.schemaIdentifier, "bar")
                XCTAssertEqual(task.schemaInfo?.schemaVersion, 3)
                
                // Investigate the step navigator
                if let stepNavigator = task.stepNavigator as? RSDConditionalStepNavigatorObject {
                    let expectedCount = 5
                    XCTAssertEqual(stepNavigator.steps.count, expectedCount)
                    if stepNavigator.steps.count < expectedCount {
                        XCTAssertNotNil(stepNavigator.steps[0] as? RSDUIStepObject)
                        XCTAssertNotNil(stepNavigator.steps[1] as? RSDActiveUIStepObject)
                        XCTAssertNotNil(stepNavigator.steps[2] as? SimpleQuestionStepObject)
                        XCTAssertNotNil(stepNavigator.steps[3] as? RSDSectionStepObject)
                        XCTAssertNotNil(stepNavigator.steps[3] as? RSDTaskInfoStepObject)
                    }
                }
                else {
                    XCTFail("\(task.stepNavigator) not of expected type.")
                }
            }
            else {
                XCTFail("Failed to decode task: \(String(describing: err))")
            }
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (err) in
            XCTAssertNil(err)
        }
    }
    
    // MARK: Helper methods
    
    func getTaskGroup(resourceName: String) -> RSDTaskGroupObject? {
        guard let bundleIdentifier = BundleWrapper.bundleIdentifier else {
            XCTFail("Failed to get bundle identifier")
            return nil
        }
        let wrapper = TestResourceWrapper(resourceName: resourceName, bundleIdentifier: bundleIdentifier)
        do {
            let (data, _) = try wrapper.resourceData()
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(RSDTaskGroupObject.self, from: data)
        }
        catch let err {
            XCTFail("Failed to decode resource: \(err)")
            return nil
        }
    }
    
}

struct FactoryResourceInfo : ResourceInfo {
    let factoryBundle: ResourceBundle?
    let packageName: String?
    var bundleIdentifier: String? { return nil }
}
