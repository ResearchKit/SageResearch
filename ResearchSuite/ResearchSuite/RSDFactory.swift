//
//  RSDFactory.swift
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

/**
 `RSDFactory` handles customization of the elements of a task.
 */
open class RSDFactory {
    
    public static var shared = RSDFactory()
    
    public init() {
    }
    
    /**
     Optional data source for this factory.
     */
    public var taskDataSource: RSDTaskDataSource?

    // MARK: Class name factory
    
    private enum TypeKeys: String, CodingKey {
        case type
    }
    
    /**
     Get a string that will identify the type of object to instantiate for the given decoder.
     
     By default, this will look in the container for the decoder for a key/value pair where the key == "type" and the value is a `String`.
     
     @param decoder     The decoder to inspect.
     
     @return            The string representing this class type (if found).
     */
    open func typeName(from decoder:Decoder) throws -> String? {
        let container = try decoder.container(keyedBy: TypeKeys.self)
        return try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    
    // MARK: Task factory

    /**
     Use the resource transformer to get a data object to decode into a task.

     @param resourceTransformer     The resource transformer.
     
     @return                        The decoded task.
     */
    open func decodeTask(with resourceTransformer: RSDResourceTransformer, taskInfo: RSDTaskInfoStep? = nil, schemaInfo: RSDSchemaInfo? = nil) throws -> RSDTask {
        let (data, type) = try resourceTransformer.resourceData()
        return try decodeTask(with: data,
                              resourceType: type,
                              typeName: resourceTransformer.classType,
                              taskInfo: taskInfo,
                              schemaInfo: schemaInfo)
    }
    
    /**
     Decode an object with top-level data (json or plist) for a given `resourceType`, `typeName`, and `taskInfo`.
     
     @param data            The data to use to decode the object.
     @param resourceType    The type of resource (json or plist).
     @param typeName        The class name type key for this task (if any).
     @param taskInfo        The task info used to create this task (if any).
     
     @return                The created task.
     */
    open func decodeTask(with data: Data, resourceType: RSDResourceType, typeName: String? = nil, taskInfo: RSDTaskInfoStep? = nil, schemaInfo: RSDSchemaInfo? = nil) throws -> RSDTask {
        let decoder = try createDecoder(for: resourceType, taskInfo: taskInfo, schemaInfo: schemaInfo)
        return try decoder.decode(RSDTaskObject.self, from: data)
    }
    
    
    // MARK: Task Info factory
    
    /**
     Decode the task info from this decoder. This method *must* return a task info object. The default implementation will return a `RSDTaskInfoStepObject`.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The task info created from this decoder.
     */
    open func decodeTaskInfo(from decoder: Decoder) throws -> RSDTaskInfoStep {
        return try RSDTaskInfoStepObject(from: decoder)
    }
    
    
    // MARK: Task Transformer factory
    
    /**
     Decode the task transformer from this decoder. This method *must* return a task transformer object. The default implementation will return a `RSDTaskResourceTransformerObject`.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The object created from this decoder.
     */
    open func decodeTaskTransformer(from decoder: Decoder) throws -> RSDTaskTransformer {
        return try RSDTaskResourceTransformerObject(from: decoder)
    }
    
    
    // MARK: Step navigator factory
    
    /**
     Decode the step navigator from this decoder. This method *must* return a step navigator. The default implementation will return a `RSDConditionalStepNavigatorObject`.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step navigator created from this decoder.
     */
    open func decodeStepNavigator(from decoder: Decoder) throws -> RSDStepNavigator {
        return try RSDConditionalStepNavigatorObject(from: decoder)
    }
    

    // MARK: Step factory
    
    /**
     Type of steps that can be created by this factory.
     */
    public enum StepType : String, Codable {
        case active         // RSDActiveUIStep
        case completion     // RSDUIStep
        case form           // RSDFormUIStep
        case instruction    // RSDUIStep
        case section        // RSDSectionStep
        case taskInfo       // RSDTaskInfoStep
    }
    
    /**
     Convenience method for decoding a list of steps.
     
     @param container   The unkeyed container with the steps.
     
     @return            An array of the steps.
     */
    public func decodeSteps(from container: UnkeyedDecodingContainer) throws -> [RSDStep] {
        var steps : [RSDStep] = []
        var stepsContainer = container
        while !stepsContainer.isAtEnd {
            let stepDecoder = try stepsContainer.superDecoder()
            if let step = try decodeStep(from: stepDecoder) {
                steps.append(step)
            }
        }
        return steps
    }
    
    /**
     Decode the step from this decoder. This method can be overridden to return `nil` if the step should be skipped.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeStep(from decoder: Decoder) throws -> RSDStep? {
        guard let name = try typeName(from: decoder) else {
            throw RSDValidationError.undefinedClassType("\(self) does not support decoding a step without a `type` key defining a value for the the type name.")
        }
        return try decodeStep(from: decoder, with: name)
    }
    
    /**
     Decode the step from this decoder. This method can be overridden to return `nil` if the step should be skipped.
     
     @param typeName   The string representing the class name for this step.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeStep(from decoder:Decoder, with typeName: String) throws -> RSDStep? {
        guard let type = StepType(rawValue: typeName) else {
            return try RSDGenericStepObject(from: decoder)
        }
        return try decodeStep(from: decoder, with: type)
    }
    
    /**
     Decode the step from this decoder. This method can be overridden to return `nil` if the step should be skipped.
     
     @param type        The `StepType` to instantiate.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeStep(from decoder:Decoder, with type:StepType) throws -> RSDStep? {
        switch (type) {
        case .instruction, .completion:
            return try RSDUIStepObject(from: decoder)
        case .active:
            return try RSDActiveUIStepObject(from: decoder)
        case .form:
            return try RSDFormUIStepObject(from: decoder)
        case .section:
            return try RSDSectionStepObject(from: decoder)
        case .taskInfo:
            return try RSDTaskInfoStepObject(from: decoder)
        }
    }
    
    
    // MARK: Input field factory
    
    /**
     Decode the input field from this decoder. This method can be overridden to return `nil` if the input field should be skipped.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeInputField(from decoder: Decoder) throws -> RSDInputField? {
        let dataType = try RSDInputFieldObject.dataType(from: decoder)
        return try decodeInputField(from: decoder, with: dataType)
    }
    
    /**
     Decode the input field from this decoder. This method can be overridden to return `nil` if the input field should be skipped.
     
     @param dataType    The data type for this step.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeInputField(from decoder:Decoder, with dataType: RSDFormDataType) throws -> RSDInputField? {
        switch dataType {
        case .collection(let collectionType, _):
            switch collectionType {
            case .multipleComponent:
                return try RSDMultipleComponentInputFieldObject(from: decoder)
                
            case .multipleChoice, .singleChoice:
                return try RSDChoiceInputFieldObject(from: decoder)
            }
        
        default:
            return try RSDInputFieldObject(from: decoder)
        }
    }
    
    
    // MARK: Conditional rule factory
    
    /**
     Decode a conditional rule from the given decoder. This method can be overridden to return `nil` if the conditional rule should be ignored for this platform.
     
     Note: syoung 10/03/2017 The base factory does not currently support any conditional rule objects. The conditional rule is included here for future implementation of data tracking across runs of a task.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The conditional rule (if any) created from this decoder.
     */
    open func decodeConditionalRule(from decoder:Decoder) throws -> RSDConditionalRule? {
        guard let typeName = try typeName(from: decoder) else {
            throw RSDValidationError.undefinedClassType("\(self) does not support decoding a conditional rule without a `type` key defining a value for the the class name.")
        }
        return try decodeConditionalRule(from: decoder, with: typeName)
    }
    
    /**
     Decode a conditional rule from the given decoder. This method can be overridden to return `nil` if the conditional rule should be ignored for this platform.
     
     Note: The base factory does not currently support any conditional rule objects. The conditional rule is included here for future implementation of data tracking.
     
     @param typeName   The string representing the class name for this conditional rule.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The conditional rule (if any) created from this decoder.
     */
    open func decodeConditionalRule(from decoder:Decoder, with typeName: String) throws -> RSDConditionalRule? {
        // Base class does not implement the conditional rule
            throw RSDValidationError.undefinedClassType("\(self) does not support `\(typeName)` as a decodable class type for a conditional rule.")
    }
    
    // MARK: UI action factory
    
    /**
     Decode an ui action from the given decoder.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The UI action created from this decoder.
     */
    open func decodeUIAction(from decoder:Decoder) throws -> RSDUIAction {
        // check if the decoder can be used to decode a web-based action
        if let webAction = try? RSDWebViewUIActionObject(from: decoder) {
            return webAction
        }
        return try RSDUIActionObject(from: decoder)
    }
    
    
    // MARK: Async action factory
    
    /**
     Decode an async action configuration from the given decoder. This method can be overridden to return `nil` if the action should be ignored for this platform.
     
     Note: syoung 10/03/2017 The base factory does not currently support any async action objects. The factory method is included here for subclassing purposes.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The configuration (if any) created from this decoder.
     */
    open func decodeAsyncActionConfiguration(from decoder:Decoder) throws -> RSDAsyncActionConfiguration? {
        guard let typeName = try typeName(from: decoder) else {
            throw RSDValidationError.undefinedClassType("\(self) does not support decoding a conditional rule without a `type` key defining a value for the the class name.")
        }
        return try decodeAsyncActionConfiguration(from: decoder, with: typeName)
    }
    
    /**
     Decode an async action configuration from the given decoder. This method can be overridden to return `nil` if the action should be ignored for this platform.
     
     Note: syoung 10/03/2017 The base factory does not currently support any async action objects. The factory method is included here for subclassing purposes.
     
     @param typeName   The string representing the class name for this conditional rule.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The configuration (if any) created from this decoder.
     */
    open func decodeAsyncActionConfiguration(from decoder:Decoder, with typeName: String) throws -> RSDAsyncActionConfiguration? {
        // Base class does not implement the conditional rule
        throw RSDValidationError.undefinedClassType("\(self) does not support `\(typeName)` as a decodable class type for an async action.")
    }
    
    
    // MARK: Result factory
    
    /**
     Type of steps that can be created by this factory.
     */
    public enum ResultType : String {
        case base, answer, collection, task, file
    }
    
    /**
     Convenience method for decoding a list of results.
     
     @param container   The unkeyed container with the results.
     
     @return            An array of the results.
     */
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
    
    /**
     Decode the result from this decoder.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The result (if any) created from this decoder.
     */
    open func decodeResult(from decoder: Decoder) throws -> RSDResult {
        guard let typeName = try typeName(from: decoder) else {
            return try RSDResultObject(from: decoder)
        }
        return try decodeResult(from: decoder, with: typeName)
    }
    
    /**
     Decode the result from this decoder.
     
     @param decoder     The decoder to use to instatiate the object.
     @param typeName   The string representing the class name for this object.
     
     @return            The result (if any) created from this decoder.
     */
    open func decodeResult(from decoder: Decoder, with typeName: String) throws -> RSDResult {
        guard let resultType = ResultType(rawValue: typeName) else {
            throw RSDValidationError.undefinedClassType("\(self) does not support `\(typeName)` as a decodable class type for a result.")
        }
        switch resultType {
        case .base:
            return try RSDResultObject(from: decoder)
        case .answer:
            return try RSDAnswerResultObject(from: decoder)
        case .collection:
            return try RSDStepCollectionResultObject(from: decoder)
        case .task:
            return try RSDTaskResultObject(from: decoder)
        case .file:
            return try RSDFileResultObject(from: decoder)
        }
    }
    
    
    // MARK: Decoder
    
    public enum CodingUserInfoKeys : String {
        
        case factory, taskInfo, schemaInfo, taskDataSource
        
        public var key : CodingUserInfoKey {
            return CodingUserInfoKey(rawValue: self.rawValue)!
        }
    }

    open func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            return try self.decodeDate(from: string, dateFormat: nil, codingPath: decoder.codingPath)
        })
        decoder.userInfo[CodingUserInfoKeys.factory.key] = self
        return decoder
    }
    
    open func createPropertyListDecoder() -> PropertyListDecoder {
        let decoder = PropertyListDecoder()
        decoder.userInfo[CodingUserInfoKeys.factory.key] = self
        return decoder
    }
    
    /**
     Create the appropriate decoder from the given resource.
     
     @param resourceType    The resource type.
     @param taskInfo        The task info to pass with the decoder.
     @param schemaInfo      The schema info to pass with the decoder.
     
     @return                The decoder for the given type.
     */
    open func createDecoder(for resourceType: RSDResourceType, taskInfo: RSDTaskInfoStep? = nil, schemaInfo: RSDSchemaInfo? = nil) throws -> RSDFactoryDecoder {
        var decoder : RSDFactoryDecoder = try {
            if resourceType == .json {
                return self.createJSONDecoder()
            }
            else if resourceType == .plist {
                return self.createPropertyListDecoder()
            }
            else {
                let supportedTypes: [RSDResourceType] = [.json, .plist]
                let supportedTypeList = supportedTypes.map({$0.rawValue}).joined(separator: ",")
                throw RSDResourceTransformerError.invalidResourceType("ResourceType \(resourceType.rawValue) is not supported by this factory. Supported types: \(supportedTypeList)")
            }
            }()
        if let taskInfo = taskInfo {
            decoder.userInfo[CodingUserInfoKeys.taskInfo.key] = taskInfo
        }
        if let schemaInfo = schemaInfo {
            decoder.userInfo[CodingUserInfoKeys.schemaInfo.key] = schemaInfo
        }
        if let dataSource = self.taskDataSource {
            decoder.userInfo[CodingUserInfoKeys.taskDataSource.key] = dataSource
        }
        return decoder
    }
    
    open func decodeDate(from string: String, dateFormat: String? = nil) -> Date? {
        if let format = dateFormat {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.date(from: string)
        } else if let date = RSDClassTypeMap.shared.timestampFormatter.date(from: string) {
            return date
        } else if let date = RSDClassTypeMap.shared.dateOnlyFormatter.date(from: string) {
            return date
        } else if let date = RSDClassTypeMap.shared.timeOnlyFormatter.date(from: string) {
            return date
        } else {
            return ISO8601DateFormatter().date(from: string)
        }
    }
    
    internal func decodeDate(from string: String, dateFormat: String?, codingPath: [CodingKey]) throws -> Date {
        guard let date = decodeDate(from: string, dateFormat: dateFormat) else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not decode \(string) into a date.")
            throw DecodingError.typeMismatch(Date.self, context)
        }
        return date
    }
    
    // MARK: Encoder
    
    open func createJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ (date, encoder) in
            let string = self.encodedDate(from: date, codingPath: encoder.codingPath)
            var container = encoder.singleValueContainer()
            try container.encode(string)
        })
        encoder.outputFormatting = .prettyPrinted
        encoder.userInfo[CodingUserInfoKeys.factory.key] = self
        return encoder
    }
    
    open func createPropertyListEncoder() -> PropertyListEncoder {
        let encoder = PropertyListEncoder()
        encoder.userInfo[CodingUserInfoKeys.factory.key] = self
        return encoder
    }
    
    open func encodedDate(from date: Date, codingPath: [CodingKey]) -> String {
        return RSDClassTypeMap.shared.timestampFormatter.string(from: date)
    }
}

