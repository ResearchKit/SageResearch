//
//  RSDFactory.swift
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
import Formatters

public protocol RSDFactoryTypeRepresentable : RawRepresentable, ExpressibleByStringLiteral {
    var stringValue: String { get }
}

/// `RSDFactory` handles customization of decoding the elements of a task. Applications should
/// override this factory to add custom elements required to run their task modules.
open class RSDFactory : SerializationFactory {
    
    public static var shared = RSDFactory.defaultFactory
    
    public let answerTypeSerializer = AnswerTypeSerializer()
    public let asyncActionSerializer = AsyncActionConfigurationSerializer()
    public let buttonActionSerializer = ButtonActionSerializer()
    public let colorMappingSerializer = ColorMappingSerializer()
    public let imageThemeSerializer = ImageThemeSerializer()
    public let inputItemSerializer = InputItemSerializer()
    public let resultSerializer = RSDResultSerializer()
    public let resultNodeSerializer = ResultNodeSerializer()
    public let stepSerializer = StepSerializer()
    public let taskSerializer = TaskSerializer()
    public let viewThemeSerializer = ViewThemeSerializer()
    
    public required init() {
        super.init()
        self.registerSerializer(answerTypeSerializer)
        self.registerSerializer(asyncActionSerializer)
        self.registerSerializer(buttonActionSerializer)
        self.registerSerializer(colorMappingSerializer)
        self.registerSerializer(imageThemeSerializer)
        self.registerSerializer(inputItemSerializer)
        self.registerSerializer(resultSerializer)
        self.registerSerializer(resultNodeSerializer)
        self.registerSerializer(stepSerializer)
        self.registerSerializer(taskSerializer)
        self.registerSerializer(viewThemeSerializer)
    }
    
    /// The type of device to point use when decoding different text depending upon the target
    /// device.
    public internal(set) var deviceType: RSDDeviceType = {
        #if os(watchOS)
        return .watch
        #elseif os(iOS)
        return .phone
        #elseif os(tvOS)
        return .tv
        #else
        return .computer
        #endif
    }()
    
    /// Optional shared tracking rules
    open var trackingRules: [RSDTrackingRule] = []
    
    // MARK: Deprecation handling
    
    @available(*, deprecated, message: "Use of a default type is deprecated. Please convert your code to use the serializers with a 'type' key instead.")
    open override func decodeDefaultObject<T>(_ type: T.Type, from decoder: Decoder) throws -> T {
        if type == AnswerType.self {
            return try decodeAnswerType(from: decoder) as! T
        }
        else if type == RSDAsyncActionConfiguration.self {
            return try decodeAsyncActionConfiguration(from: decoder) as! T
        }
        else if type == RSDUIAction.self {
            return try decodeUIAction(from: decoder, for: .custom("")) as! T
        }
        else if type == RSDColorMappingThemeElement.self {
            return try decodeColorMappingThemeElement(from: decoder) as! T
        }
        else if type == RSDImageThemeElement.self {
            return try decodeImageThemeElement(from: decoder) as! T
        }
        else if type == InputItemBuilder.self {
            return try decodeInputItem(from: decoder) as! T
        }
        else if type == RSDResult.self {
            return try decodeResult(from: decoder) as! T
        }
        else if type == RSDStep.self {
            return try decodeStep(from: decoder) as! T
        }
        else if type == RSDTask.self {
            return try decodeTask(from: decoder) as! T
        }
        else if type == RSDViewThemeElement.self {
            return try decodeViewThemeElement(from: decoder) as! T
        }
        else {
            return try super.decodeDefaultObject(type, from: decoder)
        }
    }
    
    open override func modelName(for className: String) -> String {
        switch className {
        case buttonActionSerializer.interfaceName:
            return "ButtonActionInfo"
        case imageThemeSerializer.interfaceName:
            return "ImageInfo"
        case inputItemSerializer.interfaceName:
            return "InputItem"
        case "UIActionType":
            return "ButtonAction"
        default:
            var modelName = className
            let objcPrefix = "RSD"
            if modelName.hasPrefix(objcPrefix) {
                modelName = String(modelName.dropFirst(objcPrefix.count))
            }
            return modelName.replacingOccurrences(of: "UIAction", with: "Button")
        }
    }

    // MARK: Class name factory
    
    private enum TypeKeys: String, CodingKey {
        case type
    }
    
