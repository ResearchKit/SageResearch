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
import JsonModel

class SurveyRuleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testActionSkipRule_NilAnswer() {
        
        let inputItem1 = StringTextInputItemObject(resultIdentifier: "field1")
        let inputItem2 = IntegerTextInputItemObject(resultIdentifier: "field2")
        
        let skipAction = RSDNavigationUIActionObject(skipToIdentifier: "bar", buttonTitle: "Prefer not to answer")
        
        let step = MultipleInputQuestionStepObject(identifier: "foo", inputItems: [inputItem1, inputItem2])
        step.actions = [.navigation(.skip) : skipAction]
        
        let (taskResult, answerResult) = createTaskResult(for: step, with: nil)
        answerResult.skipToIdentifier = "bar"

        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "bar")
    }
    
    func testActionSkipRule_NonNilAnswer() {
        
        let inputItem1 = StringTextInputItemObject(resultIdentifier: "field1")
        let inputItem2 = IntegerTextInputItemObject(resultIdentifier: "field2")
        
        let skipAction = RSDNavigationUIActionObject(skipToIdentifier: "bar", buttonTitle: "Prefer not to answer")
        
        let step = MultipleInputQuestionStepObject(identifier: "foo", inputItems: [inputItem1, inputItem2])
        step.actions = [.navigation(.skip) : skipAction]
        
        let (taskResult, answerResult) = createTaskResult(for: step, with: .object(["field1":"boo","field2":3]))
        answerResult.skipToIdentifier = "bar"
        
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
        
        let rule = RSDComparableSurveyRuleObject<Int>(skipToIdentifier: "always", matchingValue: nil, ruleOperator: .always)
        
        let inputItem1 = StringTextInputItemObject(resultIdentifier: "field1")
        let inputItem2 = IntegerTextInputItemObject(resultIdentifier: "field2")
        
        let step = MultipleInputQuestionStepObject(identifier: "foo", inputItems: [inputItem1, inputItem2])
        step.surveyRules = [rule]
        
        let (taskResult, _) = createTaskResult(for: step, with: .object(["field1":"boo","field2":3]))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "always")
    }
    
    // Integer
    
    func testSurveyRule_Integer_Equal() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .integer(1), .lessThan, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThan", .integer(3), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(2))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Integer_Equal_Default() {
        
        let rule = createRule("equal", .integer(3), nil, nil)
        
        let inputItem = IntegerTextInputItemObject()
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [ rule ]

        let (taskResult, _) = createTaskResult(for: step, with: .integer(3))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Integer_Skip_Default() {
        
        let rule = createRule("skip", nil, nil, nil)
        
        let inputItem = IntegerTextInputItemObject()
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [ rule ]

        let (taskResult, _) = createTaskResult(for: step, with: .null)
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "skip")
    }
    
    func testSurveyRule_Integer_LessThan() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .integer(1), .lessThan, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThan", .integer(3), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_Integer_GreaterThan() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .integer(1), .lessThan, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThan", .integer(3), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(4))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_Integer_NotGreaterThan() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .integer(1), .lessThan, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThan", .integer(3), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(3))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Integer_NotLessThan() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .integer(1), .lessThan, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThan", .integer(3), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(1))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Integer_LessThanOrEqual() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThanEqual", .integer(1), .lessThanEqual, nil),
            createRule("equal", .integer(2), .equal, nil),
            createRule("greaterThanEqual", .integer(3), .greaterThanEqual, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(1))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_Integer_NotEqual_True() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("notEqual", .integer(2), .notEqual, nil),
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(3))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Integer_NotEqual_False() {
        
        let inputItem = IntegerTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("notEqual", .integer(2), .notEqual, nil),
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .integer(2))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Decimal
    
    func testSurveyRule_Decimal_Equal() {
        
        let inputItem = DoubleTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .number(1.0), .lessThan, nil),
            createRule("equal", .number(2.0), .equal, nil),
            createRule("greaterThan", .number(3.0), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .number(2.0000000000001))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Decimal_LessThan() {
        
        let inputItem = DoubleTextInputItemObject()
        
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
            createRule("lessThan", .number(1.0), .lessThan, nil),
            createRule("equal", .number(2.0), .equal, nil),
            createRule("greaterThan", .number(3.0), .greaterThan, nil)
        ]
        
        let (taskResult, _) = createTaskResult(for: step, with: .number(0.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_Decimal_GreaterThan() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .number(1.0), .lessThan, nil),
             createRule("equal", .number(2.0), .equal, nil),
             createRule("greaterThan", .number(3.0), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(4.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_Decimal_NotGreaterThan() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .number(1.0), .lessThan, nil),
             createRule("equal", .number(2.0), .equal, nil),
             createRule("greaterThan", .number(3.0), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(3.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Decimal_NotLessThan() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .number(1.0), .lessThan, nil),
             createRule("equal", .number(2.0), .equal, nil),
             createRule("greaterThan", .number(3.0), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(1.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Decimal_LessThanOrEqual() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThanEqual", .number(1.0), .lessThanEqual, nil),
             createRule("equal", .number(2.0), .equal, nil),
             createRule("greaterThanEqual", .number(3.0), .greaterThanEqual, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(1.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_Decimal_NotEqual_True() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("notEqual", .number(2.0), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(3.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Decimal_NotEqual_False() {
        
        let inputItem = DoubleTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("notEqual", .number(2.0), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .number(2.0))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }

    // String
    
    func testSurveyRule_String_Equal() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .string("beta"), .lessThan, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThan", .string("delta"), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("charlie"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_String_LessThan() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .string("beta"), .lessThan, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThan", .string("delta"), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("alpha"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThan")
    }
    
    func testSurveyRule_String_GreaterThan() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .string("beta"), .lessThan, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThan", .string("delta"), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("gamma"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "greaterThan")
    }
    
    func testSurveyRule_String_NotGreaterThan() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .string("beta"), .lessThan, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThan", .string("delta"), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("delta"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_String_NotLessThan() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThan", .string("beta"), .lessThan, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThan", .string("delta"), .greaterThan, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("beta"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_String_LessThanOrEqual() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("lessThanEqual", .string("beta"), .lessThanEqual, nil),
             createRule("equal", .string("charlie"), .equal, nil),
             createRule("greaterThanEqual", .string("delta"), .greaterThanEqual, nil)
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("beta"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "lessThanEqual")
    }
    
    func testSurveyRule_String_NotEqual_True() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("notEqual", .string("charlie"), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("hoover"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_String_NotEqual_False() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule("notEqual", .string("charlie"), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("charlie"))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Boolean
    
    func testSurveyRule_Boolean_Equal_True() {
        
        let step = ChoiceQuestionStepObject(identifier: "foo", choices: [
            JsonChoiceObject(matchingValue: .boolean(true), text: "Yes"),
            JsonChoiceObject(matchingValue: .boolean(false), text: "No")
        ])
        
        step.surveyRules = [
             createRule("equal", .boolean(true), .equal, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .boolean(true))

        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "equal")
    }
    
    func testSurveyRule_Boolean_Equal_False() {
        
        let step = ChoiceQuestionStepObject(identifier: "foo", choices: [
            JsonChoiceObject(matchingValue: .boolean(true), text: "Yes"),
            JsonChoiceObject(matchingValue: .boolean(false), text: "No")
        ])
        
        step.surveyRules = [
             createRule("equal", .boolean(true), .equal, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .boolean(false))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    func testSurveyRule_Boolean_NotEqual_True() {
        
        let step = ChoiceQuestionStepObject(identifier: "foo", choices: [
            JsonChoiceObject(matchingValue: .boolean(true), text: "Yes"),
            JsonChoiceObject(matchingValue: .boolean(false), text: "No")
        ])
        
        step.surveyRules = [
             createRule("notEqual", .boolean(true), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .boolean(false))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertEqual(navigatingIdentifier, "notEqual")
    }
    
    func testSurveyRule_Boolean_NotEqual_False() {
        
        let step = ChoiceQuestionStepObject(identifier: "foo", choices: [
            JsonChoiceObject(matchingValue: .boolean(true), text: "Yes"),
            JsonChoiceObject(matchingValue: .boolean(false), text: "No")
        ])
        
        step.surveyRules = [
             createRule("notEqual", .boolean(true), .notEqual, nil),
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .boolean(true))
        
        let peekingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: true)
        XCTAssertNil(peekingIdentifier)
        
        let navigatingIdentifier = step.nextStepIdentifier(with: taskResult, isPeeking: false)
        XCTAssertNil(navigatingIdentifier)
    }
    
    // Cohorts
    
    func testSurveyRule_Cohort_Equal() {
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule(nil, .string("charlie"), .equal, "c"),
             createRule(nil, .string("delta"), .equal, "d"),
             createRule(nil, .null, nil, "skip"),
             createRule(nil, nil, .always, "always")
        ]

        let (taskResult, _) = createTaskResult(for: step, with: .string("charlie"))
        
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
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule(nil, .string("charlie"), .equal, "c"),
             createRule(nil, .string("delta"), .equal, "d"),
             createRule(nil, .null, nil, "skip"),
        ]

        let after1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        step.afterCohortRules = [after1]
        
        let (taskResult, _) = createTaskResult(for: step, with: nil)
        
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
        
        let inputItem = StringTextInputItemObject()
         
        let step = SimpleQuestionStepObject(identifier: "foo", inputItem: inputItem)
        step.surveyRules = [
             createRule(nil, .string("charlie"), .equal, "c"),
             createRule(nil, .string("delta"), .equal, "d"),
        ]

        let after1 = RSDCohortNavigationRuleObject(requiredCohorts: ["d"], cohortOperator: nil, skipToIdentifier: nil)
        step.afterCohortRules = [after1]
        
        let (taskResult, _) = createTaskResult(for: step, with: .string("charlie"))
        
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
    
    func createRule(_ skipIdentifier: String?, _ matchingValue: JsonElement?, _ ruleOperator: RSDSurveyRuleOperator?, _ cohort: String?) -> JsonSurveyRuleObject {
        return JsonSurveyRuleObject(skipToIdentifier: skipIdentifier, matchingValue: matchingValue, ruleOperator: ruleOperator, cohort: cohort)
    }
    
    func createTaskResult(for step: QuestionStep, with jsonValue: JsonElement?) -> (RSDTaskResultObject, AnswerResultObject) {
        var taskResult = RSDTaskResultObject(identifier: "boobaloo")
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction1"))
        taskResult.appendStepHistory(with: RSDResultObject(identifier: "instruction2"))
        
        let answerResult = step.instantiateStepResult() as! AnswerResultObject
        taskResult.appendStepHistory(with: answerResult)
        answerResult.jsonValue = jsonValue
        
        return (taskResult, answerResult)
    }
}
