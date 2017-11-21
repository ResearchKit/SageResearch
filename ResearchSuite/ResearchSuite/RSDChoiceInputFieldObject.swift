//
//  RSDChoiceInputFieldObject.swift
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

/// `RSDChoiceInputFieldObject` is a concrete implementation of `RSDChoiceInputField` that subclasses `RSDInputFieldObject`
/// to include a list of choices for a multiple choice or single choice input field.
open class RSDChoiceInputFieldObject : RSDInputFieldObject, RSDChoiceInputField {
    
    /// A list of choices for the input field.
    public let choices : [RSDChoice]
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the form item within the step.
    ///     - choices: A list of choices for the input field.
    ///     - dataType: The data type for this input field. The data type can have an associated ui hint.
    ///     - uiHint: A UI hint for how the study would prefer that the input field is displayed to the user.
    ///     - prompt: A localized string that displays a short text offering a hint to the user of the data to be entered for
    ///               this field.
    public init(identifier: String, choices: [RSDChoice], dataType: RSDFormDataType, uiHint: RSDFormUIHint? = nil, prompt: String?) {
        self.choices = choices
        super.init(identifier: identifier, dataType: dataType, uiHint: uiHint, prompt: prompt)
    }
    
    private enum CodingKeys : String, CodingKey {
        case choices
    }
    
    /// Initialize from a `Decoder`. This method uses the `RSDFormDataType.BaseType` associated with this input field to
    /// decode a list of `RSDChoiceObject` objects with the appropriate `Value` type.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError` if there is a decoding error.
    public required init(from decoder: Decoder) throws {
        
        // Get the base data type
        let dataType = try type(of: self).dataType(from: decoder)
        
        // decode the choices
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let choices: [RSDChoice]
        switch dataType.baseType {
        case .boolean:
            choices = try container.decode([RSDChoiceObject<Bool>].self, forKey: .choices)
            
        case .integer:
            choices = try container.decode([RSDChoiceObject<Int>].self, forKey: .choices)
            
        case .decimal:
            choices = try container.decode([RSDChoiceObject<Double>].self, forKey: .choices)
            
        default:
            choices = try container.decode([RSDChoiceObject<String>].self, forKey: .choices)
        }
        self.choices = choices
        
        // call super
        try super.init(from: decoder)
    }
    
// TODO: syoung 11/14/2017 Implement Encodable protocol for the survey rules if there is a need to make this encodable.
//    override open func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        var nestedContainer = container.nestedUnkeyedContainer(forKey: .choices)
//        for choice in choices {
//            guard let encodable = choice as? Encodable else {
//                throw EncodingError.invalidValue(choice, EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "The choice does not conform to the Encodable protocol"))
//            }
//            let nestedEncoder = nestedContainer.superEncoder()
//            try encodable.encode(to: nestedEncoder)
//        }
//    }
}
