//
//  RSDFactory.swift
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

public protocol RSDFactoryTypeRepresentable : RawRepresentable, ExpressibleByStringLiteral {
    var stringValue: String { get }
}

/// `RSDFactory` handles customization of decoding the elements of a task. Applications should
/// override this factory to add custom elements required to run their task modules.
open class RSDFactory {
    
    /// Singleton for the shared factory. If a factory is not passed in when creating tasks
    /// then this will be used.
    public static var shared = RSDFactory()
    
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
    
    // Initializer
    public init() {
    }
    
    /// Optional shared tracking rules
    open var trackingRules: [RSDTrackingRule] = []

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
                              typeName: resourceTransformer.classType,
                              taskIdentifier: taskIdentifier,
                              schemaInfo: schemaInfo,
                              bundle: resourceTransformer.bundle)
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
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskResourceTransformer`
    open func decodeTask(with data: Data, resourceType: RSDResourceType, typeName: String? = nil, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, bundle: Bundle? = nil) throws -> RSDTask {
        let decoder = try createDecoder(for: resourceType, taskIdentifier: taskIdentifier, schemaInfo: schemaInfo, bundle: bundle)
        return try decodeTask(with: data, from: decoder)
    }
    
    /// Decode a task from the decoder.
    ///
    /// - parameters:
    ///     - data:    The data to use to decode the object.
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTask(with data: Data, from decoder: RSDFactoryDecoder) throws -> RSDTask {
        let task = try decoder.decode(RSDTaskObject.self, from: data)
        try task.validate()
        return task
    }
    
    /// Decode a task from the decoder.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
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
    open func encodeSchemaInfo(from taskResult: RSDTaskResult, to encoder: Encoder) throws {
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
    open func decodeStepNavigator(from decoder: Decoder, with type: RSDStepNavigatorType) throws -> RSDStepNavigator {
        return try RSDConditionalStepNavigatorObject(from: decoder)
    }
    

    // MARK: Step factory

    /// Convenience method for decoding a list of steps.
    ///
    /// - parameter container: The unkeyed container with the steps.
    /// - returns: An array of the steps.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDConditionalStepNavigatorObject`, `RSDSectionStepObject`
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
    open func decodeStep(from decoder: Decoder) throws -> RSDStep? {
        guard let name = try typeName(from: decoder) else {
            return try RSDGenericStepObject(from: decoder)
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
    open func decodeStep(from decoder:Decoder, with type:RSDStepType) throws -> RSDStep? {
        
        guard let standardType = RSDStepType.StandardType(rawValue: type.rawValue)
            else {
                return try RSDGenericStepObject(from: decoder)
        }
        switch (standardType) {
        case .instruction, .active:
            return try RSDActiveUIStepObject(from: decoder)
        case .countdown:
            return try RSDCountdownUIStepObject(from: decoder)
        case .completion, .feedback:
            return try RSDResultSummaryStepObject(from: decoder)
        case .overview:
            return try RSDOverviewStepObject(from: decoder)
        case .imagePicker:
            return try RSDImagePickerStepObject(from: decoder)
        case .form, .demographics:
            return try RSDFormUIStepObject(from: decoder)
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
    
    /// Decode the step into a transfrom step. By default, this will create a `RSDStepTransformerObject`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step transform created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeStepTransformer(from decoder: Decoder) throws -> RSDStepTransformer {
        return try RSDStepTransformerObject(from: decoder)
    }
    
    /// Decode the transformable step. By default, this will return the `transformedStep` from a
    /// `RSDStepTransformer`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step created from transforming this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTransformableStep(from decoder: Decoder) throws -> RSDStep {
        let transform = try self.decodeStepTransformer(from: decoder)
        return transform.transformedStep
    }
    
    
    // MARK: Input field factory
    
    /// Decode the input field from this decoder. This method can be overridden to return `nil`
    /// if the input field should be skipped.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The step (if any) created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDFormUIStepObject`
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
    
    private func _decodeResource<T>(_ type: T.Type, from decoder: Decoder) throws -> T where T : RSDDecodableBundleInfo {
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
    open func decodeResult(from decoder: Decoder, with resultType: RSDResultType) throws -> RSDResult {

        switch resultType {
        case .base:
            return try RSDResultObject(from: decoder)
        case .answer:
            return try RSDAnswerResultObject(from: decoder)
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
    
    
    // MARK: Date Result Format
    
    /// Get the date result formatter to use for the given calendar components.
    ///
    /// | Returned Formatter | Description                                                         |
    /// |--------------------|:-------------------------------------------------------------------:|
    /// |`dateOnlyFormatter` | If only date components (year, month, day) are included.            |
    /// |`timeOnlyFormatter` | If only time components (hour, minute, second) are included.        |
    /// |`timestampFormatter`| If both date and time components are included.                      |
    ///
    /// - parameter calendarComponents: The calendar components to include.
    /// - returns: The appropriate date formatter.
    open func dateResultFormatter(from calendarComponents: Set<Calendar.Component>) -> DateFormatter {
        let hasDateComponents = calendarComponents.intersection([.year, .month, .day]).count > 0
        let hasTimeComponents = calendarComponents.intersection([.hour, .minute, .second]).count > 0
        if hasDateComponents && hasTimeComponents {
            return timestampFormatter
        } else if hasTimeComponents {
            return timeOnlyFormatter
        } else {
            return dateOnlyFormatter
        }
    }
    
    /// `DateFormatter` to use for coding date-only strings. Default = `rsd_ISO8601DateOnlyFormatter`.
    open var dateOnlyFormatter: DateFormatter {
        return rsd_ISO8601DateOnlyFormatter
    }
    
    /// `DateFormatter` to use for coding time-only strings. Default = `rsd_ISO8601TimeOnlyFormatter`.
    open var timeOnlyFormatter: DateFormatter {
        return rsd_ISO8601TimeOnlyFormatter
    }
    
    /// `DateFormatter` to use for coding timestamp strings that include both date and time components.
    /// Default = `rsd_ISO8601TimestampFormatter`.
    open var timestampFormatter: DateFormatter {
        return rsd_ISO8601TimestampFormatter
    }
    
    /// The default coding strategy to use for non-conforming elements.
    open var nonConformingCodingStrategy: (positiveInfinity: String, negativeInfinity: String, nan: String)
        = ("Infinity", "-Infinity", "NaN")

    // MARK: Decoder

    /// Create a `JSONDecoder` with this factory assigned in the user info keys as the factory
    /// to use when decoding this object.
    open func createJSONDecoder(bundle: Bundle? = nil) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            return try self.decodeDate(from: string, formatter: nil, codingPath: decoder.codingPath)
        })
        decoder.userInfo[.factory] = self
        decoder.userInfo[.bundle] = bundle
        decoder.userInfo[.codingInfo] = RSDCodingInfo()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: nonConformingCodingStrategy.positiveInfinity,
                                                                        negativeInfinity: nonConformingCodingStrategy.negativeInfinity,
                                                                        nan: nonConformingCodingStrategy.nan)
        decoder.dataDecodingStrategy = .base64
        return decoder
    }
    
    /// Create a `PropertyListDecoder` with this factory assigned in the user info keys as the factory
    /// to use when decoding this object.
    open func createPropertyListDecoder(bundle: Bundle? = nil) -> PropertyListDecoder {
        let decoder = PropertyListDecoder()
        decoder.userInfo[.factory] = self
        decoder.userInfo[.bundle] = bundle
        decoder.userInfo[.codingInfo] = RSDCodingInfo()
        return decoder
    }
    
    /// Create the appropriate decoder for the given resource type. This method will return an encoder that
    /// conforms to the `RSDFactoryDecoder` protocol. The decoder will assign the user info coding keys as
    /// appropriate.
    ///
    /// - parameters:
    ///     - resourceType:    The resource type.
    ///     - taskIdentifier:  The task identifier to pass with the decoder.
    ///     - schemaInfo:      The schema info to pass with the decoder.
    /// - returns: The decoder for the given type.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func createDecoder(for resourceType: RSDResourceType, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, bundle: Bundle? = nil) throws -> RSDFactoryDecoder {
        var decoder : RSDFactoryDecoder = try {
            if resourceType == .json {
                return self.createJSONDecoder(bundle: bundle)
            }
            else if resourceType == .plist {
                return self.createPropertyListDecoder(bundle: bundle)
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
    
    /// Decode a date from a string. This method is used during object decoding and is defined
    /// as `open` so that subclass factories can define their own formatters. 
    ///
    /// - parameters:
    ///     - string:       The string to use in decoding the date.
    ///     - formatter:    A formatter to use. If provided, this formatter will be used.
    ///                     If nil, then the string will be inspected to see if it matches
    ///                     any of the expected formats for date and time, time only, or
    ///                     date only.
    /// - returns: The date created from this string.
    open func decodeDate(from string: String, formatter: DateFormatter? = nil) -> Date? {
        if formatter != nil {
            return formatter!.date(from: string)
        } else if let date = timestampFormatter.date(from: string) {
            return date
        } else if let date = dateOnlyFormatter.date(from: string) {
            return date
        } else if let date = timeOnlyFormatter.date(from: string) {
            return date
        } else {
            return ISO8601DateFormatter().date(from: string)
        }
    }
    
    internal func decodeDate(from string: String, formatter: DateFormatter?, codingPath: [CodingKey]) throws -> Date {
        guard let date = decodeDate(from: string, formatter: formatter) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode \(string) into a date.")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        return date
    }
    
    // MARK: Encoder
    
    /// Create a `JSONEncoder` with this factory assigned in the user info keys as the factory
    /// to use when encoding objects.
    open func createJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ (date, encoder) in
            let string = self.encodeString(from: date, codingPath: encoder.codingPath)
            var container = encoder.singleValueContainer()
            try container.encode(string)
        })
        encoder.outputFormatting = .prettyPrinted
        encoder.userInfo[.factory] = self
        encoder.userInfo[.codingInfo] = RSDCodingInfo()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: nonConformingCodingStrategy.positiveInfinity,
                                                                        negativeInfinity: nonConformingCodingStrategy.negativeInfinity,
                                                                        nan: nonConformingCodingStrategy.nan)
        encoder.dataEncodingStrategy = .custom({ (data, encoder) in
            let string = self.encodeString(from: data, codingPath: encoder.codingPath)
            var container = encoder.singleValueContainer()
            try container.encode(string)
        })
        return encoder
    }
    
    /// Create a `PropertyListEncoder` with this factory assigned in the user info keys as the factory
    /// to use when encoding objects.
    open func createPropertyListEncoder() -> PropertyListEncoder {
        let encoder = PropertyListEncoder()
        encoder.userInfo[.factory] = self
        encoder.userInfo[.codingInfo] = RSDCodingInfo()
        return encoder
    }
    
    /// Overridable method for encoding a date to a string. By default, this method uses the `timestampFormatter`
    /// as the date formatter.
    open func encodeString(from date: Date, codingPath: [CodingKey]) -> String {
        return timestampFormatter.string(from: date)
    }
    
    /// Overridable method for encoding data to a string. By default, this method uses base64 encoding.
    open func encodeString(from data: Data, codingPath: [CodingKey]) -> String {
        return data.base64EncodedString()
    }
}

