//
//  RSDFormDataType.swift
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
 `RSDFormDataType` is used to describe the data type for a form input.
 */
public enum RSDFormDataType {
    
    /**
     Base data types are basic types that can be defined with only a base type.
     */
    case base(BaseType)
    
    /**
     Collection data types are some kind of a collection with a base type.
     */
    case collection(CollectionType, BaseType)
    
    /**
     A measurement is a human-collected measurement. The measurement range indicates the expected size of the human being measured. In US English units, this is required to deterine the expected localization for the measurement. For example, an infant weight would be in lb/oz whereas an adult weight would be in lb. Default range is for an adult.
     */
    case measurement(MeasurementType, MeasurementRange)
    
    /**
     Custom data types are undefined in the base SDK.
     */
    case custom(String, BaseType)
    
    public enum BaseType: String {

        /**
         The Boolean question type asks the participant to enter Yes or No (or the appropriate equivalents).
         */
        case boolean
        
        /**
         In a date question, the participant can enter a date, time or combination of the two. A date data type can map to a `RSDDateRange` to box the allowed values.
         */
        case date
        
        
        /**
         In a year question, the participant can enter a year when an event occured. A year data type can map to an `RSDDateRange` or `RSDDecimalRange` to box the allowed values.
         */
        case year
        
        /**
         The decimal question type asks the participant to enter a decimal number. A decimal data type can map to a `RSDDecimalRange` to box the allowed values.
         */
        case decimal
        
        /**
         The integer question type asks the participant to enter an integer number. A decimal data type can map to a `RSDIntegerRange` to box the allowed values.
         */
        case integer
        
        /**
         In a string question, the participant can enter text.
         */
        case string
        
        /**
         In a time interval question, the participant can enter a time span such as "4 years, 3 months" or "8 hours, 5 minutes".
         */
        // TODO: syoung 10/06/2017 add TimeIntervalRange
        //case timeInterval
    }
    
    public enum CollectionType: String {
        
        /**
         In a multiple choice question, the participant can pick one or more options.
         */
        case multipleChoice
        
        /**
         In a single choice question, the participant can pick one item from a list of options.
         */
        case singleChoice
        
        /**
         In a multiple component question, the participant can pick one choice from each component or enter a formatted text string such as a phone number.
         */
        case multipleComponent
    }
    
    public enum MeasurementType: String {
        
        /**
         A measurement of height.
         */
        case height
        
        /**
         A measurement of weight.
         */
        case weight
        
        /**
         A measurement of blood pressure.
         */
        case bloodPressure
    }
    
    public enum MeasurementRange: String {
        
        /**
         Measurement units should be ranged for an adult.
         */
        case adult
        
        /**
         Measurement units should be ranged for a child.
         */
        case child
        
        /**
         Measuremet units should be ranged for an infant.
         */
        case infant
    }
    
    /**
     List of the standard UI hints that are valid for this data type.
     */
    public var validStandardUIHints: [RSDFormUIHint.Standard] {
        switch self {
        case .base(let baseType):
            switch baseType {
            case .boolean:
                return [.list, .picker, .checkbox, .radioButton, .toggle]
                
            case .date:
                return [.picker, .textfield]
                
            case .decimal, .integer, .year:
                return [.textfield, .slider, .picker]
                
            case .string:
                return [.textfield, .multipleLine]
            }
        
        case .collection(let collectionType, _):
            switch (collectionType) {
            case .multipleChoice, .singleChoice:
                return [.list, .slider, .checkbox, .combobox, .picker, .radioButton]
                
            case .multipleComponent:
                return [.picker, .textfield]
            }
        
        case .measurement(_, _):
            return [.picker, .textfield]

        case .custom(_):
            return RSDFormUIHint.Standard.all
        }
    }
    
    public var listSelectionHints : Set<RSDFormUIHint> {
        switch self {
        case .collection(let collectionType, _):
            if collectionType == .multipleComponent {
                return []
            } else {
                return [.standard(.checkbox), .standard(.list), .standard(.radioButton)]
            }
            
        case .base(.boolean):
            return [.standard(.list)]
            
        default:
            return []
        }
    }
    
    public var baseType : BaseType {
        switch self {
        case .base(let baseType):
            return baseType
            
        case .collection(_, let baseType):
            return baseType
            
        case .measurement(let measurement, _):
            switch measurement {
            case .height, .weight:
                return .decimal
                
            case .bloodPressure:
                return .integer
            }
            
        case .custom(_, let baseType):
            return baseType
        }
    }
    
    /**
     Return the default result answer type for this input field.
     */
    public func defaultAnswerResultBaseType() -> RSDAnswerResultType.BaseType {
        switch self.baseType {
        case .boolean:
            return .boolean
        case .date:
            return .date
        case .decimal:
            return .decimal
        case .integer, .year:
            return .integer
        case .string:
            return .string
        }
    }
}

extension RSDFormDataType: RawRepresentable, Codable {
    public typealias RawValue = String
    
    public init?(rawValue: RawValue) {
        let split = rawValue.components(separatedBy: ".")
        if split.count == 1, let subtype = BaseType(rawValue: rawValue) {
            self = .base(subtype)
        }
        else if split.count <= 2, let collectionType = CollectionType(rawValue: split[0]) {
            let baseType: BaseType = ((split.count == 2) ? BaseType(rawValue: split[1]) : nil) ?? .string
            self = .collection(collectionType, baseType)
        }
        else if split.count <= 2, let measurementType = MeasurementType(rawValue: split[0]) {
            let range: MeasurementRange = ((split.count == 2) ? MeasurementRange(rawValue: split[1]) : nil) ?? .adult
            self = .measurement(measurementType, range)
        }
        else if split.count == 2, let subtype = BaseType(rawValue: split[1]) {
            self = .custom(split[0], subtype)
        }
        else {
            self = .custom(rawValue, .string)
        }
    }
    
    public var rawValue: String {
        switch (self) {
        case .base(let value):
            return value.rawValue
            
        case .collection(let collectionType, let baseType):
            return "\(collectionType.rawValue).\(baseType.rawValue)"
        
        case .measurement(let measurement, let range):
            return "\(measurement).\(range)"
            
        case .custom(let value, let baseType):
            if baseType == .string {
                return value
            }
            else {
                return "\(value).\(baseType.rawValue)"
            }
        }
    }
}

extension RSDFormDataType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDFormDataType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}
