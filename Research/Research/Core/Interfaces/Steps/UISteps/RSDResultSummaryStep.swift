//
//  RSDResultSummaryStep.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
        else if let answerResult = (cResult as? RSDAnswerResultFinder)?.findAnswerResult(with: resultIdentifier) {
            return (answerResult.value, answerResult.answerType.answerType)
        }
        else {
            return nil
        }
    }
}
