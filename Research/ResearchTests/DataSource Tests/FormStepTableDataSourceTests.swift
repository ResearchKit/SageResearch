//
//  FormStepTableDataSourceTests.swift
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

@available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
class FormStepTableDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBuildSections_List() {

        let json = """
              {
              "identifier": "selectOne",
              "type": "form",
              "inputFields": [{
                  "uiHint": "list",
                  "type": "singleChoice",
                  "choices": ["Alfa", "Bravo", "Charlie", "Delta", "Echo"]
                }]
              }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(for: json) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }
        
        XCTAssertEqual(dataSource.sections.count, 1)
        XCTAssertEqual(dataSource.itemGroups.count, 1)
        XCTAssertEqual(dataSource.sections.first?.rowCount(), 5)
        
        guard let tableItem = dataSource.sections.last?.tableItems.last else {
            XCTFail("Failed to build item group. Exiting")
            return
        }

        for ii in 0..<5 {
            XCTAssertNotNil(dataSource.tableItem(at: IndexPath(row: ii, section: 0)))
        }
        
        XCTAssertNotNil(dataSource.itemGroup(at: IndexPath(row: 4, section: 0)))
        XCTAssertEqual(dataSource.nextItem(after: IndexPath(row: 0, section: 0))?.rowIndex, 1)
        XCTAssertEqual(tableItem.indexPath, IndexPath(row: 4, section: 0))
        XCTAssertFalse(dataSource.allAnswersValid())
        
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 0)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 0)) {
            XCTAssertEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
    }
    
    func testBuildSections_MultipleItemGroups() {
        
        let json = """
              {
              "identifier": "multipleInputs",
              "type": "form",
              "title": "Pick some values",
              "detail": "These inputs use a picker view to select the answer.",
              "inputFields": [{
                              "identifier": "date",
                              "type": "date",
                              "uiHint": "picker",
                              "prompt": "Pick a date in the future",
                              "range": {
                                  "allowPast": false,
                                  "codingFormat": "yyyy-MM-dd"
                                  }
                              },
                              {
                              "identifier": "number",
                              "type": "integer",
                              "prompt": "Pick a number between -2 and +3",
                              "uiHint": "picker",
                              "range" : {   "minimumValue" : -2,
                                            "maximumValue" : 3,
                                            "stepInterval" : 1}
                              },
                              {
                              "identifier": "multipleComponent",
                              "type": "multipleComponent",
                              "prompt": "Pick a combination of colors and animals",
                              "choices" : [["blue", "red", "green", "yellow"], ["dog", "cat", "rat", "duck"]]
                              },
                              {
                              "identifier": "duration",
                              "type": "duration",
                              "prompt": "Pick a time interval"
                              },
                              {
                              "identifier": "selectOne",
                              "uiHint": "list",
                              "type": "singleChoice",
                              "choices": ["Alfa", "Bravo", "Charlie", "Delta"]
                              }
                              ]
              }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(for: json) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }
        
        XCTAssertEqual(dataSource.sections.count, 2)
        XCTAssertEqual(dataSource.itemGroups.count, 5)
        XCTAssertEqual(dataSource.sections.first?.rowCount(), 4)
        XCTAssertEqual(dataSource.sections.last?.rowCount(), 4)
        XCTAssertFalse(dataSource.allAnswersValid())

        guard dataSource.itemGroups.count == 5,
            dataSource.sections.count == 2,
            dataSource.sections[0].tableItems.count == 4,
            dataSource.sections[1].tableItems.count == 4
            else {
                XCTFail("Failed to build item group. Exiting")
            return
        }
        
        for ii in 0..<4 {
            XCTAssertEqual(dataSource.itemGroups[ii].beginningRowIndex, ii)
            XCTAssertEqual(dataSource.itemGroups[ii].sectionIndex, 0)
        }
        XCTAssertEqual(dataSource.itemGroups[4].beginningRowIndex, 0)
        XCTAssertEqual(dataSource.itemGroups[4].sectionIndex, 1)
        
        for sectionIdx in 0..<2 {
            for ii in 0..<4 {
                let expectedItem = dataSource.sections[sectionIdx].tableItems[ii]
                let indexPath = IndexPath(row: ii, section: sectionIdx)
                XCTAssertEqual(expectedItem.indexPath, indexPath)
                XCTAssertNotNil(dataSource.itemGroup(at: indexPath), "\(indexPath)")
                if let tableItem = dataSource.tableItem(at: indexPath) {
                    XCTAssertEqual(tableItem.indexPath, indexPath)
                } else {
                    XCTFail("item group nil at \(indexPath)")
                }
            }
        }
        
        // First section has unique item groups for each row
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 0)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 0)) {
            XCTAssertNotEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
        // Second section does *not* have unique item groups for each row
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 1)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 1)) {
            XCTAssertEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
        
        // Test nextItem
        if let item = dataSource.nextItem(after: IndexPath(row: 0, section: 0)) {
            XCTAssertEqual(item.rowIndex, 1)
            XCTAssertEqual(item.sectionIndex, 0)
        } else {
            XCTFail("item nil")
        }
        if let item = dataSource.nextItem(after: IndexPath(row: 3, section: 0)) {
            XCTAssertEqual(item.rowIndex, 0)
            XCTAssertEqual(item.sectionIndex, 1)
        } else {
            XCTFail("item nil")
        }
        XCTAssertNil(dataSource.nextItem(after: IndexPath(row: 3, section: 1)))
    }
    
    func testSelection_SingleChoiceWithNil() {
        let choices = [try! RSDChoiceObject<Int>(value: 0, text: "one"),
                       try! RSDChoiceObject<Int>(value: 1, text: "two"),
                       try! RSDChoiceObject<Int>(value: 2, text: "three"),
                       try! RSDChoiceObject<Int>(value: nil, text: "none")]
        let inputField = RSDChoiceInputFieldObject(identifier: "foo", choices: choices, dataType: .collection(.singleChoice, .integer))
        inputField.isOptional = false
        let formStep = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField])
        let dataSource = RSDFormStepDataSourceObject(step: formStep, parent: nil)
        
        XCTAssertEqual(dataSource.itemGroups.count, 1)
        guard let itemGroup = dataSource.itemGroups.first as? RSDChoicePickerTableItemGroup,
            let tableItem = itemGroup.items.last
            else {
                XCTFail("Failed to create expected type. \(dataSource.itemGroups)")
                return
        }
        
        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: IndexPath(row: 3, section: 0))
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let aResult = dataSource.collectionResult().inputResults.first as? RSDAnswerResult
            else {
                XCTFail("Failed to add answer result")
                return
        }
        
        // But the answer result should use a nil value.
        XCTAssertNil(aResult.value)
    }
    
    func testSelection_SingleChoiceWithValueSelected() {
        let choices = [try! RSDChoiceObject<Int>(value: 0, text: "one"),
                       try! RSDChoiceObject<Int>(value: 1, text: "two"),
                       try! RSDChoiceObject<Int>(value: 2, text: "three"),
                       try! RSDChoiceObject<Int>(value: nil, text: "none")]
        let inputField = RSDChoiceInputFieldObject(identifier: "foo", choices: choices, dataType: .collection(.singleChoice, .integer))
        inputField.isOptional = false
        let formStep = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField])
        let dataSource = RSDFormStepDataSourceObject(step: formStep, parent: nil)
        
        XCTAssertEqual(dataSource.itemGroups.count, 1)
        guard let itemGroup = dataSource.itemGroups.first as? RSDChoicePickerTableItemGroup,
            let tableItem = itemGroup.items.first
            else {
                XCTFail("Failed to create expected type. \(dataSource.itemGroups)")
                return
        }
        
        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: IndexPath(row: 0, section: 0))
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let aResult = dataSource.collectionResult().inputResults.first as? RSDAnswerResult
            else {
                XCTFail("Failed to add answer result")
                return
        }
        
        // But the answer result should use a nil value.
        XCTAssertEqual(aResult.value as? Int, 0)
    }
    
    func testBuildSections_SingleChoiceWithNil_DefaultValue() {
        let choices = [try! RSDChoiceObject<Int>(value: 0, text: "one"),
                       try! RSDChoiceObject<Int>(value: 1, text: "two"),
                       try! RSDChoiceObject<Int>(value: 2, text: "three"),
                       try! RSDChoiceObject<Int>(value: nil, text: "none")]
        let inputField = RSDChoiceInputFieldObject(identifier: "foo", choices: choices, dataType: .collection(.singleChoice, .integer),uiHint: nil, prompt: nil, defaultAnswer: 0)
        inputField.isOptional = false
        let formStep = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField])
        let dataSource = RSDFormStepDataSourceObject(step: formStep, parent: nil)
        
        XCTAssertEqual(dataSource.itemGroups.count, 1)
        guard let itemGroup = dataSource.itemGroups.first as? RSDChoicePickerTableItemGroup,
            let tableItem = itemGroup.items.first as? RSDChoiceTableItem
            else {
                XCTFail("Failed to create expected type. \(dataSource.itemGroups)")
                return
        }
        
        // Before selecting an answer because there is a default answer that has been set,
        // it should be valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        XCTAssertTrue(tableItem.selected)
        
        guard let aResult = dataSource.collectionResult().inputResults.first as? RSDAnswerResult
            else {
                XCTFail("Failed to add answer result")
                return
        }
        
        // But the answer result should use a nil value.
        XCTAssertEqual(aResult.value as? Int, 0)
    }
    
    // Helper methods
    
    func createDataSource(for json: Data, with initialResult: RSDCollectionResult? = nil) -> RSDFormStepDataSourceObject? {
        
        do {
            let step = try decoder.decode(RSDFormUIStepObject.self, from: json)
            let navigator = RSDConditionalStepNavigatorObject(with: [step])
            let task = RSDTaskObject(identifier: "test", stepNavigator: navigator)
            let taskViewModel = RSDTaskViewModel(task: task)
            if let result = initialResult {
                taskViewModel.taskResult.appendStepHistory(with: result)
            }
            taskViewModel.taskResult.appendStepHistory(with: step.instantiateStepResult())
            return RSDFormStepDataSourceObject(step: step, parent: taskViewModel)
        } catch let err {
            XCTFail("Failed to decode the step. \(err)")
            return nil
        }
    }
}