/// Extension of CodingUserInfoKey to add keys used by the Codable objects in this framework.
extension CodingUserInfoKey {
    
    /// The key for the factory to use when coding.
    public static let factory = CodingUserInfoKey(rawValue: "RSDFactory.factory")!
    
    /// The key for the task identifier to use when coding.
    public static let taskIdentifier = CodingUserInfoKey(rawValue: "RSDFactory.taskIdentifier")!
    
    /// The key for the schema info to use when coding.
    public static let schemaInfo = CodingUserInfoKey(rawValue: "RSDFactory.schemaInfo")!
    
    /// The key for the task data source to use when coding.
    public static let taskDataSource = CodingUserInfoKey(rawValue: "RSDFactory.taskDataSource")!
    
    /// The key for pointing to a specific bundle for the decoded resources.
    public static let bundle = CodingUserInfoKey(rawValue: "RSDFactory.bundle")!
    
    /// The key for pointing to mutable coding info.
    public static let codingInfo = CodingUserInfoKey(rawValue: "RSDFactory.codingInfo")!
}

/// `JSONDecoder` and `PropertyListDecoder` do not share a common protocol so extend them to be
/// able to create the appropriate decoder and set the userInfo keys as needed.
public protocol RSDFactoryDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

extension JSONDecoder : RSDFactoryDecoder {
}

