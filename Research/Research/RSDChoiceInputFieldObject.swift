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

/// `RSDChoiceInputFieldObject` is a concrete implementation of `RSDChoiceInputField` that subclasses `RSDInputFieldObject`
/// to include a list of choices for a multiple choice or single choice input field.
open class RSDChoiceInputFieldObject : RSDInputFieldObject, RSDChoiceOptions {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case choices, defaultAnswer
    }
    
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
            super.isOptional = isOptional
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
        self.defaultAnswer = nil
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
    
    /// Initialize from a `Decoder`. This method uses the `RSDFormDataType.BaseType` associated with this input field to
    /// decode a list of `RSDChoiceObject` objects with the appropriate `Value` type.
    ///
    /// - example:
    ///
    ///     ```
    ///        // A JSON example where this is for a single choice input field that is a `decimal` base type
    ///        // with a survey rule where the task should exit if the matching answer is `0`. This will
    ///        // decode the choices as an array of `RSDChoiceObject<Double>` objects.
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
    ///                                "isExclusive" : true }],
    ///                "matchingAnswer": 0
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
    ///                                "isExclusive" : true }],
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
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
            defaultAnswer = try container.decodeIfPresent(Bool.self, forKey: .defaultAnswer)
        case .integer, .year:
            choices = try container.decode([RSDChoiceObject<Int>].self, forKey: .choices)
            defaultAnswer = try container.decodeIfPresent(Int.self, forKey: .defaultAnswer)
        case .decimal, .duration:
            choices = try container.decode([RSDChoiceObject<Double>].self, forKey: .choices)
            defaultAnswer = try container.decodeIfPresent(Double.self, forKey: .defaultAnswer)
        case .fraction:
            choices = try container.decode([RSDChoiceObject<RSDFraction>].self, forKey: .choices)
            defaultAnswer = try container.decodeIfPresent(RSDFraction.self, forKey: .defaultAnswer)
        case .date:
            choices = try container.decode([RSDChoiceObject<Date>].self, forKey: .choices)
            defaultAnswer = try container.decodeIfPresent(Date.self, forKey: .defaultAnswer)
        case .string:
            choices = try container.decode([RSDChoiceObject<String>].self, forKey: .choices)
            defaultAnswer = try container.decodeIfPresent(String.self, forKey: .defaultAnswer)
        case .codable:
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "`.codable` data type is not supported by this object.")
            throw DecodingError.typeMismatch(Codable.self, context)
        }
        self.choices = choices
        
        // call super
        try super.init(from: decoder)
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    override open func encode(to encoder: Encoder) throws {
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
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
                "identifier": "foo",
                "prompt": "Choose a number",
                "type": "singleChoice.decimal",
                "uiHint": "picker",
                "defaultAnswer": 1.2,
                "choices" : [[  "value" : 0,
                                "text" : "0"],
                             [  "value" : 1.2,
                                "text" : "1.2"],
                             [  "value" : 3.1425,
                                "text" : "pi",
                                "detail" : "Is the magic number" ],
                             [  "text" : "None of the above",
                                "isExclusive" : true ]],
                "matchingAnswer": 0
            ]
        
        let jsonB: [String : RSDJSONValue] = [
              "identifier": "step3",
              "prompt": "Step 3",
              "type": "multipleChoice",
              "defaultAnswer": "alpha",
              "choices" : ["alpha", "beta", "charlie", "delta"]
              ]
        
        let jsonC: [String : RSDJSONValue] = [
            "identifier": "happiness",
            "prompt": "How happy are you?",
            "type": "singleChoice.integer",
            "defaultAnswer": 1,
            "choices": [[
                        "text": "delighted",
                        "detail": "Nothing could be better!",
                        "value": 1,
                        "icon": "moodScale1"
                        ],
                        [
                        "text": "good",
                        "detail": "Life is good.",
                        "value": 2,
                        "icon": "moodScale2"
                        ],
                        [
                        "text": "so-so",
                        "detail": "Things are okay, I guess.",
                        "value": 3,
                        "icon": "moodScale3"
                        ],
                        [
                        "text": "sad",
                        "detail": "I'm feeling a bit down.",
                        "value": 4,
                        "icon": "moodScale4"
                        ],
                        [
                        "text": "miserable",
                        "detail": "I cry into my pillow every night.",
                        "value": 5,
                        "icon": "moodScale5"
                        ]]
            ]
        
        let jsonD: [String : RSDJSONValue] = [
                "identifier": "heightLimit",
                "prompt": "Are you tall?",
                "type": "singleChoice.boolean",
                "defaultAnswer": true,
                "choices" : [[  "value" : true,
                                "text" : "Yes"],
                             [  "value" : false,
                                "text" : "No"],
                             [  "text" : "I don't know",
                                "isExclusive" : true ]],
            ]
        
        let jsonE: [String : RSDJSONValue] = [
            "identifier": "happiness",
            "prompt": "How happy are you?",
            "type": "singleChoice.fraction",
            "defaultAnswer": "3/5",
            "choices": [[
                            "text": "delighted",
                            "detail": "Nothing could be better!",
                            "value": "1/5",
                            "icon": "moodScale1"
                        ],
                        [
                            "text": "good",
                            "detail": "Life is good.",
                            "value": "2/5",
                            "icon": "moodScale2"
                        ],
                        [
                            "text": "so-so",
                            "detail": "Things are okay, I guess.",
                            "value": "3/5",
                            "icon": "moodScale3"
                        ],
                        [
                            "text": "sad",
                            "detail": "I'm feeling a bit down.",
                            "value": "4/5",
                            "icon": "moodScale4"
                        ],
                        [
                            "text": "miserable",
                            "detail": "I cry into my pillow every night.",
                            "value": "5/5",
                            "icon": "moodScale5"
                        ]
            ]
        ]
        
        return [jsonA, jsonB, jsonC, jsonD, jsonE]
    }
}
