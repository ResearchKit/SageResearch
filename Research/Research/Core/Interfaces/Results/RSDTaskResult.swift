//
//  RSDTaskResult.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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


/// `RSDTaskResult` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public protocol RSDTaskResult : BranchNodeResult, RSDAnswerResultFinder {

    /// A list of all the asynchronous results for this task. The list should include uniquely identified results.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    var asyncResults: [RSDResult]? { get set }
}

/// The `RSDTaskRunResult` is a task result where the task run UUID can be set to allow for nested
/// results that all use the same run UUID.
public protocol RSDTaskRunResult : RSDTaskResult, AssessmentResult {
    
    /// Schema info associated with this task.
    var schemaInfo: RSDSchemaInfo? { get set }
}

extension RSDTaskRunResult {
    public var versionString: String? {
        guard let revision = schemaInfo?.schemaVersion else { return nil }
        return "\(revision)"
    }
    
    public var assessmentIdentifier: String? {
        self.identifier
    }
    
    public var schemaIdentifier: String? {
        self.schemaInfo?.schemaIdentifier
    }
}

extension RSDTaskResult  {
    
    public var inputResults: [RSDResult] {
        get { asyncResults ?? [] }
        set { asyncResults = newValue }
    }
    
    /// Find a result within the step history.
    /// - parameter step: The step associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findResult(for step: RSDStep) -> RSDResult? {
        return self.stepHistory.first(where: { $0.identifier == step.identifier })
    }
    
    /// Find a result within the step history.
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findResult(with identifier: String) -> RSDResult? {
        return self.stepHistory.first(where: { $0.identifier == identifier })
    }
    

    /// Append the result to the end of the step history. If the last result has the same
    /// identifier, then remove it.
    /// - parameter result:  The result to add to the step history.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func appendStepHistory(with result: RSDResult) -> RSDResult? {
        var previousResult: RSDResult?
        if let idx = stepHistory.lastIndex(where: { $0.identifier == result.identifier }) {
            previousResult = (idx == stepHistory.count - 1) ? stepHistory.remove(at: idx) : stepHistory[idx]
        }
        stepHistory.append(result)
        if nodePath.last != result.identifier {
            nodePath.append(result.identifier)
        }
        return previousResult
    }
    
    /// Remove the nodePath from `stepIdentifier` to the end of the result set.
    /// - parameter stepIdentifier:  The identifier of the result associated with the given step.
    /// - returns: The previous results or `nil` if there weren't any.
    @discardableResult
    mutating public func removeStepHistory(from stepIdentifier: String) -> Array<RSDResult>? {
        if let idx = nodePath.lastIndex(of: stepIdentifier) {
            nodePath.removeSubrange(idx...)
        }
        guard let idx = stepHistory.lastIndex(where: { $0.identifier == stepIdentifier }) else { return nil }
        return Array(stepHistory[idx...])
    }
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    /// - parameter result:  The result to add to the async results.
    mutating public func appendAsyncResult(with result: RSDResult) {
        if let idx = asyncResults?.firstIndex(where: { $0.identifier == result.identifier }) {
            asyncResults?.remove(at: idx)
        }
        if asyncResults == nil {
            asyncResults = [result]
        }
        else {
            asyncResults!.append(result)
        }
    }
}

public extension RSDTaskResult {
    /// Find an *answer* result within this collection. This method will return `nil` if there is a result
    /// but that result does **not** conform to to the `RSDAnswerResult` protocol.
    ///
    /// - seealso: `RSDAnswerResultFinder`
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    @available(*, deprecated, message: "Use `AnswerFinder.findAnswer` instead.")
    func findAnswerResult(with identifier:String ) -> RSDAnswerResult? {
        for result in stepHistory {
            if let answerResult = (result as? RSDAnswerResultFinder)?.findAnswerResult(with: identifier) {
                return answerResult
            }
        }
        if let results = asyncResults {
            for result in results {
                if let answerResult = (result as? RSDAnswerResultFinder)?.findAnswerResult(with: identifier) {
                    return answerResult
                }
            }
        }
        return nil
    }
    
}

public extension RSDTaskResult {
    func findAnswer(with identifier:String ) -> AnswerResult? {
        for result in stepHistory {
            if let answerResult = (result as? AnswerFinder)?.findAnswer(with: identifier) {
                return answerResult
            }
        }
        if let results = asyncResults {
            for result in results {
                if let answerResult = (result as? AnswerFinder)?.findAnswer(with: identifier) {
                    return answerResult
                }
            }
        }
        return nil
    }
}
