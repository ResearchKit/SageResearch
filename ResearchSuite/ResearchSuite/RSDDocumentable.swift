//
//  RSDDocumentable.swift
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

public struct RSDDocumentCreator {
    
    let allEnums: [RSDDocumentableEnum.Type] = [
        RSDAnswerResultType.BaseType.self,
        RSDAnswerResultType.SequenceType.self,
        RSDDeviceType.self,
        RSDFormDataType.self,
        RSDFormUIHint.self,
        RSDIdentifier.self,
        RSDStandardPermissionType.self,
        RSDResultType.self,
        RSDStepType.self,
        RSDDateCoderObject.self,
        RSDSurveyRuleOperator.self,
        UITextAutocapitalizationType.self,
        UITextAutocorrectionType.self,
        UITextSpellCheckingType.self,
        UIKeyboardType.self,
        ]
    
    let allOptionSets: [RSDDocumentableOptionSet.Type] = [
        RSDActiveUIStepCommand.self,
        ]
    
    let allStringLiterals: [RSDDocumentableStringLiteral.Type] = [
        RSDImageWrapper.self,
        RSDChoiceObject<String>.self,
        RSDRegExValidatorObject.self,
        ]

    let allCodableObjects: [RSDDocumentableCodableObject.Type] = [
        RSDAnswerResultType.self,
        RSDResourceTransformerObject.self,
        RSDStandardAsyncActionConfiguration.self,
        RSDResultObject.self,
        RSDAnswerResultObject.self,
        RSDFileResultObject.self,
        RSDCollectionResultObject.self,
        RSDTaskResultObject.self,
        RSDColorThemeElementObject.self,
        RSDFetchableImageThemeElementObject.self,
        RSDAnimatedImageThemeElementObject.self,
        RSDViewThemeElementObject.self,
        RSDUIActionObject.self,
        RSDSkipToUIActionObject.self,
        RSDWebViewUIActionObject.self,
        RSDDateRangeObject.self,
        RSDNumberRangeObject.self,
        RSDTextFieldOptionsObject.self,
        ]
    
    let allDecodableObjects: [RSDDocumentableDecodableObject.Type] = [
        RSDChoiceObject<String>.self,
        RSDChoiceObject<Int>.self,
        RSDChoiceObject<Bool>.self,
        RSDChoiceObject<Double>.self,
        RSDComparableSurveyRuleObject<Bool>.self,
        RSDComparableSurveyRuleObject<String>.self,
        RSDComparableSurveyRuleObject<Date>.self,
        RSDComparableSurveyRuleObject<Double>.self,
        RSDComparableSurveyRuleObject<Int>.self,
        RSDUIStepObject.self,
        RSDActiveUIStepObject.self,
        RSDFormUIStepObject.self,
        RSDSectionStepObject.self,
        RSDTransformerStepObject.self,
        RSDInputFieldObject.self,
        RSDChoiceInputFieldObject.self,
        RSDSchemaInfoObject.self,
        RSDConditionalStepNavigatorObject.self,
        RSDTaskGroupObject.self,
        RSDTaskInfoStepObject.self,
        RSDTaskObject.self,
        ]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Decodable` objects used by this framework.
protocol RSDDocumentable {
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` enum objects used by this framework.
protocol RSDDocumentableEnum : RSDDocumentable, Codable {
    
    /// Not all of the enums have a `rawValue` of a `String` but they should all be codable using a string value.
    var stringValue: String { get }

    /// All the coding keys supported by this framework for defining this enum using a JSON dictionary.
    static func allCodingKeys() -> [String]
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
    
    /// Method called during testing to validate that all the coding keys are included.
    static func validateAllKeysIncluded() -> Bool
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
