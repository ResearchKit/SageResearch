//
//  RSDInputFieldObject.swift
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

/// `RSDInputFieldObject` is a `Decodable` implementation of the `RSDSurveyInputField` protocol. This is implemented as
/// an open class so that the decoding strategy can be used to support subclasses.
///
open class RSDInputFieldObject : RSDSurveyInputField, RSDMutableInputField, RSDCopyInputField, Codable {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier
        case inputPrompt = "prompt"
        case inputPromptDetail = "promptDetail"
        case placeholder
        case dataType = "type"
        case inputUIHint = "uiHint"
        case isOptional = "optional"
        case textFieldOptions
        case range
        case surveyRules
    }

    /// A short string that uniquely identifies the input field within the step. The identifier is reproduced in the
    /// results of a step result in the step history of a task result.
    public let identifier: String
    
    /// The data type for this input field. The data type can have an associated ui hint.
    open private(set) var dataType: RSDFormDataType
    
    /// A UI hint for how the study would prefer that the input field is displayed to the user.
    open private(set) var inputUIHint: RSDFormUIHint?
    
    /// A localized string that displays a short text offering a hint to the user of the data to be entered for
    /// this field. This is only applicable for certain types of UI hints and data types.
    open var inputPrompt: String?
    
    /// Additional detail about this input field.
    open var inputPromptDetail: String?
    
    /// A localized string that displays placeholder information for the input field.
    ///
    /// You can display placeholder text in a text field or text area to help users understand how to answer
    /// the item's question.
    open var placeholder: String?
    
    /// Options for displaying a text field. This is only applicable for certain types of UI hints and data types.
    open var textFieldOptions: RSDTextFieldOptions?
    
    /// A range used by dates and numbers for setting up a picker wheel, slider, or providing text field
    /// input validation. This is only applicable for certain types of UI hints and data types.
    open var range: RSDRange?
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    open var isOptional: Bool = true
    
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
    
    /// Default for the picker source is to optionally cast self.
    open var pickerSource: RSDPickerDataSource? {
        return self as? RSDPickerDataSource
    }
    
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
        self.inputUIHint = uiHint
        self.inputPrompt = prompt
    }
    
    public required init(identifier: String, dataType: RSDFormDataType) {
        self.identifier = identifier
        self.dataType = dataType
    }
    
    public func copy(with identifier: String) -> Self {
        let copy = type(of: self).init(identifier: identifier, dataType: dataType)
        copyInto(copy as RSDInputFieldObject)
        return copy
    }
    
    /// Swift subclass override for copying properties from the instantiated class of the `copy(with:)`
    /// method. Swift does not nicely handle casting from `Self` to a class instance for non-final classes.
    /// This is a work-around.
    open func copyInto(_ copy: RSDInputFieldObject) {
        copy.inputUIHint = self.inputUIHint
        copy.inputPrompt = self.inputPrompt
        copy.inputPromptDetail = self.inputPromptDetail
        copy.placeholder = self.placeholder
        copy.textFieldOptions = self.textFieldOptions
        copy.range = self.range
        copy.isOptional = self.isOptional
        copy.surveyRules = self.surveyRules
        copy._formatter = self._formatter
    }
    
    /// Validate the input field to check for any configuration that should throw an error.
    open func validate() throws {
    }
    
    /// Class function for decoding the data type from the decoder. The default implementation will key to
    /// `CodingKeys.dataType`.
    ///
    /// - parameter decoder: The decoder used to decode this object.
    /// - returns: The decoded `RSDFormDataType` data type.
    /// - throws: `DecodingError` if the data type field is missing or is not a `String`.
    public final class func dataType(from decoder: Decoder) throws -> RSDFormDataType {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        return try container.decode(RSDFormDataType.self, forKey: .dataType)
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
    
    /// Initialize from a `Decoder`. This decoding method will decode all the properties for this
    /// input field.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        
        let dataType = try type(of: self).dataType(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let factory = decoder.factory
        
        // Look to the form step for an identifier.
        if !container.contains(.identifier),
            let identifier = decoder.codingInfo?.userInfo[.stepIdentifier] as? String {
            self.identifier = identifier
        }
        else {
            self.identifier = try container.decode(String.self, forKey: .identifier)
        }
        
        // Decode the survey rules from the factory.
        if container.contains(.surveyRules) {
            let nestedContainer = try container.nestedUnkeyedContainer(forKey: .surveyRules)
            self.surveyRules = try factory.decodeSurveyRules(from: nestedContainer, for: dataType)
        }
        else {
             self.surveyRules = nil
        }
        
        // Decode the range from the factory.
        if container.contains(.range) {
            let nestedDecoder = try container.superDecoder(forKey: .range)
            self.range = try factory.decodeRange(from: nestedDecoder, for: dataType)
        }
        else {
            self.range = nil
        }
        
        self.dataType = dataType
        self.inputUIHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .inputUIHint)
        self.textFieldOptions = try type(of: self).textFieldOptions(from: decoder, dataType: dataType)
        self.inputPrompt = try container.decodeIfPresent(String.self, forKey: .inputPrompt)
        self.inputPromptDetail = try container.decodeIfPresent(String.self, forKey: .inputPromptDetail)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? false
    }
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.dataType, forKey: .dataType)
        try container.encodeIfPresent(inputPrompt, forKey: .inputPrompt)
        try container.encodeIfPresent(inputPromptDetail, forKey: .inputPromptDetail)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(inputUIHint, forKey: .inputUIHint)
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
    
    
    // Overrides must be defined in the base implementation
    
    class func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    class func examples() -> [[String : RSDJSONValue]] {
        
        let baseTypes = RSDFormDataType.BaseType.allCases
        let examples = baseTypes.compactMap { (baseType) -> [String : RSDJSONValue]? in
            switch baseType {
            case .boolean:
                return [ "identifier" : "booleanExample",
                         "prompt" : "This is a boolean input field",
                         "type" : "boolean",
                         "uiHint" : "toggle",
                         "optional" : true]
            
            case .date:
                return [ "identifier" : "dateExample",
                         "prompt" : "This is a date input field",
                         "type" : "date",
                         "uiHint" : "picker",
                         "placeholder" : "enter a date",
                         "range" : [ "minimumDate" : "2017-02-20",
                                     "maximumDate" : "2017-03-20",
                                     "codingFormat" : "yyyy-MM-dd"]]
            case .decimal:
                return [ "identifier" : "decimalExample",
                         "prompt" : "This is a decimal input field",
                         "type" : "decimal",
                         "uiHint" : "slider",
                         "placeholder" : "select a numer",
                         "range" : [ "minimumValue" : -2.5,
                                     "maximumValue" : 3,
                                     "stepInterval" : 0.1,
                                     "unit" : "feet",
                                     "formatter" : ["maximumDigits" : 3]],
                         "surveyRules" : [["skipToIdentifier": "lessThan",
                                           "ruleOperator": "lt",
                                           "matchingAnswer": 0],
                                          ["skipToIdentifier": "greaterThan",
                                           "ruleOperator": "gt",
                                           "matchingAnswer": 0]]]
            case .integer:
                return [ "identifier" : "integerExample",
                         "prompt" : "This is a integer input field",
                         "type" : "integer",
                         "uiHint" : "popover",
                         "placeholder" : "select a numer",
                         "range" : [ "minimumValue" : -10,
                                     "maximumValue" : 10,
                                     "stepInterval" : 2],
                         "matchingAnswer" : 0]
                
            case .fraction:
                return [ "identifier" : "fractionExample",
                         "prompt" : "This is a fraction input field",
                         "type" : "fraction",
                         "uiHint" : "textfield",
                         "placeholderText" : "select a numer",
                         "range" : [ "minimumValue" : -1.0,
                                     "maximumValue" : 1.0,
                                     "stepInterval" : 0.25],
                         "matchingAnswer" : 0]
                
            case .duration:
                return [ "identifier" : "timeIntervalExample",
                         "prompt" : "This is a time interval input field",
                         "type" : "duration",
                         "uiHint" : "picker",
                         "placeholderText" : "select a time interval",
                         "range" : [ "minimumValue" : 0,
                                     "maximumValue" : 26,
                                     "unit" : "minute"]]
                
            case .year:
                return [ "identifier" : "yearExample",
                         "prompt" : "This is a year input field",
                         "type" : "year",
                         "uiHint" : "textfield",
                         "placeholder" : "birth year",
                         "range" : [ "allowFuture" : false]]
            
            case .string:
                return [ "identifier" : "stringExample",
                         "prompt" : "This is a string input field",
                         "type" : "string",
                         "placeholder" : "enter some text",
                         "textFieldOptions" : [ "keyboardType" : "asciiCapable"]]
                
            case .codable:
                return nil
            }
        }

        return examples
    }
}

extension RSDInputFieldObject : RSDDocumentableDecodableObject {
}
