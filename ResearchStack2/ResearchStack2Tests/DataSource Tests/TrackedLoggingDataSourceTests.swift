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
        XCTAssertEqual(dataSource.sections.count, 1)

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
        
        do {
            // Select the answer
            let (selected, _) = try dataSource.selectAnswer(item: choiceItem, at: indexPath)
            XCTAssertTrue(selected)
            
            if let result = dataSource.taskPath.result.findResult(with: dataSource.step.identifier) as? RSDCollectionResult,
                let loggedResult = result.findResult(with: "medC1") as? RSDTrackedLoggingResultObject {
                XCTAssertNotNil(loggedResult.loggedDate)
            } else {
                XCTFail("Failed to get expected result. \(dataSource.taskPath.result)")
            }

            // Do it again - answer should remain selected.
            let (selected2, _) = try dataSource.selectAnswer(item: choiceItem, at: indexPath)
            XCTAssertTrue(selected2)

        } catch let err {
            XCTFail("Failed to select/deselect answer. \(err)")
        }
    }
    
    // Helper methods
    
    func buildDataSource() -> RSDTableDataSource? {
        let (items, sections) = buildMedicationItems()
        let tracker = RSDTrackedItemsStepNavigator(items: items, sections: sections)
        var result = RSDTrackedItemsResultObject(identifier: "selection")
        result.items = ["medA2", "medB1", "medC1"].map { RSDIdentifier(rawValue: $0) }
        tracker.previousResult = result
        
        let task = RSDTaskObject(identifier: "loggingTest", stepNavigator: tracker)
        let taskPath = RSDTaskPath(task: task)
        
        let step = RSDTrackedItemsLoggingStepObject(identifier: "logging", items: items, sections: sections)
        step.result = result

        guard let dataSource = step.instantiateDataSource(with: taskPath, for: [.logging, .list, .textfield]) else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return nil
        }
        return dataSource
    }
}
