//
//  CodableQuestionTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
class CodableQuestionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChoiceQuestion_Codable() {
        
        let json = """
            {
                 "identifier": "foo",
                 "type": "choiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "baseType": "integer",
                 "uiHint": "checkmark",
                 "choices":[
                     {"text":"choice 1","icon":"choice1","value":1},
                     {"text":"choice 2","value":2},
                     {"text":"choice 3","value":3},
                     {"text":"none of the above","exclusive":true}
                 ],
                 "surveyRules": [{ "matchingAnswer": 0}]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.choiceQuestion, ChoiceQuestionStepObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(QuestionWrapper<ChoiceQuestionStepObject>.self, from: json)
            let object = wrapper.questionStep
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Hello World!", object.title)
            XCTAssertEqual(.choiceQuestion, object.stepType)
            XCTAssertFalse(object.isOptional)
            XCTAssertFalse(object.isSingleAnswer)
            XCTAssertEqual(.checkmark, object.inputUIHint)
            XCTAssertEqual(.integer, object.baseType)
            
            if let choices = object.jsonChoices as? [JsonChoiceObject] {
                let expectedChoices = [
                    JsonChoiceObject(matchingValue: .integer(1), text: "choice 1", detail: nil, isExclusive: nil, icon: RSDResourceImageDataObject(imageName: "choice1")),
                    JsonChoiceObject(matchingValue: .integer(2), text: "choice 2"),
                    JsonChoiceObject(matchingValue: .integer(3), text: "choice 3"),
                    JsonChoiceObject(matchingValue: nil, text: "none of the above", detail: nil, isExclusive: true, icon: nil)
                ]
                XCTAssertEqual(expectedChoices, choices)
            }
            else {
                XCTFail("Failed to decode expected choice objects.")
            }
            
            if let surveyRules = object.surveyRules as? [JsonSurveyRuleObject] {
                let expectedRules = [
                    JsonSurveyRuleObject(skipToIdentifier: nil, matchingValue: .integer(0), ruleOperator: nil, cohort: nil)
                ]
                XCTAssertEqual(expectedRules, surveyRules)
            }
            else {
                XCTFail("Failed to decode expected surveyRules.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any]
                else {
                    XCTFail("input json not a dictionary")
                    return
            }
            
            expectedDictionary.forEach { (pair) in
                let encodedValue = dictionary[pair.key]
                XCTAssertNotNil(encodedValue, "\(pair.key)")
                if let str = pair.value as? String {
                    XCTAssertEqual(str, encodedValue as? String, "\(pair.key)")
                }
                else if let num = pair.value as? NSNumber {
                    XCTAssertEqual(num, encodedValue as? NSNumber, "\(pair.key)")
                }
                else if let arr = pair.value as? NSArray {
                    XCTAssertEqual(arr, encodedValue as? NSArray, "\(pair.key)")
                }
                else if let dict = pair.value as? NSDictionary {
                    XCTAssertEqual(dict, encodedValue as? NSDictionary, "\(pair.key)")
                }
                else {
                    XCTFail("Failed to match \(pair.key)")
                }
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }

    func testSimpleQuestion_Codable() {
        
        let json = """
            {
                 "identifier": "foo",
                 "type": "simpleQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItem":{"type" : "year"},
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"},
                 "surveyRules": [{ "matchingAnswer": 1900}]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.simpleQuestion, SimpleQuestionStepObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(QuestionWrapper<SimpleQuestionStepObject>.self, from: json)
            let object = wrapper.questionStep
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Hello World!", object.title)
            XCTAssertEqual(.simpleQuestion, object.stepType)
            XCTAssertFalse(object.isOptional)
            
            XCTAssertTrue(object.inputItem is YearTextInputItemObject)
            if let skip = object.skipCheckbox as? SkipCheckboxInputItemObject {
                let expected = SkipCheckboxInputItemObject(fieldLabel: "No answer")
                XCTAssertEqual(expected, skip)
            }
            else {
                XCTFail("Failed to decode expected skipCheckbox.")
            }
            
            if let surveyRules = object.surveyRules as? [JsonSurveyRuleObject] {
                let expectedRules = [
                    JsonSurveyRuleObject(skipToIdentifier: nil, matchingValue: .integer(1900))
                ]
                XCTAssertEqual(expectedRules, surveyRules)
            }
            else {
                XCTFail("Failed to decode expected surveyRules.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any]
                else {
                    XCTFail("input json not a dictionary")
                    return
            }
            
            expectedDictionary.forEach { (pair) in
                let encodedValue = dictionary[pair.key]
                XCTAssertNotNil(encodedValue, "\(pair.key)")
                if let str = pair.value as? String {
                    XCTAssertEqual(str, encodedValue as? String, "\(pair.key)")
                }
                else if let num = pair.value as? NSNumber {
                    XCTAssertEqual(num, encodedValue as? NSNumber, "\(pair.key)")
                }
                else if let arr = pair.value as? NSArray {
                    XCTAssertEqual(arr, encodedValue as? NSArray, "\(pair.key)")
                }
                else if let dict = pair.value as? NSDictionary {
                    XCTAssertEqual(dict, encodedValue as? NSDictionary, "\(pair.key)")
                }
                else {
                    XCTFail("Failed to match \(pair.key)")
                }
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMultipleInputQuestionObject_Codable() {
        
        let json = """
            {
                 "identifier": "foo",
                 "type": "multipleInputQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "inputItems":[{"type" : "year"},{"type":"string"}],
                 "skipCheckbox":{"type":"skipCheckbox","fieldLabel":"No answer"},
                 "surveyRules": [{ "matchingAnswer": 1900}]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.multipleInputQuestion, MultipleInputQuestionStepObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(QuestionWrapper<MultipleInputQuestionStepObject>.self, from: json)
            let object = wrapper.questionStep
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Hello World!", object.title)
            XCTAssertEqual(.multipleInputQuestion, object.stepType)
            XCTAssertFalse(object.isOptional)
            
            
            XCTAssertEqual(2, object.inputItems.count)
            if object.inputItems.count == 2 {
                XCTAssertTrue(object.inputItems[0] is YearTextInputItemObject)
                XCTAssertTrue(object.inputItems[1] is StringTextInputItemObject)
            }
            
            if let skip = object.skipCheckbox as? SkipCheckboxInputItemObject {
                let expected = SkipCheckboxInputItemObject(fieldLabel: "No answer")
                XCTAssertEqual(expected, skip)
            }
            else {
                XCTFail("Failed to decode expected skipCheckbox.")
            }
            
            if let surveyRules = object.surveyRules as? [JsonSurveyRuleObject] {
                let expectedRules = [
                    JsonSurveyRuleObject(skipToIdentifier: nil, matchingValue: .integer(1900))
                ]
                XCTAssertEqual(expectedRules, surveyRules)
            }
            else {
                XCTFail("Failed to decode expected surveyRules.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any]
                else {
                    XCTFail("input json not a dictionary")
                    return
            }
            
            expectedDictionary.forEach { (pair) in
                let encodedValue = dictionary[pair.key]
                XCTAssertNotNil(encodedValue, "\(pair.key)")
                if let str = pair.value as? String {
                    XCTAssertEqual(str, encodedValue as? String, "\(pair.key)")
                }
                else if let num = pair.value as? NSNumber {
                    XCTAssertEqual(num, encodedValue as? NSNumber, "\(pair.key)")
                }
                else if let arr = pair.value as? NSArray {
                    XCTAssertEqual(arr, encodedValue as? NSArray, "\(pair.key)")
                }
                else if let dict = pair.value as? NSDictionary {
                    XCTAssertEqual(dict, encodedValue as? NSDictionary, "\(pair.key)")
                }
                else {
                    XCTFail("Failed to match \(pair.key)")
                }
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testStringChoiceQuestion_Codable() {
        
        let json = """
            {
                 "identifier": "foo",
                 "type": "stringChoiceQuestion",
                 "title": "Hello World!",
                 "optional": false,
                 "singleChoice": false,
                 "uiHint": "checkmark",
                 "choices":["foo","ba","lalala"],
                 "surveyRules": [{ "matchingAnswer": "foo"}]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.stringChoiceQuestion, StringChoiceQuestionStepObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(QuestionWrapper<StringChoiceQuestionStepObject>.self, from: json)
            let object = wrapper.questionStep
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Hello World!", object.title)
            XCTAssertEqual(.stringChoiceQuestion, object.stepType)
            XCTAssertFalse(object.isOptional)
            XCTAssertFalse(object.isSingleAnswer)
            XCTAssertEqual(.checkmark, object.inputUIHint)
            XCTAssertEqual(.string, object.baseType)
            
            if let choices = object.jsonChoices as? [JsonChoiceObject] {
                let expectedChoices = [
                    JsonChoiceObject(text: "foo"),
                    JsonChoiceObject(text: "ba"),
                    JsonChoiceObject(text: "lalala")
                ]
                XCTAssertEqual(expectedChoices, choices)
            }
            else {
                XCTFail("Failed to decode expected choice objects.")
            }
            
            if let surveyRules = object.surveyRules as? [JsonSurveyRuleObject] {
                let expectedRules = [
                    JsonSurveyRuleObject(skipToIdentifier: nil, matchingValue: .string("foo"))
                ]
                XCTAssertEqual(expectedRules, surveyRules)
            }
            else {
                XCTFail("Failed to decode expected surveyRules.")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String : Any]
                else {
                    XCTFail("input json not a dictionary")
                    return
            }
            
            expectedDictionary.forEach { (pair) in
                let encodedValue = dictionary[pair.key]
                XCTAssertNotNil(encodedValue, "\(pair.key)")
                if let str = pair.value as? String {
                    XCTAssertEqual(str, encodedValue as? String, "\(pair.key)")
                }
                else if let num = pair.value as? NSNumber {
                    XCTAssertEqual(num, encodedValue as? NSNumber, "\(pair.key)")
                }
                else if let arr = pair.value as? NSArray {
                    XCTAssertEqual(arr, encodedValue as? NSArray, "\(pair.key)")
                }
                else if let dict = pair.value as? NSDictionary {
                    XCTAssertEqual(dict, encodedValue as? NSDictionary, "\(pair.key)")
                }
                else {
                    XCTFail("Failed to match \(pair.key)")
                }
            }

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    struct QuestionWrapper<Value : QuestionStep> : Decodable {
        let questionStep : Value
        init(from decoder: Decoder) throws {
            let step = try decoder.factory.decodePolymorphicObject(RSDStep.self, from: decoder)
            guard let qStep = step as? Value else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode a QuestionStep")
                throw DecodingError.typeMismatch(Value.self, context)
            }
            self.questionStep = qStep
        }
    }
}
