//
//  SurveyRuleTests.swift
//  ResearchTests
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

import Foundation

import XCTest
import Research

class SurveyRuleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testActionSkipRule_NilResult() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        let skipAction = RSDNavigationUIActionObject(skipToIdentifier: "bar", buttonTitle: "Prefer not to answer")
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        step.actions = [.navigation(.skip) : skipAction]
        
        var taskResult = RSDTaskResultObject(identifier: "boobaloo")
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction1"))
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction2"))
        
        let collectionResult = RSDCollectionResultObject(identifier: "foo")
        taskResult.appendStepHistory(with: collectionResult)

        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "bar")
    }
    
    func testActionSkipRule_NilAnswer() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        let skipAction = RSDNavigationUIActionObject(skipToIdentifier: "bar", buttonTitle: "Prefer not to answer")
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        step.actions = [.navigation(.skip) : skipAction]
        
        let taskResult = createTaskResult(answerType: .integer, value: nil)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "bar")
    }
    
    func testSkipRule_NavigationResult() {

        let step = RSDUIStepObject(identifier: "foo")
        
        var taskResult = RSDTaskResultObject(identifier: "boobaloo")
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction1"))
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction2"))
        
        var stepResult = RSDResultObject(identifier: "foo")
        stepResult.skipToIdentifier = "bar"
        taskResult.appendStepHistory(with: stepResult)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "bar")
    }
    
    // Always survey navigation
    
    func testSurveyRule_Always() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        let rule = RSDComparableSurveyRuleObject<Int>(skipToIdentifier: "always", matchingValue: nil, ruleOperator: .always)
        inputField2.surveyRules = [rule]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 2)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "always")
    }
    
    // Integer
    
    func testSurveyRule_Integer_Equal() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1, .lessThan),
            createRule("equal", 2, .equal),
            createRule("greaterThan", 3, .greaterThan)
        ]

        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 2)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Integer_Equal_Default() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        let rule = RSDComparableSurveyRuleObject<Int>(skipToIdentifier: "equal", matchingValue: 2, ruleOperator: nil)
        inputField2.surveyRules = [ rule ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 2)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Integer_Skip_Default() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        let rule = RSDComparableSurveyRuleObject<Int>(skipToIdentifier: "skip", matchingValue: nil, ruleOperator: nil)
        inputField2.surveyRules = [ rule ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: nil)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "skip")
    }
    
    func testSurveyRule_Integer_LessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1, .lessThan),
            createRule("equal", 2, .equal),
            createRule("greaterThan", 3, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_Integer_GreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1, .lessThan),
            createRule("equal", 2, .equal),
            createRule("greaterThan", 3, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 4)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_Integer_NotGreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1, .lessThan),
            createRule("equal", 2, .equal),
            createRule("greaterThan", 3, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 3)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Integer_NotLessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1, .lessThan),
            createRule("equal", 2, .equal),
            createRule("greaterThan", 3, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 1)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Integer_LessThanOrEqual() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("lessThanEqual", 1, .lessThanEqual),
            createRule("equal", 2, .equal),
            createRule("greaterThanEqual", 3, .greaterThanEqual)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 1)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_Integer_NotEqual_True() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("notEqual", 2, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 3)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Integer_NotEqual_False() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.integer))
        
        inputField2.surveyRules = [
            createRule("notEqual", 2, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .integer, value: 2)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Decimal
    
    func testSurveyRule_Decimal_Equal() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1.0, .lessThan),
            createRule("equal", 2.0, .equal),
            createRule("greaterThan", 3.0, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 2.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Decimal_LessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1.0, .lessThan),
            createRule("equal", 2.0, .equal),
            createRule("greaterThan", 3.0, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 0.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_Decimal_GreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1.0, .lessThan),
            createRule("equal", 2.0, .equal),
            createRule("greaterThan", 3.0, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 4.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_Decimal_NotGreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1.0, .lessThan),
            createRule("equal", 2.0, .equal),
            createRule("greaterThan", 3.0, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 3.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Decimal_NotLessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThan", 1.0, .lessThan),
            createRule("equal", 2.0, .equal),
            createRule("greaterThan", 3.0, .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 1.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Decimal_LessThanOrEqual() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("lessThanEqual", 1.0, .lessThanEqual),
            createRule("equal", 2.0, .equal),
            createRule("greaterThanEqual", 3.0, .greaterThanEqual)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 1.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_Decimal_NotEqual_True() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("notEqual", 2.0, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 3.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Decimal_NotEqual_False() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.decimal))
        
        inputField2.surveyRules = [
            createRule("notEqual", 2.0, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .decimal, value: 2.0)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }

    // String
    
    func testSurveyRule_String_Equal() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThan", "beta", .lessThan),
            createRule("equal", "charlie", .equal),
            createRule("greaterThan", "delta", .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "charlie")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_String_LessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThan", "beta", .lessThan),
            createRule("equal", "charlie", .equal),
            createRule("greaterThan", "delta", .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "alpha")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_String_GreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThan", "beta", .lessThan),
            createRule("equal", "charlie", .equal),
            createRule("greaterThan", "delta", .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "gamma")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_String_NotGreaterThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThan", "beta", .lessThan),
            createRule("equal", "charlie", .equal),
            createRule("greaterThan", "delta", .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "delta")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_String_NotLessThan() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThan", "beta", .lessThan),
            createRule("equal", "charlie", .equal),
            createRule("greaterThan", "delta", .greaterThan)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "beta")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_String_LessThanOrEqual() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("lessThanEqual", "beta", .lessThanEqual),
            createRule("equal", "charlie", .equal),
            createRule("greaterThanEqual", "delta", .greaterThanEqual)
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "beta")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_String_NotEqual_True() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("notEqual", "charlie", .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "hoover")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_String_NotEqual_False() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        inputField2.surveyRules = [
            createRule("notEqual", "charlie", .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "charlie")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Boolean
    
    func testSurveyRule_Boolean_Equal_True() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.boolean))
        
        inputField2.surveyRules = [
            createRule("equal", true, .equal),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .boolean, value: true)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Boolean_Equal_False() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.boolean))
        
        inputField2.surveyRules = [
            createRule("equal", true, .equal),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .boolean, value: false)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Boolean_NotEqual_True() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.boolean))
        
        inputField2.surveyRules = [
            createRule("notEqual", true, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .boolean, value: false)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Boolean_NotEqual_False() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.boolean))
        
        inputField2.surveyRules = [
            createRule("notEqual", true, .notEqual),
        ]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .boolean, value: true)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Cohorts
    
    func testSurveyRule_Cohort_Equal() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        let rule1 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "charlie", ruleOperator: .equal, cohort: "c")
        let rule2 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "delta", ruleOperator: .equal, cohort: "d")
        let rule3 = RSDComparableSurveyRuleObject<String>(skipToIdentifier: nil, matchingValue: nil, ruleOperator: nil, cohort: "skip")
        let rule4 = RSDComparableSurveyRuleObject<String>(skipToIdentifier: nil, matchingValue: nil, ruleOperator: .always, cohort: "always")
        inputField2.surveyRules = [rule1, rule2, rule3, rule4]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "charlie")
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
        
        if let cohorts = step.cohortsToApply(with: taskResult) {
            XCTAssertEqual(cohorts.add, ["c", "always"])
            XCTAssertEqual(cohorts.remove, ["d", "skip"])
        } else {
            XCTFail("Cohorts for this step should not return nil")
        }
    }
    
    func testSurveyRule_Cohort_Skip() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        let rule1 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "charlie", ruleOperator: .equal, cohort: "c")
        let rule2 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "delta", ruleOperator: .equal, cohort: "d")
        let rule3 = RSDComparableSurveyRuleObject<String>(skipToIdentifier: nil, matchingValue: nil, ruleOperator: nil, cohort: "skip")
        inputField2.surveyRules = [rule1, rule2, rule3]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let after1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        step.afterCohortRules = [after1]
        
        let taskResult = createTaskResult(answerType: .string, value: nil)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
        
        if let cohorts = step.cohortsToApply(with: taskResult) {
            XCTAssertEqual(cohorts.add, ["skip"])
            XCTAssertEqual(cohorts.remove, ["d", "c"])
        } else {
            XCTFail("Cohorts for this step should not return nil")
        }
    }
    
    func testCohortTrackingRule_NextStep() {
        
        let inputField1 = RSDInputFieldObject(identifier: "field1", dataType: .base(.string))
        let inputField2 = RSDInputFieldObject(identifier: "field2", dataType: .base(.string))
        
        let rule1 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "charlie", ruleOperator: .equal, cohort: "c")
        let rule2 = RSDComparableSurveyRuleObject(skipToIdentifier: nil, matchingValue: "delta", ruleOperator: .equal, cohort: "d")
        inputField2.surveyRules = [rule1, rule2]
        
        let step = RSDFormUIStepObject(identifier: "foo", inputFields: [inputField1, inputField2])
        
        let taskResult = createTaskResult(answerType: .string, value: "charlie")
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["d", "test"])
        
        // If peeking, should not change the cohorts.
        let id1 = tracker.nextStepIdentifier(after: step, with: taskResult, isPeeking: true)
        XCTAssertNil(id1)
        XCTAssertEqual(tracker.currentCohorts, ["d", "test"])
        
        // If not peeking, should change the cohorts.
        let id2 = tracker.nextStepIdentifier(after: step, with: taskResult, isPeeking: false)
        XCTAssertNil(id2)
        XCTAssertEqual(tracker.currentCohorts, ["c", "test"])
    }
    
    func testCohortTrackingRule_SkipStep_Default() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let beforeRule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let beforeRule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let beforeRule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.beforeCohortRules = [beforeRule1, beforeRule2, beforeRule3]
        
        let afterRule = RSDCohortNavigationRuleObject(requiredCohorts: ["c"], cohortOperator: .all, skipToIdentifier: "cat")
        step.afterCohortRules = [afterRule]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["d", "test"])
        
        let skipToPeeking = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: true)
        let skipToActual = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: false)
        
        XCTAssertEqual(skipToPeeking, RSDIdentifier.nextStep.stringValue)
        XCTAssertEqual(skipToActual, RSDIdentifier.nextStep.stringValue)
    }
    
    func testCohortTrackingRule_SkipStep_All_Failed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let beforeRule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let beforeRule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let beforeRule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.beforeCohortRules = [beforeRule1, beforeRule2, beforeRule3]
        
        let afterRule = RSDCohortNavigationRuleObject(requiredCohorts: ["c"], cohortOperator: .all, skipToIdentifier: "cat")
        step.afterCohortRules = [afterRule]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["e", "test"])
        
        let skipToPeeking = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: true)
        let skipToActual = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertNil(skipToActual)
    }
    
    func testCohortTrackingRule_SkipStep_All_Passed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let beforeRule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let beforeRule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let beforeRule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.beforeCohortRules = [beforeRule1, beforeRule2, beforeRule3]
        
        let afterRule = RSDCohortNavigationRuleObject(requiredCohorts: ["c"], cohortOperator: .all, skipToIdentifier: "cat")
        step.afterCohortRules = [afterRule]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["e", "g", "test"])
        
        let skipToPeeking = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: true)
        let skipToActual = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: false)
        
        XCTAssertEqual(skipToPeeking, "elephant")
        XCTAssertEqual(skipToActual, "elephant")
    }
    
    func testCohortTrackingRule_SkipStep_Any_Passed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let beforeRule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let beforeRule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let beforeRule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.beforeCohortRules = [beforeRule1, beforeRule2, beforeRule3]
        
        let afterRule = RSDCohortNavigationRuleObject(requiredCohorts: ["c"], cohortOperator: .all, skipToIdentifier: "cat")
        step.afterCohortRules = [afterRule]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["h", "test"])
        
        let skipToPeeking = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: true)
        let skipToActual = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: false)
        
        XCTAssertEqual(skipToPeeking, "fox")
        XCTAssertEqual(skipToActual, "fox")
    }
    
    func testCohortTrackingRule_SkipStep_Any_Failed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let beforeRule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let beforeRule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let beforeRule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.beforeCohortRules = [beforeRule1, beforeRule2, beforeRule3]
        
        let afterRule = RSDCohortNavigationRuleObject(requiredCohorts: ["c"], cohortOperator: .all, skipToIdentifier: "cat")
        step.afterCohortRules = [afterRule]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["test"])
        
        let skipToPeeking = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: true)
        let skipToActual = tracker.skipToStepIdentifier(before: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertNil(skipToActual)
    }
    
    func testCohortTrackingRule_NextStep_Default() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let rule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let rule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let rule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.afterCohortRules = [rule1, rule2, rule3]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["d", "test"])
        
        let skipToPeeking = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: true)
        let skipToActual = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertEqual(skipToActual, RSDIdentifier.nextSection.stringValue)
    }
    
    func testCohortTrackingRule_NextStep_All_Failed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let rule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let rule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let rule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.afterCohortRules = [rule1, rule2, rule3]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["e", "test"])
        
        let skipToPeeking = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: true)
        let skipToActual = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertNil(skipToActual)
    }
    
    func testCohortTrackingRule_NextStep_All_Passed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let rule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let rule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let rule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.afterCohortRules = [rule1, rule2, rule3]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["e", "g", "test"])
        
        let skipToPeeking = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: true)
        let skipToActual = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertEqual(skipToActual, "elephant")
    }
    
    func testCohortTrackingRule_NextStep_Any_Passed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let rule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let rule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let rule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.afterCohortRules = [rule1, rule2, rule3]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["h", "test"])
        
        let skipToPeeking = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: true)
        let skipToActual = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertEqual(skipToActual, "fox")
    }
    
    func testCohortTrackingRule_NextStep_Any_Failed() {
        
        let step = RSDUIStepObject(identifier: "foo")
        
        let rule1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        let rule2 = RSDCohortNavigationRuleObject(requiredCohorts: ["e", "g"], cohortOperator: .all, skipToIdentifier: "elephant")
        let rule3 = RSDCohortNavigationRuleObject(requiredCohorts: ["f", "h"], cohortOperator: .any, skipToIdentifier: "fox")
        step.afterCohortRules = [rule1, rule2, rule3]
        
        let tracker = RSDCohortTrackingRule(initialCohorts: ["test"])
        
        let skipToPeeking = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: true)
        let skipToActual = tracker.nextStepIdentifier(after: step, with: nil, isPeeking: false)
        
        XCTAssertNil(skipToPeeking)
        XCTAssertNil(skipToActual)
    }
    
    
    // Helper methods
    
    func createRule<Value : Codable>(_ skipIdentifier: String?, _ matchingValue: Value, _ ruleOperator:RSDSurveyRuleOperator) -> RSDComparableSurveyRuleObject<Value> {
        return RSDComparableSurveyRuleObject<Value>(skipToIdentifier: skipIdentifier, matchingValue: matchingValue, ruleOperator: ruleOperator)
    }
    
    func createTaskResult(answerType: RSDAnswerResultType, value: Any?) -> RSDTaskResultObject {
        
        var taskResult = RSDTaskResultObject(identifier: "boobaloo")
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction1"))
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction2"))
        
        var collectionResult = RSDCollectionResultObject(identifier: "foo")
        collectionResult.appendInputResults(with: RSDAnswerResultObject(identifier: "field1", answerType: RSDAnswerResultType.string))
        var answerResult = RSDAnswerResultObject(identifier: "field2", answerType: answerType)
        answerResult.value = value
        collectionResult.appendInputResults(with: answerResult)
        taskResult.appendStepHistory(with: collectionResult)
        
        return taskResult
    }
}