    /// Get a string that will identify the type of object to instantiate for the given decoder.
    ///
    /// By default, this will look in the container for the decoder for a key/value pair where
    /// the key == "type" and the value is a `String`.
    ///
    /// - parameter decoder: The decoder to inspect.
    /// - returns: The string representing this class type (if found).
    /// - throws: `DecodingError` if the type name cannot be decoded.
    open func typeName(from decoder:Decoder) throws -> String? {
        let container = try decoder.container(keyedBy: TypeKeys.self)
        return try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    
    // MARK: Task factory

    /// Use the resource transformer to get a data object to decode into a task.
    ///
    /// - parameters:
    ///     - resourceTransformer: The resource transformer.
    ///     - taskIdentifier: The identifier of the task.
    ///     - schemaInfo: The schema info for the task.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskResourceTransformer`
    open func decodeTask(with resourceTransformer: RSDResourceTransformer, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil) throws -> RSDTask {
        let (data, type) = try resourceTransformer.resourceData()
        return try decodeTask(with: data,
                              resourceType: type,
                              typeName: nil, //resourceTransformer.classType, TODO: syoung 04/14/2020 Refactor task decoding to a serialization strategy supported by Kotlin.
                              taskIdentifier: taskIdentifier,
                              schemaInfo: schemaInfo,
                              resourceInfo: resourceTransformer)
    }
    
    /// Decode an object with top-level data (json or plist) for a given `resourceType`,
    /// `typeName`, and `taskInfo`.
    ///
    /// - parameters:
    ///     - data:            The data to use to decode the object.
    ///     - resourceType:    The type of resource (json or plist).
    ///     - typeName:        The class name type key for this task (if any).
    ///     - taskIdentifier:  The identifier of the task.
    ///     - schemaInfo:      The schema info for the task.
    ///     - resourceInfo:    The resource info for the source of the data.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTask(with data: Data, resourceType: RSDResourceType, typeName: String? = nil, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, resourceInfo: ResourceInfo? = nil) throws -> RSDTask {
        let decoder = try createDecoder(for: resourceType, taskIdentifier: taskIdentifier, schemaInfo: schemaInfo, resourceInfo: resourceInfo)
        return try decoder.factory.decodeTask(with: data, from: decoder)
    }
    
    /// Decode a task from the decoder.
    ///
    /// - parameters:
    ///     - data:    The data to use to decode the object.
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTask(with data: Data, from decoder: FactoryDecoder) throws -> RSDTask {
        let wrapper = try decoder.decode(TaskWrapper.self, from: data)
        let task = wrapper.task
        try task.validate()
        return task
    }
    
    private struct TaskWrapper : Decodable {
        let task: RSDTask
        init(from decoder: Decoder) throws {
            self.task = try decoder.factory.decodePolymorphicObject(RSDTask.self, from: decoder)
        }
    }
    
