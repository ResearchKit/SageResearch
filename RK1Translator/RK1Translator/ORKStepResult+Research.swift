//
//  ORKStepResult+Research.swift
//  RK1Translator
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

func _orkResult(from rsdResult: RSDResult) -> ORKResult {
    if let result = rsdResult as? ORKResult {
        return result
    }
    else if let result = rsdResult as? RSDAnswerResult {
        return result.orkResult()
    }
    else if let result = rsdResult as? RSDFileResult {
        return ORKFileResult(from: result)
    }
    else {
        let result = ORKResult(identifier: rsdResult.identifier)
        result.startDate = rsdResult.startDate
        result.endDate = rsdResult.endDate
        return result
    }
}

/// The `ORKStepResult` implements the `RSDCollectionResult` protocol.
extension ORKStepResult : RSDCollectionResult {
    
    public convenience init(from result: RSDResult) {
        self.init(identifier: result.identifier)
        if let collectionResult = result as? RSDCollectionResult {
            self.results = collectionResult.inputResults.map { _orkResult(from: $0) }
        }
        else if let taskResult = result as? RSDTaskResult {
            self.results = taskResult.stepHistory.map { _orkResult(from: $0) }
        }
        else {
            self.results = [_orkResult(from: result)]
        }
    }
    
    /// Map and filter `results` to/from `RSDResult`.
    public var inputResults: [RSDResult] {
        get {
            return self.results?.compactMap { $0 as? RSDResult } ?? []
        }
        set(newValue) {
            self.results = newValue.compactMap { $0 as? ORKResult }
        }
    }
    
    /// Returns `.collection`
    public var type: RSDResultType {
        return .collection
    }
    
    /// Encodes the result as an `RSDCollectionResultObject`
    public func encode(to encoder: Encoder) throws {
        var result = RSDCollectionResultObject(identifier: identifier)
        result.startDate = startDate
        result.endDate = endDate
        result.inputResults = self.inputResults
        try result.encode(to: encoder)
    }
}
