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

class CodableInputFieldObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // setup to have an image wrapper delegate set so the image wrapper won't crash
        RSDImageWrapper.sharedDelegate = TestImageWrapperDelegate()
        
        // Use a statically defined timezone.
        rsd_ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRSDChoiceObject_Codable_Dictionary_StringValue() {
        
        let json = """
        {
            "value": "foo",
            "text": "Some text.",
            "detail": "A detail about the object",
            "icon": "fooImage",
            "isExclusive": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDChoiceObject<String>.self, from: json)
            
            XCTAssertEqual(object.answerValue as? String, "foo")
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "A detail about the object")
            XCTAssertEqual(object.icon?.imageName, "fooImage")
            XCTAssertTrue(object.isExclusive)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? String, "foo")
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["detail"] as? String, "A detail about the object")
            XCTAssertEqual(dictionary["icon"] as? String, "fooImage")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testRSDChoiceObject_Codable_Dictionary_IntValue() {
        
        let json = """
        {
            "value": 3,
            "text": "Some text.",
            "detail": "A detail about the object",
            "icon": "fooImage",
            "isExclusive": true
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let object = try decoder.decode(RSDChoiceObject<Int>.self, from: json)
            
            XCTAssertEqual(object.answerValue as? Int, 3)
            XCTAssertEqual(object.text, "Some text.")
            XCTAssertEqual(object.detail, "A detail about the object")
            XCTAssertEqual(object.icon?.imageName, "fooImage")
            XCTAssertTrue(object.isExclusive)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? Int, 3)
            XCTAssertEqual(dictionary["text"] as? String, "Some text.")
            XCTAssertEqual(dictionary["detail"] as? String, "A detail about the object")
            XCTAssertEqual(dictionary["icon"] as? String, "fooImage")
            XCTAssertEqual(dictionary["isExclusive"] as? Bool, true)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testRSDChoiceObject_Codable_Dictionary_TextValue() {
        
        let json = """
        ["alpha", "beta"]
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let objects = try decoder.decode([RSDChoiceObject<String>].self, from: json)
            
            XCTAssertEqual(objects.count, 2)
            XCTAssertEqual(objects.first?.answerValue as? String, "alpha")
            XCTAssertEqual(objects.last?.answerValue as? String, "beta")
            
            guard let object = objects.first else {
                return
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["value"] as? String, "alpha")
            XCTAssertEqual(dictionary["text"] as? String, "alpha")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
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
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .collection(.multipleChoice, .string))
            XCTAssertFalse(object.isOptional)
            XCTAssertEqual(object.choices.count, 4)
            XCTAssertEqual(object.choices.last?.text, "always")
            XCTAssertEqual(object.choices.last?.answerValue as? String, "always")
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "multipleChoice.string")
            XCTAssertEqual(dictionary["optional"] as? Bool, false)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 4)
            
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
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.inputPrompt, "Text")
            XCTAssertEqual(object.placeholder, "enter text")
            XCTAssertEqual(object.dataType, .collection(.singleChoice, .integer))
            XCTAssertEqual(object.inputUIHint, .picker)
            XCTAssertTrue(object.isOptional)
            XCTAssertEqual(object.choices.count, 4)
            XCTAssertEqual(object.choices.last?.text, "always")
            XCTAssertEqual(object.choices.last?.answerValue as? Int, 3)
            
            if let surveyRules = object.surveyRules, let rule = surveyRules.first as? RSDComparableSurveyRule {
                XCTAssertNil(rule.skipToIdentifier)
                XCTAssertNil(rule.ruleOperator)
                XCTAssertEqual(rule.matchingAnswer as? Int, 0)
            } else {
                XCTFail("Failed to decode inline survey rule.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["prompt"] as? String, "Text")
            XCTAssertEqual(dictionary["placeholder"] as? String, "enter text")
            XCTAssertEqual(dictionary["type"] as? String, "singleChoice.integer")
            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
            XCTAssertEqual(dictionary["optional"] as? Bool, true)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 4)

            if let surveyRules = dictionary["surveyRules"] as? [[String: Any]],
                let firstRule = surveyRules.first {
                XCTAssertEqual(firstRule["matchingAnswer"] as? Int, 0)
            } else {
                XCTFail("Failed to encode surveyRules")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testChoiceInputFieldObject_Codable_Fraction() {
        
        let json = """
        {
            "identifier": "foo",
            "prompt": "Text",
            "type": "singleChoice.fraction",
            "choices" : ["1/25","1/50","1/125"]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDCodableChoiceInputFieldObject<RSDFraction>.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.inputPrompt, "Text")
            XCTAssertEqual(object.dataType, .collection(.singleChoice, .fraction))
            XCTAssertEqual(object.choices.count, 3)
            XCTAssertEqual(object.choices.last?.text, "1/125")
            XCTAssertEqual((object.choices.last?.answerValue as? RSDFraction)?.doubleValue, 1.0 / 125.0)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMultipleComponentInputFieldObject_Codable_String() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "multipleComponent",
            "choices" : [["blue", "red", "green", "yellow"], ["dog", "cat", "rat"]]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDMultipleComponentInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .collection(.multipleComponent, .string))
            XCTAssertFalse(object.isOptional)
            XCTAssertEqual(object.choices.count, 2)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "multipleComponent.string")
            XCTAssertEqual(dictionary["optional"] as? Bool, false)
            XCTAssertEqual((dictionary["choices"] as? [Any])?.count ?? 0, 2)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Integer() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "integer",
            "uiHint": "slider",
            "range" : { "minimumValue" : -2,
                        "maximumValue" : 3,
                        "stepInterval" : 1,
                        "unit" : "feet" },
            "surveyRules" : [
                            {
                            "skipToIdentifier": "lessThan",
                            "ruleOperator": "lt",
                            "matchingAnswer": 0,
                            "cohort": "less"
                            },
                            {
                            "skipToIdentifier": "greaterThan",
                            "ruleOperator": "gt",
                            "matchingAnswer": 1
                            }
                            ]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.integer))
            XCTAssertEqual(object.inputUIHint, .slider)
            if let range = object.range as? RSDNumberRange {
                XCTAssertEqual(range.minimumValue, -2)
                XCTAssertEqual(range.maximumValue, 3)
                XCTAssertEqual(range.stepInterval, 1)
                XCTAssertEqual(range.unit, "feet")
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            if let surveyRules = object.surveyRules,
                let firstRule = surveyRules.first as? RSDComparableSurveyRule,
                let lastRule = surveyRules.last as? RSDComparableSurveyRule {
                
                XCTAssertEqual(firstRule.skipToIdentifier, "lessThan")
                XCTAssertEqual(firstRule.ruleOperator, .lessThan)
                XCTAssertEqual(firstRule.matchingAnswer as? Int, 0)
                XCTAssertEqual(firstRule.cohort, "less")
                
                XCTAssertEqual(lastRule.skipToIdentifier, "greaterThan")
                XCTAssertEqual(lastRule.ruleOperator, .greaterThan)
                XCTAssertEqual(lastRule.matchingAnswer as? Int, 1)
                
            } else {
                XCTFail("Failed to decode inline survey rule.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "integer")
            XCTAssertEqual(dictionary["uiHint"] as? String, "slider")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumValue"] as? Int, -2)
                XCTAssertEqual(range["maximumValue"] as? Int, 3)
                XCTAssertEqual(range["stepInterval"] as? Int, 1)
                XCTAssertEqual(range["unit"] as? String, "feet")
            }
            else {
                XCTFail("Failed to encode range")
            }
            
            if let surveyRules = dictionary["surveyRules"] as? [[String: Any]],
                let firstRule = surveyRules.first,
                let lastRule = surveyRules.last {
                XCTAssertEqual(firstRule["skipToIdentifier"] as? String, "lessThan")
                XCTAssertEqual(firstRule["ruleOperator"] as? String, "lt")
                XCTAssertEqual(firstRule["matchingAnswer"] as? Int, 0)
                XCTAssertEqual(lastRule["skipToIdentifier"] as? String, "greaterThan")
                XCTAssertEqual(lastRule["ruleOperator"] as? String, "gt")
                XCTAssertEqual(lastRule["matchingAnswer"] as? Int, 1)
            } else {
                XCTFail("Failed to encode surveyRules")
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
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.decimal))
            XCTAssertEqual(object.inputUIHint, .slider)
            if let range = object.range as? RSDNumberRangeObject {
                XCTAssertEqual(range.minimumValue, -2.5)
                XCTAssertEqual(range.maximumValue, 3)
                XCTAssertEqual(range.stepInterval, 0.1)
                XCTAssertEqual(range.unit, "feet")
                XCTAssertEqual((range.formatter as? NumberFormatter)?.maximumFractionDigits ?? 0, 3)
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "decimal")
            XCTAssertEqual(dictionary["uiHint"] as? String, "slider")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumValue"] as? Double, -2.5)
                XCTAssertEqual(range["maximumValue"] as? Double, 3)
                XCTAssertEqual(range["stepInterval"] as? Double, 0.1)
                XCTAssertEqual(range["unit"] as? String, "feet")
                if let formatter = range["formatter"] as? [String: Any] {
                    XCTAssertEqual(formatter["maximumDigits"] as? Int, 3)
                } else {
                    XCTFail("Failed to encode the formatter.")
                }
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_TimeInterval() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "duration",
            "uiHint": "picker",
            "range" : { "minimumValue" : 15,
                        "maximumValue" : 360,
                        "stepInterval" : 5,
                        "unit" : "min",
                        "durationUnits" : ["min", "hr"]
                       }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.duration))
            XCTAssertEqual(object.inputUIHint, .picker)
            if let range = object.range as? RSDDurationRangeObject {
                XCTAssertEqual(range.baseUnit, .minutes)
                XCTAssertEqual(range.minimumDuration, Measurement(value: 15, unit: UnitDuration.minutes))
                XCTAssertEqual(range.maximumDuration, Measurement(value: 6, unit: UnitDuration.hours))
                XCTAssertEqual(range.stepInterval, 5)
                let expectedUnits: Set<UnitDuration> = [.hours, .minutes]
                XCTAssertEqual(range.durationUnits, expectedUnits)
                XCTAssertNotNil((range.formatter as? DateComponentsFormatter), "\(String(describing: range.formatter))")
            }
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "duration")
            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumValue"] as? Int, 15)
                XCTAssertEqual(range["maximumValue"] as? Int, 360)
                XCTAssertEqual(range["stepInterval"] as? Int, 5)
                XCTAssertEqual(range["unit"] as? String, "min")
                if let timeUnits = range["durationUnits"] as? [String] {
                    XCTAssertEqual(Set(timeUnits), Set(["min", "hr"]))
                } else {
                    XCTFail("Failed to encode time interval units.")
                }
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_Date() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "date",
            "uiHint": "picker",
            "range" : { "minimumDate" : "2017-02-20",
                        "maximumDate" : "2017-03-20",
                        "codingFormat" : "yyyy-MM-dd" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.date))
            XCTAssertEqual(object.inputUIHint, .picker)
            if let range = object.range as? RSDDateRange {
                
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
            else{
                XCTFail("Failed to decode range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "date")
            XCTAssertEqual(dictionary["uiHint"] as? String, "picker")
            
            if let range = dictionary["range"] as? [String: Any] {
                XCTAssertEqual(range["minimumDate"] as? String, "2017-02-20")
                XCTAssertEqual(range["maximumDate"] as? String, "2017-03-20")
                XCTAssertEqual(range["codingFormat"] as? String, "yyyy-MM-dd")
            }
            else {
                XCTFail("Failed to encode range")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_String() {
        
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
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.string))
            XCTAssertEqual(object.inputUIHint, .textfield)
            if let textFieldOptions = object.textFieldOptions  {
                XCTAssertEqual((textFieldOptions.textValidator as? RSDRegExValidatorObject)?.regExPattern, "[A:C]")
                XCTAssertEqual(textFieldOptions.invalidMessage, "You know me")
                XCTAssertEqual(textFieldOptions.maximumLength, 10)
                XCTAssertEqual(textFieldOptions.autocapitalizationType, .words)
                XCTAssertEqual(textFieldOptions.keyboardType, .asciiCapable)
                XCTAssertTrue(textFieldOptions.isSecureTextEntry)
            }
            else{
                XCTFail("Failed to decode textFieldOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "string")
            XCTAssertEqual(dictionary["uiHint"] as? String, "textfield")
            
            if let textFieldOptions = dictionary["textFieldOptions"] as? [String: Any] {
                XCTAssertEqual(textFieldOptions["textValidator"] as? String, "[A:C]")
                XCTAssertEqual(textFieldOptions["invalidMessage"] as? String, "You know me")
                XCTAssertEqual(textFieldOptions["maximumLength"] as? Int, 10)
                XCTAssertEqual(textFieldOptions["autocapitalizationType"] as? String, "words")
                XCTAssertEqual(textFieldOptions["keyboardType"] as? String, "asciiCapable")
            }
            else {
                XCTFail("Failed to encode textFieldOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_String_DefaultOptions() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "string",
            "uiHint": "textfield",
            "textFieldOptions" : {}
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.string))
            XCTAssertEqual(object.inputUIHint, .textfield)
            if let textFieldOptions = object.textFieldOptions  {
                XCTAssertNil(textFieldOptions.textValidator)
                XCTAssertNil(textFieldOptions.invalidMessage)
                XCTAssertEqual(textFieldOptions.maximumLength, 0)
                XCTAssertEqual(textFieldOptions.autocapitalizationType, .none)
                XCTAssertEqual(textFieldOptions.keyboardType, .default)
                XCTAssertFalse(textFieldOptions.isSecureTextEntry)
            }
            else{
                XCTFail("Failed to decode textFieldOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode object: \(err)")
            return
        }
    }
    
    func testInputFieldObject_Codable_PostalCode() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "postalCode"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .postalCode)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "postalCode")
            
        } catch let err {
            XCTFail("Failed to decode object: \(err)")
            return
        }
    }
    
    func testDetailInputFieldObject_Codable() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "detail",
            "inputFields":[{
                "identifier": "foo",
                "type": "string"}]
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDDetailInputFieldObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.dataType, .base(.string))
            
        } catch let err {
            XCTFail("Failed to decode object: \(err)")
            return
        }
    }
    
}
