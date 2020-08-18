//
//  RSDFormDataType.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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

/// `RSDFormDataType` is used to describe the data type for a form input. This is different from the
/// `RSDAnswerResultType` which is a struct that can be used to encode and decode the input field
/// answer value. This describes the type of information required by the input field.
///
/// - seealso: `RSDInputField` and `RSDFormUIHint`.
///
@available(*, deprecated, message: "Use `AnswerType` instead")
public enum RSDFormDataType {
    
    /// Base data types are basic types that can be defined with only a base type.
    case base(BaseType)
    
    /// Collection data types are some kind of a collection with a base type.
    case collection(CollectionType, BaseType)
    
    /// A date that includes encoding information for the portion of the date/time that is
    /// represented by this data type.
    case dateRange(DateRangeType)
    
    /// A measurement is a human-data measurement. The measurement range indicates the expected size
    /// of the human being measured. In US English units, this is required to determine the expected
    /// localization for the measurement.
    ///
    /// For example, an infant weight would be in lb/oz whereas an adult weight would be in lb.
    /// Default range is for an adult.
    case measurement(MeasurementType, MeasurementRange)
    
    /// A postal code is a custom input field that only stores a part of the participant's postal
    /// code (zipcode). This is to protect the participant's privacy. Typically, this will mean
    /// only storing the first 3 characters of the postal code. The base type for a postal code is
    /// always a string.
    case postalCode
    
    /// A "detail" form data type is a data type that represents an input field where the data entry uses a
    /// detail that displays information using one or more input fields. The default base type is `.codable`.
    case detail(BaseType)
    
    /// Custom data types are undefined in the base SDK.
    case custom(String, BaseType)
    
    /// The base type of the form input field. This is used to indicate what the type is of the
    /// value being prompted and will affect the choice of allowed formatters.
    public enum BaseType: String, CaseIterable {

        /// The Boolean question type asks the participant to enter Yes or No (or the appropriate equivalents).
        case boolean
        
        /// In a date question, the participant can enter a date, time, or combination of the two. A date data
        /// type can map to a `RSDDateRange` to box the allowed values.
        case date
        
        /// The decimal question type asks the participant to enter a decimal number. A decimal data type can
        /// map to a `RSDNumberRange` to box the allowed values.
        case decimal
        
        /// In a duration question, the participant can enter a time span such as "8 hours, 5 minutes"
        /// or "3 minutes, 15 seconds".
        case duration
        
        /// The fraction question type asks the participant to enter a fractional number. A fractional data type
        /// can map to a `RSDNumberRange` to box the allowed values.
        case fraction
        
        /// The integer question type asks the participant to enter an integer number. An integer data type can
        /// map to a `RSDNumberRange` to box the allowed values, but will store the value as an `Int`.
        case integer
        
        /// In a string question, the participant can enter text.
        case string
        
        /// In a year question, the participant can enter a year when an event occured. A year data type can map
        /// to an `RSDDateRange` or `RSDNumberRange` to box the allowed values.
        case year
        
        /// A `Codable` object. This is an object that can be represented using a JSON or XML dictionary.
        case codable
    }
    
    /// The collection type for the input field. The supported types are for choice-style questions or
    /// multiple component questions where the user selected from one or more fields to build a single
    /// answer result.
    public enum CollectionType: String, CaseIterable {
        
        /// In a multiple choice question, the participant can pick one or more options.
        case multipleChoice
        
        /// In a single choice question, the participant can pick one item from a list of options.
        case singleChoice
        
        /// In a multiple component question, the participant can pick one choice from each component
        /// or enter a formatted text string such as a phone number or blood pressure.
        case multipleComponent
    }
    
    /// A measurement type is a human-data measurement such as height or weight.
    public enum MeasurementType: String, CaseIterable {
        
        /// A measurement of height.
        case height
        
        /// A measurement of weight.
        case weight
        
        /// A measurement of blood pressure.
        case bloodPressure
    }
    
    /// The measurement range is used to determine units that are appropriate to the
    /// size of the person.
    public enum MeasurementRange: String, CaseIterable {
        
        /// Measurement units should be ranged for an adult.
        case adult
        
        /// Measurement units should be ranged for a child.
        case child
        
        /// Measuremet units should be ranged for an infant.
        case infant
    }
    
    /// The `DateRangeType` is used to simplify transforming classes on Android.
    ///
    /// Android has different classes for the common date components that may be of interest when
    /// asking the participant about a "date". Because of this, for many cases, that platform does
    /// not need to define an `RSDDateRange` to differentiate between *which* subset of date
    /// components should be requested. This form data type is used to differentiate between these
    /// different types. While on iOS, this requires some custom handling in the data source, it
    /// greatly simplifies decoding on Android and is thus supported here.
    ///
    /// The date range type *only* supports those types that are native to Android. Custom date
    /// components such as year only or year and month only still require defining the supported
    /// ranges using the `RSDDateRange` protocol.
    ///
    /// Additionally, the `rawValue` key of "date" still maps to `.base(.date)` to maintain
    /// reverse-compatibility to existing JSON-encoded objects.
    ///
    public enum DateRangeType: String, CaseIterable {
        