    /// Decode a task from the decoder.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeTask(from decoder: Decoder) throws -> RSDTask {
        return try RSDTaskObject(from: decoder)
    }
    
    
    // MARK: Task Info factory
    
    /// Decode the task info from this decoder. This method *must* return a task info object.
    /// The default implementation will return a `RSDTaskInfoStepObject`.
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The task info created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskGroupObject`
    @available(*, deprecated, message: "Use of a default type is deprecated. Please convert your decode `RSDTaskInfoObject` or the appropriate replacement directly.")
    open func decodeTaskInfo(from decoder: Decoder) throws -> RSDTaskInfo {
        return try RSDTaskInfoObject(from: decoder)
    }
    
    
    // MARK: Schema Info factory
    
    /// Decode the schema info from this decoder. This method *must* return a schema info object.
    /// The default implementation will return a `RSDSchemaInfoObject`.
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The schema info created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskResultObject`
    open func decodeSchemaInfo(from decoder: Decoder) throws -> RSDSchemaInfo {
        return try RSDSchemaInfoObject(from: decoder)
    }
    
    /// Encode the schema info from the given task result to the given encoder. This allows a subclass
    /// of the factory to encode additional schema information to the schema info defined by the
    /// `RSDSchemaInfo` protocol.
    ///
    /// - parameters:
    ///     - taskResult: The task result being encoded.
    ///     - encoder: The nested encoder to encode the schema info to.
    open func encodeSchemaInfo(from taskResult: RSDTaskRunResult, to encoder: Encoder) throws {
        if let schema = taskResult.schemaInfo, let encodableSchema = schema as? Encodable {
            try encodableSchema.encode(to: encoder)
        } else {
            let encodableSchema = RSDSchemaInfoObject(identifier: taskResult.schemaInfo?.schemaIdentifier ?? taskResult.identifier,
                                                      revision: taskResult.schemaInfo?.schemaVersion ?? 1)
            try encodableSchema.encode(to: encoder)
        }
    }
    
    
    // MARK: Task Transformer factory
    
    /// Decode the task transformer from this decoder. This method *must* return a task transformer
    /// object. The default implementation will return a `RSDResourceTransformerObject`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The object created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTaskTransformer(from decoder: Decoder) throws -> RSDTaskTransformer {
        return try _decodeResource(RSDResourceTransformerObject.self, from: decoder)
    }
    
    
    // MARK: Step navigator factory
    
    /// Decode the step navigator from this decoder. This method *must* return a step navigator.
    /// The default implementation will return a `RSDConditionalStepNavigatorObject` if the type
    /// is not in the decoder.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step navigator created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskObject`
    @available(*, deprecated, message: "See `RSDAssessmentTaskObject` for example decoding. Decode the task and use lazy init to decode the navigator.")
    open func decodeStepNavigator(from decoder: Decoder) throws -> RSDStepNavigator {
        guard let name = try typeName(from: decoder) else {
            return try RSDConditionalStepNavigatorObject(from: decoder)
        }
        return try self.decodeStepNavigator(from: decoder, with: RSDStepNavigatorType(rawValue: name))
    }
    
    /// Decode the step navigator from this decoder. This method *must* return a step navigator.
    /// The default implementation will return a `RSDConditionalStepNavigatorObject` for an
    /// unrecognized type.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    ///     - type: The `RSDStepNavigatorType` to instantiate.
    /// - returns: The step navigator created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "See `RSDAssessmentTaskObject` for example decoding. Decode the task and use lazy init to decode the navigator.")
    open func decodeStepNavigator(from decoder: Decoder, with type: RSDStepNavigatorType) throws -> RSDStepNavigator {
        return try RSDConditionalStepNavigatorObject(from: decoder)
    }
    

    // MARK: Step factory
    
    /// Override mapping the array to allow steps to add a pointer between the countdown step and
    /// the active step. This is handled in Kotlin native serialization during unpacking.
    open override func mapDecodedArray<RSDStep>(_ objects: [RSDStep]) throws -> [RSDStep] {
        objects.enumerated().forEach { (index, step) in
            if let countdown = step as? RSDCountdownUIStepObject,
                index + 1 < objects.count,
                let activeStep = objects[index + 1] as? RSDActiveUIStep {
                // Special-case handling of a countdown step. Inspect the step to see if this is
                // a countdown/active step pairing and if so, set the countdown step to include a
                // pointer to the active step.
                //
                // WARNING: This is *not* a weak pointer b/c the `RSDActiveUIStep` protocol does not
                // require that step to be a class (but it might be) so this will cause a retain
                // loop if this special-case handling is ever modified to have a pointer from the
                // countdown step to the active step. syoung 07/12/2019
                //
                countdown.activeStep = activeStep
            }
        }
        return objects
    }
    
    /// Override mapping the object to check if this is a step transformer, and transform the step
    /// if needed. In Kotlin native, this is handled during unpacking of the assessment.
    open override func mapDecodedObject<T>(_ type: T.Type, object: Any, codingPath: [CodingKey]) throws -> T {
        if let step = (object as? RSDStepTransformer)?.transformedStep as? T {
            return step
        }
        else {
            return try super.mapDecodedObject(type, object: object, codingPath: codingPath)
        }
    }

    /// Convenience method for decoding a list of steps.
    ///
    /// - parameter container: The unkeyed container with the steps.
    /// - returns: An array of the steps.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDConditionalStepNavigatorObject`, `RSDSectionStepObject`
    @available(*, deprecated, message: "Use `decodePolymorphicArray` instead.")
    public func decodeSteps(from container: UnkeyedDecodingContainer) throws -> [RSDStep] {
        var steps : [RSDStep] = []
        var stepsContainer = container
        var countdownStep: RSDCountdownUIStepObject?
        while !stepsContainer.isAtEnd {
            let stepDecoder = try stepsContainer.superDecoder()
            if let step = try decodeStep(from: stepDecoder) {
                steps.append(step)
                
                // Special-case handling of a countdown step. Inspect the step to see if this is
                // a countdown/active step pairing and if so, set the countdown step to include a
                // pointer to the active step.
                //
                // WARNING: This is *not* a weak pointer b/c the `RSDActiveUIStep` protocol does not
                // require that step to be a class (but it might be) so this will cause a retain
                // loop if this special-case handling is ever modified to have a pointer from the
                // countdown step to the active step. syoung 07/12/2019
                //
                if let countdown = countdownStep, let activeStep = step as? RSDActiveUIStep {
                    countdown.activeStep = activeStep
                    countdownStep = nil
                }
                else {
                    countdownStep = step as? RSDCountdownUIStepObject
                }
            }
        }
        return steps
    }
    
    /// Decode the step from this decoder.
    ///
    /// This method can be overridden to return `nil` if the step should be skipped.
    /// For example, if the step does not apply for a task run on an Apple watch or
    /// iPad, but does apply to a task run on an iPhone.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeStep(from decoder: Decoder) throws -> RSDStep? {
        guard let name = try typeName(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Conformance to step protocol decoding requires a 'type' coding key.")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
        let step = try decodeStep(from: decoder, with: RSDStepType(rawValue: name))
        try step?.validate()
        return step
    }
    
    /// Decode the step from this decoder. This method can be overridden to return `nil`
    /// if the step should be skipped.
    ///
    /// - parameters:
    ///     - type:        The `StepType` to instantiate.
    ///     - decoder:     The decoder to use to instantiate the object.
    /// - returns: The step (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeStep(from decoder:Decoder, with type:RSDStepType) throws -> RSDStep? {
        if let standardType = RSDStepType.StandardType(rawValue: type.rawValue) {
            return try decodeStandardStep(from: decoder, standardType: standardType)
        }
        else if let questionType = RSDStepType.QuestionType(rawValue: type.rawValue) {
            return try decodeQuestionStep(from: decoder, questionType: questionType)
        }
        else {
            return try decodeDeprecatedStep(from: decoder, with: type)
        }
    }
    
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    func decodeStandardStep(from decoder: Decoder, standardType: RSDStepType.StandardType) throws -> RSDStep {
        switch (standardType) {
        case .instruction:
            return try RSDInstructionStepObject(from: decoder)
        case .active:
            return try RSDActiveUIStepObject(from: decoder)
        case .countdown:
            return try RSDCountdownUIStepObject(from: decoder)
        case .completion, .feedback:
            return try RSDResultSummaryStepObject(from: decoder)
        case .overview:
            return try RSDOverviewStepObject(from: decoder)
        case .section:
            return try RSDSectionStepObject(from: decoder)
        case .taskInfo:
            let taskInfo = try RSDTaskInfoObject(from: decoder)
            return RSDTaskInfoStepObject(with: taskInfo)
        case .transform:
            return try self.decodeTransformableStep(from: decoder)
        case .subtask:
            return try RSDSubtaskStepObject(from: decoder)
        }
    }
    
    func decodeQuestionStep(from decoder: Decoder, questionType: RSDStepType.QuestionType) throws -> RSDStep {
        switch (questionType) {
        case .choiceQuestion:
            return try ChoiceQuestionStepObject(from: decoder)
        case .multipleInputQuestion:
            return try MultipleInputQuestionStepObject(from: decoder)
        case .simpleQuestion:
            return try SimpleQuestionStepObject(from: decoder)
        case .stringChoiceQuestion:
            return try StringChoiceQuestionStepObject(from: decoder)
        }
    }
    
    @available(*, deprecated, message: "Implement `QuestionStep` instead. This method will be deleted in future versions.")
    func decodeDeprecatedStep(from decoder: Decoder, with type: RSDStepType) throws -> RSDStep? {
        guard let deprecatedType = RSDStepType.DeprecatedType(rawValue: type.rawValue)
            else {
                return nil
        }
        
        switch deprecatedType {
        case .form, .demographics:
            print("WARNING!!! Step type '\(type)' is deprecated and decoding support will be removed in future releases.")
            let formStep = try RSDFormUIStepObject(from: decoder)
            return formStep
        }
    }
    
    /// Decode the step into a transfrom step. By default, this will create a `RSDStepTransformerObject`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step transform created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeStepTransformer(from decoder: Decoder) throws -> RSDStepTransformer {
        return try RSDStepTransformerObject(from: decoder)
    }
    
    /// Decode the transformable step. By default, this will return the `transformedStep` from a
    /// `RSDStepTransformer`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step created from transforming this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeTransformableStep(from decoder: Decoder) throws -> RSDStep {
        let transform = try self.decodeStepTransformer(from: decoder)
        return transform.transformedStep
    }
    
    // MARK: Answer type factory
    
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeAnswerType(from decoder: Decoder) throws -> AnswerType {
        guard let name = try typeName(from: decoder) else {
            return try decodeDeprecatedAnswerType(from: decoder)
        }
        let typeKey = AnswerTypeType(rawValue: name)
        switch typeKey {
        case .array:
            return try AnswerTypeArray(from: decoder)
        case .boolean:
            return try AnswerTypeBoolean(from: decoder)
        case .dateTime:
            return try AnswerTypeDateTime(from: decoder)
        case .integer:
            return try AnswerTypeInteger(from: decoder)
        case .measurement:
            return try AnswerTypeMeasurement(from: decoder)
        case .null:
            return try AnswerTypeNull(from: decoder)
        case .number:
            return try AnswerTypeNumber(from: decoder)
        case .object:
            return try AnswerTypeObject(from: decoder)
        case .string:
            return try AnswerTypeString(from: decoder)
        default:
            let codingPath = decoder.codingPath
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not find supported answer type")
            throw DecodingError.typeMismatch(Codable.self, context)
        }
    }
    
    @available(*, deprecated, message: "Implement `AnswerResult` instead. This method will be deleted in future versions.")
    func decodeDeprecatedAnswerType(from decoder: Decoder) throws -> AnswerType {
        print("WARNING!!! Default AnswerType is deprecated. \(decoder.codingPath)")
        let oldType = try RSDAnswerResultType(from: decoder)
        return oldType.answerType
    }
    
    
    // MARK: Input field factory
    
    /// Decode the input field from this decoder. This method can be overridden to return `nil`
    /// if the input field should be skipped.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDFormUIStepObject`
    @available(*, deprecated, message: "Use `Question` and `InputItem` instead")
    open func decodeInputField(from decoder: Decoder) throws -> RSDInputField? {
        let dataType = try RSDInputFieldObject.dataType(from: decoder)
        let inputField = try decodeInputField(from: decoder, with: dataType)
        try inputField?.validate()
        return inputField
    }
    
    /// Decode the input field from this decoder. This method can be overridden to return `nil`
    /// if the input field should be skipped.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    ///     - dataType: The type for this input field.
    /// - returns: The input field (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `Question` and `InputItem` instead")
    open func decodeInputField(from decoder:Decoder, with dataType: RSDFormDataType) throws -> RSDInputField? {
        switch dataType {
        case .collection(let collectionType, _):
            switch collectionType {
            case .multipleComponent:
                return try RSDMultipleComponentInputFieldObject(from: decoder)
                
            case .multipleChoice, .singleChoice:
                switch dataType.baseType {
                case .boolean:
                    return try RSDCodableChoiceInputFieldObject<Bool>(from: decoder)
                case .string:
                    return try RSDCodableChoiceInputFieldObject<String>(from: decoder)
                case .date:
                    return try RSDCodableChoiceInputFieldObject<Date>(from: decoder)
                case .decimal, .duration:
                    return try RSDCodableChoiceInputFieldObject<Double>(from: decoder)
                case .fraction:
                    return try RSDCodableChoiceInputFieldObject<RSDFraction>(from: decoder)
                case .integer, .year:
                    return try RSDCodableChoiceInputFieldObject<Int>(from: decoder)
                case .codable:
                    let codingPath = decoder.codingPath
                    let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Input field choices for a .codable data type are not supported by this factory: \(self).")
                    throw DecodingError.typeMismatch(Codable.self, context)
                }
            }
            
        case .detail(_):
            return try RSDDetailInputFieldObject(from: decoder)
        
        default:
            return try RSDInputFieldObject(from: decoder)
        }
    }
    
    // MARK: InputItem
    
    @available(*, deprecated, message: "Use `decodePolymorphicArray` instead.")
    public func decodeInputItems(from itemsContainer: UnkeyedDecodingContainer) throws -> [InputItemBuilder] {
        var container = itemsContainer
        var items = [InputItemBuilder]()
        while !container.isAtEnd {
            let nestedDecoder = try container.superDecoder()
            let item = try self.decodePolymorphicObject(InputItemBuilder.self, from: nestedDecoder)
            items.append(item)
        }
        return items
    }
    
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    public func decodeInputItem(from decoder: Decoder) throws -> InputItemBuilder {
        guard let name = try typeName(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Conformance to the step protocol decoding requires a 'type' coding key.")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
        return try decodeInputItem(from: decoder, with: InputItemType(rawValue: name))
    }
    
    func decodeInputItem(from decoder: Decoder, with type: InputItemType) throws -> InputItemBuilder {
        switch type {
        case .decimal:
            return try DoubleTextInputItemObject(from: decoder)
        case .integer:
            return try IntegerTextInputItemObject(from: decoder)
        case .string:
            return try StringTextInputItemObject(from: decoder)
        case .year:
            return try YearTextInputItemObject(from: decoder)
        case .dateTime:
            return try DateTimeInputItemObject(from: decoder)
        case .date:
            return try DateInputItemObject(from: decoder)
        case .time:
            return try TimeInputItemObject(from: decoder)
        case .checkbox:
            return try CheckboxInputItemObject(from: decoder)
        case .choicePicker:
            return try ChoicePickerInputItemObject(from: decoder)
        case .stringChoicePicker:
            return try StringChoicePickerInputItemObject(from: decoder)
        case .height:
            return try HeightInputItemBuilderObject(from: decoder)
        case .weight:
            return try WeightInputItemBuilderObject(from: decoder)
        default:
            let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                debugDescription: "Cannot decode InputItem with type '\(type)'")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
    }
    
    
    // MARK: Survey rules
    
    /// Overridable function for decoding a list of survey rules from an unkeyed container for a given data
    /// type. The default implementation will instantiate a list of `RSDComparableSurveyRuleObject` instances
    /// appropriate to the `BaseType` of the given data type.
    ///
    /// - example:
    ///
    /// The following will decode the "surveyRules" key as an array of `[RSDComparableSurveyRuleObject<Int>]`.
    ///
    ///     ````
    ///        {
    ///            "identifier": "foo",
    ///            "type": "integer",
    ///            "surveyRules" : [
    ///                            {
    ///                            "skipToIdentifier": "lessThan",
    ///                            "ruleOperator": "lt",
    ///                            "matchingAnswer": 0
    ///                            },
    ///                            {
    ///                            "skipToIdentifier": "greaterThan",
    ///                            "ruleOperator": "gt",
    ///                            "matchingAnswer": 1
    ///                            }
    ///                            ]
    ///        }
    ///     ````
    ///
    /// - parameters:
    ///     - rulesContainer: The unkeyed container for the survey rules.
    ///     - dataType: The data type associated with this instance.
    /// - returns: An array of survey rules.
    /// - throws: `DecodingError`
    /// - seealso: `RSDInputFieldObject`
    @available(*, deprecated, message: "Use `Question` and `InputItem` instead")
    open func decodeSurveyRules(from rulesContainer: UnkeyedDecodingContainer, for dataType: RSDFormDataType) throws -> [RSDSurveyRule] {
        var container = rulesContainer
        var surveyRules = [RSDSurveyRule]()
        while !container.isAtEnd {
            let nestedDecoder = try container.superDecoder()
            let surveyRule = try self.decodeSurveyRule(from: nestedDecoder, for: dataType)
            surveyRules.append(surveyRule)
        }
        return surveyRules
    }
    
    /// Overridable factory method for returning a survey rule. By default, this will return a
    /// `RSDComparableSurveyRuleObject` appropriate to the base type of the data type.
    @available(*, deprecated, message: "Use `Question` and `InputItem` instead")
    open func decodeSurveyRule(from decoder: Decoder, for dataType: RSDFormDataType) throws -> RSDSurveyRule {
        switch dataType.baseType {
        case .boolean:
            return try RSDComparableSurveyRuleObject<Bool>(from: decoder)
        case .string:
            return try RSDComparableSurveyRuleObject<String>(from: decoder)
        case .date:
            return try RSDComparableSurveyRuleObject<Date>(from: decoder)
        case .decimal, .duration:
            return try RSDComparableSurveyRuleObject<Double>(from: decoder)
        case .fraction:
            return try RSDComparableSurveyRuleObject<RSDFraction>(from: decoder)
        case .integer, .year:
            return try RSDComparableSurveyRuleObject<Int>(from: decoder)
        case .codable:
            let codingPath = decoder.codingPath
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Survey rules for a .codable data type are not supported.")
            throw DecodingError.typeMismatch(Codable.self, context)
        }
    }
    
    // MARK: Range factory
    
    /// Overridable  function for decoding the range from the decoder. The default implementation will
    /// decode a range object appropriate to the data type.
    ///
    /// | RSDFormDataType.BaseType      | Type of range to decode                                    |
    /// |-------------------------------|:----------------------------------------------------------:|
    /// | .integer, .decimal, .fraction | `RSDNumberRangeObject`                                     |
    /// | .date                         | `RSDDateRangeObject`                                       |
    /// | .year                         | `RSDDateRangeObject` or `RSDNumberRangeObject`             |
    /// | .duration                     | `RSDDurationRangeObject`                                   |
    ///
    /// - parameters:
    ///     - decoder: The decoder used to decode this object.
    ///     - dataType: The data type associated with this instance.
    /// - returns: An appropriate instance of `RSDRange`.
    /// - throws: `DecodingError`
    /// - seealso: `RSDInputFieldObject`
    @available(*, deprecated, message: "Use `Question` and `InputItem` instead")
    open func decodeRange(from decoder: Decoder, for dataType: RSDFormDataType) throws -> RSDRange? {
        switch dataType.baseType {
        case .integer, .decimal, .fraction:
            return try RSDNumberRangeObject(from: decoder)
        case .duration:
            return try RSDDurationRangeObject(from: decoder)
        case .date:
            return try RSDDateRangeObject(from: decoder)
        case .year:
            // For a year data type, we first need to check if there is a min/max range set using the date
            // and if so, return that. The decoder could fail to find any property keys and not fail to
            // decode because everything in the range is optional.
            if let dateRange = try? RSDDateRangeObject(from: decoder),
                (dateRange.minimumDate != nil || dateRange.maximumDate != nil) {
                return dateRange
            } else {
                return try RSDNumberRangeObject(from: decoder)
            }
        case .string, .boolean, .codable:
            let codingPath = decoder.codingPath
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Ranges for a \(dataType.baseType) data type are not supported.")
            throw DecodingError.typeMismatch(Codable.self, context)
        }
    }
    
    
    // MARK: Text Validator factory
    
    /// Decode the text validator from this decoder. The default implementation will instantiate a
    /// `RSDRegExValidatorObject` from the decoder.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The text validator created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTextFieldOptionsObject`
    @available(*, deprecated, message: "Use `KeyboardOptions` and `TextInputValidator` instead.")
    open func decodeTextValidator(from decoder: Decoder) throws -> RSDTextValidator? {
        return try RSDRegExValidatorObject(from: decoder)
    }
    
    
    // MARK: Formatter factory
    
    /// Decode a number formatter from this decoder. The default implementation will instantiate a  `NumberFormatter`
    /// from the decoder using the convenience method defined in an extension in this framework.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The number formatter created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDNumberRangeObject`
    @available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
    open func decodeNumberFormatter(from decoder: Decoder) throws -> NumberFormatter {
        return try NumberFormatter(from: decoder)
    }

    
    // MARK: UI action factory

    
    /// Decode UI action from the given decoder.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    ///     - actionType: The action type for this button.
    ///     - objectType: The object type to which this action should be cast.
    /// - returns: The UI action created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDUIActionHandlerObject`
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeUIAction(from decoder:Decoder, for actionType: RSDUIActionType) throws -> RSDUIAction {
        guard let typeName = try self.typeName(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support decoding a UI action without a `type` key defining a value for the the class name.")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
        
        let objType: RSDUIActionObjectType = RSDUIActionObjectType(rawValue: typeName)
        return try decodeUIAction(from: decoder, with: objType)
    }
    
    /// Decode UI action from the given decoder.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    ///     - objectType: The object type to which this action should be cast.
    /// - returns: The UI action created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeUIAction(from decoder:Decoder, with objectType: RSDUIActionObjectType) throws -> RSDUIAction {
        switch objectType {
        case .navigation:
            return try _decodeResource(RSDNavigationUIActionObject.self, from: decoder)
        case .reminder:
            return try _decodeResource(RSDReminderUIActionObject.self, from: decoder)
        case .webView:
            return try _decodeResource(RSDWebViewUIActionObject.self, from: decoder)
        case .videoView:
            return try _decodeResource(RSDVideoViewUIActionObject.self, from: decoder)
        default:
            return try _decodeResource(RSDUIActionObject.self, from: decoder)
        }
    }
    
    
    // MARK: UI theme factory
    
    /// Decode UI color mapping theme from the given decoder.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The UI color theme created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDUIStepObject`
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeColorMappingThemeElement(from decoder:Decoder) throws -> RSDColorMappingThemeElement? {
        guard let typeName = try self.typeName(from: decoder)
            else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support a default decodable for a color theme element. `type` field is required.")
                throw DecodingError.typeMismatch(RSDColorMappingThemeElement.self, context)
        }
        let themeType = RSDColorMappingThemeElementType(rawValue: typeName)
        switch themeType {
        case .singleColor:
            return try _decodeResource(RSDSingleColorThemeElementObject.self, from: decoder)
        case .placementMapping:
            return try _decodeResource(RSDColorPlacementThemeElementObject.self, from: decoder)
        default:
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support `\(typeName)` as a decodable class type for a color theme element.")
            throw DecodingError.typeMismatch(RSDColorMappingThemeElement.self, context)
        }
    }
    
    /// Decode UI view theme from the given decoder.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The UI view theme created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDUIStepObject`
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeViewThemeElement(from decoder:Decoder) throws -> RSDViewThemeElement? {
        return try _decodeResource(RSDViewThemeElementObject.self, from: decoder)
    }
    
    /// Decode UI image theme from the given decoder.
    ///
    /// - parameters:
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The UI image theme created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDUIStepObject`
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeImageThemeElement(from decoder:Decoder) throws -> RSDImageThemeElement? {
        guard let typeName = try self.typeName(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support decoding an image theme without a `type` key defining a value for the the class name.")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
        
        let type = RSDImageThemeElementType(rawValue: typeName)
        switch type {
        case .fetchable:
            return try _decodeResource(RSDFetchableImageThemeElementObject.self, from: decoder)
        case .animated:
            return try _decodeResource(RSDAnimatedImageThemeElementObject.self, from: decoder)
        default:
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support `\(typeName)` as a decodable class type for a image theme element.")
            throw DecodingError.typeMismatch(RSDImageThemeElement.self, context)
        }
    }
    
    private func _decodeResource<T>(_ type: T.Type, from decoder: Decoder) throws -> T where T : DecodableBundleInfo {
        var resource = try T(from: decoder)
        resource.factoryBundle = decoder.bundle
        return resource
    }
    
    
    // MARK: Async action factory
    
    /// Decode an async action configuration from the given decoder. This method can be overridden to return `nil`
    /// if the action should be ignored for this platform.
    ///
    /// - note: The base factory does not currently support any async action objects. The factory method is
    /// included here for subclassing purposes. (syoung 10/03/2017)
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The configuration (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskObject`, `RSDSectionStepObject`
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeAsyncActionConfiguration(from decoder:Decoder) throws -> RSDAsyncActionConfiguration? {
        guard let typeName = try typeName(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "\(self) does not support decoding an async action without a `type` key defining a value for the the class name.")
            throw DecodingError.keyNotFound(TypeKeys.type, context)
        }
        let config = try decodeAsyncActionConfiguration(from: decoder, with: typeName)
        try config?.validate()
        return config
    }
    
    /// Decode an async action configuration from the given decoder. This method can be overridden to return
    /// `nil` if the action should be ignored for this platform.
    ///
    /// - note: The base factory does not currently support any async action objects.
    /// The factory method is included here for subclassing purposes. (syoung 10/03/2017)
    ///
    /// - parameters:
    ///     - typeName:     The string representing the class name for this conditional rule.
    ///     - decoder:      The decoder to use to instantiate the object.
    /// - returns: The configuration (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeAsyncActionConfiguration(from decoder:Decoder, with typeName: String) throws -> RSDAsyncActionConfiguration? {
        
        // Look to see if there is a standard permission to map to this config.
        let type = RSDAsyncActionType(rawValue: typeName)
        switch type {
        case .motion:
            return try RSDMotionRecorderConfiguration(from: decoder)
        case .distance:
            return try RSDDistanceRecorderConfiguration(from: decoder)
        default:
            return try RSDStandardAsyncActionConfiguration(from: decoder)
        }
    }
    
    
    // MARK: Result factory
    
    /// Convenience method for decoding a list of results.
    ///
    /// - parameter container: The unkeyed container with the results.
    /// - returns: An array of the results.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskResultObject`, `RSDCollectionResultObject`
    @available(*, deprecated, message: "Use `decodePolymorphicArray` instead.")
    public func decodeResults(from container: UnkeyedDecodingContainer) throws -> [RSDResult] {
        var results : [RSDResult] = []
        var mutableContainer = container
        while !mutableContainer.isAtEnd {
            let decoder = try mutableContainer.superDecoder()
            let result = try decodeResult(from: decoder)
            results.append(result)
        }
        return results
    }
    
    /// Decode the result from this decoder.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The result (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeResult(from decoder: Decoder) throws -> RSDResult {
        guard let typeName = try typeName(from: decoder) else {
            return try RSDResultObject(from: decoder)
        }
        return try decodeResult(from: decoder, with: RSDResultType(rawValue: typeName))
    }
    
    /// Decode the result from this decoder.
    ///
    /// - parameters:
    ///     - resultType:   The result type for this result.
    ///     - decoder:      The decoder to use to instantiate the object.
    /// - returns: The result (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    @available(*, deprecated, message: "Use `decodePolymorphicObject` instead.")
    open func decodeResult(from decoder: Decoder, with resultType: RSDResultType) throws -> RSDResult {

        switch resultType {
        case .base:
            return try RSDResultObject(from: decoder)
        case .answer:
            return try AnswerResultObject(from: decoder)
        case .collection:
            return try RSDCollectionResultObject(from: decoder)
        case .task:
            return try RSDTaskResultObject(from: decoder)
        case .file:
            return try RSDFileResultObject(from: decoder)
        default:
            throw RSDValidationError.undefinedClassType("\(self) does not support `\(resultType)` as a decodable class type for a result.")
        }
    }

    // MARK: Decoder
    
    /// Create the appropriate decoder for the given resource type. This method will return an
    /// decoder that conforms to the `FactoryDecoder` protocol. The decoder will assign the
    /// user info coding keys as appropriate.
    ///
    /// - parameters:
    ///     - resourceType:    The resource type.
    ///     - taskIdentifier:  The task identifier to pass with the decoder.
    ///     - schemaInfo:      The schema info to pass with the decoder.
    ///     - resourceInfo:    The resource info for this decoder.
    /// - returns: The decoder for the given type.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func createDecoder(for resourceType: RSDResourceType, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, resourceInfo: ResourceInfo? = nil) throws -> FactoryDecoder {
        var decoder : FactoryDecoder = try {
            if resourceType == .json {
                return self.createJSONDecoder(resourceInfo: resourceInfo)
            }
            else if resourceType == .plist {
                return self.createPropertyListDecoder(resourceInfo: resourceInfo)
            }
            else {
                let supportedTypes: [RSDResourceType] = [.json, .plist]
                let supportedTypeList = supportedTypes.map({$0.rawValue}).joined(separator: ",")
                throw RSDResourceTransformerError.invalidResourceType("ResourceType \(resourceType.rawValue) is not supported by this factory. Supported types: \(supportedTypeList)")
            }
            }()
        if let taskIdentifier = taskIdentifier {
            decoder.userInfo[.taskIdentifier] = taskIdentifier
        }
        if let schemaInfo = schemaInfo {
            decoder.userInfo[.schemaInfo] = schemaInfo
        }
        return decoder
    }
    
    // MARK: Encoding polymophic objects
    
    open func encode(_ list: [Any], to nestedContainer: UnkeyedEncodingContainer) throws {
        var container = nestedContainer
        try list.forEach {
            guard let encodable = $0 as? Encodable else {
                let context = EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "Object does not conform to the encodable protocol.")
                throw EncodingError.invalidValue($0, context)
            }
            let nestedEncoder = container.superEncoder()
            try encodable.encode(to: nestedEncoder)
        }
    }
}

/// Extension of CodingUserInfoKey to add keys used by the Codable objects in this framework.
extension CodingUserInfoKey {
        
    /// The key for the task identifier to use when coding.
    public static let taskIdentifier = CodingUserInfoKey(rawValue: "RSDFactory.taskIdentifier")!
    
    /// The key for the schema info to use when coding.
    public static let schemaInfo = CodingUserInfoKey(rawValue: "RSDFactory.schemaInfo")!
    
    /// The key for the task data source to use when coding.
    public static let taskDataSource = CodingUserInfoKey(rawValue: "RSDFactory.taskDataSource")!
}

extension FactoryDecoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task identifier to use when decoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
}

/// Extension of Decoder to return the factory objects used by the Codable objects
/// in this framework.
extension Decoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task identifier to use when decoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when decoding if there isn't a local task info defined on the object.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
}

/// Extension of Encoder to return the factory objects used by the Codable objects
/// in this framework.
extension Encoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task info to use when encoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when encoding.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
}
