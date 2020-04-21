//
//  CodableInputFieldObjectTests.swift
//  ResearchTests
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
import JsonModel

@available(*, deprecated, message: "These tests are for the deprecated RSDInputField objects")
class CodableInputFieldObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChoiceInputFieldObject_Codable_String() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "multipleChoice",
            "choices" : ["never", "sometimes", "often", "always"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDCodableChoiceInputFieldObject<String>.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard it == nil, let question = qn else {
                XCTFail("Failed to decode expeced question or input item.")
                return
            }
            
            XCTAssertEqual(question.identifier, "foo")
            XCTAssertEqual(question.nextStepIdentifier, "goo")
            XCTAssertEqual(question.baseType, .string)
            XCTAssertEqual(question.isOptional, object.isOptional)
            XCTAssertFalse(question.isSingleAnswer)
            XCTAssertEqual(question.choices.count, 4)
            XCTAssertEqual(question.choices.last?.text, "always")
            XCTAssertEqual(question.jsonChoices.last?.matchingValue, .string("always"))
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testChoiceInputFieldObject_Codable_Int() {
        
        let json = """
        {
            "identifier": "foo",
            "prompt": "Text",
            "placeholder": "enter text",
            "type": "singleChoice.integer",
            "uiHint": "picker",
            "optional": true,
            "choices" : [{  "value" : 0,
                            "text" : "never"},
                         {  "value" : 1,
                            "text" : "sometimes"},
                         {  "value" : 2,
                            "text" : "often"},
                         {  "value" : 3,
                            "text" : "always"}],
            "surveyRules": [{ "matchingAnswer": 0}]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDCodableChoiceInputFieldObject<Int>.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard qn == nil, let item = it as? ChoicePickerInputItemObject else {
                XCTFail("Failed to decode expeced question or input item.")
                return
            }

            XCTAssertEqual("foo", item.identifier)
            XCTAssertEqual(.choicePicker, item.inputItemType)
            XCTAssertEqual(.picker, item.inputUIHint)
            XCTAssertEqual("Text", item.fieldLabel)
            XCTAssertEqual("enter text", item.placeholder)
            
            XCTAssertTrue(item.answerType is AnswerTypeInteger)
            XCTAssertEqual(item.jsonChoices.count, 4)
            if let choices = item.jsonChoices as? [JsonChoiceObject],
                let last = choices.last {
                XCTAssertEqual(last.matchingValue, .integer(3))
                XCTAssertEqual(last.text, "always")
            }
            else {
                XCTFail("Failed to decode expected choice objects")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    // TODO: syoung 04/10/2020 Implement support for fractions when/if we need it.
//    func testChoiceInputFieldObject_Codable_Fraction() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "prompt": "Text",
//            "type": "singleChoice.fraction",
//            "choices" : ["1/25","1/50","1/125"]
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDCodableChoiceInputFieldObject<RSDFraction>.self, from: json)
//
//            XCTAssertEqual(object.identifier, "foo")
//            XCTAssertEqual(object.inputPrompt, "Text")
//            XCTAssertEqual(object.dataType, .collection(.singleChoice, .fraction))
//            XCTAssertEqual(object.choices.count, 3)
//            XCTAssertEqual(object.choices.last?.text, "1/125")
//            XCTAssertEqual((object.choices.last?.answerValue as? RSDFraction)?.doubleValue, 1.0 / 125.0)
//
//        } catch let err {
//            XCTFail("Failed to decode/encode object: \(err)")
//            return
//        }
//    }
  
    // TODO: syoung 04/10/20 Implement support for multiple component fields when/if we need it.
//    func testMultipleComponentInputFieldObject_Codable_String() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "type": "multipleComponent",
//            "choices" : [["blue", "red", "green", "yellow"], ["dog", "cat", "rat"]]
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDMultipleComponentInputFieldObject.self, from: json)
//
//            XCTAssertEqual(object.identifier, "foo")
//            XCTAssertEqual(object.dataType, .collection(.multipleComponent, .string))
//            XCTAssertFalse(object.isOptional)
//            XCTAssertEqual(object.choices.count, 2)
//
//            let jsonData = try encoder.encode(object)
//            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
//                else {
//                    XCTFail("Encoded object is not a dictionary")
//                    return
//            }
//
//            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
//            XCTAssertEqual(dictionary["type"] as? String, "multipleComponent.string")
//            XCTAssertEqual(dictionary["optional"] as? Bool, false)
//            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 2)
//
//        } catch let err {
//            XCTFail("Failed to decode/encode object: \(err)")
//            return
//        }
//    }
    
    func testInputFieldObject_Codable_Integer() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "integer",
            "uiHint": "slider",
            "range" : { "minimumValue" : -2,
                        "maximumValue" : 3,
                        "stepInterval" : 1,
                        "unit" : "feet" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard qn == nil, let item = it as? IntegerTextInputItemObject else {
                XCTFail("Failed to decode expeced question or input item.")
                return
            }

            XCTAssertEqual(item.identifier, "foo")
            XCTAssertEqual(item.isOptional, object.isOptional)
            XCTAssertEqual(item.fieldLabel, object.inputPrompt)
            XCTAssertFalse(item.isExclusive)
            XCTAssertEqual(item.inputUIHint, .slider)
            XCTAssertEqual(item.placeholder, "feet")
            if let range = item.formatOptions {
                XCTAssertEqual(range.minimumValue, -2)
                XCTAssertEqual(range.maximumValue, 3)
                XCTAssertEqual(range.stepInterval, 1)
            }
            else{
                XCTFail("Failed to decode range")
            }
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Decimal() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "decimal",
            "uiHint": "slider",
            "range" : { "minimumValue" : -2.5,
                        "maximumValue" : 3,
                        "stepInterval" : 0.1,
                        "unit" : "feet",
                        "formatter" : {"maximumDigits" : 3 }
                       }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard qn == nil, let item = it as? DoubleTextInputItemObject else {
                XCTFail("Failed to decode expeced question or input item.")
                return
            }

            XCTAssertEqual(item.identifier, "foo")
            XCTAssertEqual(item.isOptional, object.isOptional)
            XCTAssertEqual(item.fieldLabel, object.inputPrompt)
            XCTAssertFalse(item.isExclusive)
            XCTAssertEqual(item.inputUIHint, .slider)
            XCTAssertEqual(item.placeholder, "feet")
            if let range = item.formatOptions {
                XCTAssertEqual(range.minimumValue, -2.5)
                XCTAssertEqual(range.maximumValue, 3.0)
                XCTAssertEqual(range.stepInterval, 0.1)
                XCTAssertEqual(range.maximumFractionDigits, 3)
            }
            else {
                XCTFail("Failed to decode range")
            }
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    // TODO: syoung 04/10/2020 Implement support for duration when/if we need it.
//    func testInputFieldObject_Codable_TimeInterval() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "type": "duration",
//            "uiHint": "picker",
//            "range" : { "minimumValue" : 15,
//                        "maximumValue" : 360,
//                        "stepInterval" : 5,
//                        "unit" : "min",
//                        "durationUnits" : ["min", "hr"]
//                       }
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
//
//            XCTAssertEqual(object.identifier, "foo")
//            XCTAssertEqual(object.dataType, .base(.duration))
//            XCTAssertEqual(object.inputUIHint, .picker)
//            if let range = object.range as? RSDDurationRangeObject {
//                XCTAssertEqual(range.baseUnit, .minutes)
//                XCTAssertEqual(range.minimumDuration, Measurement(value: 15, unit: UnitDuration.minutes))
//                XCTAssertEqual(range.maximumDuration, Measurement(value: 6, unit: UnitDuration.hours))
//                XCTAssertEqual(range.stepInterval, 5)
//                let expectedUnits: Set<UnitDuration> = [.hours, .minutes]
//                XCTAssertEqual(range.durationUnits, expectedUnits)
//                XCTAssertNotNil((range.formatter as? DateComponentsFormatter), "\(String(describing: range.formatter))")
//            }
//            else{
//                XCTFail("Failed to decode range")
//            }
//
//            let jsonData = try encoder.encode(object)
//            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
//                else {
//                    XCTFail("Encoded object is not a dictionary")
//                    return
//            }
//
//            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
//            XCTAssertEqual(dictionary["type"] as? String, "duration")
//            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
//
//            if let range = dictionary["range"] as? [String: Any] {
//                XCTAssertEqual(range["minimumValue"] as? Int, 15)
//                XCTAssertEqual(range["maximumValue"] as? Int, 360)
//                XCTAssertEqual(range["stepInterval"] as? Int, 5)
//                XCTAssertEqual(range["unit"] as? String, "min")
//                if let timeUnits = range["durationUnits"] as? [String] {
//                    XCTAssertEqual(Set(timeUnits), Set(["min", "hr"]))
//                } else {
//                    XCTFail("Failed to encode time interval units.")
//                }
//            }
//            else {
//                XCTFail("Failed to encode range")
//            }
//
//        } catch let err {
//            XCTFail("Failed to decode/encode object: \(err)")
//            return
//        }
//    }
    
    func testInputFieldObject_Codable_Date() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "date",
            "uiHint": "picker",
            "range" : { "minimumValue" : "2017-02-20",
                        "maximumValue" : "2017-03-20",
                        "codingFormat" : "yyyy-MM-dd" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard qn == nil, let item = it as? DateInputItemObject else {
                XCTFail("Failed to decode expected question or input item.")
                return
            }

            XCTAssertEqual(item.identifier, "foo")
            XCTAssertEqual(item.isOptional, object.isOptional)
            XCTAssertEqual(item.fieldLabel, object.inputPrompt)
            XCTAssertEqual(item.placeholder, object.placeholder)
            XCTAssertFalse(item.isExclusive)
            XCTAssertEqual(item.inputUIHint, .picker)
            if let range = item.formatOptions {
                
                let calendar = Calendar(identifier: .iso8601)
                let calendarComponents = range.calendarComponents
                XCTAssertEqual(calendarComponents, [.year, .month, .day])
                
                XCTAssertNotNil(range.minimumDate)
                if let date = range.minimumDate {
                    let min = calendar.dateComponents(calendarComponents, from: date)
                    XCTAssertEqual(min.year, 2017)
                    XCTAssertEqual(min.month, 2)
                    XCTAssertEqual(min.day, 20)
                }
                
                XCTAssertNotNil(range.maximumDate)
                if let date = range.maximumDate {
                    let max = calendar.dateComponents(calendarComponents, from: date)
                    XCTAssertEqual(max.year, 2017)
                    XCTAssertEqual(max.month, 3)
                    XCTAssertEqual(max.day, 20)
                }
            }
            else {
                XCTFail("Failed to decode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_String_RexEx() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "string",
            "uiHint": "textfield",
            "textFieldOptions" : {
                        "textValidator" : "[A:C]",
                        "invalidMessage" : "You know me",
                        "maximumLength" : 10,
                        "autocapitalizationType" : "words",
                        "keyboardType" : "asciiCapable",
                        "isSecureTextEntry" : true }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
            
            guard qn == nil, let item = it as? StringTextInputItemObject else {
                XCTFail("Failed to decode expected question or input item.")
                return
            }

            XCTAssertEqual(item.identifier, "foo")
            XCTAssertEqual(item.isOptional, object.isOptional)
            XCTAssertEqual(item.fieldLabel, object.inputPrompt)
            XCTAssertEqual(item.placeholder, object.placeholder)
            XCTAssertFalse(item.isExclusive)
            
            if let validator = item.regExValidator {
                XCTAssertEqual(validator.pattern.pattern, "[A:C]")
                XCTAssertEqual(validator.invalidMessage, "You know me")
            }
            else {
                XCTFail("Failed to convert regEx validator")
            }

            if let textFieldOptions = item.keyboardOptionsObject  {
                XCTAssertEqual(textFieldOptions.autocapitalizationType, .words)
                XCTAssertEqual(textFieldOptions.keyboardType, .asciiCapable)
                XCTAssertTrue(textFieldOptions.isSecureTextEntry)
            }
            else {
                XCTFail("Failed to decode textFieldOptions")
            }
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    // TODO: syoung 04/10/2020 Support max length validator when/if needed
//    func testInputFieldObject_Codable_String_MaxLen() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "type": "string",
//            "textFieldOptions" : {
//                        "maximumLength" : 10
//                }
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
//
//            let (qn, it) = try object.convertToQuestionOrInputItem(nextStepIdentifier: "goo")
//
//            guard qn == nil, let item = it as? StringTextInputItemObject else {
//                XCTFail("Failed to decode expeced question or input item.")
//                return
//            }
//
//            XCTAssertEqual(item.identifier, "foo")
//
//        } catch let err {
//            XCTFail("Failed to decode/encode object: \(err)")
//            return
//        }
//    }
    
    
    // TODO: syoung 04/10/2020 Support postal code when/if needed.
//    func testInputFieldObject_Codable_PostalCode() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "type": "postalCode"
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
//
//            XCTAssertEqual(object.identifier, "foo")
//            XCTAssertEqual(object.dataType, .postalCode)
//
//            let jsonData = try encoder.encode(object)
//            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
//                else {
//                    XCTFail("Encoded object is not a dictionary")
//                    return
//            }
//
//            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
//            XCTAssertEqual(dictionary["type"] as? String, "postalCode")
//
//        } catch let err {
//            XCTFail("Failed to decode object: \(err)")
//            return
//        }
//    }
    
    // TODO: syoung 04/10/2020 Support detail input fields when/if needed.
//    func testDetailInputFieldObject_Codable() {
//
//        let json = """
//        {
//            "identifier": "foo",
//            "type": "detail",
//            "inputFields":[{
//                "identifier": "foo",
//                "type": "string"}]
//        }
//        """.data(using: .utf8)! // our data in native (JSON) format
//
//        do {
//
//            let object = try decoder.decode(RSDDetailInputFieldObject.self, from: json)
//
//            XCTAssertEqual(object.identifier, "foo")
//            XCTAssertEqual(object.dataType, .base(.string))
//
//        } catch let err {
//            XCTFail("Failed to decode object: \(err)")
//            return
//        }
//    }
}
