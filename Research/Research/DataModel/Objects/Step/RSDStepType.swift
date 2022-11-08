//
//  RSDStepType.swift
//  Research
//

import Foundation
import JsonModel

/// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
/// the UI.
public struct RSDStepType : RSDFactoryTypeRepresentable, Codable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    enum StandardType : String, Codable, CaseIterable {
        
        case active
        case completion
        case countdown
        case feedback
        case instruction
        case overview
        case section
        case transform
        case taskInfo
        case subtask
        
        var type: RSDStepType {
            return RSDStepType(rawValue: self.rawValue)
        }
    }
    
    enum QuestionType : String, Codable, CaseIterable {
        case simpleQuestion
        case multipleInputQuestion
        case choiceQuestion
        case stringChoiceQuestion
        
        var type: RSDStepType {
            return RSDStepType(rawValue: self.rawValue)
        }
    }
    
    /// Defaults to creating a `RSDActiveUIStepObject`.
    public static let active = StandardType.active.type
    
    /// Defaults to creating a `RSDResultSummaryStepObject` used to mark task completion.
    public static let completion = StandardType.completion.type
    
    /// Defaults to creating a `RSDActiveUIStepObject` used as a countdown to an active step.
    public static let countdown = StandardType.countdown.type
    
    /// Defaults to creating a `RSDResultSummaryStepObject` used show the user results.
    public static let feedback = StandardType.feedback.type
    
    /// Defaults to creating a `RSDActiveUIStep`.
    public static let instruction = StandardType.instruction.type
    
    /// Defaults to creating a `RSDOverviewStepObject`.
    public static let overview = StandardType.overview.type

    /// Defaults to creating a `RSDSectionStep`.
    public static let section = StandardType.section.type
    
    /// Defaults to creating a `RSDSectionStep` created using a `RSDTransformerStep`.
    public static let transform = StandardType.transform.type
    
    /// Defaults to creating a `RSDTaskInfoStep`.
    public static let taskInfo = StandardType.taskInfo.type
    
    /// Defaults to creating a `RSDSubtaskStep`.
    public static let subtask = StandardType.subtask.type
    
    public static let simpleQuestion = QuestionType.simpleQuestion.type
    public static let multipleInputQuestion = QuestionType.multipleInputQuestion.type
    public static let choiceQuestion = QuestionType.choiceQuestion.type
    public static let stringChoiceQuestion = QuestionType.stringChoiceQuestion.type
    
    @available(*, deprecated, message: "Replaced with the appropriate `QuestionType`")
    public static let form: RSDStepType = "form"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDStepType] {
        var types = StandardType.allCases.map { $0.type }
        types.append(contentsOf: QuestionType.allCases.map { $0.type })
        return types
    }
}

extension RSDStepType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDStepType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}

public final class StepSerializer : IdentifiableInterfaceSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `Step` is the base protocol for the steps that can compose a task for presentation using
        a controller appropriate to the device and application. Each `RSDStep` object represents one
        logical piece of data entry, information, or activity in a larger task.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    public var jsonSchema: URL {
        URL(string: "\(RSDFactory.shared.modelName(for: self.interfaceName)).json", relativeTo: kSageJsonSchemaBaseURL)!
    }
    
    override init() {
        let uiExamples: [SerializableStep] = [
            RSDActiveUIStepObject.serializationExample(),
            RSDCountdownUIStepObject.serializationExample(),
            RSDCompletionStepObject.serializationExample(),
            RSDInstructionStepObject.serializationExample(),
            RSDResultSummaryStepObject.serializationExample(),
            RSDOverviewStepObject.serializationExample(),
        ]
        let questionExamples: [SerializableStep] = [
            ChoiceQuestionStepObject.serializationExample(),
            MultipleInputQuestionStepObject.serializationExample(),
            SimpleQuestionStepObject.serializationExample(),
            StringChoiceQuestionStepObject.serializationExample(),
        ]
        let nodeExamples: [SerializableStep] = [
            RSDSectionStepObject.serializationExample(),
            RSDTaskInfoStepObject.serializationExample(),
            RSDStepTransformerObject.serializableExample(),
        ]
        self.examples = [uiExamples, questionExamples, nodeExamples].flatMap { $0 }
    }
    
    public private(set) var examples: [RSDStep]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDStepType.documentableType()))
    }
    
    public func add(_ example: SerializableStep) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

public protocol SerializableStep : RSDStep, PolymorphicRepresentable {
}

public extension SerializableStep {
    var typeName: String { return stepType.rawValue }
}

extension RSDUIStepObject : SerializableStep {
    internal static func serializationExample() -> Self {
        self.init(identifier: self.defaultType().rawValue)
    }
}

extension RSDTaskInfoStepObject : SerializableStep {
    internal static func serializationExample() -> RSDTaskInfoStepObject {
        self.examples().first!
    }
}

extension RSDSectionStepObject : SerializableStep {
    internal static func serializationExample() -> RSDSectionStepObject {
        RSDSectionStepObject(identifier: RSDStepType.section.rawValue, steps: [])
    }
}

extension RSDStepTransformerObject : SerializableStep {
}
