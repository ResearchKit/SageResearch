//
//  ORKTaskResult+Research.swift
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

fileprivate var _schemaInfoMap: [UUID : RSDSchemaInfo] = [:]
fileprivate var _asyncResults: [UUID : [RSDResult]] = [:]

/// The `ORKStepResult` implements the `RSDCollectionResult` protocol.
extension ORKTaskResult : RSDTaskResult {
    
    public convenience init(from taskResult: RSDTaskResult) {
        self.init(identifier: taskResult.identifier)
        self.results = taskResult.stepHistory.map { ORKStepResult(from: $0) }
    }
    
    /// Schema info is stored to a private static var.
    public var schemaInfo: RSDSchemaInfo? {
        get {
            return _schemaInfoMap[self.taskRunUUID]
        }
        set(newValue) {
            _schemaInfoMap[self.taskRunUUID] = newValue
        }
    }
    
    /// step history is mapped to `results`.
    public var stepHistory: [RSDResult] {
        get {
            return self.results?.compactMap { $0 as? RSDResult } ?? []
        }
        set(newValue) {
            self.results = newValue.compactMap { $0 as? ORKResult }
        }
    }
    
    /// Async results are stored to a private static var.
    public var asyncResults: [RSDResult]? {
        get {
            return _asyncResults[self.taskRunUUID]
        }
        set(newValue) {
            _asyncResults[self.taskRunUUID] = newValue
        }
    }
    
    /// Returns `.task`
    public var type: RSDResultType {
        return .task
    }
    
    /// Encodes the result as an `RSDTaskResultObject`
    public func encode(to encoder: Encoder) throws {
        var result = RSDTaskResultObject(identifier: identifier)
        result.startDate = startDate
        result.endDate = endDate
        result.stepHistory = self.stepHistory
        try result.encode(to: encoder)
    }
}
