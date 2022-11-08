//
//  ResultNodeSerializer.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Will be deleted in a future version.")
public final class ResultNodeSerializer : IdentifiableInterfaceSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `ResultNode` is an interface used to allow for a related grouping of questions.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    public var jsonSchema: URL {
        URL(string: "\(RSDFactory.shared.modelName(for: self.interfaceName)).json", relativeTo: kSageJsonSchemaBaseURL)!
    }
    
    override init() {
        let examples: [SerializableResultNode] = [
            ChoiceQuestionStepObject.serializationExample(),
            MultipleInputQuestionStepObject.serializationExample(),
            SimpleQuestionStepObject.serializationExample(),
            StringChoiceQuestionStepObject.serializationExample(),
        ]
        self.examples = examples
    }
    
    public private(set) var examples: [ResultNode]
    
    public func add(_ example: SerializableResultNode) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol SerializableResultNode : ResultNode, PolymorphicRepresentable {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension ChoiceQuestionStepObject : SerializableResultNode {}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension MultipleInputQuestionStepObject : SerializableResultNode {}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension SimpleQuestionStepObject : SerializableResultNode {}
