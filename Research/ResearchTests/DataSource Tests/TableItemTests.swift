//
//  TableItemTests.swift
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
import Formatters

@available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
class TableItemTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBloodPressure() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "bloodPressure", dataType: .measurement(.bloodPressure, .adult))
        let itemGroup = RSDHumanMeasurementTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .textfield)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        do {
            try itemGroup.setAnswer("120 / 40")
            XCTAssertEqual(itemGroup.answer as? String, "120 / 40")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
    }
    
    func testNumberTableItem_Decimal() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "number", dataType: .base(.decimal), uiHint: .picker)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        inputField.range = RSDNumberRangeObject(minimumDecimal: -1.5, maximumDecimal: 3.5, stepInterval: 0.5, unit: "foo", formatter: formatter)

        let itemGroup = RSDNumberTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        if let item = itemGroup.items.first as? RSDNumberInputTableItem {
            XCTAssertEqual(item.formatter, formatter)
            XCTAssertEqual(item.answerType.baseType, .decimal)
            XCTAssertEqual(item.answerType.unit, "foo")
            if let picker = item.pickerSource as? RSDNumberPickerDataSource {
                XCTAssertEqual(picker.minimum, -1.5)
                XCTAssertEqual(picker.maximum, 3.5)
                XCTAssertEqual(picker.stepInterval, 0.5)
            } else {
                XCTFail("\(String(describing: item.pickerSource)) not of expected type.")
            }
        } else {
            XCTFail("\(itemGroup.items) not of expected type.")
        }
        
        do {
            try itemGroup.setAnswer("1.36")
            let answer = itemGroup.answer
            XCTAssertEqual((answer as? NSNumber)?.doubleValue, 1.36, "\(String(describing: itemGroup.answer))")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
        
        do {
            try itemGroup.setAnswer("4")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.greaterThanMaximumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
        
        do {
            try itemGroup.setAnswer("-3.123")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.lessThanMinimumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
    
    func testNumberTableItem_Integer() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "number", dataType: .base(.integer), uiHint: .picker)
        let formatter = NumberFormatter()
        inputField.range = RSDNumberRangeObject(minimumDecimal: -1, maximumDecimal: 3, stepInterval: nil, unit: "foo", formatter: formatter)
        
        let itemGroup = RSDNumberTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        if let item = itemGroup.items.first as? RSDNumberInputTableItem {
            XCTAssertEqual(item.formatter, formatter)
            XCTAssertEqual(item.answerType.baseType, .integer)
            XCTAssertEqual(item.answerType.unit, "foo")
            if let picker = item.pickerSource as? RSDNumberPickerDataSource {
                XCTAssertEqual(picker.minimum, -1)
                XCTAssertEqual(picker.maximum, 3)
                XCTAssertNil(picker.stepInterval)
            } else {
                XCTFail("\(String(describing: item.pickerSource)) not of expected type.")
            }
        } else {
            XCTFail("\(itemGroup.items) not of expected type.")
        }
        
        do {
            try itemGroup.setAnswer("1")
            let answer = itemGroup.answer
            XCTAssertEqual((answer as? NSNumber)?.intValue, 1, "\(String(describing: itemGroup.answer))")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
        
        do {
            try itemGroup.setAnswer("4")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.greaterThanMaximumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
        
        do {
            try itemGroup.setAnswer("-3")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.lessThanMinimumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
    
    func testNumberTableItem_Year() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "number", dataType: .base(.year), uiHint: .picker)
        let year1970 = RSDDateCoderObject(rawValue: "yyyy")?.date(from: "1970")
        let yearNow = Calendar.current.component(.year, from: Date())
        inputField.range = RSDDateRangeObject(minimumDate: year1970, maximumDate: nil, allowFuture: false, allowPast: nil)
        
        let itemGroup = RSDNumberTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        if let item = itemGroup.items.first as? RSDNumberInputTableItem {
            XCTAssertEqual(item.answerType.baseType, .integer)
            if let picker = item.pickerSource as? RSDNumberPickerDataSource {
                XCTAssertEqual(picker.minimum, 1970)
                XCTAssertEqual(picker.maximum, Decimal(yearNow))
                XCTAssertNil(picker.stepInterval)
            } else {
                XCTFail("\(String(describing: item.pickerSource)) not of expected type.")
            }
        } else {
            XCTFail("\(itemGroup.items) not of expected type.")
        }
        
        do {
            try itemGroup.setAnswer("1980")
            let answer = itemGroup.answer
            XCTAssertEqual((answer as? NSNumber)?.intValue, 1980, "\(String(describing: itemGroup.answer))")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
        
        do {
            let futureYear = "\(yearNow + 5)"
            try itemGroup.setAnswer(futureYear)
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.greaterThanMaximumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
        
        do {
            try itemGroup.setAnswer("1950")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.lessThanMinimumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
    
    func testNumberTableItem_Fraction() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "number", dataType: .base(.fraction), uiHint: .picker)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 3
        inputField.range = RSDNumberRangeObject(minimumDecimal: -1.5, maximumDecimal: 3.5, stepInterval: 0.5, unit: "foo", formatter: formatter)
        
        let itemGroup = RSDNumberTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        if let item = itemGroup.items.first as? RSDNumberInputTableItem {
            
            XCTAssertEqual(item.answerType.baseType, .decimal)
            XCTAssertEqual(item.answerType.unit, "foo")
            
            if let picker = item.pickerSource as? RSDNumberPickerDataSource {
                XCTAssertEqual(picker.minimum, -1.5)
                XCTAssertEqual(picker.maximum, 3.5)
                XCTAssertEqual(picker.stepInterval, 0.5)
            } else {
                XCTFail("\(String(describing: item.pickerSource)) not of expected type.")
            }
            
            if let fractionFormatter = item.formatter as? RSDFractionFormatter {
                XCTAssertEqual(fractionFormatter.numberFormatter.maximumFractionDigits, 3)
            } else {
                XCTFail("\(String(describing: item.formatter)) not of expected type.")
            }
        } else {
            XCTFail("\(itemGroup.items) not of expected type.")
        }
        
        do {
            try itemGroup.setAnswer("136/100")
            let answer = itemGroup.answer
            XCTAssertEqual((answer as? NSNumber)?.doubleValue, 1.36, "\(String(describing: itemGroup.answer))")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
        
        do {
            try itemGroup.setAnswer("48/2")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.greaterThanMaximumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
        
        do {
            try itemGroup.setAnswer("-312/100")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.lessThanMinimumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
    
    func testNumberTableItem_Duration() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "number", dataType: .base(.duration), uiHint: .picker)
        let min = Measurement(value: 15, unit: UnitDuration.minutes)
        let max = Measurement(value: 5, unit: UnitDuration.hours)
        let range = RSDDurationRangeObject(durationUnits: [.hours, .minutes], minimumDuration: min, maximumDuration: max)
        inputField.range = range
        
        // test assumptions
        XCTAssertEqual(range.minimumDuration, min)
        XCTAssertEqual(range.maximumDuration, max)
        XCTAssertEqual(range.baseUnit, .minutes)
        XCTAssertEqual(range.durationUnits, Set([.minutes, .hours]))

        let itemGroup = RSDNumberTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
        
        XCTAssertEqual(itemGroup.items.count, 1)
        
        if let item = itemGroup.items.first as? RSDNumberInputTableItem {
            
            XCTAssertEqual(item.answerType.baseType, .decimal)
            XCTAssertEqual(item.answerType.unit, "min")
            
            if let picker = item.pickerSource as? RSDDurationPickerDataSourceObject {
                XCTAssertEqual(picker.baseUnit, .minutes)
            } else {
                XCTFail("\(String(describing: item.pickerSource)) not of expected type.")
            }
            
            if let durationFormatter = item.formatter as? RSDDurationFormatter {
                XCTAssertEqual(durationFormatter.toStringUnit, .minutes)
                XCTAssertEqual(durationFormatter.fromStringUnit, .minutes)
            } else {
                XCTFail("\(String(describing: item.formatter)) not of expected type.")
            }
            
        } else {
            XCTFail("\(itemGroup.items) not of expected type.")
        }
        
        do {
            try itemGroup.setAnswer("2 hours, 50 minutes")
            let answer = itemGroup.answer
            XCTAssertEqual((answer as? NSNumber)?.intValue, 170, "\(String(describing: itemGroup.answer))")
        } catch let error {
            XCTFail("Failed to set the answer to a valid answer. \(error)")
        }
        
        do {
            try itemGroup.setAnswer("48:00")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.greaterThanMaximumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
        
        do {
            try itemGroup.setAnswer("-2:30")
            XCTFail("Setting answer to a value outside allowed range should fail.")
        } catch RSDInputFieldError.lessThanMinimumValue(_, _) {
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
    
    func testPostalCode() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let inputField = RSDInputFieldObject(identifier: "postalCode", dataType: .postalCode)
        let postalCodeItem = RSDPostalCodeTableItem(rowIndex: 0, inputField: inputField)
        
        do {
            try postalCodeItem.setAnswer("98101")
            let answerA = postalCodeItem.answer as? String
            XCTAssertEqual(answerA, "981**")
            
            try postalCodeItem.setAnswer("89301")
            let answerB = postalCodeItem.answer as? String
            XCTAssertEqual(answerB, "*****")
            
        } catch let error {
            XCTFail("Threw unexpected error \(error)")
        }
    }
}
