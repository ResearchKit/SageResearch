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
import JsonModel

/// An `AnswerResult` is used to hold a serializable answer to a question or measurement. This
/// protocol is defined as a class to allow for mutating the `jsonValue` without requiring the
/// controller to keep replacing the result in the collection or task result that contains the
/// value. However, that means that the instance *must* be explicitly copied when using this
/// to revisit a question.
public protocol AnswerResult : class, RSDResult, AnswerFinder {
    
    /// Optional property for defining additional information about the answer expected for this result.
    var jsonAnswerType: AnswerType? { get }

    /// The answer held by this result.
    var jsonValue: JsonElement? { get set }
    
    /// The question text that was displayed for this answer result.
    var questionText: String? { get }
}

public extension AnswerResult {
    
    var value: Any? {
        return jsonValue?.jsonObject()
    }
    
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

/// A `CollectionResult` is used to describe a collection of results.
public protocol CollectionResult : RSDResult, AnswerFinder {

    /// The collection of results. This can be the async results of a sensor recorder, a response
    /// to a service call, or the results from a form where all the fields are displayed together
    /// and the results do not represent a linear path. The results within this set should each
    /// have a unique identifier.
    var inputResults: [RSDResult] { get set }
}

public extension CollectionResult {
    func findAnswer(with identifier: String) -> AnswerResult? {
        self.inputResults.first(where: { $0.identifier == identifier }) as? AnswerResult
    }
    
    /// Find a result within this collection.
    /// - parameter identifier: The identifier associated with the result.
    /// - returns: The result or `nil` if not found.
    func findResult(with identifier: String) -> RSDResult? {
        return self.inputResults.first(where: { $0.identifier == identifier })
    }
    
    /// Append the result to the end of the input results, replacing the previous instance with the same identifier.
    /// - parameter result: The result to add to the input results.
    /// - returns: The previous result or `nil` if there wasn't one.
    @discardableResult
    mutating func appendInputResults(with result: RSDResult) -> RSDResult? {
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
    mutating func removeInputResult(with identifier: String) -> RSDResult? {
        guard let idx = inputResults.firstIndex(where: { $0.identifier == identifier }) else {
            return nil
        }
        return inputResults.remove(at: idx)
    }
}

/// The `BranchNodeResult` is the result created for a given level of navigation of a node tree.
public protocol BranchNodeResult : CollectionResult {

    /// The running history of the nodes that were traversed as a part of running an assessment.
    /// This will only include a subset (section) that is the path defined at this level of the
    /// overall assessment hierarchy.
    var stepHistory: [RSDResult] { get set }
    
    /// The path traversed by this branch. The `nodePath` is specific to the navigation implemented
    /// on iOS and is different from the `path` implementation in the Kotlin-native framework.
    var nodePath: [String] { get set }
}

/// An `AssessmentResult` is the top-level `Result` for an assessment.
public protocol AssessmentResult : BranchNodeResult {

    /// A unique identifier for this run of the assessment. This property is defined as readwrite
    /// to allow the controller for the task to set this on the `AssessmentResult` children
    /// included in this run.
    var taskRunUUID: UUID { get set }

    /// The `versionString` may be a semantic version, timestamp, or sequential revision integer.
    var versionString: String? { get }
    
    ///  A unique identifier for a Assessment model associated with this result. This is explicitly
    /// included so that the `identifier` can be associated as per the needs of the developers and
    /// to allow for changes to the API that are not important to the researcher.
    var assessmentIdentifier: String? { get }
    
    /// A unique identifier for a schema associated with this result. This is explicitly
    /// included so that the `identifier` can be associated as per the needs of the developers and
    /// to allow for changes to the API that are not important to the researcher.
    var schemaIdentifier: String? { get }
}


// TODO: Remove once we have parity. syoung 06/30/2020

///**
// * A [Result] is any data result that should be included with an [Assessment]. The base level interface only has an
// * [identifier] and does not include any other properties. The [identifier] in this case may be either the
// * [ResultMapElement.resultIdentifier] *or* the [ResultMapElement.identifier] if the result identifier is undefined.
// *
// * TODO: syoung 01/10/2020 figure out a clean-ish way to encode the result and include in the base interface. In Swift, the `RSDResult` conforms to the `Encodable` protocol so it can be encoded to a JSON dictionary. Is there a Kotlin equivalent?
// *
// */
//interface Result {
//    fun copyResult(identifier: String = this.identifier) : Result
//
//    /**
//     * The identifier for the result. This identifier maps to the [ResultMapElement.resultIdentifier] for an associated
//     * [Assessment] element.
//     */
//    val identifier: String
//
//    /**
//     * The start date timestamp for the result.
//     */
//    var startDateString: String
//
//    /**
//     * The end date timestamp for the result.
//     */
//    var endDateString: String?
//}
//
//fun MutableSet<Result>.copyResults() = map { it.copyResult() }.toMutableSet()
//fun MutableList<Result>.copyResults() = map { it.copyResult() }.toMutableList()
//
///**
// * A [CollectionResult] is used to describe the output of a [Section], [FormStep], or [Assessment].
// */
//interface CollectionResult : Result {
//    override fun copyResult(identifier: String) : CollectionResult
//
//    /**
//     * The [inputResults] is a set that contains results that are recorded in parallel to the user-facing node
//     * path. This can be the async results of a sensor recorder, a response to a service call, or the results from a
//     * form where all the fields are displayed together and the results do not represent a linear path. The results
//     * within this set should each have a unique identifier.
//     */
//    var inputResults: MutableSet<Result>
//}
//
///**
// * The [BranchNodeResult] is the result created for a given level of navigation of a node tree. The
// * [pathHistoryResults] is additive where each time a node is traversed, it is added to the list.
// */
//interface BranchNodeResult : CollectionResult {
//    override fun copyResult(identifier: String) : BranchNodeResult
//
//    /**
//     * The [pathHistoryResults] includes the history of the [Node] results that were traversed as a part of running an
//     * [Assessment]. This will only include a subset that is the path defined at this level of the overall [Assessment]
//     * hierarchy.
//     */
//    var pathHistoryResults: MutableList<Result>
//
//    /**
//     * The path traversed by this branch.
//     */
//    val path: MutableList<PathMarker>
//}
//
//@Serializable
//data class PathMarker(val identifier: String, val direction: NavigationPoint.Direction)
//
///**
// * An [AssessmentResult] is the top-level [Result] for an [Assessment].
// */
//interface AssessmentResult : BranchNodeResult {
//    override fun copyResult(identifier: String) : AssessmentResult
//
//    /**
//     * A unique identifier for this run of the assessment. This property is defined as readwrite to allow the
//     * controller for the task to set this on the [AssessmentResult] children included in this run.
//     */
//    var runUUIDString: String
//
//    /**
//     * The [versionString] may be a semantic version, timestamp, or sequential revision integer. This should map to the
//     * [Assessment.versionString].
//     */
//    val versionString: String?
//}
//
///**
// * An [AnswerResult] is used to hold a serializable answer to a question or measurement.
// */
//interface AnswerResult : Result {
//    override fun copyResult(identifier: String) : AnswerResult
//
//    /**
//     * Optional property for defining additional information about the answer expected for this result.
//     */
//    val answerType: AnswerType?
//
//    /**
//     * The answer held by this result.
//     */
//    var jsonValue: JsonElement?
//}
