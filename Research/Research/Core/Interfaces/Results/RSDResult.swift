//
//  RSDResult.swift
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
import JsonModel

/// `RSDResult` is the base implementation for a result associated with a task, step, or asynchronous action.
///
/// When running a task, there will be a result of some variety used to mark each step in the task. This is
/// the base protocol. All the `RSDResult` objects are required to conform to the `Encodable` protocol to allow
/// the app to store and upload results in a standardized way.
///
/// - note: syoung 04/16/2020 Since the purpose of the `Result` protocol is to support
/// serialization of the result set, and since this framework is no longer reverse-compatible to
/// ResearchKit.ORKResult objects, these objected are now defined as `PolymorphicRepresentable`
/// and `Encodable`.
///
public protocol RSDResult : PolymorphicRepresentable, Encodable {
    
    /// The identifier associated with the task, step, or asynchronous action.
    var identifier: String { get }
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    var type: RSDResultType { get }
    
    /// The start date timestamp for the result.
    var startDate: Date { get set }
    
    /// The end date timestamp for the result.
    var endDate: Date { get set }
}

extension RSDResult {
    
    public var typeName: String {
        type.rawValue
    }
    
    func shortDescription() -> String {
        if let answerResult = self as? AnswerResult {
            return "{\(self.identifier) : \(String(describing: answerResult.value)))}"
        }
        else if let collectionResult = self as? CollectionResult {
            return "{\(self.identifier) : \(collectionResult.inputResults.map ({ $0.shortDescription() }))}"
        }
        else if let taskResult = self as? RSDTaskResult {
            return "{\(self.identifier) : \(taskResult.stepHistory.map ({ $0.shortDescription() }))}"
        }
        else {
            return self.identifier
        }
    }
}
