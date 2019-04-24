//
//  RSDCollectionResult.swift
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
    
    /// Return a mapping of all the `RSDAnswerResult` objects in this collection as a mapping
    /// of the identifier to the value.
    public func answers() -> [String : Any] {
        return self.inputResults.reduce(into: [String : Any]()) { (hashtable, result) in
            guard let answerResult = result as? RSDAnswerResult, let value = answerResult.value else { return }
            hashtable[answerResult.identifier] = value
        }
    }
    
    /// Append the result to the end of the input results, replacing the previous instance with the same identifier.
    /// - parameter result: The result to add to the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func appendInputResults(with result: RSDResult) -> RSDResult? {
        var previousResult: RSDResult?
        if let idx = inputResults.firstIndex(where: { $0.identifier == result.identifier }) {
            previousResult = inputResults.remove(at: idx)
        }
        inputResults.append(result)
        return previousResult
    }
    
    /// Remove the result with the given identifier.
    /// - parameter result: The result to remove from the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating public func removeInputResult(with identifier: String) -> RSDResult? {
        guard let idx = inputResults.firstIndex(where: { $0.identifier == identifier }) else {
            return nil
        }
        return inputResults.remove(at: idx)
    }
}
