//
//  TrackedSelectionDataSourceTests.swift
//  ResearchSuite
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

class TrackedSelectionDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialSelection() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        guard let dataSource = buildDataSource() else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return
        }
        
        // Must select at least one item
        XCTAssertFalse(dataSource.allAnswersValid())
        
        let expectedCounts = [3,3,3,3,2,1]
        XCTAssertEqual(dataSource.sections.count, expectedCounts.count)
        
        guard dataSource.sections.count == expectedCounts.count else {
            XCTFail("Failed to build sections. Exiting.")
            return
        }

        for (sectionIdx, rowCount) in expectedCounts.enumerated() {
            
            XCTAssertEqual(dataSource.sections[sectionIdx].tableItems.count, rowCount)
            let uuid = dataSource.itemGroup(at: IndexPath(row: 0, section: sectionIdx))?.uuid
            XCTAssertNotNil(uuid)
            
            for ii in 0..<rowCount {
                
                let expectedItem = dataSource.sections[sectionIdx].tableItems[ii]
                let indexPath = IndexPath(row: ii, section: sectionIdx)
                XCTAssertEqual(expectedItem.indexPath, indexPath)

                if let tableItem = dataSource.tableItem(at: indexPath) {
                    XCTAssertEqual(tableItem.indexPath, indexPath)
                } else {
                    XCTFail("item nil at \(indexPath)")
                }
                
                if let tableGroup = dataSource.itemGroup(at: indexPath) {
                    XCTAssertEqual(uuid, tableGroup.uuid)
                } else {
                    XCTFail("item nil at \(indexPath)")
                }
                
                if sectionIdx + 1 < expectedCounts.count || ii + 1 < rowCount {
                    XCTAssertNotNil(dataSource.nextItem(after: indexPath))
                } else {
                    XCTAssertNil(dataSource.nextItem(after: indexPath))
                }
            }
        }
    }
    
    func testSelectAnswer() {
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
        do {
            // Select the answer
            try dataSource.selectAnswer(item: choiceItem, at: indexPath)
            if let result = dataSource.taskPath.result.findResult(with: dataSource.step.identifier) as? RSDTrackedItemsResult {
                XCTAssertEqual(result.selectedIdentifiers, ["medC1"])
            } else {
                XCTFail("Failed to get expected result. \(dataSource.taskPath.result)")
            }
            
            // Deselect the answer
            try dataSource.selectAnswer(item: choiceItem, at: indexPath)
            if let result = dataSource.taskPath.result.findResult(with: dataSource.step.identifier) as? RSDTrackedItemsResult {
                XCTAssertEqual(result.selectedIdentifiers, [])
            } else {
                XCTFail("Failed to get expected result. \(dataSource.taskPath.result)")
            }
            
        } catch let err {
            XCTFail("Failed to select/deselect answer. \(err)")
        }
    }
    
    // Helper methods
    
    func buildDataSource() -> RSDTableDataSource? {
        let (items, sections) = buildMedicationItems()
        let medTracker = RSDMedicationTrackingStepNavigator(items: items, sections: sections)
        let task = RSDTaskObject(identifier: "medication", stepNavigator: medTracker)
        let taskPath = RSDTaskPath(task: task)
        
        guard let selectionStep = medTracker.selectionStep as? RSDTrackedSelectionStepObject else {
            XCTFail("Selection step not of expected type. Exiting.")
            return nil
        }
        guard let dataSource = selectionStep.instantiateDataSource(with: taskPath, for: [.list]) else {
            XCTFail("Failed to instantiate the data source. Exiting.")
            return nil
        }
        return dataSource
    }
}
