//
//  RSDScoreBuilder.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDScoreBuilder {
    
    /// Build the scoring data from a task result.
    ///
    /// - parameter taskResult: The task result to parse for score values.
    func getScoringData(from taskResult: RSDTaskResult) -> JsonSerializable?
}

/// Default implementation for building a task scoring.
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDDefaultScoreBuilder : RSDScoreBuilder {
    public init() {
    }
    
    /// Recursively build the scoring data.
    public func getScoringData(from taskResult: RSDTaskResult) -> JsonSerializable? {
        let builder = RecursiveScoreBuilder()
        return builder.getScoringData(from: taskResult)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
internal struct RecursiveScoreBuilder : RSDScoreBuilder {
    
    /// Build the scoring data from a task result by recursively looking for results that conform to either
    /// `RSDScoringResult` or `RSDAnswerResult`.
    /// - parameter taskResult: The task result to parse for score values.
    func getScoringData(from taskResult: RSDTaskResult) -> JsonSerializable? {
        do {
            return try _recursiveGetScoringData(from: taskResult)
        }
        catch let err {
            debugPrint("Failed to create task scoring. \(err)")
            return nil
        }
    }

    private func _recursiveGetScoringData(from taskResult: RSDTaskResult) throws -> JsonSerializable? {
        var dataResults: [ResultData] = taskResult.stepHistory
        if let asyncResults = taskResult.asyncResults {
            dataResults.append(contentsOf: asyncResults)
        }
        return try _recursiveGetScoringData(from: dataResults)
    }
    
    private func _scoringData(_ result: ResultData) throws -> JsonSerializable? {
        if let scoringResult = result as? RSDScoringResult,
            let scoringData = try scoringResult.dataScore() {
            return scoringData
        }
        else if let taskResult = result as? RSDTaskResult {
            return try self._recursiveGetScoringData(from: taskResult)
        }
        else if let collectionResult = result as? CollectionResult {
            return try self._recursiveGetScoringData(from: collectionResult.children)
        }
        else if let answerResult = result as? AnswerResult {
            return try answerResult.encodingValue()?.jsonObject()
        }
        else {
            return nil
        }
    }
    
    private func _recursiveGetScoringData(from results: [ResultData]) throws -> JsonSerializable? {

        let dictionary = try results.reduce(into: [String : JsonSerializable]()) { (hashtable, result) in
            guard let data = try _scoringData(result) else { return }
            hashtable[result.identifier] = data
        }
        
        // Return the "most appropriate" value for the combined results.
        if dictionary.count == 0 {
            return nil
        }
        else if dictionary.count == 1 {
            return dictionary.first!.value
        }
        else {
            return dictionary
        }
    }
}
