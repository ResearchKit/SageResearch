//
//  RSDStepTransformerObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// `RSDStepTransformerObject` is used in decoding a step with replacement properties for some or all of the steps in a
/// section that is defined using a different resource. The factory will convert this step into an appropriate
/// `RSDSectionStep` from the decoded object.
public struct RSDStepTransformerObject : RSDStepTransformer, RSDStep, Decodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, stepType = "type", resourceTransformer
    }
    
    public private(set) var stepType: RSDStepType = .transform
    
    /// The transformed step.
    public let transformedStep: RSDStep!
    
    /// Initialize from a `Decoder`. 
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes a transformation step. The section is created from the
    ///         // resource and then the values in the `replacementSteps` are used to mutate that step.
    ///         let json = """
    ///            {
    ///             "identifier"         : "heartRate.before",
    ///             "type"               : "transform",
    ///             "resourceTransformer"    : { "resourceName": "HeartrateStep.json"}
    ///            }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        
        // get the step from the resource.
        let resourceTransformer = try container.decode(RSDResourceTransformerObject.self, forKey: .resourceTransformer)
        let (data, resourceType) = try resourceTransformer.resourceData(using: decoder)
        let resourceDecoder = try decoder.factory.createDecoder(for: resourceType,
                                                                taskIdentifier: decoder.taskIdentifier,
                                                                schemaInfo: decoder.schemaInfo,
                                                                resourceInfo: _ResourceInfo(from: decoder))
        let stepDecoder = try resourceDecoder.decode(_StepDecoder.self, from: data)
        
        // copy to transformer
        if let copyableStep = stepDecoder.step as? RSDCopyStep {
            self.transformedStep = try copyableStep.copy(with: identifier, decoder: decoder)
        }
        else if let copyableStep = stepDecoder.step as? RSDCopyWithIdentifier {
            self.transformedStep = (copyableStep.copy(with: identifier) as! RSDStep)
        }
        else {
            self.transformedStep = stepDecoder.step
        }
    }
    
    private init() {
        self.transformedStep = PlaceholderStep(identifier: RSDStepType.transform.rawValue)
    }

    internal static func serializableExample() -> RSDStepTransformerObject { .init() }
    
    // Wrapper for the transformed step.
    
    public var identifier: String {
        transformedStep.identifier
    }
    
    public func instantiateStepResult() -> ResultData {
        transformedStep.instantiateStepResult()
    }
    
    public func validate() throws {
        try transformedStep.validate()
    }
}

fileprivate struct _ResourceInfo : ResourceInfo {
    let factoryBundle: ResourceBundle?
    let packageName: String?
    var bundleIdentifier: String? { return nil }
    init(from decoder: Decoder) {
        self.factoryBundle = decoder.bundle
        self.packageName = decoder.packageName
    }
}

fileprivate struct _StepDecoder: Decodable {
    
    let step: RSDStep
    
    init(from decoder: Decoder) throws {
        self.step = try decoder.factory.decodePolymorphicObject(RSDStep.self, from: decoder)
    }
}

fileprivate struct PlaceholderStep: RSDStep {
    let identifier: String
    let stepType: RSDStepType = "placeholder"
    func instantiateStepResult() -> ResultData { ResultObject(identifier: identifier) }
    func validate() throws { }
}

extension RSDStepTransformerObject : DocumentableObject {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isOpen() -> Bool { false }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { true }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .stepType:
            return .init(constValue: RSDStepType.transform)
        case .resourceTransformer:
            return .init(propertyType: .reference(RSDResourceTransformerObject.documentableType()))
        }
    }
    
    public static func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[ "identifier" : "heartRate.before",
          "type" : "transform",
          "resourceTransformer" : ["resourceName" : "HeartrateStep.json"]
        ]]
    }
}
