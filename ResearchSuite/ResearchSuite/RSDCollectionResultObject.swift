//
//  RSDCollectionResultObject.swift
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

/// `RSDCollectionResultObject` is used include multiple results associated with a single step or async action that
/// may have more that one result.
public struct RSDCollectionResultObject : RSDCollectionResult, Codable {
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let type: RSDResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// The list of input results associated with this step. These are generally assumed to be answers to
    /// field inputs, but they are not required to implement the `RSDAnswerResult` protocol.
    public var inputResults: [RSDResult]
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    public init(identifier: String) {
        self.identifier = identifier
        self.type = .collection
        self.inputResults = []
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, startDate, endDate, inputResults
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `inputResults`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.type = try container.decode(RSDResultType.self, forKey: .type)
        
        let resultsContainer = try container.nestedUnkeyedContainer(forKey: .inputResults)
        self.inputResults = try decoder.factory.decodeResults(from: resultsContainer)
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(type, forKey: .type)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .inputResults)
        for result in inputResults {
            let nestedEncoder = nestedContainer.superEncoder()
            try result.encode(to: nestedEncoder)
        }
    }
}

extension RSDCollectionResultObject : RSDDocumentableDecodableObject {
    
    static func codingMap() -> Array<(CodingKey, Any.Type, String)> {
        let codingKeys: [CodingKeys] = [.identifier, .type, .startDate, .endDate, .inputResults]
        return codingKeys.map {
            switch $0 {
            case .identifier:
                return ($0, String.self, "The identifier associated with the task, step, or asynchronous action.")
            case .type:
                return ($0, RSDResultType.self, "A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.")
            case .startDate:
                return ($0, Date.self, "The start date timestamp for the result.")
            case .endDate:
                return ($0, Date.self, "The end date timestamp for the result.")
            case .inputResults:
                return ($0, [RSDResult].self, "The list of input results associated with this step.")
            }
        }
    }
    
    static func exampleResult() -> RSDCollectionResultObject {
        var result = RSDCollectionResultObject(identifier: "formStep")
        result.startDate = RSDClassTypeMap.shared.timestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        result.endDate = result.startDate.addingTimeInterval(5 * 60)
        result.inputResults = RSDAnswerResultObject.answerResultExamples()
        return result
    }
    
    static func examples() -> [Encodable] {
        let result = exampleResult()
        return [result]
    }
}
