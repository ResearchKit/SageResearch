//
//  ResultTests.swift
//  ResearchTests_iOS
//
//  Created by Shannon Young on 3/25/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import XCTest
@testable import Research

class ResultTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCollectionResultExtensions() {
        
        var collection = RSDCollectionResultObject(identifier: "test")
        let answers = ["a" : 3, "b": 5, "c" : 7]
        answers.forEach {
            let answerResult = RSDAnswerResultObject(identifier: $0.key, answerType: .integer, value: $0.value)
            collection.appendInputResults(with: answerResult)
        }
        
        let answerMap = collection.answers()
        XCTAssertEqual(answerMap as? [String : Int], answers)

        let answerB = RSDAnswerResultObject(identifier: "a", answerType: .integer, value: 8)
        let previous = collection.appendInputResults(with: answerB)
        XCTAssertNotNil(previous)
        if let previousResult = previous as? RSDAnswerResultObject {
            XCTAssertEqual(previousResult.value as? Int, 3)
        }
        else {
            XCTFail("Failed to return the previous answer")
        }
        
        if let newResult = collection.findAnswerResult(with: "a") {
            XCTAssertEqual(newResult.value as? Int, 8)
        }
        else {
            XCTFail("Failed to find the new answer")
        }
        
        let removed = collection.removeInputResult(with: "b")
        XCTAssertNotNil(removed)
        if let removedResult = removed as? RSDAnswerResultObject {
            XCTAssertEqual(removedResult.value as? Int, 5)
        }
        else {
            XCTFail("Failed to remove the result")
        }
        
        let removedD = collection.removeInputResult(with: "d")
        XCTAssertNil(removedD)
    }

}
