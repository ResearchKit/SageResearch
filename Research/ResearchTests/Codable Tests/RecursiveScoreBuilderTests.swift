//
//  RecursiveScoreBuilderTests.swift
//  ResearchTests_iOS
//

import XCTest
import JsonModel
import ResultModel
@testable import Research

@available(*,deprecated, message: "Will be deleted in a future version.")
class RecursiveScoreBuilderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNestedDictionaryScore() {

        let answer1 = AnswerResultObject(identifier: "answer1", value: .boolean(true))
        let answer2 = AnswerResultObject(identifier: "answer2", value: .integer(2))
        let answer3 = AnswerResultObject(identifier: "answer3", value: .integer(3))
        
        let score1 = TestResult(identifier: "score1", score: 1, startDate: Date(), endDate: Date())
        let score2 = TestResult(identifier: "score2", score: 2, startDate: Date(), endDate: Date())
        let score3 = TestResult(identifier: "score2", score: 3, startDate: Date(), endDate: Date())
        
        let taskResult = RSDTaskResultObject(identifier: "topLevel")
        
        // Build section A
        let subResultA = RSDTaskResultObject(identifier: "sectionA")
        subResultA.appendStepHistory(with: ResultObject(identifier: "intruction"))
        subResultA.appendStepHistory(with: score1)
        subResultA.appendStepHistory(with: answer1)
        let collection1 = CollectionResultObject(identifier: "collection")
        collection1.appendInputResults(with: answer2)
        collection1.appendInputResults(with: answer3)
        subResultA.appendStepHistory(with: collection1)
        taskResult.appendStepHistory(with: subResultA)
        
        // Build section B
        let subResultB = RSDTaskResultObject(identifier: "sectionB")
        subResultB.appendStepHistory(with: ResultObject(identifier: "intruction"))
        subResultB.appendStepHistory(with: score2)
        taskResult.appendStepHistory(with: subResultB)
        
        // Build section C
        let subResultC = RSDTaskResultObject(identifier: "sectionC")
        subResultC.appendStepHistory(with: ResultObject(identifier: "intruction"))
        subResultC.appendStepHistory(with: score3)
        taskResult.appendStepHistory(with: subResultC)
        
        let expectedJson: [String : JsonSerializable] = [
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

@available(*,deprecated, message: "Will be deleted in a future version.")
struct TestResult : SerializableResultData, RSDScoringResult {

    let identifier: String
    
    let score: Int
    
    private(set) var serializableType: SerializableResultType = "test"
    
    var startDate: Date = Date()
    
    var endDate: Date = Date()

    func dataScore() throws -> JsonSerializable? {
        return score
    }
    
    func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)? {
        fatalError("not implemented for this test")
    }
    
    func deepCopy() -> TestResult {
        self
    }
}
