//
//  RSDChoiceInputFieldObject.swift
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
import JsonModel
import Formatters

/// `RSDChoiceInputFieldObject` is a concrete implementation of `RSDChoiceInputField` that subclasses
/// `RSDInputFieldObject` to include a list of choices for a multiple choice or single choice input field. It
/// is intended to be instantiated with a list of choices but can be subclassed to decode the choices using
/// a custom decoder.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
open class RSDChoiceInputFieldObject : RSDInputFieldObject, RSDChoiceOptionsWithDefault {
    
    /// A list of choices for the input field.
    public private(set) var choices : [RSDChoice]
    
    /// The default answer associated with this option set.
    open private(set) var defaultAnswer: Any?
    
    /// Override `isOptional` to allow for "nil" behavior if there is only one choice. Otherwise, there isn't
    /// really a way for the user to **not** select that choice.
    override open var isOptional: Bool {
        get {
            return super.isOptional || self.choices.count <= 1
        }
        set {
            super.isOptional = newValue
        }
    }
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the form item within the step.
    ///     - choices: A list of choices for the input field.
    ///     - dataType: The data type for this input field. The data type can have an associated ui hint.
    ///     - uiHint: A UI hint for how the study would prefer that the input field is displayed to the user.
    ///     - prompt: A localized string that displays a short text offering a hint to the user of the data to be entered for
    ///               this field.
    public init(identifier: String, choices: [RSDChoice], dataType: RSDFormDataType, uiHint: RSDFormUIHint? = nil, prompt: String? = nil, defaultAnswer: Any? = nil) {
        self.choices = choices
        self.defaultAnswer = defaultAnswer
        super.init(identifier: identifier, dataType: dataType, uiHint: uiHint, prompt: prompt)
    }
    
    /// This is a required initializer for copying, but the choices will be an empty array.
    public required init(identifier: String, dataType: RSDFormDataType) {
        self.choices = []
        super.init(identifier: identifier, dataType: dataType)
    }
    
    override open func copyInto(_ copy: RSDInputFieldObject) {
        guard let subclassCopy = copy as? RSDChoiceInputFieldObject else {
            assertionFailure("Failed to cast the class to the subclass.")
            return
        }
        subclassCopy.choices = self.choices
        subclassCopy.defaultAnswer = self.defaultAnswer
    }
    
    /// Support for non-typed decoding of a choice list.
    open class func decodeChoices(from decoder: Decoder) throws -> [RSDChoice] {
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Base implementation does not support decoding the choices.")
        throw DecodingError.typeMismatch([RSDChoice].self, context)
    }
    
    /// Decoding is not supported without overriding `decodeChoices()`.
    public required init(from decoder: Decoder) throws {
        self.choices = try type(of: self).decodeChoices(from: decoder)
        try super.init(from: decoder)
    }
    
    /// Encoding is not supported.
    override open func encode(to encoder: Encoder) throws {
        let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Encoding not supported for this subclass.")
        throw EncodingError.invalidValue(self, context)
    }
}

/// `RSDCodableChoiceInputFieldObject` is a concrete implementation of `RSDChoiceInputField` that subclasses
/// `RSDInputFieldObject` to include a list of choices for a multiple choice or single choice input field.
/// It is designed to be used by `RSDFactory` or a subclass to encode and decode the choices as a typed array
/// of `RSDChoiceObject` objects.
@available(*, deprecated, message: "Use `Question` instead. This protocol is not supported by Kotlin.")
public final class RSDCodableChoiceInputFieldObject<T : Codable> : RSDInputFieldObject, RSDChoiceOptions {
    public typealias Value = T
    
    override public func convertToQuestionOrInputItem(nextStepIdentifier: String?) throws -> (ChoiceQuestionStepObject?, InputItemBuilder?) {
        guard case .collection(let collectionType, _) = self.dataType,
            ((collectionType == .singleChoice) || (collectionType == .multipleChoice))
            else {
                throw RSDValidationError.undefinedClassType("Not implemented for \(self.dataType)")
        }
        
        let choices: [JsonChoiceObject] = self.choices.map { choice in
            let jsonValue: JsonElement? = (choice.answerValue as? JsonValue).map { JsonElement($0) }
            return JsonChoiceObject(matchingValue: jsonValue,
                             text: choice.text,
                             detail: choice.detail,
                             isExclusive: choice.isExclusive ? true : nil,
                             icon: choice.imageData as? RSDResourceImageDataObject)
        }
        
        if self.inputUIHint == .picker {
            let inputItem = ChoicePickerInputItemObject(jsonChoices: choices, resultIdentifier: identifier)
            self.copyInto(inputItem)
            return (nil, inputItem)
        }
        else if choices.count == 1, let choice = choices.first,
            let match = choice.matchingValue, match == .boolean(true),
            let text = choice.text {
            let inputItem = CheckboxInputItemObject(fieldLabel: text,
                                                    resultIdentifier: self.identifier,
                                                    detail: choice.detail)
            return (nil, inputItem)
        }
        else {
            let question = ChoiceQuestionStepObject(identifier: identifier,
                                                    choices: choices,
                                                    isSingleAnswer: (collectionType == .singleChoice),
                                                    inputUIHint: self.inputUIHint ?? .list,
                                                    nextStepIdentifier: nextStepIdentifier)
            if question.isOptional != self.isOptional {
                question.isOptional = self.isOptional
            }
            return (question, nil)
        }
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case choices, defaultAnswer
    }
    
    /// A list of choices for the input field.
    public private(set) var choices : [RSDChoice]
    
    /// The default answer associated with this option set.
    public private(set) var defaultAnswer: Any?
    
