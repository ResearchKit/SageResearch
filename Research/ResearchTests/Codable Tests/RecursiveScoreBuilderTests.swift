//
//  RecursiveScoreBuilderTests.swift
//  ResearchTests_iOS
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