        /// Includes time, date, and GMT timezone offset ("yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ").
        case timestamp
        
        /// Includes date only ("yyyy-MM-dd").
        ///
        /// - note: This framework already maps the `rawValue` of "date" to the `.base(.date)` data
        /// type which is a generic that can be used to define dates independently of which
        /// components are displayed to the user.
        case dateOnly
        
        /// Includes time only ("HH:mm:ss").
        ///
        /// - note: Use a custom naming key of "time" to match the `rawValue` already defined for
        /// Android.
        case timeOnly = "time"

        /// The default coding date format.
        public var dateFormat: String {
            switch self {
            case .timestamp:
                return RSDDateCoderObject.timestamp.rawValue
            case .dateOnly:
                return RSDDateCoderObject.dateOnly.rawValue
            case .timeOnly:
                return RSDDateCoderObject.timeOfDay.rawValue
            }
        }
    }
    
    /// List of the standard UI hints that are valid for this data type.
    ///
    /// The valid hints are returned in priority order such that if the preferred hint is not
    /// supported by the UI then a fall-back will be selected. For example, `.base(.date)` will
    /// return `.picker` as its preferred hint, whereas `.base(.integer)` will return `.textfield`,
    /// but both support `.textfield` *and* `.picker`.
    ///
    public var validStandardUIHints: [RSDFormUIHint] {
        switch self {
        case .base(let baseType):
            switch baseType {
            case .boolean:
                return [.list, .checkbox, .radioButton, .toggle, .picker]
                
            case .date, .duration:
                return [.picker, .textfield]
                
            case .decimal, .integer, .year, .fraction:
                return [.textfield, .slider, .picker]
                
            case .string:
                return [.textfield, .multipleLine]
            
            case .codable:
                return [.disclosureArrow, .button, .link]
            }
        
        case .collection(let collectionType, _):
            switch collectionType {
            case .multipleChoice, .singleChoice:
                return [.list, .checkbox, .combobox, .picker, .radioButton, .slider]
                
            case .multipleComponent:
                return [.picker, .textfield]
            }
            
        case .dateRange(_):
            return [.picker, .textfield]
        
        case .measurement(let measurementType, _):
            switch measurementType {
            case .bloodPressure:
                return [.textfield]
            case .height, .weight:
                return [.picker, .textfield]
            }
        
        case .postalCode:
            return [.textfield]
            
        case .detail(_):
            return [.disclosureArrow, .button, .link, .section]

        case .custom(_,_):
            return RSDFormUIHint.StandardHints.allCases.map { $0.hint }
        }
    }
    
    /// The set of ui hints that can display using a list format such as a scrolling list.
    public var listSelectionHints : Set<RSDFormUIHint> {
        switch self {
        case .collection(.singleChoice, _),
             .collection(.multipleChoice, _),
             .base(.boolean):
            return [.list, .checkbox, .radioButton]
            
        default:
            return []
        }
    }
    
    /// The `BaseType` for this form type. All data types have a base type, though some carry additional information.
    public var baseType : BaseType {
        switch self {
        case .base(let baseType):
            return baseType
            
        case .collection(_, let baseType):
            return baseType
            
        case .dateRange(_):
            return .date
            
        case .measurement(let measurement, _):
            switch measurement {
            case .height, .weight:
                return .decimal
                
            case .bloodPressure:
                return .integer
            }
        
        case .postalCode:
            return .string
            
        case .detail(let baseType):
            return baseType
            
        case .custom(_, let baseType):
            return baseType
        }
    }
    
