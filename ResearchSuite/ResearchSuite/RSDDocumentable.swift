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
        ]
    
    let allOptionSets: [RSDDocumentableOptionSet.Type] = [
        RSDActiveUIStepCommand.self,
        ]
    
    let allStringLiterals: [RSDDocumentableStringLiteral.Type] = [
        RSDImageWrapper.self,
        RSDChoiceObject<String>.self,
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
        ]
    
    let allDecodableObjects: [RSDDocumentableDecodableObject.Type] = [
        RSDChoiceObject<String>.self,
        RSDChoiceObject<Int>.self,
        RSDChoiceObject<Bool>.self,
        RSDChoiceObject<Double>.self,
        ]
}

protocol RSDDocumentable {
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` enum objects used by this framework.
protocol RSDDocumentableEnum : RSDDocumentable, Codable {

    /// All the coding keys supported by this framework for defining this enum using a JSON dictionary.
    static func allCodingKeys() -> Set<String>
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` option set objects that are decoded from a list of strings.
/// - seealso: `RSDStringLiteralOptionSet`
protocol RSDDocumentableOptionSet : RSDDocumentable, Codable {
    
    /// All the coding keys supported by this framework for defining this option set using a JSON dictionary.
    static func allCodingKeys() -> Set<String>
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects that are encoded and decoded using any string.
/// - seealso: `ExpressibleByStringLiteral`
protocol RSDDocumentableStringLiteral : RSDDocumentable, Codable {
    
    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [String]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects and for use in documenting them.
protocol RSDDocumentableCodableObject : RSDDocumentable, Codable {
    
    /// An mapping of all the `Decodable` properties to their CodingKey along with a description for
    /// the property.
    static func codingMap() -> Array<(CodingKey, Any.Type, String)>
    
    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [Encodable]
}

/// This is an internal protocol (accessible by test but not externally) that can be used to set up
/// testing of `Codable` objects and for use in documenting them.
protocol RSDDocumentableDecodableObject : RSDDocumentable, Decodable {
    
    /// An mapping of all the `Decodable` properties to their CodingKey along with a description for
    /// the property.
    static func codingMap() -> Array<(CodingKey, Any.Type, String)>
    
    /// An array of encodable objects to use as the set of examples for decoding this object.
    static func examples() -> [[String : RSDJSONValue]]
}
