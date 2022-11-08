//
//  ResultTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research
import JsonModel
import ResultModel

class ResultTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCollectionResultExtensions() {
        
        let collection = CollectionResultObject(identifier: "test")
        let answers = ["a" : 3, "b": 5, "c" : 7]
        answers.forEach {
            let answerResult = AnswerResultObject(identifier: $0.key, value: .integer($0.value))
            collection.appendInputResults(with: answerResult)
        }

        let answerB = AnswerResultObject(identifier: "a", value: .integer(8))
        let previous = collection.appendInputResults(with: answerB)
        XCTAssertNotNil(previous)
        if let previousResult = previous as? AnswerResultObject {
            XCTAssertEqual(previousResult.value as? Int, 3)
        }
        else {
            XCTFail("Failed to return the previous answer")
        }
        
        if let newResult = collection.findAnswer(with: "a") {
            XCTAssertEqual(newResult.value as? Int, 8)
        }
        else {
            XCTFail("Failed to find the new answer")
        }
        
        let removed = collection.removeInputResult(with: "b")
        XCTAssertNotNil(removed)
        if let removedResult = removed as? AnswerResultObject {
            XCTAssertEqual(removedResult.value as? Int, 5)
        }
        else {
            XCTFail("Failed to remove the result")
        }
        
        let removedD = collection.removeInputResult(with: "d")
        XCTAssertNil(removedD)
    }
}
