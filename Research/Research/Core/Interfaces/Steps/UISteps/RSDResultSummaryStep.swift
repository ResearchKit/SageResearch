//
//  RSDResultSummaryStep.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// A result summary step is used to display a result that is calculated or measured earlier in the task.
public protocol RSDResultSummaryStep : RSDUIStep {
    
    /// Text to display as the title above the result.
    var resultTitle: String? { get }
    
    /// The identifier for the result to display.
    var resultIdentifier: String? { get }
    
    /// The step result identifier for the result to display.
    var stepResultIdentifier: String? { get }
    
    /// The localized unit to display for this result.
    var unitText: String? { get }
}

extension RSDResultSummaryStep {
    
    /// Get the result to display as the answer from the task result.
    /// - parameter taskResult: The task result for this step.
    /// - returns: The answer (if any).
    public func answerValueAndType(from taskResult: RSDTaskResult) -> (value: Any?, answerType: AnswerType?)? {
        guard let resultIdentifier = self.resultIdentifier else { return nil }
        let cResult = (self.stepResultIdentifier != nil) ? taskResult.findResult(with: self.stepResultIdentifier!) : taskResult
        if let answerResult = (cResult as? AnswerFinder)?.findAnswer(with: resultIdentifier) {
            return (answerResult.value, answerResult.jsonAnswerType)
        }
        else {
            return nil
        }
    }
}