extension PropertyListDecoder : RSDFactoryDecoder {
}

/// Extension of Decoder to return the factory objects used by the Codable objects
/// in this framework.
extension Decoder {
    
    /// The factory to use when decoding.
    public var factory: RSDFactory {
        return self.userInfo[.factory] as? RSDFactory ?? RSDFactory.shared
    }
    
    /// The task info to use when decoding if there isn't a local task info defined on the object.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when decoding if there isn't a local task info defined on the object.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
    
    /// The default bundle to use for embedded resources.
    public var bundle: Bundle? {
        return self.userInfo[.bundle] as? Bundle
    }
    
    /// The coding info object to use when decoding.
    public var codingInfo: RSDCodingInfo? {
        return self.userInfo[.codingInfo] as? RSDCodingInfo
    }
}

/// `JSONEncoder` and `PropertyListEncoder` do not share a common protocol so extend them to be able
/// to create the appropriate decoder and set the userInfo keys as needed.
public protocol RSDFactoryEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

extension JSONEncoder : RSDFactoryEncoder {
}

extension PropertyListEncoder : RSDFactoryEncoder {
}

/// Extension of Encoder to return the factory objects used by the Codable objects
/// in this framework.
extension Encoder {
    
    /// The factory to use when encoding.
    public var factory: RSDFactory {
        return self.userInfo[.factory] as? RSDFactory ?? RSDFactory.shared
    }
    
    /// The task info to use when encoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when encoding.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
    
    /// The coding info object to use when encoding.
    public var codingInfo: RSDCodingInfo? {
        return self.userInfo[.codingInfo] as? RSDCodingInfo
    }
}

/// `RSDCodingInfo` is used as a pointer to a mutable class that can be used to assign any info that must be
/// mutated during the Decoding of an object.
public class RSDCodingInfo {
    public var userInfo : [CodingUserInfoKey : Any] = [:]
}