    /// Override `isOptional` to allow for "nil" behavior if there is only one choice. Otherwise, there isn't
    /// really a way for the user to **not** select that choice.
    override public var isOptional: Bool {
        get {
            return super.isOptional || self.choices.count <= 1
        }
        set {
            super.isOptional = newValue
        }
    }
    
    /// This is a required initializer for copying, but the choices will be an empty array.
    public required init(identifier: String, dataType: RSDFormDataType) {
        self.choices = []
        super.init(identifier: identifier, dataType: dataType)
    }
    
    override public func copyInto(_ copy: RSDInputFieldObject) {
        guard let subclassCopy = copy as? RSDCodableChoiceInputFieldObject else {
            assertionFailure("Failed to cast the class to the subclass.")
            return
        }
        subclassCopy.choices = self.choices
        subclassCopy.defaultAnswer = self.defaultAnswer
    }
    
    /// Initialize from a `Decoder`. This method uses the `RSDFormDataType.BaseType` associated with this input field to
    /// decode a list of `RSDChoiceObject` objects with the appropriate `Value` type.
    ///
    /// - example:
    ///
    ///     ```
    ///        // A JSON example where this is for a single choice input field that is a `decimal` base type.
    ///        // This will decode the choices as an array of `RSDChoiceObject<Double>` objects.
    ///        let json = """
    ///            {
    ///                "identifier": "foo",
    ///                "prompt": "Choose a number",
    ///                "type": "singleChoice.decimal",
    ///                "uiHint": "picker",
    ///                "choices" : [{  "value" : 0,
    ///                                "text" : "0"},
    ///                             {  "value" : 1.2,
    ///                                "text" : "1.2"},
    ///                             {  "value" : 3.1425,
    ///                                "text" : "pi",
    ///                                "detail" : "Is the magic number" },
    ///                             {  "text" : "None of the above",
    ///                                "exclusive" : true }],
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///        // A multiple choice question where the choices are coded as a list of text strings. This will
    ///        // decode the choices as an array of `RSDChoiceObject<String>` objects where `value == text`.
    ///        let json = """
    ///              {
    ///              "identifier": "step3",
    ///              "title": "Step 3",
    ///              "type": "multipleChoice",
    ///              "choices" : ["alpha", "beta", "charlie", "delta"]
    ///              }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///        // A single choice question where each choice has an icon image representing the choice. This will
    ///        // decode the choices as an array of `RSDChoiceObject<Int>` objects.
    ///        let json = """
    ///            {
    ///            "identifier": "happiness",
    ///            "title": "How happy are you?",
    ///            "type": "singleChoice.integer",
    ///            "defaultAnswer": 3,
    ///            "choices": [{
    ///                        "text": "delighted",
    ///                        "detail": "Nothing could be better!",
    ///                        "value": 1,
    ///                        "icon": "moodScale1"
    ///                        },
    ///                        {
    ///                        "text": "good",
    ///                        "detail": "Life is good.",
    ///                        "value": 2,
    ///                        "icon": "moodScale2"
    ///                        },
    ///                        {
    ///                        "text": "so-so",
    ///                        "detail": "Things are okay, I guess.",
    ///                        "value": 3,
    ///                        "icon": "moodScale3"
    ///                        },
    ///                        {
    ///                        "text": "sad",
    ///                        "detail": "I'm feeling a bit down.",
    ///                        "value": 4,
    ///                        "icon": "moodScale4"
    ///                        },
    ///                        {
    ///                        "text": "miserable",
    ///                        "detail": "I cry into my pillow every night.",
    ///                        "value": 5,
    ///                        "icon": "moodScale5"
    ///                        }]
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///        // A JSON example where this is for a single choice input field that is a `bool` base type. This will
    ///        // decode the choices as an array of `RSDChoiceObject<Bool>` objects.
    ///        let json = """
    ///            {
    ///                "identifier": "heightLimit",
    ///                "prompt": "Are you tall?",
    ///                "type": "singleChoice.boolean",
    ///                "choices" : [{  "value" : true,
    ///                                "text" : "Yes"},
    ///                             {  "value" : false,
    ///                                "text" : "No"},
    ///                             {  "text" : "I don't know",
    ///                                "exclusive" : true }],
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError` if there is a decoding error.
    public required init(from decoder: Decoder) throws {
        
        // Get the base data type
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.choices = try container.decode([RSDChoiceObject<Value>].self, forKey: .choices)
        self.defaultAnswer = try container.decodeIfPresent(Value.self, forKey: .defaultAnswer)
        
        // call super
        try super.init(from: decoder)
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)

        var nestedContainer = container.nestedUnkeyedContainer(forKey: .choices)
        for choice in choices {
            guard let encodable = choice as? Encodable else {
                throw EncodingError.invalidValue(choice, EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "The choice does not conform to the Encodable protocol"))
            }
            let nestedEncoder = nestedContainer.superEncoder()
            try encodable.encode(to: nestedEncoder)
        }
        if let obj = self.defaultAnswer as? Bool {
            try container.encode(obj, forKey: .defaultAnswer)
        } else if let obj = self.defaultAnswer as? Int {
            try container.encode(obj, forKey: .defaultAnswer)
        } else if let obj = self.defaultAnswer as? Double {
            try container.encode(obj, forKey: .defaultAnswer)
        } else if let obj = self.defaultAnswer as? Date {
            try container.encode(obj, forKey: .defaultAnswer)
        } else if let obj = self.defaultAnswer as? String {
            try container.encode(obj, forKey: .defaultAnswer)
        } else if let obj = self.defaultAnswer as? RSDFraction {
            try container.encode(obj, forKey: .defaultAnswer)
        } 
    }
}
