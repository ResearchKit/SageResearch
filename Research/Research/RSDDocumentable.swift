//
//  RSDDocumentable.swift
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

/// `RSDStringEnumSet` is a protocol for defining the set of all string values included in an enum.
public protocol RSDStringEnumSet : Hashable, RawRepresentable, CaseIterable where RawValue == String {
}

/// `RSDIntEnumSet` is a protocol for defining the set of all int values included in an enum.
public protocol RSDIntEnumSet : Hashable, RawRepresentable, CaseIterable where RawValue == Int {
}

public struct RSDDocumentCreator {
    
    let allStringEnums: [RSDDocumentableStringEnum.Type] = {
        
        var allEnums: [RSDDocumentableStringEnum.Type] = [
        RSDAnswerResultType.BaseType.self,
        RSDAnswerResultType.SequenceType.self,
        RSDAsyncActionType.self,
        RSDCohortRuleOperator.self,
        RSDDateCoderObject.self,
        RSDDeviceType.self,
        RSDFormDataType.self,
        RSDFormUIHint.self,
        RSDIdentifier.self,
        RSDKeyboardType.self,
        RSDMotionRecorderType.self,
        RSDResultType.self,
        RSDStandardPermissionType.self,
        RSDStepType.self,
        RSDSurveyRuleOperator.self,
        RSDTextAutocapitalizationType.self,
        RSDTextAutocorrectionType.self,
        RSDTextSpellCheckingType.self,
        ]
        
        return allEnums
    }()
    
    let allIntEnums: [RSDDocumentableIntEnum.Type] = {
        
        var allEnums: [RSDDocumentableIntEnum.Type] = [
            RSDWeekday.self,
            ]
        
        return allEnums
    }()
    
    let allOptionSets: [RSDDocumentableOptionSet.Type] = [
        RSDActiveUIStepCommand.self,
        ]
    
    let allStringLiterals: [RSDDocumentableStringLiteral.Type] = [
        RSDChoiceObject<String>.self,
        RSDColorKey.self,
        RSDImageWrapper.self,
        RSDRegExValidatorObject.self,
        ]

    let allCodableObjects: [RSDDocumentableCodableObject.Type] = {
        var allCodableObjects: [RSDDocumentableCodableObject.Type] = [
            RSDAnimatedImageThemeElementObject.self,
            RSDAnswerResultObject.self,
            RSDAnswerResultType.self,
            RSDCohortNavigationRuleObject.self,
            RSDCollectionResultObject.self,
            RSDColorSwatch.self,
            RSDColorTile.self,
            RSDDateRangeObject.self,
            RSDDurationRangeObject.self,
            RSDFetchableImageThemeElementObject.self,
            RSDFileResultObject.self,
            RSDGrayScale.self,
            RSDNavigationUIActionObject.self,
            RSDNumberRangeObject.self,
            RSDResourceTransformerObject.self,
            RSDResultObject.self,
            RSDStandardAsyncActionConfiguration.self,
            RSDTaskResultObject.self,
            RSDTextFieldOptionsObject.self,
            RSDUIActionObject.self,
            RSDViewThemeElementObject.self,
            RSDWebViewUIActionObject.self,
            RSDVideoViewUIActionObject.self,
            RSDWeeklyScheduleObject.self,
            ]
        
        return allCodableObjects
    }()
    
    let allDecodableObjects: [RSDDocumentableDecodableObject.Type] = [
        RSDChoiceObject<Bool>.self,
        RSDChoiceObject<Date>.self,
        RSDChoiceObject<Double>.self,
        RSDChoiceObject<Int>.self,
        RSDChoiceObject<RSDFraction>.self,
        RSDChoiceObject<String>.self,
        RSDComparableSurveyRuleObject<Bool>.self,
        RSDComparableSurveyRuleObject<String>.self,
        RSDComparableSurveyRuleObject<Date>.self,
        RSDComparableSurveyRuleObject<Double>.self,
        RSDComparableSurveyRuleObject<Int>.self,
        RSDComparableSurveyRuleObject<RSDFraction>.self,
        RSDUIStepObject.self,
        RSDActiveUIStepObject.self,
        RSDFormUIStepObject.self,
        RSDOverviewStepObject.self,
        RSDResultSummaryStepObject.self,
        RSDSectionStepObject.self,
        RSDStepTransformerObject.self,
        RSDInputFieldObject.self,
        RSDDetailInputFieldObject.self,
        RSDCodableChoiceInputFieldObject<Bool>.self,
        RSDCodableChoiceInputFieldObject<String>.self,
        RSDCodableChoiceInputFieldObject<Date>.self,
        RSDCodableChoiceInputFieldObject<Double>.self,
        RSDCodableChoiceInputFieldObject<Int>.self,
        RSDCodableChoiceInputFieldObject<RSDFraction>.self,
        RSDColorKey.self,
        RSDColorPlacementThemeElementObject.self,
        RSDSingleColorThemeElementObject.self,
        RSDColorPalette.self,
        RSDMultipleComponentInputFieldObject.self,
        RSDSchemaInfoObject.self,
        RSDConditionalStepNavigatorObject.self,
        RSDTaskGroupObject.self,
        RSDTaskInfoObject.self,
        RSDTaskObject.self,
        ]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Decodable` objects used by this framework.
protocol RSDDocumentable {
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` enum objects used by this framework.
protocol RSDDocumentableStringEnum : RSDDocumentable, Codable {
    
    /// Not all of the enums have a `rawValue` of a `String` but they should all be codable using a string value.
    var stringValue: String { get }

    /// All the coding keys supported by this framework for defining this enum using a JSON dictionary.
    static func allCodingKeys() -> [String]
}

/// Any enum set can represent its coding keys by mapping the raw value to a string.
extension RSDStringEnumSet {
    static func allCodingKeys() -> [String] {
        return self.allCases.map{ $0.rawValue }
    }
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` enum objects used by this framework.
protocol RSDDocumentableIntEnum : RSDDocumentable, Codable {
    
    /// The int Value for the enum.
    var intValue: Int { get }
    
    /// All the coding keys supported by this framework for defining this enum using a JSON dictionary.
    static func allCodingKeys() -> [Int]
}

/// Any enum set can represent its coding keys by mapping the raw value to a string.
extension RSDIntEnumSet {
    
    var intValue: Int {
        return rawValue
    }
    
    static func allCodingKeys() -> [Int] {
        return self.allCases.map{ $0.rawValue }
    }
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` option set objects that are decoded from a list of strings.
/// - seealso: `RSDStringLiteralOptionSet`
protocol RSDDocumentableOptionSet : RSDDocumentable, Codable {
    
    /// All the coding keys supported by this framework for defining this option set using a JSON dictionary.
    static func allCodingKeys() -> [String]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects that are encoded and decoded using any string.
/// - seealso: `ExpressibleByStringLiteral`
protocol RSDDocumentableStringLiteral : RSDDocumentable, Codable {
    
    /// Not all of the string literals have a `rawValue` of a `String` but they should all be codable using a string value.
    var stringValue: String { get }
    
    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [String]
}

extension RawRepresentable where Self.RawValue == String {
    public var stringValue: String { return rawValue }
}

protocol RSDDocumentableObject : RSDDocumentable {
    
    /// A list of `CodingKey` values for all the `Decodable` properties on this object.
    static func codingKeys() -> [CodingKey]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects and for use in documenting them.
protocol RSDDocumentableCodableObject : RSDDocumentableObject, Codable {

    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [Encodable]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects and for use in documenting them.
protocol RSDDocumentableDecodableObject : RSDDocumentableObject, Decodable {
    
    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [[String : RSDJSONValue]]
}
