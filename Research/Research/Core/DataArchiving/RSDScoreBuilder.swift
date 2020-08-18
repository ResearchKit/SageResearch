//
//  RSDScoreBuilder.swift
//  Research
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

import Foundation
import JsonModel

public protocol RSDScoreBuilder {
    
    /// Build the scoring data from a task result.
    ///
    /// - parameter taskResult: The task result to parse for score values.
    func getScoringData(from taskResult: RSDTaskResult) -> JsonSerializable?
}

/// Default implementation for building a task scoring.
public struct RSDDefaultScoreBuilder : RSDScoreBuilder {
    public init() {
    }
    
    /// Recursively build the scoring data.
    public func getScoringData(from taskResult: RSDTaskResult) -> JsonSerializable? {
        let builder = RecursiveScoreBuilder()
        return builder.getScoringData(from: taskResult)
    }
}

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
        var dataResults: [RSDResult] = taskResult.stepHistory
        if let asyncResults = taskResult.asyncResults {
            dataResults.append(contentsOf: asyncResults)
        }
        return try _recursiveGetScoringData(from: dataResults)
    }
    
    private func _scoringData(_ result: RSDResult) throws -> JsonSerializable? {
        if let scoringResult = result as? RSDScoringResult,
            let scoringData = try scoringResult.dataScore() {
            return scoringData
        }
        else if let taskResult = result as? RSDTaskResult {
            return try self._recursiveGetScoringData(from: taskResult)
        }
        else if let collectionResult = result as? CollectionResult {
            return try self._recursiveGetScoringData(from: collectionResult.inputResults)
        }
        else if let answerResult = result as? AnswerResult {
            return try answerResult.encodingValue()?.jsonObject()
        }
        else if let answerResult = result as? RSDAnswerResult {
            print("WARNING!!! `RSDAnswerResult` is deprecated and will be deleted a future version.")
            return try answerResult.answerType.jsonEncode(from: answerResult.value)
        }
        else {
            return nil
        }
    }
    
    private func _recursiveGetScoringData(from results: [RSDResult]) throws -> JsonSerializable? {

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