/**
 `JSONDecoder` and `PropertyListDecoder` do not share a common protocol so extend them to be able to create the appropriate decoder and set the userInfo keys as needed.
 */
public protocol RSDFactoryDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

extension JSONDecoder : RSDFactoryDecoder {
}

extension PropertyListDecoder : RSDFactoryDecoder {
}

extension Decoder {
    
    public var factory: RSDFactory {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.factory.key] as? RSDFactory ?? RSDFactory.shared
    }
    
    public var taskInfo: RSDTaskInfoStep? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.taskInfo.key] as? RSDTaskInfoStep
    }
    
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.schemaInfo.key] as? RSDSchemaInfo
    }
    
    public var taskDataSource: RSDTaskDataSource? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.taskDataSource.key] as? RSDTaskDataSource
    }
}

/**
 `JSONEncoder` and `PropertyListEncoder` do not share a common protocol so extend them to be able to create the appropriate decoder and set the userInfo keys as needed.
 */
public protocol RSDFactoryEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

extension JSONEncoder : RSDFactoryEncoder {
}

extension PropertyListEncoder : RSDFactoryEncoder {
}

extension Encoder {
    
    public var factory: RSDFactory {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.factory.key] as? RSDFactory ?? RSDFactory.shared
    }
    
    public var taskInfo: RSDTaskInfoStep? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.taskInfo.key] as? RSDTaskInfoStep
    }
    
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.schemaInfo.key] as? RSDSchemaInfo
    }
    
    public var taskDataSource: RSDTaskDataSource? {
        return self.userInfo[RSDFactory.CodingUserInfoKeys.taskDataSource.key] as? RSDTaskDataSource
    }
}
