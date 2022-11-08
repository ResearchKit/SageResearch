//
//  PickerDataSourceTests.swift
//  Research
//

import XCTest
@testable import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
class PickerDataSourceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
    }
    
    override func tearDown() {
        NSLocale.setCurrentTest(nil)
        super.tearDown()
    }
    
    func testHeightPicker() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let picker = RSDUSHeightPickerDataSourceObject()
        
        XCTAssertEqual(picker.converter.baseUnit, .centimeters)
        XCTAssertEqual(picker.numberOfComponents, 2)
        XCTAssertEqual(picker.numberOfRows(in: 0), 8)
        XCTAssertEqual(picker.numberOfRows(in: 1), 12)
        
        let choice = picker.choice(forRow: 2, forComponent: 0)
        XCTAssertEqual(choice?.text, "3′")
        
        let selectedAnswer = picker.selectedAnswer(with: [4, 6])
        XCTAssertNotNil(selectedAnswer)
        if let answer = selectedAnswer as? Double {
            XCTAssertEqual(answer, 167.6, accuracy: 0.1)
        } else {
            XCTFail("Failed to decode the answer from the selected rows: \(String(describing: selectedAnswer))")
        }
        
        if let rows = picker.selectedRows(from: 167.64) {
            XCTAssertEqual(rows, [4, 6])
        } else {
            XCTFail("Failed to decode the selected rows from the answer")
        }
        
        let text = picker.textAnswer(from: 167.64)
        XCTAssertEqual(text, "5′ 6″")
    }
    
    func testWeightPicker() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let picker = RSDUSInfantMassPickerDataSourceObject()
        
        XCTAssertEqual(picker.converter.baseUnit, .kilograms)
        XCTAssertEqual(picker.numberOfComponents, 2)
        XCTAssertEqual(picker.numberOfRows(in: 0), 20)
        XCTAssertEqual(picker.numberOfRows(in: 1), 16)
        
        let choice = picker.choice(forRow: 2, forComponent: 0)
        XCTAssertEqual(choice?.text, "3 lb")
        
        let selectedAnswer = picker.selectedAnswer(with: [7, 12])
        XCTAssertNotNil(selectedAnswer)
        if let answer = selectedAnswer as? Double {
            XCTAssertEqual(answer, 3.97, accuracy: 0.01)
        } else {
            XCTFail("Failed to decode the answer from the selected rows: \(String(describing: selectedAnswer))")
        }
        
        if let rows = picker.selectedRows(from: 3.97) {
            XCTAssertEqual(rows, [7, 12])
        } else {
            XCTFail("Failed to decode the selected rows from the answer")
        }
        
        let text = picker.textAnswer(from: 3.97)
        XCTAssertEqual(text, "8 lb, 12 oz")
    }
    
    func testChoiceOptionsPicker() {
        
        let choices = ["dog", "cat", "rat"].enumerated().map { try! RSDChoiceObject(value:$0.offset + 3, text: $0.element) }
        let picker = RSDChoiceOptionsObject(choices: choices, isOptional: false)
        
        XCTAssertEqual(picker.numberOfComponents, 1)
        XCTAssertEqual(picker.numberOfRows(in: 0), 3)
        
        let choice = picker.choice(forRow: 2, forComponent: 0)
        XCTAssertEqual(choice?.text, "rat")
        
        let selectedAnswer = picker.selectedAnswer(with: [1])
        XCTAssertEqual(selectedAnswer as? Int, 1 + 3)
        
        if let rows = picker.selectedRows(from: 0 + 3) {
            XCTAssertEqual(rows, [0])
        } else {
            XCTFail("Failed to decode the selected rows from the answer")
        }
        
        let text = picker.textAnswer(from: 1 + 3)
        XCTAssertEqual(text, "cat")
    }
    
    func testNumberPickerDataSource() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let formatter = NumberFormatter.defaultNumberFormatter(with: 1)
        let picker = RSDNumberPickerDataSourceObject(minimum: -1.0, maximum: 1.0, stepInterval: 0.2, numberFormatter: formatter)
        
        let inputAnswer = Double(0.8)
        
        let numberAnswer = picker.numberAnswer(from: inputAnswer)
        XCTAssertEqual(numberAnswer, Decimal(floatLiteral: 0.8))
        
        let textAnswer = picker.textAnswer(from: inputAnswer)
        XCTAssertEqual(textAnswer, "0.8")
    }
    
    func testTimeIntervalPickerDataSource_MinuteSecond() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let range = RSDDurationRangeObject(durationUnits: [.seconds, .minutes])
        
        // Confirm assumptions about defaults
        XCTAssertEqual(range.baseUnit, .seconds)
        XCTAssertEqual(range.minimumDuration, Measurement(value: 0, unit: UnitDuration.seconds))
        
        guard let picker = RSDDurationPickerDataSourceObject(range: range)
            else {
                XCTFail("Failed to instantiate a picker from the given range")
                return
        }
        
        XCTAssertEqual(picker.numberOfComponents, 2)
        
        // minute field
        XCTAssertEqual(picker.numberOfRows(in: 0), 61)
        XCTAssertEqual(picker.componentChoices[0].first?.answerValue as? Int, 0)
        XCTAssertEqual(picker.componentChoices[0].last?.answerValue as? Int, 60)

        // second field
        XCTAssertEqual(picker.numberOfRows(in: 1), 60)
        XCTAssertEqual(picker.componentChoices[1].first?.answerValue as? Int, 0)
        XCTAssertEqual(picker.componentChoices[1].last?.answerValue as? Int, 59)
        
        let inputAnswer = Double(90)
        let expectedRows = [1, 30]
        let expectedMinutes = 1
        let expectedSeconds = 30
        let expectedText = "01:30"
        
        if let rows = picker.selectedRows(from: inputAnswer) {
            XCTAssertEqual(rows, expectedRows)
            if rows.count == 2 {
                XCTAssertEqual(picker.choice(forRow: rows[0], forComponent: 0)?.answerValue as? Int, expectedMinutes)
                XCTAssertEqual(picker.choice(forRow: rows[1], forComponent: 1)?.answerValue as? Int, expectedSeconds)
            } else {
                XCTFail("Row count does not match expected. \(rows)")
            }
        } else {
            XCTFail("Failed to get the rows for an answer within range")
        }
        
        let textAnswer = picker.textAnswer(from: inputAnswer)
        XCTAssertEqual(textAnswer, expectedText)
        
        XCTAssertEqual(picker.selectedAnswer(with: expectedRows) as? Double, inputAnswer)
    }
    
    func testTimeIntervalPickerDataSource_HourMinute() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let range = RSDDurationRangeObject(durationUnits: [.minutes, .hours])
        
        // Confirm assumptions about defaults
        XCTAssertEqual(range.baseUnit, .minutes)
        XCTAssertEqual(range.minimumDuration, Measurement(value: 0, unit: UnitDuration.minutes))
        
        guard let picker = RSDDurationPickerDataSourceObject(range: range)
            else {
                XCTFail("Failed to instantiate a picker from the given range")
                return
        }
        
        XCTAssertEqual(picker.numberOfComponents, 2)
        
        // hour field
        XCTAssertEqual(picker.numberOfRows(in: 0), 25)
        XCTAssertEqual(picker.componentChoices[0].first?.answerValue as? Int, 0)
        XCTAssertEqual(picker.componentChoices[0].last?.answerValue as? Int, 24)
        
        // minute field
        XCTAssertEqual(picker.numberOfRows(in: 1), 60)
        XCTAssertEqual(picker.componentChoices[1].first?.answerValue as? Int, 0)
        XCTAssertEqual(picker.componentChoices[1].last?.answerValue as? Int, 59)
        
        let inputAnswer = Double(90)
        let expectedRows = [1, 30]
        let expectedHours = 1
        let expectedMinutes = 30
        let expectedText = "01:30"
        
        if let rows = picker.selectedRows(from: inputAnswer) {
            XCTAssertEqual(rows, expectedRows)
            if rows.count == 2 {
                XCTAssertEqual(picker.choice(forRow: rows[0], forComponent: 0)?.answerValue as? Int, expectedHours)
                XCTAssertEqual(picker.choice(forRow: rows[1], forComponent: 1)?.answerValue as? Int, expectedMinutes)
            } else {
                XCTFail("Row count does not match expected. \(rows)")
            }
        } else {
            XCTFail("Failed to get the rows for an answer within range")
        }
        
        let textAnswer = picker.textAnswer(from: inputAnswer)
        XCTAssertEqual(textAnswer, expectedText)
        
        XCTAssertEqual(picker.selectedAnswer(with: expectedRows) as? Double, inputAnswer)
    }
}