    public func defaultAnswerResultType() -> RSDAnswerResultType {
        let base = self.defaultAnswerResultBaseType()
        
        switch self {
        case .collection(let collectionType, _):
            switch collectionType {
            case .multipleChoice, .multipleComponent:
                return RSDAnswerResultType(baseType: base, sequenceType: .array, formDataType: self, dateFormat: nil, unit: nil, sequenceSeparator: nil)
            case .singleChoice:
                return RSDAnswerResultType(baseType: base, sequenceType: nil, formDataType: self, dateFormat: nil, unit: nil, sequenceSeparator: nil)
            }
            
        case .dateRange(let rangeType):
            return RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: self, dateFormat: rangeType.dateFormat, unit: nil, sequenceSeparator: nil)
            
        case .measurement(let measurementType, _):
            switch measurementType {
            case .bloodPressure:
                return RSDAnswerResultType(baseType: .string, sequenceType: nil, formDataType: self, dateFormat: nil, unit: nil, sequenceSeparator: nil)
            case .height, .weight:
                return RSDAnswerResultType(baseType: .decimal, sequenceType: nil, formDataType: self, dateFormat: nil, unit: nil, sequenceSeparator: nil)
            }
            
        default:
            return RSDAnswerResultType(baseType: base, sequenceType: nil, formDataType: self, dateFormat: nil, unit: nil, sequenceSeparator: nil)
        }
        
    }

    /// Maps the base type of the `RSDFormDataType` to the base type of the `RSDAnswerResultType`.
    ///
    /// - returns: the default result answer type for this input field.
    public func defaultAnswerResultBaseType() -> RSDAnswerResultType.BaseType {
        switch self.baseType {
        case .boolean:
            return .boolean
        case .date:
            return .date
        case .decimal, .fraction, .duration:
            return .decimal
        case .integer, .year:
            return .integer
        case .string:
            return .string
        case .codable:
            return .codable
        }
    }
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDFormDataType] {
        let baseTypes = BaseType.allCases
        let allBase: [RSDFormDataType] = baseTypes.map { .base($0) }
        let allCollection: [RSDFormDataType] = CollectionType.allCases.map { (collectionType) -> [RSDFormDataType] in
            return baseTypes.map { .collection(collectionType, $0)}
            }.flatMap { $0 }
        let allMeasurement: [RSDFormDataType] = MeasurementType.allCases.map { (measurementType) -> [RSDFormDataType] in
            return MeasurementRange.allCases.map { .measurement(measurementType, $0) }
        }.flatMap { $0 }
        let allDateRange: [RSDFormDataType] = DateRangeType.allCases.map { .dateRange($0) }
        let allDetail: [RSDFormDataType] = baseTypes.map { .detail($0) }
        return [allBase, allCollection, allDateRange, allMeasurement, allDetail, [.postalCode]].flatMap { $0 }
    }
}

fileprivate let kDetailCodingKey = "detail"
fileprivate let kPostalCodeCodingKey = "postalCode"

@available(*, deprecated, message: "Use `AnswerType` instead")
extension RSDFormDataType: RawRepresentable, Codable, Hashable {
    
    public init?(rawValue: String) {
        let split = rawValue.components(separatedBy: ".")
        if split.count == 1, let subtype = BaseType(rawValue: rawValue) {
            self = .base(subtype)
        }
        else if split.count == 1, let rangeType = DateRangeType(rawValue: rawValue) {
            self = .dateRange(rangeType)
        }
        else if split.count <= 2, let collectionType = CollectionType(rawValue: split[0]) {
            let baseType: BaseType = ((split.count == 2) ? BaseType(rawValue: split[1]) : nil) ?? .string
            self = .collection(collectionType, baseType)
        }
        else if split.count <= 2, let measurementType = MeasurementType(rawValue: split[0]) {
            let range: MeasurementRange = ((split.count == 2) ? MeasurementRange(rawValue: split[1]) : nil) ?? .adult
            self = .measurement(measurementType, range)
        }
        else if rawValue == kPostalCodeCodingKey {
            self = .postalCode
        }
        else {
            let subtype: BaseType = {
                guard split.count == 2, let subtype = BaseType(rawValue: split[1])
                    else {
                        return .codable
                }
                return subtype
            }()
            let typeValue = split[0]
            if typeValue == kDetailCodingKey {
                self = .detail(subtype)
            }
            else {
                self = .custom(typeValue, subtype)
            }
        }
    }
    
    public var rawValue: String {
        switch (self) {
        case .base(let value):
            return value.rawValue
            
        case .collection(let collectionType, let baseType):
            return "\(collectionType.rawValue).\(baseType.rawValue)"
            
        case .dateRange(let rangeType):
            return rangeType.rawValue
        
        case .measurement(let measurement, let range):
            return "\(measurement.rawValue).\(range.rawValue)"
            
        case .detail(let baseType):
            if baseType == .codable {
                return kDetailCodingKey
            }
            else {
                return "\(kDetailCodingKey).\(baseType.rawValue)"
            }
        
        case .postalCode:
            return kPostalCodeCodingKey
            
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

@available(*, deprecated, message: "Use `AnswerType` instead")
extension RSDFormDataType : ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

@available(*, deprecated, message: "Use `AnswerType` instead")
extension RSDFormDataType.BaseType {
    var jsonType : JsonType {
        switch self {
        case .boolean: return .boolean
        case .codable: return .object
        case .date: return .string
        case .decimal: return .number
        case .duration: return .number
        case .fraction: return .string
        case .integer: return .integer
        case .string: return .string
        case .year: return .integer
        }
    }
}
