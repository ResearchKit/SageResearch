//
//  RSDAnswerResult.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

/// `RSDAnswerResult` is a result that can be described using a single value.
@available(*, deprecated, message: "Implement `AnswerResult` instead.")
public protocol RSDAnswerResult : RSDResult, RSDAnswerResultFinder {
    
    /// The answer type of the answer result. This includes coding information required to encode and
    /// decode the value. The value is expected to conform to one of the coding types supported by the answer type.
    var answerType: RSDAnswerResultType { get }
    
    /// The answer for the result.
    var value: Any? { get }
    
    /// The question associated with this answer in localized text.
    var questionText: String? { get }
}

@available(*, deprecated, message: "Implement `AnswerResult` instead.")
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

/// `RSDAnswerResultFinder` is a convenience protocol used to retrieve an answer result. It is used in
/// survey navigation to find the result for a given input field.
///
/// - seealso: `RSDSurveyNavigationStep`
@available(*, deprecated, message: "Implement `AnswerResult` instead.")
public protocol RSDAnswerResultFinder {
    
    /// Find an *answer* result within this result. This method will return `nil` if there is a result
    /// but that result does **not** conform to to the `RSDAnswerResult` protocol.
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    func findAnswerResult(with identifier:String ) -> RSDAnswerResult?
}
