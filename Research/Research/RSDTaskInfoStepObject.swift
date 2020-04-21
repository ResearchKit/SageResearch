//
//  RSDTaskInfoStepObject.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

/// `RSDTaskInfoStepObject` is a concrete implementation of the `RSDTaskInfoStep` protocol.
public struct RSDTaskInfoStepObject : RSDTaskInfoStep, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case stepType = "type"
    }

    /// Returns the task info identifier.
    public var identifier: String {
        return self.taskInfo.identifier
    }
    
    /// For the task info step, the task info
    public let taskInfo : RSDTaskInfo

    /// The type of the step.
    public private(set) var stepType: RSDStepType = .taskInfo
    
    /// Default initializer.
    /// - parameter identifier: A short string that uniquely identifies the step.
    @available(*, deprecated, message: "Kotlin serialization requires a one-to-one mapping of the 'type' keyword.")
    public init(with taskInfo: RSDTaskInfo, stepType: RSDStepType = .taskInfo) {
        self.taskInfo = taskInfo
        self.stepType = stepType
    }
    
    public init(with taskInfo: RSDTaskInfoObject) {
        self.taskInfo = taskInfo
    }
    
    public init(from decoder: Decoder) throws {
        self.taskInfo = try RSDTaskInfoObject(from: decoder)
    }
    
    private init(_ taskInfo: RSDTaskInfo, _ stepType: RSDStepType) {
        self.taskInfo = taskInfo
        self.stepType = stepType
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let encodable = self.taskInfo as? Encodable else {
            let context = EncodingError.Context(codingPath: encoder.codingPath,
                                                debugDescription: "\(self.taskInfo) does not conform to the Encodable protocol")
            throw EncodingError.invalidValue(self.taskInfo, context)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.stepType, forKey: .stepType)
        try encodable.encode(to: encoder)
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDTaskInfoStepObject {
        RSDTaskInfoStepObject(self.taskInfo.copy(with: identifier), stepType)
    }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: `RSDTaskResultObject` with the `identifier` from this task reference.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    /// Required method for the `RSDStep` protocol. No validation for this step.
    public func validate() throws {
    }
}

extension RSDTaskInfoStepObject : DocumentableStruct {

    public static func codingKeys() -> [CodingKey] {
        var codingKeys = RSDTaskInfoObject.codingKeys()
        codingKeys.append(contentsOf: CodingKeys.allCases)
        return codingKeys
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        RSDTaskInfoObject.isRequired(codingKey) || (codingKey is CodingKeys)
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try RSDTaskInfoObject.documentProperty(for: codingKey)
        }
        switch key {
        case .stepType:
            return .init(constValue: RSDStepType.taskInfo)
        }
    }
    
    public static func examples() -> [RSDTaskInfoStepObject] {
        [RSDTaskInfoStepObject(with: RSDTaskInfoObject.examples().first!)]
    }
}

