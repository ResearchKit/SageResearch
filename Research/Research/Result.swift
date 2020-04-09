//
//  Result.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

// TODO: syoung 04/06/2020 Deprecate the existing `RSDResult` in favor of the newer result protocols.
// The kotlin results do not *require* the startDate/endDate and other properties on all results.
// This allows for a simplier serialization strategy for handling stored results.

/// A `Result` is any data result that should be included with an `Assessment`. The base level
/// interface only has an `identifier` and does not include any other properties.
public protocol Result : Encodable, NSCopying {

    /// The identifier for the result.
    var identifier: String { get }
}

/// An `AnswerResult` is used to hold a serializable answer to a question or measurement. This
/// protocol is defined as a class to allow for mutating the `jsonValue` without requiring the
/// controller to keep replacing the result in the collection or task result that contains the
/// value. However, that means that the instance *must* be explicitly copied when using this
/// to revisit a question.
public protocol AnswerResult : class, Result {
    
    /// Optional property for defining additional information about the answer expected for this result.
    var jsonAnswerType: AnswerType? { get }

    /// The answer held by this result.
    var jsonValue: JsonElement? { get set }
    
    /// The question text that was displayed for this answer result.
    var questionText: String? { get }
    
    /// The answer for the result, converted from a JsonElement if needed.
    var value: Any? { get }
}

public extension AnswerResult {
    func findAnswer(with identifier:String ) -> AnswerResult? {
        return self.identifier == identifier ? self : nil
    }
    
    func encodingValue() throws -> JsonElement? {
        try self.jsonAnswerType?.encodeAnswer(from: self.jsonValue) ?? self.jsonValue
    }
}

public protocol AnswerFinder {
    
    /// Find an *answer* result within this result. This method will return `nil` if there is a
    /// result but that result does **not** conform to to the `AnswerResult` protocol.
    ///
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    func findAnswer(with identifier: String) -> AnswerResult?
}

// TODO: syoung 04/06/2020 These are stubbed out here for reference. These will require modification
// to the protocols in order to support using them while running a task instead of the older
// RSDResult protocols.

/// A `CollectionResult` is used to describe a collection of results.
public protocol CollectionResult : Result, AnswerFinder {

    /// The collection of results. This can be the async results of a sensor recorder, a response
    /// to a service call, or the results from a form where all the fields are displayed together
    /// and the results do not represent a linear path. The results within this set should each
    /// have a unique identifier.
    var inputResults: [Result] { get }
}

/// The `BranchNodeResult` is the result created for a given level of navigation of a node tree.
public protocol BranchNodeResult : CollectionResult {

    /// The running history of the nodes that were traversed as a part of running an assessment.
    /// This will only include a subset (section) that is the path defined at this level of the
    /// overall assessment hierarchy.
    var pathHistoryResults: [Result] { get }
}

/// An `AssessmentResult` is the top-level `Result` for an assessment.
public protocol AssessmentResult : BranchNodeResult {

    /// A unique identifier for this run of the assessment. This property is defined as readwrite
    /// to allow the controller for the task to set this on the `AssessmentResult` children
    /// included in this run.
    var runUUIDString: String { get set }

    /// The `versionString` may be a semantic version, timestamp, or sequential revision integer.
    var versionString: String? { get }

    /// The start date timestamp for the result.
    var startDateString: String { get }

    /// The end date timestamp for the result.
    var endDateString: String { get }
}
