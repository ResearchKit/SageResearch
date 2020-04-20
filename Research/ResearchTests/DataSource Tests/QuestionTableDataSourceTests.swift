//
//  QuestionTableDataSourceTests.swift
//  ResearchTests_iOS
//
//  Copyright © 2018-2020 Sage Bionetworks. All rights reserved.
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

class QuestionTableDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBuildSections_StringChoice() {
        let json = """
            {
                 "identifier": "selectOne",
                 "type": "stringChoiceQuestion",
                 "title": "Hello World!",
                 "uiHint": "list",
                 "optional": false,
                 "choices":["Alfa", "Bravo", "Charlie", "Delta", "Echo"]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }
        
        XCTAssertEqual(dataSource.sections.count, 1)
        XCTAssertEqual(dataSource.sections.first?.rowCount(), 5)
        
        guard let tableItem = dataSource.sections.last?.tableItems.last else {
            XCTFail("Failed to build item group. Exiting")
            return
        }

        for ii in 0..<5 {
            let item = dataSource.tableItem(at: IndexPath(row: ii, section: 0))
            XCTAssertNotNil(item)
            XCTAssertTrue(item is ChoiceInputItemTableItem)
        }
        
        XCTAssertNotNil(dataSource.itemGroup(at: IndexPath(row: 4, section: 0)))
        XCTAssertEqual(dataSource.nextItem(after: IndexPath(row: 0, section: 0))?.rowIndex, 1)
        XCTAssertEqual(tableItem.indexPath, IndexPath(row: 4, section: 0))
        
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 0)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 0)) {
            XCTAssertEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
    }
    
    func testBuildSections_SimpleQuestion() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "simpleQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItem":{"type" : "year"},
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }
        
        XCTAssertEqual(dataSource.sections.count, 1)
        XCTAssertEqual(dataSource.sections.first?.rowCount(), 2)
        
        guard let textItem = dataSource.sections.first?.tableItems.first,
            let checkboxItem = dataSource.sections.last?.tableItems.last else {
            XCTFail("Failed to build item group. Exiting")
            return
        }

        XCTAssertEqual(textItem.indexPath, IndexPath(row: 0, section: 0))
        XCTAssertTrue(textItem is TextInputItemTableItem)
        
        XCTAssertEqual(checkboxItem.indexPath, IndexPath(row: 1, section: 0))
        XCTAssertTrue(checkboxItem is ChoiceInputItemTableItem)
        
        XCTAssertNotNil(dataSource.itemGroup(at: IndexPath(row: 1, section: 0)))
        XCTAssertEqual(dataSource.nextItem(after: IndexPath(row: 0, section: 0))?.rowIndex, 1)
        
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 0)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 0)) {
            XCTAssertEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
    }
    
    func testBuildSections_MultipleInputQuestion() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "multipleInputQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItems":[{"type" : "year"},{"type":"string"}],
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }
        
        XCTAssertEqual(dataSource.sections.count, 1)
        XCTAssertEqual(dataSource.sections.first?.rowCount(), 3)
        
        guard let textItem = dataSource.sections.first?.tableItems.first,
            let checkboxItem = dataSource.sections.last?.tableItems.last else {
            XCTFail("Failed to build item group. Exiting")
            return
        }

        XCTAssertEqual(textItem.indexPath, IndexPath(row: 0, section: 0))
        XCTAssertTrue(textItem is TextInputItemTableItem)
        
        XCTAssertEqual(checkboxItem.indexPath, IndexPath(row: 2, section: 0))
        XCTAssertTrue(checkboxItem is ChoiceInputItemTableItem)
        
        XCTAssertNotNil(dataSource.itemGroup(at: IndexPath(row: 2, section: 0)))
        XCTAssertEqual(dataSource.nextItem(after: IndexPath(row: 0, section: 0))?.rowIndex, 1)
        
        if let itemGroup0 = dataSource.itemGroup(at: IndexPath(row: 0, section: 0)),
            let itemGroup1 = dataSource.itemGroup(at: IndexPath(row: 1, section: 0)) {
            XCTAssertEqual(itemGroup0.uuid, itemGroup1.uuid)
        } else {
            XCTFail("item group nil")
        }
    }
    
    // MARK: Single Choice
    
    func testSelection_SingleChoice_NilSelected() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": true,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
        
        let indexPath = IndexPath(row: 3, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertTrue(aResult.value is NSNull)
    }
    
    func testSelection_SingleChoice_NonNilSelected() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": true,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? Int, 1)
    }
    
    func testSelection_SingleChoice_InitialResult() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": true,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .integer(2))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let initialItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        XCTAssertTrue(initialItem.selected)
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertFalse(initialItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? Int, 1)
    }
    
    // MARK: Multiple Choice
    
    func testSelection_MultipleChoice_NilSelected() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
        
        let indexPath = IndexPath(row: 3, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer should be empty
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? [Int], [])
    }
    
    func testSelection_MultipleChoice_NonNilSelected() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        guard let dataSource = createDataSource(json: json, initialResult: nil) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Before selecting an answer because the input field is *not* optional, the answer is
        // not valid.
        XCTAssertFalse(dataSource.allAnswersValid())
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? [Int], [1])
    }
    
    func testSelection_MultipleChoice_InitialResult() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .array([2]))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let initialItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        XCTAssertTrue(initialItem.selected)
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertTrue(initialItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? [Int], [1,2])
    }
    
    func testSelection_MultipleChoice_InitialResult_NoneSelected() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "baseType": "integer",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .array([]))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let initialItem = dataSource.tableItem(at: IndexPath(row: 3, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        XCTAssertTrue(initialItem.selected)
        
        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableItem = dataSource.tableItem(at: indexPath) else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
                
        do {
            let _ = try dataSource.selectAnswer(item: tableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertFalse(initialItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? [Int], [1])
    }
    
    // Simple Question
    
    func testSelection_SimpleQuestion_InitialResult() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "simpleQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItem":{"type" : "year"},
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .integer(2020))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let textItem = dataSource.tableItem(at: IndexPath(row: 0, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let checkboxItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        
        XCTAssertTrue(textItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        let indexPath = IndexPath(row: 0, section: 0)
        do {
            let _ = try dataSource.saveAnswer("2019", at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertTrue(textItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? Int, 2019)
    }
    
    func testSelection_SimpleQuestion_InitialResult_SelectSkip() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "simpleQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItem":{"type" : "year"},
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .integer(2020))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let textItem = dataSource.tableItem(at: IndexPath(row: 0, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let checkboxItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        
        XCTAssertTrue(textItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        let indexPath = IndexPath(row: 1, section: 0)
        do {
            let _ = try dataSource.selectAnswer(item: checkboxItem as! RSDTableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertFalse(textItem.selected)
        XCTAssertTrue(checkboxItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? NSNull, NSNull())
        
        // Toggle off skip checkbox
        do {
            let _ = try dataSource.selectAnswer(item: checkboxItem as! RSDTableItem, at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertTrue(textItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        XCTAssertNotNil(aResult.value)
        XCTAssertEqual(aResult.value as? Int, 2020)
    }
    
    // Multiple Input Question
    
    func testSelection_MultipleInputQuestion_InitialResult() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "multipleInputQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItems":[{"type":"year","identifier":"year"},{"type":"string","identifier":"string"}],
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .object(["year":2020,"string":"boo"]))
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let yearItem = dataSource.tableItem(at: IndexPath(row: 0, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let stringItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let checkboxItem = dataSource.tableItem(at: IndexPath(row: 2, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        
        XCTAssertTrue(yearItem.selected)
        XCTAssertTrue(stringItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        let indexPath = IndexPath(row: 0, section: 0)
        do {
            let _ = try dataSource.saveAnswer("2019", at: indexPath)
        } catch let err {
            XCTFail("Failed to select item group. \(err)")
        }
        
        XCTAssertTrue(yearItem.selected)
        XCTAssertTrue(stringItem.selected)
        XCTAssertFalse(checkboxItem.selected)
        
        // After an answer has been selected, then the result is valid. This should be true even
        // if the answer result value is nil.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        let aResult = dataSource.itemGroup.answerResult
        
        // But the answer result should use a nil value.
        XCTAssertEqual(aResult.jsonValue, .object(["year":2019,"string":"boo"]))
    }
    
    func testSelection_MultipleInputQuestion_InitialResultNull() {
        let json = """
            {
                 "identifier": "foo",
                 "type": "multipleInputQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItems":[{"type":"year","identifier":"year"},{"type":"string","identifier":"string"}],
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"}
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        let initialResult = AnswerResultObject(identifier: "foo", value: .null)
        guard let dataSource = createDataSource(json: json, initialResult: initialResult) else {
            XCTFail("Failed to decode the step. Exiting.")
            return
        }

        // Has initial result therefore answers are valid.
        XCTAssertTrue(dataSource.allAnswersValid())
        
        guard let yearItem = dataSource.tableItem(at: IndexPath(row: 0, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let stringItem = dataSource.tableItem(at: IndexPath(row: 1, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        guard let checkboxItem = dataSource.tableItem(at: IndexPath(row: 2, section: 0)) as? InputItemState else {
            XCTFail("Failed to build item group. Exiting")
            return
        }
        
        XCTAssertFalse(yearItem.selected)
        XCTAssertFalse(stringItem.selected)
        XCTAssertTrue(checkboxItem.selected)
    }
    
    // Helper methods
    
    func createDataSource(json: Data, initialResult: AnswerResultObject?) -> QuestionStepDataSource? {
        do {
            let wrapper = try decoder.decode(QuestionWrapper.self, from: json)
            let step = wrapper.questionStep
            let task = AssessmentTaskObject(identifier: "test", steps: [step])
            let taskViewModel = RSDTaskViewModel(task: task)
            if let result = initialResult {
                taskViewModel.append(previousResult: result)
            }
            taskViewModel.taskResult.appendStepHistory(with: step.instantiateStepResult())
            return QuestionStepDataSource(step: step, parent: taskViewModel)
         } catch let err {
             XCTFail("Failed to decode the step. \(err)")
             return nil
         }
    }
    
    struct QuestionWrapper : Decodable {
        let questionStep : QuestionStep
        init(from decoder: Decoder) throws {
            let step = try decoder.factory.decodePolymorphicObject(RSDStep.self, from: decoder)
            guard let qStep = step as? QuestionStep else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode a QuestionStep")
                throw DecodingError.typeMismatch(QuestionStep.self, context)
            }
            self.questionStep = qStep
        }
    }
}
