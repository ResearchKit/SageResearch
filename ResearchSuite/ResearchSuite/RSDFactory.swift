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

public protocol RSDFactoryDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder : RSDFactoryDecoder {
}

extension PropertyListDecoder : RSDFactoryDecoder {
}

open class RSDFactory {
    
    public static var shared = RSDFactory()
    
    // MARK: Decoding
    
    public static let decoderFactoryKey = CodingUserInfoKey(rawValue: "RSDFactory")!
    
    open func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.userInfo[RSDFactory.decoderFactoryKey] = self
        return decoder
    }
    
    open func createPropertyListDecoder() -> PropertyListDecoder {
        let decoder = PropertyListDecoder()
        decoder.userInfo[RSDFactory.decoderFactoryKey] = self
        return decoder
    }
    
    
    // MARK: Class name factory
    
    private enum ClassTypeKey: String, CodingKey {
        case type
    }
    
    /**
     Get a string that will identify the type of class to instantiate for the given decoder.
     
     By default, this will look in the container for the decoder for a key/value pair where the key == "type" and the value is a `String`.
     
     @param decoder     The decoder to inspect.
     
     @return            The string representing this class type (if found).
     */
    open func classTypeName(from decoder:Decoder) throws -> String? {
        let container = try decoder.container(keyedBy: ClassTypeKey.self)
        return try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    
    // MARK: Task factory

    /**
     Use the resource transformer to get a data object to decode into a task.

     @param resourceTransformer     The resource transformer.
     
     @return                        The decoded task.
     */
    open func decodeTask(with resourceTransformer: RSDResourceTransformer) throws -> RSDTask {
        let (data, type) = try resourceTransformer.resourceData()
        return try decodeTask(with: data,
                              resourceType: type,
                              className: resourceTransformer.classType,
                              taskInfo: resourceTransformer as? RSDTaskInfo)
    }
    
    /**
     Decode an object with top-level data (json or plist) for a given `resourceType`, `className`, and `taskInfo`.
     
     @param data            The data to use to decode the object.
     @param resourceType    The type of resource (json or plist).
     @param className       The class name type key for this task (if any).
     @param taskInfo        The task info used to create this task (if any).
     
     @return                The created task.
     */
    open func decodeTask(with data: Data, resourceType: RSDResourceType, className: String? = nil, taskInfo: RSDTaskInfo? = nil) throws -> RSDTask {
        let decoder : RSDFactoryDecoder = try {
            if resourceType == .json {
                return self.createJSONDecoder()
            }
            else if resourceType == .plist {
                return self.createPropertyListDecoder()
            }
            else {
                throw RSDResourceTransformerError.invalidResourceType
            }
        }()
        var task = try decoder.decode(RSDTaskObject.self, from: data)
        if task.taskInfo == nil {
            task.taskInfo = taskInfo
        }
        return task
    }
    
    
    // Mark: Step navigator factory
    
    /**
     Decode the step navigator from this decoder. This method *must* return a step navigator. The default implementation will return a `RSDConditionalStepNavigatorObject`.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step navigator created from this decoder.
     */
    open func decodeStepNavigator(decoder: Decoder) throws -> RSDStepNavigator {
        return try RSDConditionalStepNavigatorObject(from: decoder)
    }
    

    // MARK: Step factory
    
    /**
     Type of steps that can be created by this factory.
     */
    public enum StepType : String {
        case instruction, active
    }
    
    /**
     Decode the step from this decoder. This method can be overridden to return `nil` if the step should be skipped.
     
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeStep(from decoder: Decoder) throws -> RSDStep? {
        guard let className = try classTypeName(from: decoder) else {
            throw RSDValidationError.undefinedClassType
        }
        return try decodeStep(from: decoder, with: className)
    }
    
    /**
     Decode the step from this decoder. This method can be overridden to return `nil` if the step should be skipped.
     
     @param className   The string representing the class name for this step.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The step (if any) created from this decoder.
     */
    open func decodeStep(from decoder:Decoder, with className: String) throws -> RSDStep? {
        guard let type = StepType(rawValue: className) else {
            throw RSDValidationError.undefinedClassType
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
        case .instruction:
            return try RSDUIStepObject(from: decoder)
        case .active:
            return try RSDActiveUIStepObject(from: decoder)
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
        guard let className = try classTypeName(from: decoder) else {
            throw RSDValidationError.undefinedClassType
        }
        return try decodeConditionalRule(from: decoder, with: className)
    }
    
    /**
     Decode a conditional rule from the given decoder. This method can be overridden to return `nil` if the conditional rule should be ignored for this platform.
     
     Note: The base factory does not currently support any conditional rule objects. The conditional rule is included here for future implementation of data tracking.
     
     @param className   The string representing the class name for this conditional rule.
     @param decoder     The decoder to use to instatiate the object.
     
     @return            The conditional rule (if any) created from this decoder.
     */
    open func decodeConditionalRule(from decoder:Decoder, with className: String) throws -> RSDConditionalRule? {
        // Base class does not implement the conditional rule
        throw RSDValidationError.undefinedClassType
    }
}
