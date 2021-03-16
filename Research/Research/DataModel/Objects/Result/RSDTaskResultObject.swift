//
//  RSDTaskResultObject.swift
//  Research
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
import JsonModel

/// `RSDTaskResultObject` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public struct RSDTaskResultObject : SerializableResultData, AssessmentResult, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, serializableType = "type", startDate, endDate, taskRunUUID, assessmentIdentifier, schemaIdentifier, versionString, stepHistory, asyncResults, nodePath
    }
    public private(set) var serializableType: SerializableResultType = .task
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    public let versionString: String?
    public let assessmentIdentifier: String?
    public let schemaIdentifier: String?

    public var startDate: Date = Date()
    public var endDate: Date = Date()
    public var taskRunUUID: UUID = UUID()
    public var stepHistory: [ResultData] = []
    public var asyncResults: [ResultData]?
    public var nodePath: [String] = []
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - schemaInfo: The schemaInfo associated with this task result. Default = `nil`.
    public init(identifier: String,
                versionString: String? = nil,
                assessmentIdentifier: String? = nil,
                schemaIdentifier: String? = nil) {
        self.identifier = identifier
        self.versionString = versionString
        self.assessmentIdentifier = assessmentIdentifier
        self.schemaIdentifier = schemaIdentifier
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `stepHistory`, `asyncResults`, and `schemaInfo`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.taskRunUUID = try container.decode(UUID.self, forKey: .taskRunUUID)
        self.nodePath = try container.decodeIfPresent([String].self, forKey: .nodePath) ?? []
        self.versionString = try container.decodeIfPresent(String.self, forKey: .versionString)
        self.assessmentIdentifier = try container.decodeIfPresent(String.self, forKey: .assessmentIdentifier)
        self.schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier)
        
        let resultsContainer = try container.nestedUnkeyedContainer(forKey: .stepHistory)
        self.stepHistory = try decoder.factory.decodePolymorphicArray(ResultData.self, from: resultsContainer)
        
        if container.contains(.asyncResults) {
            let asyncResultsContainer = try container.nestedUnkeyedContainer(forKey: .asyncResults)
            self.asyncResults = try decoder.factory.decodePolymorphicArray(ResultData.self, from: asyncResultsContainer)
        }
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(serializableType, forKey: .serializableType)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(taskRunUUID, forKey: .taskRunUUID)
        try container.encode(nodePath, forKey: .nodePath)
        try container.encodeIfPresent(self.assessmentIdentifier, forKey: .assessmentIdentifier)
        try container.encodeIfPresent(self.schemaIdentifier, forKey: .schemaIdentifier)
        try container.encodeIfPresent(self.versionString, forKey: .versionString)
    
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .stepHistory)
        for result in stepHistory {
            let nestedEncoder = nestedContainer.superEncoder()
            try result.encode(to: nestedEncoder)
        }
        
        if let results = asyncResults {
            var asyncContainer = container.nestedUnkeyedContainer(forKey: .asyncResults)
            for result in results {
                let nestedEncoder = asyncContainer.superEncoder()
                try result.encode(to: nestedEncoder)
            }
        }
    }
    
    public func deepCopy() -> RSDTaskResultObject {
        var copy = RSDTaskResultObject(identifier: self.identifier,
                                       versionString: self.versionString,
                                       assessmentIdentifier: self.assessmentIdentifier,
                                       schemaIdentifier: self.schemaIdentifier)
        copy.startDate = self.startDate
        copy.endDate = self.endDate
        copy.taskRunUUID = self.taskRunUUID
        copy.stepHistory = self.stepHistory.map { $0.deepCopy() }
        copy.asyncResults = self.asyncResults?.map { $0.deepCopy() }
        copy.nodePath = self.nodePath
        return copy
    }
}

extension RSDTaskResultObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .serializableType, .identifier, .startDate, .endDate, .taskRunUUID, .stepHistory:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: SerializableResultType.task)
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .assessmentIdentifier, .schemaIdentifier, .versionString:
            return .init(propertyType: .primitive(.string))
        case .startDate, .endDate:
            return .init(propertyType: .format(.dateTime))
        case .taskRunUUID:
            return .init(propertyType: .primitive(.string))
        case .stepHistory, .asyncResults:
            return .init(propertyType: .interfaceArray("\(ResultData.self)"))
        case .nodePath:
            return .init(propertyType: .primitiveArray(.string))
        }
    }
    
    public static func examples() -> [RSDTaskResultObject] {
        
        var result = RSDTaskResultObject(identifier: "example")
        
        var introStepResult = RSDResultObject(identifier: "introduction")
        introStepResult.startDate = ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!
        introStepResult.endDate = introStepResult.startDate.addingTimeInterval(20)
        var collectionResult = RSDCollectionResultObject.examples().first!
        collectionResult.startDate = introStepResult.endDate
        collectionResult.endDate = collectionResult.startDate.addingTimeInterval(2 * 60)
        var conclusionStepResult = RSDResultObject(identifier: "conclusion")
        conclusionStepResult.startDate = collectionResult.endDate
        conclusionStepResult.endDate = conclusionStepResult.startDate.addingTimeInterval(20)
        result.stepHistory = [introStepResult, collectionResult, conclusionStepResult]
        
        var fileResult = FileResultObject.examples().first!
        fileResult.startDate = collectionResult.startDate
        fileResult.endDate = collectionResult.endDate
        result.asyncResults = [fileResult]
        
        result.startDate = introStepResult.startDate
        result.endDate = conclusionStepResult.endDate
        
        return [result]
    }
}
