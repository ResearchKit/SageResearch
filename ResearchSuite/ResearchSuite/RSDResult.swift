//
//  RSDResult.swift
//  ResearchSuite
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDResult` is the base implementation for a result associated with a task, step, or asynchronous action.
///
/// When running a task, there will be a result of some variety used to mark each step in the task. This is
/// the base protocol. All the `RSDResult` objects are required to conform to the `Codable` protocol to allow
/// the app to store and upload results in a standardized way.
///
public protocol RSDResult : Encodable {
    
    /// The identifier associated with the task, step, or asynchronous action.
    var identifier: String { get }
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    var type: RSDResultType { get }
    
    /// The start date timestamp for the result.
    var startDate: Date { get set }
    
    /// The end date timestamp for the result.
    var endDate: Date { get set }
}

/// `RSDTaskResult` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public protocol RSDTaskResult : RSDResult, RSDAnswerResultFinder {
    
    /// A unique identifier for this task run.
    var taskRunUUID: UUID { get }
    
    /// Schema info associated with this task.
    var schemaInfo: RSDSchemaInfo? { get set }
    
    /// A listing of the step history for this task or section. The listed step results should *only* include the
    /// last result for any given step.
    var stepHistory: [RSDResult] { get set }
    
    /// A list of all the asynchronous results for this task. The list should include uniquely identified results.
    var asyncResults: [RSDResult]? { get set }
}

extension RSDTaskResult  {
    
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
    
    /// Find an *answer* result within this collection. This method will return `nil` if there is a result
    /// but that result does **not** conform to to the `RSDAnswerResult` protocol.
    ///
    /// - seealso: `RSDAnswerResultFinder`
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findAnswerResult(with identifier:String ) -> RSDAnswerResult? {
        for result in stepHistory {
            if let answerResult = (result as? RSDAnswerResultFinder)?.findAnswerResult(with: identifier) {
                return answerResult
            }
        }
        return nil
    }
    
    /// Append the result to the end of the step history, replacing the previous instance with the same identifier.
    /// - parameter result:  The result to add to the step history.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func appendStepHistory(with result: RSDResult) -> RSDResult? {
        var previousResult: RSDResult?
        if let idx = stepHistory.index(where: { $0.identifier == result.identifier }) {
            previousResult = stepHistory.remove(at: idx)
        }
        stepHistory.append(result)
        return previousResult
    }
    
    /// Remove results from the step history from the result with the given identifier to the end of the array.
    /// - parameter stepIdentifier:  The identifier of the result associated with the given step.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func removeStepHistory(from stepIdentifier: String) -> Array<RSDResult>? {
        guard let idx = stepHistory.index(where: { $0.identifier == stepIdentifier }) else { return nil }
        let subrange = stepHistory[idx...]
        stepHistory.replaceSubrange(idx..., with: [])
        return Array(subrange)
    }
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// - parameter result:  The result to add to the async results.
    mutating public func appendAsyncResult(with result: RSDResult) {
        if let idx = asyncResults?.index(where: { $0.identifier == result.identifier }) {
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

/// `RSDCollectionResult` is used include multiple results associated with a single step or async action that
/// may have more that one result.
public protocol RSDCollectionResult : RSDResult, RSDAnswerResultFinder {
    
    /// The list of input results associated with this step. These are generally assumed to be answers to
    /// field inputs, but they are not required to implement the `RSDAnswerResult` protocol.
    var inputResults: [RSDResult] { get set }
}

extension RSDCollectionResult {
    
    /// Find a result within this collection.
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findResult(with identifier: String) -> RSDResult? {
        return self.inputResults.first(where: { $0.identifier == identifier })
    }
    
    /// Find an *answer* result within this collection. This method will return `nil` if there is a result
    /// but that result does **not** conform to to the `RSDAnswerResult` protocol.
    ///
    /// - seealso: `RSDAnswerResultFinder`
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findAnswerResult(with identifier:String ) -> RSDAnswerResult? {
        return self.findResult(with: identifier) as? RSDAnswerResult
    }
    
    /// Append the result to the end of the input results, replacing the previous instance with the same identifier.
    /// - parameter result: The result to add to the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func appendInputResults(with result: RSDResult) -> RSDResult? {
        var previousResult: RSDResult?
        if let idx = inputResults.index(where: { $0.identifier == result.identifier }) {
            previousResult = inputResults.remove(at: idx)
        }
        inputResults.append(result)
        return previousResult
    }
    
    /// Append the result to the end of the input results, replacing the previous instance with the same identifier.
    /// - parameter result: The result to add to the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func removeInputResult(with identified: String) -> RSDResult? {
        guard let idx = inputResults.index(where: { $0.identifier == identifier }) else {
            return nil
        }
        return inputResults.remove(at: idx)
    }
}

/// `RSDFileResult` is a result that holds a pointer to a file url.
public protocol RSDFileResult : RSDResult {
    
    /// The URL with the path to the file-based result.
    var url: URL? { get }
    
    /// The MIME content type of the result.
    /// - example: `"application/json"`
    var contentType: String? { get }
    
    /// The system clock uptime when the recorder was started (if applicable).
    var startUptime: TimeInterval? { get }
}

/// `RSDErrorResult` is a result that holds information about an error.
public protocol RSDErrorResult : RSDResult {
    
    /// A description associated with an `NSError`.
    var errorDescription: String { get }
    
    /// A domain associated with an `NSError`.
    var errorDomain: String { get }
    
    /// The error code associated with an `NSError`.
    var errorCode: Int { get }
}

/// `RSDAnswerResultFinder` is a convenience protocol used to retrieve an answer result. It is used in
/// survey navigation to find the result for a given input field.
///
/// - seealso: `RSDSurveyNavigationStep`
public protocol RSDAnswerResultFinder {
    
    /// Find an *answer* result within this result. This method will return `nil` if there is a result
    /// but that result does **not** conform to to the `RSDAnswerResult` protocol.
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    func findAnswerResult(with identifier:String ) -> RSDAnswerResult?
}

/// `RSDAnswerResult` is a result that can be described using a single value.
public protocol RSDAnswerResult : RSDResult, RSDAnswerResultFinder {
    
    /// The answer type of the answer result. This includes coding information required to encode and
    /// decode the value. The value is expected to conform to one of the coding types supported by the answer type.
    var answerType: RSDAnswerResultType { get }
    
    /// The answer for the result.
    var value: Any? { get set }
}

extension RSDAnswerResult {
    
    /// This method will return `self` if the identifier matches the identifier of this result. Otherwise,
    /// the method will return `nil`.
    ///
    /// - seealso: `RSDAnswerResultFinder`
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findAnswerResult(with identifier:String ) -> RSDAnswerResult? {
        return self.identifier == identifier ? self : nil
    }
}




