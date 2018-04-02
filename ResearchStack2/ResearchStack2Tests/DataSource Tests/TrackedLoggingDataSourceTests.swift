//
//  TrackedLoggingDataSourceTests.swift
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

class TrackedLoggingDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialState_NoInputFields() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        guard let dataSource = buildDataSource() else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return
        }
        
        // Must log at least one item
        XCTAssertFalse(dataSource.allAnswersValid())
            
        let expectedItems = ["medA2", "medB1", "medC1"]
        XCTAssertEqual(dataSource.sections.count, 2)

        guard let section = dataSource.sections.first else {
            XCTFail("Failed to build sections. Exiting.")
            return
        }
        
        XCTAssertEqual(section.tableItems.count, expectedItems.count)
        let uuid = dataSource.itemGroup(at: IndexPath(row: 0, section: 0))?.uuid
        XCTAssertNotNil(uuid)
        
        for (ii, itemIdentifier) in expectedItems.enumerated() {
            
            let indexPath = IndexPath(row: ii, section: 0)
            
            if let tableItem = dataSource.tableItem(at: indexPath) as? RSDTrackedLoggingTableItem {
                XCTAssertEqual(tableItem.indexPath, indexPath, "\(ii)")
                XCTAssertNil(tableItem.loggedDate, "\(ii)")
                XCTAssertEqual(tableItem.identifier, itemIdentifier, "\(ii)")
            } else {
                XCTFail("item nil or not expected class at \(indexPath) \(ii)")
            }
            
            if let tableGroup = dataSource.itemGroup(at: indexPath) {
                XCTAssertEqual(uuid, tableGroup.uuid, "\(ii)")
            } else {
                XCTFail("item nil at \(indexPath) \(ii)")
            }
        }
        
        let selectionIndexPath = IndexPath(row: 0, section: 1)
        let itemGroup = dataSource.itemGroup(at: selectionIndexPath)
        XCTAssertNotNil(itemGroup)
        
        if let tableItem = dataSource.tableItem(at: selectionIndexPath) as? RSDModalStepTableItem {
            XCTAssertEqual(tableItem.identifier, "addMore")
            XCTAssertEqual(tableItem.action.buttonTitle, "Edit Items")
        } else {
            XCTFail("item nil or not expected class at \(selectionIndexPath)")
        }
    }
    
    func testItemLogged_NoInputFields() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        guard let dataSource = buildDataSource() else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return
        }

        let indexPath = IndexPath(row: 2, section: 0)
        guard let choiceItem = dataSource.tableItem(at: indexPath) as? RSDChoiceTableItem else {
            XCTFail("Failed to get expected table item. Exiting.")
            return
        }
        
        XCTAssertEqual(choiceItem.choice.answerValue as? String, "medC1")
        XCTAssertEqual(choiceItem.reuseIdentifier, "logging")
        
        /// Loop through twice. Item should remain selected.
        for _ in 1...2 {
            
            select(indexPath: indexPath, with: dataSource)
            
            guard let result = dataSource.taskPath.result.findResult(with: dataSource.step.identifier) as? RSDCollectionResult
                else {
                    XCTFail("Failed to get expected result. \(dataSource.taskPath.result)")
                    return
            }
            
            let loggedResult = result.findResult(with: "medC1") as? RSDTrackedLoggingResultObject
            XCTAssertNotNil(loggedResult)
            XCTAssertNotNil(loggedResult?.loggedDate)
            
            let medA2Result = result.findResult(with: "medA2")
            XCTAssertNotNil(medA2Result)
            XCTAssertNil((medA2Result as? RSDTrackedLoggingResultObject)?.loggedDate)
            
            let medB1Result = result.findResult(with: "medB1")
            XCTAssertNotNil(medB1Result)
            XCTAssertNil((medB1Result as? RSDTrackedLoggingResultObject)?.loggedDate)
        }
    }
    
    func testAddMore_NoInputFields() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        guard let dataSource = buildDataSource() as? (RSDModalStepDataSource & RSDModalStepTaskControllerDelegate & RSDTrackingDataSource)
            else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return
        }
        
        // Log one of the items
        let loggedIndexPath = IndexPath(row: 2, section: 0)
        select(indexPath: loggedIndexPath, with: dataSource)
        
        addMore(dataSource, ["medA2", "medB1", "medC1"], ["medC4"], [], ["medA2", "medB1", "medC1", "medC4"], ["medC1"], [3], [])
        addMore(dataSource, ["medA2", "medB1", "medC1", "medC4"], ["medA1"], ["medA2", "medB1"], ["medA1", "medC1", "medC4"], ["medC1"], [0], [0,1])
        addMore(dataSource, ["medA1", "medC1", "medC4"], [], ["medA1", "medC4"], ["medC1"], ["medC1"], [], [0,2])
    }
    
    func addMore(_ dataSource: (RSDModalStepDataSource & RSDModalStepTaskControllerDelegate & RSDTrackingDataSource), _ initialIdentifiers: Set<String>, _ addIdentifiers: Set<String>, _ removeIdentifiers: Set<String>, _ expectedIdentifiers: Set<String>, _ previouslyLogged: [String], _ expectedAdded: Set<Int>, _ expectedRemoved: Set<Int>) {

        // Then edit the selection state
        let indexPath = IndexPath(row: 0, section: 1)
        guard let tableItem = dataSource.tableItem(at: indexPath) as? RSDModalStepTableItem else {
            XCTFail("Failed to get expected table item. Exiting.")
            return
        }
        
        let step = dataSource.step(for: tableItem)
        XCTAssertEqual(step.identifier, "selection")
        
        guard let selectionStep = step as? RSDTrackedSelectionStepObject,
            let selectionResult = selectionStep.result else {
            XCTFail("Failed to get expected step type for the selection step. Exiting.")
            return
        }
        
        XCTAssertEqual(Set(selectionResult.selectedIdentifiers), initialIdentifiers)
        
        let items = selectionStep.items
        let stepController = TestStepController()
        stepController.step = step
        
        dataSource.willPresent(stepController, from: tableItem)
        
        XCTAssertNotNil(stepController.taskController)
        
        guard let taskController = stepController.taskController as? RSDModalStepTaskController,
            let taskPath = taskController.taskPath else {
            XCTFail("Failed to set task path. Exiting.")
            return
        }
        
        XCTAssertEqual(taskPath.currentStep?.identifier, step.identifier)
        XCTAssertTrue(taskPath.isFirstStep)
        XCTAssertEqual(taskPath.childPaths.count, 0)
        XCTAssertNil(taskPath.parentPath)
        XCTAssertNotNil(taskPath.task)
        
        let testDelegate = TestDataSourceDelegate()
        dataSource.delegate = testDelegate
        
        var stepResult = selectionResult.copy(with: step.identifier)
        var selectedIdentifiers = stepResult.selectedIdentifiers
        selectedIdentifiers.append(contentsOf: addIdentifiers)
        selectedIdentifiers.remove(where: { removeIdentifiers.contains($0) })
        
        stepResult.updateSelected(to: selectedIdentifiers, with: items)
        taskPath.appendStepHistory(with: stepResult)
        
        // validate assumptions
        XCTAssertEqual(Set(selectedIdentifiers), expectedIdentifiers)
        XCTAssertEqual(Set(stepResult.selectedIdentifiers), expectedIdentifiers)
        
        dataSource.goForward(with: taskController)
        
        XCTAssertTrue(testDelegate.didFinishWith_called)
        XCTAssertTrue(testDelegate.tableDataSourceWillBeginUpdate_called)
        if let added = testDelegate.tableDataSourceDidEndUpdate_added?.map({ $0.row }),
            let removed = testDelegate.tableDataSourceDidEndUpdate_removed?.map({ $0.row }) {
            XCTAssertEqual(Set(added), expectedAdded)
            XCTAssertEqual(Set(removed), expectedRemoved)
        } else {
            XCTFail("tableDataSourceDidEndUpdate not called")
        }
        
        let currentResult = dataSource.taskPath.result.findResult(with: dataSource.step.identifier)
        XCTAssertNotNil(currentResult)
        guard let loggedResult = currentResult as? RSDTrackedItemsResult else {
            XCTFail("Result not of expected type")
            return
        }
        
        XCTAssertEqual(Set(loggedResult.selectedIdentifiers), expectedIdentifiers)
        
        guard let collectionResult = loggedResult as? RSDCollectionResult
            else {
                XCTFail("Failed to get expected result. \(dataSource.taskPath.result)")
                return
        }
        
        for identifier in expectedIdentifiers {
            let itemResult = collectionResult.findResult(with: identifier) as? RSDTrackedLoggingResultObject
            XCTAssertNotNil(itemResult)
            if previouslyLogged.contains(identifier) {
                XCTAssertNotNil(itemResult?.loggedDate)
            } else {
                XCTAssertNil(itemResult?.loggedDate)
            }
        }
    }
    
    
    // Helper methods
    
    func select(indexPath: IndexPath, with dataSource: RSDTableDataSource) {
        
        guard let choiceItem = dataSource.tableItem(at: indexPath) as? RSDChoiceTableItem else {
            XCTFail("Failed to get expected table item. Exiting.")
            return
        }
        
        do {
            // Select the answer
            let (selected, _) = try dataSource.selectAnswer(item: choiceItem, at: indexPath)
            XCTAssertTrue(selected)
            
        } catch let err {
            XCTFail("Failed to select/deselect answer. \(err)")
        }
    }
    
    func buildDataSource() -> RSDTableDataSource? {
        let (items, sections) = buildMedicationItems()
        let tracker = RSDTrackedItemsStepNavigator(items: items, sections: sections)
        var result = RSDTrackedItemsResultObject(identifier: "selection")
        result.items = ["medA2", "medB1", "medC1"].map { RSDIdentifier(rawValue: $0) }
        tracker.previousResult = result
        
        let task = RSDTaskObject(identifier: "loggingTest", stepNavigator: tracker)
        let taskPath = RSDTaskPath(task: task)
        
        let step = RSDTrackedItemsLoggingStepObject(identifier: "logging", items: items, sections: sections)
        step.actions = [ .navigation(.addMore) : RSDUIActionObject(buttonTitle: "Edit Items") ]
        step.result = result

        guard let dataSource = step.instantiateDataSource(with: taskPath, for: [.logging, .list, .textfield]) else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return nil
        }
        return dataSource
    }
}

class TestDataSourceDelegate : NSObject, RSDTableDataSourceDelegate {

    var answersDidChange_section: Int?
    var didFinishWith_called: Bool = false
    var tableDataSourceWillBeginUpdate_called: Bool = false
    var tableDataSourceDidEndUpdate_added: [IndexPath]?
    var tableDataSourceDidEndUpdate_removed: [IndexPath]?
    
    func tableDataSource(_ dataSource: RSDTableDataSource, didChangeAnswersIn section: Int) {
        answersDidChange_section = section
    }
    
    func tableDataSource(_ dataSource: RSDTableDataSource, didFinishWith stepController: RSDStepController) {
        didFinishWith_called = true
    }
    
    func tableDataSourceWillBeginUpdate(_ dataSource: RSDTableDataSource) {
        tableDataSourceWillBeginUpdate_called = true
    }
    
    func tableDataSourceDidEndUpdate(_ dataSource: RSDTableDataSource, addedRows: [IndexPath], removedRows: [IndexPath]) {
        tableDataSourceDidEndUpdate_added = addedRows
        tableDataSourceDidEndUpdate_removed = removedRows
    }
}
