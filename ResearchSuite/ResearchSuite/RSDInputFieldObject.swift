//
//  RSDInputFieldObject.swift
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

/// `RSDInputFieldObject` is a `Decodable` implementation of the `RSDSurveyInputField` protocol. This is implemented as
/// an open class so that the decoding strategy can be used to support subclasses.
///
open class RSDInputFieldObject : RSDSurveyInputField, Codable {
    
    /// A short string that uniquely identifies the input field within the step. The identifier is reproduced in the
    /// results of a step result in the step history of a task result.
    public let identifier: String
    
    /// The data type for this input field. The data type can have an associated ui hint.
    open private(set) var dataType: RSDFormDataType
    
    /// A UI hint for how the study would prefer that the input field is displayed to the user.
    open private(set) var uiHint: RSDFormUIHint?
    
    /// A localized string that displays a short text offering a hint to the user of the data to be entered for
    /// this field. This is only applicable for certain types of UI hints and data types.
    open var prompt: String?
    
    /// A localized string that displays placeholder information for the input field.
    ///
    /// You can display placeholder text in a text field or text area to help users understand how to answer
    /// the item's question.
    open var placeholderText: String?
    
    /// Options for displaying a text field. This is only applicable for certain types of UI hints and data types.
    open var textFieldOptions: RSDTextFieldOptions?
    
    /// A range used by dates and numbers for setting up a picker wheel, slider, or providing text field
    /// input validation. This is only applicable for certain types of UI hints and data types.
    open var range: RSDRange?
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    open var isOptional: Bool = false
    
    /// A list of survey rules associated with this input field.
    open var surveyRules: [RSDSurveyRule]?
    
    /// A formatter that is appropriate to the data type. If `nil`, the format will be determined by the UI.
    /// This is the formatter used to display a previously entered answer to the user or to convert an answer
    /// entered in a text field into the appropriate value type.
    ///
    /// - seealso: `RSDAnswerResultType.BaseType` and `RSDFormStepDataSource`
    open var formatter: Formatter? {
        get {
            return _formatter ?? (self.range as? RSDRangeWithFormatter)?.formatter
        }
        set {
            _formatter = newValue
        }
    }
    private var _formatter: Formatter?
    
    /// Default intializer.
    ///
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the input field within the step.
    ///     - dataType: The data type for this input field.
    ///     - uiHint: A UI hint for how the study would prefer that the input field is displayed to the user.
    ///     - prompt: A localized string that displays a short text offering a hint to the user of the data to be entered for
    ///               this field.
    public init(identifier: String, dataType: RSDFormDataType, uiHint: RSDFormUIHint? = nil, prompt: String? = nil) {
        self.identifier = identifier
        self.dataType = dataType
        self.uiHint = uiHint
        self.prompt = prompt
    }
    
    /// Validate the input field to check for any configuration that should throw an error.
    open func validate() throws {
        // TODO: syoung 10/04/2017 Implement 
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, prompt, placeholderText, dataType, uiHint, isOptional = "optional", textFieldOptions, range, surveyRules
    }
    
    /// Overridable class function for decoding the data type from the decoder. The default implementation will key to
    /// `CodingKeys.dataType`.
    /// - parameter decoder: The decoder used to decode this object.
    /// - returns: The decoded `RSDFormDataType` data type.
    /// - throws: `DecodingError` if the data type field is missing or is not a `String`.
    open class func dataType(from decoder: Decoder) throws -> RSDFormDataType {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        return try container.decode(RSDFormDataType.self, forKey: .dataType)
    }
    
