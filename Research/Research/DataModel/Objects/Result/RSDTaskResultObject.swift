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
public struct RSDTaskResultObject : RSDTaskRunResult, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, type, startDate, endDate, taskRunUUID, schemaInfo, stepHistory, asyncResults, nodePath
        case assessmentIdentifier, schemaIdentifier, versionString
    }
    
    /// The identifier associated with the task, step, or asynchronous action.
    public let identifier: String
    
    /// A String that indicates the type of the result. This is used to decode the result using a `RSDFactory`.
    public let type: RSDResultType
    
    /// The start date timestamp for the result.
    public var startDate: Date = Date()
    
    /// The end date timestamp for the result.
    public var endDate: Date = Date()
    
    /// A unique identifier for this task run.
    public var taskRunUUID: UUID
    
    /// Schema info associated with this task.
    public var schemaInfo: RSDSchemaInfo?
    
    /// A listing of the step history for this task or section. The listed step results should *only* include the
    /// last result for any given step.
    public var stepHistory: [RSDResult] = []
    
    /// A list of all the asynchronous results for this task. The list should include uniquely identified results.
    public var asyncResults: [RSDResult]?
    
    /// The path to the current result.
    public var nodePath: [String] = []
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - schemaInfo: The schemaInfo associated with this task result. Default = `nil`.
    public init(identifier: String, schemaInfo: RSDSchemaInfo? = nil) {
        self.identifier = identifier
        self.schemaInfo = schemaInfo
        self.taskRunUUID = UUID()
        self.type = .task
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `stepHistory`, `asyncResults`, and `schemaInfo`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decode(RSDResultType.self, forKey: .type)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.taskRunUUID = try container.decode(UUID.self, forKey: .taskRunUUID)
        self.nodePath = try container.decodeIfPresent([String].self, forKey: .nodePath) ?? []
        
        if container.contains(.schemaInfo) {
            let nestedDecoder = try container.superDecoder(forKey: .schemaInfo)
            self.schemaInfo = try decoder.factory.decodeSchemaInfo(from: nestedDecoder)
        }
        else if let schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier),
            let versionString = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier) {
            self.schemaInfo = RSDSchemaInfoObject(identifier: schemaIdentifier,
                                                  revision: (versionString as NSString).integerValue)
        }
        
        let resultsContainer = try container.nestedUnkeyedContainer(forKey: .stepHistory)
        self.stepHistory = try decoder.factory.decodePolymorphicArray(RSDResult.self, from: resultsContainer)
        
        if container.contains(.asyncResults) {
            let asyncResultsContainer = try container.nestedUnkeyedContainer(forKey: .asyncResults)
            self.asyncResults = try decoder.factory.decodePolymorphicArray(RSDResult.self, from: asyncResultsContainer)
        }
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
        try container.encode(taskRunUUID, forKey: .taskRunUUID)
        try container.encode(nodePath, forKey: .nodePath)
        
        // For now, include both the "old" schema info keys and the new ones.
        try container.encodeIfPresent(self.assessmentIdentifier, forKey: .assessmentIdentifier)
        try container.encodeIfPresent(self.schemaIdentifier, forKey: .schemaIdentifier)
        try container.encodeIfPresent(self.versionString, forKey: .schemaIdentifier)
        let nestedEncoder = container.superEncoder(forKey: .schemaInfo)
        try encoder.factory.encodeSchemaInfo(from: self, to: nestedEncoder)
        
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
}

extension RSDTaskResultObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .type, .identifier, .startDate, .endDate, .taskRunUUID, .stepHistory:
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
        case .type:
            return .init(constValue: RSDResultType.task)
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .assessmentIdentifier, .schemaIdentifier, .versionString:
            return .init(propertyType: .primitive(.string))
        case .startDate, .endDate:
            return .init(propertyType: .format(.dateTime))
        case .taskRunUUID:
            return .init(propertyType: .primitive(.string))
        case .schemaInfo:
            return .init(propertyType: .reference(RSDSchemaInfoObject.documentableType()))
        case .stepHistory, .asyncResults:
            return .init(propertyType: .interfaceArray("\(RSDResult.self)"))
        case .nodePath:
            return .init(propertyType: .primitiveArray(.string))
        }
    }
    
    public static func examples() -> [RSDTaskResultObject] {
        
        var result = RSDTaskResultObject(identifier: "example")
        result.schemaInfo = RSDSchemaInfoObject(identifier: "example schema", revision: 3)
        
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
        
        var fileResult = RSDFileResultObject.examples().first!
        fileResult.startDate = collectionResult.startDate
        fileResult.endDate = collectionResult.endDate
        result.asyncResults = [fileResult]
        
        result.startDate = introStepResult.startDate
        result.endDate = conclusionStepResult.endDate
        
        return [result]
    }
}
