//
//  RecursiveScoreBuilderTests.swift
//  ResearchTests_iOS
//
//  Created by Shannon Young on 3/7/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import XCTest
@testable import Research

class RecursiveScoreBuilderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNestedDictionaryScore() {

        var answer1 = RSDAnswerResultObject(identifier: "answer1", answerType: .boolean)
        answer1.value = true
        
        var answer2 = RSDAnswerResultObject(identifier: "answer2", answerType: .integer)
        answer2.value = 2
        
        var answer3 = RSDAnswerResultObject(identifier: "answer3", answerType: .integer)
        answer3.value = 3
        
        var answer4 = RSDAnswerResultObject(identifier: "answer4", answerType: .integer)
        answer4.value = 3
        
        let score1 = TestResult(identifier: "score1", score: 1, startDate: Date(), endDate: Date())
        let score2 = TestResult(identifier: "score2", score: 2, startDate: Date(), endDate: Date())
        let score3 = TestResult(identifier: "score2", score: 3, startDate: Date(), endDate: Date())
        
        var taskResult = RSDTaskResultObject(identifier: "topLevel")
        
        // Build section A
        var subResultA = RSDTaskResultObject(identifier: "sectionA")
        subResultA.appendStepHistory(with: RSDResultObject(identifier: "intruction"))
        subResultA.appendStepHistory(with: score1)
        subResultA.appendStepHistory(with: answer1)
        var collection1 = RSDCollectionResultObject(identifier: "collection")
        collection1.appendInputResults(with: answer2)
        collection1.appendInputResults(with: answer3)
        subResultA.appendStepHistory(with: collection1)
        taskResult.appendStepHistory(with: subResultA)
        
        // Build section B
        var subResultB = RSDTaskResultObject(identifier: "sectionB")
        subResultB.appendStepHistory(with: RSDResultObject(identifier: "intruction"))
        subResultB.appendStepHistory(with: score2)
        taskResult.appendStepHistory(with: subResultB)
        
        // Build section C
        var subResultC = RSDTaskResultObject(identifier: "sectionC")
        subResultC.appendStepHistory(with: RSDResultObject(identifier: "intruction"))
        subResultC.appendStepHistory(with: score3)
        taskResult.appendStepHistory(with: subResultC)
        
        let expectedJson: [String : RSDJSONSerializable] = [
            "sectionA" : [
                "score1" : 1,
                "answer1" : true,
                "collection" : [
                    "answer2" : 2,
                    "answer3" : 3
                ]
            ],
            "sectionB" : 2,
            "sectionC" : 3
        ]
        
        let builder = RecursiveScoreBuilder()
        guard let json = builder.getScoringData(from: taskResult) else {
            XCTFail("Failed to create JSON scoring object")
            return
        }
        
        XCTAssertEqual(json as? NSDictionary, expectedJson as NSDictionary)
    }
}

struct TestResult : RSDScoringResult {

    let identifier: String
    
    let score: Int
    
    let type: RSDResultType = "test"
    
    var startDate: Date = Date()
    
    var endDate: Date = Date()

    func dataScore() throws -> RSDJSONSerializable? {
        return score
    }
    
    func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        fatalError("not implemented for this test")
    }
}