    /// Overridable class function for decoding the uiHint from the decoder. The default implementation will key to
    /// `CodingKeys.uiHint` and will check that the ui hint is valid for the given data type.
    ///
    /// - parameters:
    ///     - decoder: The decoder used to decode this object.
    ///     - dataType: The data type associated with this instance.
    /// - returns: The UI Hint associated with this input field (if any).
    /// - throws: `DecodingError` if the uiHint is not a `String`.
    ///           `RSDValidationError.invalidType` if it is not valid for this data type.
    open class func uiHint(from decoder: Decoder, for dataType: RSDFormDataType) throws -> RSDFormUIHint? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let uiHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .uiHint) else {
            return nil
        }
        guard let standardType = uiHint.standardType else {
            return uiHint
        }
        guard dataType.validStandardUIHints.contains(standardType) else {
            throw RSDValidationError.invalidType("\(uiHint) is not a valid uiHint for \(dataType)")
        }
        return uiHint
    }
    
    /// Overridable class function for decoding the range from the decoder. The default implementation will key to
    /// `CodingKeys.range` and will decode a range object appropriate to the data type.
    ///
    /// | RSDFormDataType.BaseType | Type of range to decode                                    |
    /// |--------------------------|:----------------------------------------------------------:|
    /// | .integer, .decimal       | `RSDNumberRangeObject`                                     |
    /// | .date                    | `RSDDateRangeObject`                                       |
    /// | .year                    | `RSDDateRangeObject` or `RSDNumberRangeObject`             |
    ///
    /// - parameters:
    ///     - decoder: The decoder used to decode this object.
    ///     - dataType: The data type associated with this instance.
    /// - returns: An appropriate instance of `RSDRange` or `nil` if none is present.
    /// - throws: `DecodingError`
    open class func range(from decoder: Decoder, dataType: RSDFormDataType) throws -> RSDRange? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch dataType.baseType {
        case .integer, .decimal:
            return try container.decodeIfPresent(RSDNumberRangeObject.self, forKey: .range)
        case .date:
            return try container.decodeIfPresent(RSDDateRangeObject.self, forKey: .range)
        case .year:
            // For a year data type, we first need to check if there is a min/max range set using the date
            // and if so, return that. The decoder could fail to find any property keys and not fail to
            // decode because everything in the range is optional.
            if let dateRange = try container.decodeIfPresent(RSDDateRangeObject.self, forKey: .range),
                (dateRange.minimumDate != nil || dateRange.maximumDate != nil) {
                return dateRange
            } else {
                return try container.decodeIfPresent(RSDNumberRangeObject.self, forKey: .range)
            }
        default:
            return nil
        }
    }
    
    /// Overridable class function for decoding the `RSDTextFieldOptions` from the decoder. The default implementation
    /// will key to `CodingKeys.textFieldOptions`. If no text field options are defined in the decoder, then for certain
    /// data types, the default keyboard type is instantiated.
    ///
    /// If the data type has a `BaseType` of an `integer`, an instance of `RSDTextFieldOptionsObject` will be created with
    /// a `numberPad` keyboard type.
    ///
    /// If the data type has a `BaseType` of a `decimal`, an instance of `RSDTextFieldOptionsObject` will be created with
    /// a `decimalPad` keyboard type.
    ///
    /// - parameters:
    ///     - decoder: The decoder used to decode this object.
    ///     - dataType: The data type associated with this instance.
    /// - returns: An appropriate instance of `RSDTextFieldOptions` or `nil` if none is present.
    /// - throws: `DecodingError`
    open class func textFieldOptions(from decoder: Decoder, dataType: RSDFormDataType) throws -> RSDTextFieldOptions? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let textFieldOptions = try container.decodeIfPresent(RSDTextFieldOptionsObject.self, forKey: .textFieldOptions) {
            return textFieldOptions
        }
        // If there isn't a text field returned, then set the default for certain types
        switch dataType.baseType {
        case .integer:
            return RSDTextFieldOptionsObject(keyboardType: .numberPad)
        case .decimal:
            return RSDTextFieldOptionsObject(keyboardType: .decimalPad)
        default:
            return nil
        }
    }
    
    /// Overridable class function for decoding a list of survey rules from the decoder for this instance.
    /// The default implementation will check the container for a keyed array using `CodingKeys.surveyRules`
    /// and will instantiate a list of `RSDComparableSurveyRuleObject` instances appropriate to the `BaseType`
    /// of the given data type.
    ///
    /// If there isn't a list keyed to `CodingKeys.surveyRules` then the decoder will be tested to see if it
    /// contains the keys for a `RSDComparableSurveyRuleObject` instance.
    ///
    /// - example:
    ///
    /// The following will decode as a `RSDComparableSurveyRuleObject<String>` because of the "matchingAnswer" key.
    ///
    ///     ````
    ///     {
    ///     "identifier": "foo",
    ///     "prompt": "Text",
    ///     "placeholderText": "enter text",
    ///     "dataType": "singleChoice.string",
    ///     "choices" : ["never", "sometimes", "often", "always"],
    ///     "matchingAnswer": "never"
    ///     }
    ///     ````
    ///
    /// The following will decode as an array of `[RSDComparableSurveyRuleObject<Int>]` because of the "surveyRules" key.
    ///
    ///     ````
    ///        {
    ///            "identifier": "foo",
    ///            "dataType": "integer",
    ///            "uiHint": "slider",
    ///            "range" : { "minimumValue" : -2,
    ///                        "maximumValue" : 3,
    ///                        "stepInterval" : 1,
    ///                        "unit" : "feet" },
    ///            "surveyRules" : [
    ///                            {
    ///                            "skipToIdentifier": "lessThan",
    ///                            "ruleOperator": "lt",
    ///                            "matchingAnswer": 0
    ///                            },
    ///                            {
    ///                            "skipToIdentifier": "greaterThan",
    ///                            "ruleOperator": "gt",
    ///                            "matchingAnswer": 1
    ///                            }
    ///                            ]
    ///        }
    ///     ````
    ///
    /// - parameters:
    ///     - decoder: The decoder used to decode this object.
    ///     - dataType: The data type associated with this instance.
    /// - returns: An array of `RSDComparableSurveyRuleObject` objects or `nil` if none are present.
    /// - throws: `DecodingError`
    open class func surveyRules(from decoder: Decoder, dataType: RSDFormDataType) throws -> [RSDSurveyRule]? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.surveyRules) {
            switch dataType.baseType {
            case .boolean:
                return try container.decode([RSDComparableSurveyRuleObject<Bool>].self, forKey: .surveyRules)
            case .string:
                return try container.decode([RSDComparableSurveyRuleObject<String>].self, forKey: .surveyRules)
            case .date:
                return try container.decode([RSDComparableSurveyRuleObject<Date>].self, forKey: .surveyRules)
            case .decimal:
                return try container.decode([RSDComparableSurveyRuleObject<Double>].self, forKey: .surveyRules)
            case .integer, .year:
                return try container.decode([RSDComparableSurveyRuleObject<Int>].self, forKey: .surveyRules)
            }
        } else {
            let rule: RSDSurveyRule?
            switch dataType.baseType {
            case .boolean:
                rule = try? RSDComparableSurveyRuleObject<Bool>(from: decoder)
            case .string:
                rule = try? RSDComparableSurveyRuleObject<String>(from: decoder)
            case .date:
                rule = try? RSDComparableSurveyRuleObject<Date>(from: decoder)
            case .decimal:
                rule = try? RSDComparableSurveyRuleObject<Double>(from: decoder)
            case .integer, .year:
                rule = try? RSDComparableSurveyRuleObject<Int>(from: decoder)
            }
            if rule != nil {
                return [rule!]
            }
        }
        
        return nil
    }
    
    /// Initialize from a `Decoder`. This decoding method will decode all the properties for this
    /// input field.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        
        let dataType = try type(of: self).dataType(from: decoder)
        let uiHint = try type(of: self).uiHint(from: decoder, for: dataType)
        let range = try type(of: self).range(from: decoder, dataType: dataType)
        let textFieldOptions = try type(of: self).textFieldOptions(from: decoder, dataType: dataType)
        let surveyRules = try type(of: self).surveyRules(from: decoder, dataType: dataType)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataType = dataType
        self.uiHint = uiHint
        self.range = range
        self.textFieldOptions = textFieldOptions
        self.surveyRules = surveyRules
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
        self.placeholderText = try container.decodeIfPresent(String.self, forKey: .placeholderText)
        self.isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? false
    }
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.dataType, forKey: .dataType)
        try container.encodeIfPresent(prompt, forKey: .prompt)
        try container.encodeIfPresent(placeholderText, forKey: .placeholderText)
        try container.encodeIfPresent(uiHint, forKey: .uiHint)
        if let obj = self.range {
            let nestedEncoder = container.superEncoder(forKey: .range)
            guard let encodable = obj as? Encodable else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedEncoder.codingPath, debugDescription: "The range does not conform to the Encodable protocol"))
            }
            try encodable.encode(to: nestedEncoder)
        }
        if let obj = self.textFieldOptions {
            let nestedEncoder = container.superEncoder(forKey: .textFieldOptions)
            guard let encodable = obj as? Encodable else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedEncoder.codingPath, debugDescription: "The textFieldOptions does not conform to the Encodable protocol"))
            }
            try encodable.encode(to: nestedEncoder)
        }
        try container.encode(isOptional, forKey: .isOptional)
        if let obj = self.surveyRules {
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .surveyRules)
            guard let encodables = obj as? [Encodable] else {
                throw EncodingError.invalidValue(obj, EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "The surveyRules do not conform to the Encodable protocol"))
            }
            
            for encodable in encodables {
                let nestedEncoder = nestedContainer.superEncoder()
                try encodable.encode(to: nestedEncoder)
            }
        }
    }
}
