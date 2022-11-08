//
//  RSDTaskInfoStepObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

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
    public func instantiateStepResult() -> ResultData {
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

