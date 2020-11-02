//
//  InputItemObjects.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

public final class InputItemSerializer : AbstractPolymorphicSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        An `InputItem` describes a "part" of a question representing a single answer.
        
        For example, if a question is "what is your name" then the input items may include
        "given name" and "family name" where separate text fields are used to allow the participant
        to enter their first and last name, and the question may also include a list of titles from
        which to choose.
        
        In another example, the input item could be a single cell in a list that shows the possible
        choices for a question. In essence, this is akin to a single cell in a table view though
        the actual implementation may differ.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        let examples: [SerializableInputItemBuilder] = [
            
            DoubleTextInputItemObject(),
            IntegerTextInputItemObject(),
            StringTextInputItemObject(),
            YearTextInputItemObject(),
            
            DateTimeInputItemObject(),
            DateInputItemObject(),
            TimeInputItemObject(),
            
            StringChoicePickerInputItemObject(choices: []),
            ChoicePickerInputItemObject(jsonChoices: []),

            CheckboxInputItemObject(fieldLabel: "Checkbox A"),
            
            HeightInputItemBuilderObject(),
            WeightInputItemBuilderObject(),
        ]
        self.examples = examples
    }
    
    public private(set) var examples: [InputItemBuilder]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(InputItemType.documentableType()))
    }
    
    public func add(_ example: SerializableInputItemBuilder) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

public protocol SerializableInputItemBuilder : InputItemBuilder, PolymorphicRepresentable, Encodable {
    var inputItemType: InputItemType { get }
}

public extension SerializableInputItemBuilder {
    var typeName: String { return inputItemType.rawValue }
}

public struct InputItemType : TypeRepresentable, Codable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(jsonType: JsonType) {
        self.rawValue = jsonType.rawValue
    }
}

extension InputItemType : ExpressibleByStringLiteral, DocumentableStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public static let decimal: InputItemType = "decimal"
    public static let integer: InputItemType = "integer"
    public static let string: InputItemType = "string"
    public static let year: InputItemType = "year"
    
    public static let dateTime: InputItemType = "date-time"
    public static let date: InputItemType = "date"
    public static let time: InputItemType = "time"
    
    public static let stringChoicePicker: InputItemType = "stringChoicePicker"
    public static let choicePicker: InputItemType = "choicePicker"
    public static let checkbox: InputItemType = "checkbox"
    
    public static let height: InputItemType = "height"
    public static let weight: InputItemType = "weight"
    
    static func allStandardTypes() -> [InputItemType] {
        return [
            .checkbox,
            .choicePicker,
            .date,
            .dateTime,
            .decimal,
            .height,
            .integer,
            .string,
            .stringChoicePicker,
            .time,
            .weight,
            .year]
    }
    
    public static func examples() -> [String] {
        allStandardTypes().map { $0.rawValue }
    }
}

open class AbstractInputItemObject {

    private enum CodingKeys : String, CodingKey, CaseIterable {
        case inputItemType = "type"
        case identifier
        case inputUIHint = "uiHint"
        case fieldLabel
        case placeholder
        case isOptional = "optional"
        case isExclusive = "exclusive"
    }
    
    public private(set) var inputItemType: InputItemType
    public private(set) var identifier: String?
    open var fieldLabel: String?
    open var placeholder: String?
    
    open var inputUIHint: RSDFormUIHint {
        get { _inputUIHint ?? defaultUIHint()}
        set { _inputUIHint = newValue }
    }
    private var _inputUIHint: RSDFormUIHint?
    
    public var isOptional: Bool {
        get { _isOptional ?? true }
        set { _isOptional = newValue }
    }
    private var _isOptional: Bool?
    
    public var isExclusive: Bool {
         _isExclusive ?? false
    }
    private var _isExclusive: Bool?
    
    public init(resultIdentifier: String? = nil) {
        self.identifier = resultIdentifier
        self.inputItemType = type(of: self).defaultType()
    }
    
    open class func defaultType() -> InputItemType {
        InputItemType(rawValue: "null")
    }
    
    open func defaultUIHint() -> RSDFormUIHint {
        .textfield
    }

    open func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inputItemType = try container.decode(InputItemType.self, forKey: .inputItemType)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier) ?? self.identifier
        self._isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? self._isOptional
        self._isExclusive = try container.decodeIfPresent(Bool.self, forKey: .isExclusive) ?? self._isExclusive
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? self.placeholder
        self.fieldLabel = try container.decodeIfPresent(String.self, forKey: .fieldLabel) ?? self.fieldLabel
        self._inputUIHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .inputUIHint) ?? self._inputUIHint
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inputItemType, forKey: .inputItemType)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(_inputUIHint, forKey: .inputUIHint)
        try container.encodeIfPresent(fieldLabel, forKey: .fieldLabel)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(_isOptional, forKey: .isOptional)
        try container.encodeIfPresent(_isExclusive, forKey: .isExclusive)
    }
    
    // DocumentableObject implementation
    
    open class func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    open class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .inputItemType
    }
    
    open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not handled by \(self).")
        }
        switch key {
        case .inputItemType:
            return .init(constValue: defaultType())
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .inputUIHint:
            return .init(propertyType: .reference(RSDFormUIHint.documentableType()))
        case .fieldLabel:
            return .init(propertyType: .primitive(.string))
        case .placeholder:
            return .init(propertyType: .primitive(.string))
        case .isOptional:
            return .init(propertyType: .primitive(.boolean))
        case .isExclusive:
            return .init(propertyType: .primitive(.boolean))
        }
    }
}

// MARK: TextInputItem

public final class DoubleTextInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, DoubleTextInputItem {
    public override class func defaultType() -> InputItemType {
        return .decimal
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions
    }
    
    public var formatOptions: DoubleFormatOptions?
        
    public override init(resultIdentifier: String? = nil) {
        super.init(resultIdentifier: resultIdentifier)
    }
    
    public init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formatOptions = try container.decodeIfPresent(DoubleFormatOptions.self, forKey: .formatOptions) ?? self.formatOptions
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.formatOptions, forKey: .formatOptions)
    }
    
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .formatOptions:
            return .init(propertyType: .reference(DoubleFormatOptions.documentableType()))
        }
    }
}

extension DoubleTextInputItemObject : DocumentableStruct {
    public static func examples() -> [DoubleTextInputItemObject] {
        let exA = DoubleTextInputItemObject()
        let exB = DoubleTextInputItemObject(resultIdentifier: "field1")
        exB.formatOptions = DoubleFormatOptions.examples().first
        exB.fieldLabel = "How much?"
        exB.placeholder = "Enter a value"
        return [exA, exB]
    }
}

public final class IntegerTextInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, IntegerTextInputItem {
    public override class func defaultType() -> InputItemType {
        return .integer
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions, keyboardOptions
    }
    
    public var formatOptions: IntegerFormatOptions?
    
    public var keyboardOptions: KeyboardOptions {
        keyboardOptionsObject ?? KeyboardOptionsObject.integerEntryOptions
    }
    public var keyboardOptionsObject: KeyboardOptionsObject?
        
    public override init(resultIdentifier: String? = nil) {
        super.init(resultIdentifier: resultIdentifier)
    }
    
    public init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formatOptions = try container.decodeIfPresent(IntegerFormatOptions.self, forKey: .formatOptions) ?? self.formatOptions
        self.keyboardOptionsObject = try container.decodeIfPresent(KeyboardOptionsObject.self, forKey: .keyboardOptions) ?? self.keyboardOptionsObject
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.formatOptions, forKey: .formatOptions)
        try container.encodeIfPresent(self.keyboardOptionsObject, forKey: .keyboardOptions)
    }
        
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .formatOptions:
            return .init(propertyType: .reference(IntegerFormatOptions.documentableType()))
        case .keyboardOptions:
            return .init(propertyType: .reference(KeyboardOptionsObject.documentableType()))
        }
    }
}

extension IntegerTextInputItemObject : DocumentableStruct {
    public static func examples() -> [IntegerTextInputItemObject] {
        let exA = IntegerTextInputItemObject()
        let exB = IntegerTextInputItemObject(resultIdentifier: "field1")
        exB.formatOptions = IntegerFormatOptions.examples().first
        exB.fieldLabel = "How much?"
        exB.placeholder = "Enter a value"
        return [exA, exB]
    }
}

public final class YearTextInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, YearTextInputItem {
    public override class func defaultType() -> InputItemType {
        return .year
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions
    }
    
    public var formatOptions: YearFormatOptions?
        
    public override init(resultIdentifier: String? = nil) {
        super.init(resultIdentifier: resultIdentifier)
    }
    
    public init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formatOptions = try container.decodeIfPresent(YearFormatOptions.self, forKey: .formatOptions) ?? self.formatOptions
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.formatOptions, forKey: .formatOptions)
    }
    
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .formatOptions:
            return .init(propertyType: .reference(YearFormatOptions.documentableType()))
        }
    }
}

extension YearTextInputItemObject : DocumentableStruct {
    public static func examples() -> [YearTextInputItemObject] {
        let exA = YearTextInputItemObject()
        let exB = YearTextInputItemObject(resultIdentifier: "field1")
        exB.formatOptions = YearFormatOptions.examples().first
        exB.fieldLabel = "How much?"
        exB.placeholder = "Enter a value"
        return [exA, exB]
    }
}

public final class StringTextInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, KeyboardTextInputItem {
    public override class func defaultType() -> InputItemType {
        return .string
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case keyboardOptions, regExValidator
    }
    
    public var regExValidator: RegExValidator?
    public var keyboardOptionsObject: KeyboardOptionsObject?
    
    public let answerType: AnswerType = AnswerTypeString()
    public var keyboardOptions: KeyboardOptions {
        keyboardOptionsObject ?? KeyboardOptionsObject()
    }
        
    public override init(resultIdentifier: String? = nil) {
        super.init(resultIdentifier: resultIdentifier)
    }
    
    public init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.regExValidator = try container.decodeIfPresent(RegExValidator.self, forKey: .regExValidator) ?? self.regExValidator
        self.keyboardOptionsObject = try container.decodeIfPresent(KeyboardOptionsObject.self, forKey: .keyboardOptions) ?? self.keyboardOptionsObject
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.regExValidator, forKey: .regExValidator)
        try container.encodeIfPresent(self.keyboardOptionsObject, forKey: .keyboardOptions)
    }

    public func buildTextValidator() -> TextInputValidator {
        regExValidator ?? PassThruValidator()
    }
    
    public func buildPickerSource() -> RSDPickerDataSource? { nil }
        
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .keyboardOptions:
            return .init(propertyType: .reference(KeyboardOptionsObject.documentableType()))
        case .regExValidator:
            return .init(propertyType: .reference(RegExValidator.documentableType()))
        }
    }
}

extension StringTextInputItemObject : DocumentableStruct {
    public static func examples() -> [StringTextInputItemObject] {
        let exA = StringTextInputItemObject()
        let exB = StringTextInputItemObject(resultIdentifier: "field1")
        exB.keyboardOptionsObject = KeyboardOptionsObject.examples().first
        exB.regExValidator = RegExValidator.examples().first
        exB.fieldLabel = "How much?"
        exB.placeholder = "Enter a value"
        return [exA, exB]
    }
}

// MARK: Date and Time

// Note: syoung 04/10/2020 - These classes are included to support parity with Kotlin where there
// isn't a class for "Date" that includes both date and time.

public class DateTimeInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, DateTimeInputItem {
    public override class func defaultType() -> InputItemType {
        return .dateTime
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions
    }
    
    public var pickerMode: RSDDatePickerMode {
        RSDDatePickerMode(rawValue: self.inputItemType.rawValue) ?? .dateAndTime
    }

    public var formatOptions: RSDDateRangeObject?
    
    public override init(resultIdentifier: String? = nil) {
        super.init(resultIdentifier: resultIdentifier)
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.formatOptions = try container.decodeIfPresent(RSDDateRangeObject.self, forKey: .formatOptions) ?? self.formatOptions
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.formatOptions, forKey: .formatOptions)
    }
    
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .formatOptions:
            return .init(propertyType: .reference(RSDDateRangeObject.documentableType()))
        }
    }
    
    public class func isOpen() -> Bool { true }
    
    public class func jsonExamples() throws -> [[String : JsonSerializable]] {
         [["identifier": "foo", "type": "date-time"]]
    }
}

extension DateTimeInputItemObject : DocumentableObject {
}

public final class DateInputItemObject : DateTimeInputItemObject {
    override public class func defaultType() -> InputItemType {
        return .date
    }
    
    public override class func isOpen() -> Bool { false }
    
    public override class func jsonExamples() throws -> [[String : JsonSerializable]] {
         [[
            "identifier": "foo",
            "type": "date",
            "formatOptions" : [
                "minimumValue" : "1900-01",
                "allowFuture" : false,
                "codingFormat" : "yyyy-MM"
            ]
        ]]
    }
}

public final class TimeInputItemObject : DateTimeInputItemObject {
    override public class func defaultType() -> InputItemType {
        return .time
    }

    public override class func isOpen() -> Bool { false }
    
    public override class func jsonExamples() throws -> [[String : JsonSerializable]] {
         [[
            "identifier": "foo",
            "type": "time",
            "formatOptions" : [
                "minimumValue" : "06:00",
                "allowFuture" : false,
                "codingFormat" : "HH:mm"
            ]
        ]]
    }
}

// MARK: Choice Picker

open class ChoicePickerInputItemObject : AbstractInputItemObject, SerializableInputItemBuilder, ChoicePickerInputItem {
    open override class func defaultType() -> InputItemType {
        return .choicePicker
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case jsonChoices = "choices"
    }
    
    open private(set) var jsonChoices: [JsonChoice]
    open private(set) var answerType: AnswerType
    
    open var defaultAnswer: Any? { nil }
    
    open override func defaultUIHint() -> RSDFormUIHint { .picker }
    
    public init(jsonChoices: [JsonChoice], resultIdentifier: String? = nil) {
        self.jsonChoices = jsonChoices
        self.answerType = defaultBaseType(for: jsonChoices).answerType
        super.init(resultIdentifier: resultIdentifier)
    }
    
    public required init(from decoder: Decoder) throws {
        self.jsonChoices = []
        self.answerType = AnswerTypeString()
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = try container.nestedUnkeyedContainer(forKey: .jsonChoices)
        var choices = [JsonChoice]()
        while !nestedContainer.isAtEnd {
            let nestedDecoder = try nestedContainer.superDecoder()
            let choice = try decodeJsonChoice(from: nestedDecoder)
            choices.append(choice)
        }
        self.jsonChoices = choices
        self.answerType = defaultBaseType(for: choices).answerType
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try encodeJsonChoices(to: container.nestedUnkeyedContainer(forKey: .jsonChoices))
    }
    
    open func decodeJsonChoice(from decoder: Decoder) throws -> JsonChoice {
        try JsonChoiceObject(from: decoder)
    }
    
    open func encodeJsonChoices(to container: UnkeyedEncodingContainer) throws {
        var nestedContainer = container
        try jsonChoices.forEach {
            guard let encodable = $0 as? Encodable else {
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\($0) Does not conform to the Encodable protocol.")
                throw EncodingError.invalidValue($0, context)
            }
            let nestedEncoder = nestedContainer.superEncoder()
            try encodable.encode(to: nestedEncoder)
        }
    }
    
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .jsonChoices:
            return .init(propertyType: .referenceArray(JsonChoiceObject.documentableType()))
        }
    }
    
    open class func isOpen() -> Bool { true }
    
    open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
         "identifier": "foo",
         "type": "choicePicker",
         "fieldLabel": "Favorite color",
         "placeholder": "Blue, no! Red!",
         "choices" : [
            [  "value" : 0, "text" : "never"],
            [  "value" : 1, "text" : "sometimes"],
            [  "value" : 2, "text" : "often"],
            [  "value" : 3, "text" : "always"]]
        ]]
    }
}

extension ChoicePickerInputItemObject : DocumentableObject {
}

internal func defaultBaseType(for jsonChoices: [JsonChoice]) -> JsonType {
    jsonChoices.first(where: {
        $0.matchingValue != nil && $0.matchingValue != JsonElement.null
    })?.matchingValue!.jsonType ?? .string
}

public final class StringChoicePickerInputItemObject : ChoicePickerInputItemObject {
    public override class func defaultType() -> InputItemType {
        .stringChoicePicker
    }
    
    public init(choices: [String], resultIdentifier: String? = nil) {
        super.init(jsonChoices: choices.map { JsonChoiceObject(text: $0) }, resultIdentifier: resultIdentifier)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func decodeJsonChoice(from decoder: Decoder) throws -> JsonChoice {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        return JsonChoiceObject(text: text)
    }
    
    public override func encodeJsonChoices(to container: UnkeyedEncodingContainer) throws {
        var nestedContainer = container
        try jsonChoices.forEach {
            try nestedContainer.encode($0.text)
        }
    }
    
    public override class func isOpen() -> Bool { false }
    
    public override class func jsonExamples() throws -> [[String : JsonSerializable]] {
        [[
         "identifier": "foo",
         "type": "stringChoicePicker",
         "fieldLabel": "Favorite color",
         "placeholder": "Blue, no! Red!",
         "choices" : ["never","sometimes","often","always"]
        ]]
    }
}

// MARK: SkipCheckboxInputItem


public struct SkipCheckboxInputItemObject : SkipCheckboxInputItem, Codable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case classType = "type", fieldLabel, matchingValue = "value"
    }
    // This private field is a work-around for Kotlin serialization which requires a "type" field
    // for polymorphic decoding and does not allow for decoding using a default type. syoung 04/06/2020
    private var classType: String? = "skipCheckbox"
    
    public let fieldLabel: String?
    public let matchingValue: JsonElement?
    
    public var text: String? {
        return fieldLabel
    }
    
    public init(fieldLabel: String, matchingValue: JsonElement? = nil) {
        self.fieldLabel = fieldLabel
        self.matchingValue = matchingValue
    }
}

extension SkipCheckboxInputItemObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .fieldLabel || key == .classType
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .classType:
            return .init(constValue: InputItemType(rawValue: "skipCheckbox"), propertyDescription: "Kotlin serialization requires a 'type' field for any polymorphic class.")
        case .fieldLabel:
            return .init(propertyType: .primitive(.string))
        case .matchingValue:
            return .init(propertyType: .any)
        }
    }
    
    public static func examples() -> [SkipCheckboxInputItemObject] {
        [SkipCheckboxInputItemObject(fieldLabel: "Perfer not to answer", matchingValue: .integer(-1))]
    }
}

// MARK: CheckboxInputItem

public struct CheckboxInputItemObject : CheckboxInputItem, SerializableInputItemBuilder, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case inputItemType = "type", fieldLabel, detail, identifier
    }
    public private(set) var inputItemType: InputItemType = .checkbox
    
    public var identifier: String?
    public let fieldLabel: String?
    public let detail: String?
    
    public var text: String? {
        return fieldLabel
    }

    public init(fieldLabel: String, resultIdentifier: String? = nil, detail: String? = nil) {
        self.fieldLabel = fieldLabel
        self.detail = detail
        self.identifier = resultIdentifier
    }
}

extension CheckboxInputItemObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .inputItemType || key == .fieldLabel
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .inputItemType:
            return .init(constValue: InputItemType.checkbox)
        case .fieldLabel, .detail, .identifier:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [CheckboxInputItemObject] {
        [CheckboxInputItemObject(fieldLabel: "Check the box")]
    }
}

// MARK: Height and Weight

public enum HumanMeasurementRange : String, Codable, CaseIterable {
    case adult, child, infant
}

extension HumanMeasurementRange : StringEnumSet, DocumentableStringEnum {
}

public class AbstractMeasurementInputItemObject : AbstractInputItemObject, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case measurementRange
    }
    
    public var measurementRange: HumanMeasurementRange?
    
    override public var inputUIHint: RSDFormUIHint {
        get { .textfield }
        set { }
    }
    
    public init(measurementRange: HumanMeasurementRange? = nil, resultIdentifier: String? = nil) {
        self.measurementRange = measurementRange
        super.init(resultIdentifier: resultIdentifier)
    }
    
    required public init(from decoder: Decoder) throws {
        self.measurementRange = nil
        super.init()
        try self.decode(from: decoder)
    }
    
    override public func decode(from decoder: Decoder) throws {
        try super.decode(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.measurementRange = try container.decodeIfPresent(HumanMeasurementRange.self, forKey: .measurementRange) ?? self.measurementRange
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.measurementRange, forKey: .measurementRange)
    }
    
    public override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        keys.append(contentsOf: CodingKeys.allCases)
        return keys
    }
    
    public override class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .measurementRange:
            return .init(propertyType: .reference(HumanMeasurementRange.documentableType()))
        }
    }
}

public final class HeightInputItemBuilderObject : AbstractMeasurementInputItemObject, SerializableInputItemBuilder {
    public override class func defaultType() -> InputItemType {
        .height
    }
    
    public let answerType: AnswerType = AnswerTypeMeasurement(unit: "cm")
    
    public func buildInputItem(for question: Question) -> InputItem {
        HeightInputItemObject(measurementRange: self.measurementRange,
                              identifier: self.identifier,
                              fieldLabel: self.fieldLabel,
                              isOptional: self.isOptional,
                              placeholder: self.placeholder)
    }
}

extension HeightInputItemBuilderObject : DocumentableStruct {
    public static func examples() -> [HeightInputItemBuilderObject] {
        [HeightInputItemBuilderObject()]
    }
}

/// Use a wrapper for the height to allow the app to vend a different formatter depending upon
/// whether or not the participant is using metric and to wrap the input item for use by BridgeSDK
/// model objects.
public struct HeightInputItemObject : KeyboardTextInputItem, TextInputValidator {

    public let identifier: String?
    public let fieldLabel: String?
    public let isOptional: Bool
    public let placeholder: String?
    
    public let isExclusive: Bool = false
    public let keyboardOptions: KeyboardOptions = KeyboardOptionsObject.measurementEntryOptions
    public let answerType: AnswerType = AnswerTypeMeasurement(unit: "cm")
    
    public let lengthFormatter: RSDLengthFormatter
    public let inputUIHint: RSDFormUIHint
    
    public init(measurementRange: HumanMeasurementRange?,
                identifier: String?,
                fieldLabel: String?,
                isOptional: Bool,
                placeholder: String?) {
        self.identifier = identifier
        self.fieldLabel = fieldLabel
        self.isOptional = isOptional
        
        let measurementSize = (measurementRange ?? .adult)
        let lengthFormatter = RSDLengthFormatter(forChildUse: (measurementSize != .adult), unitSymbol: nil)
        self.lengthFormatter = lengthFormatter
        
        if let placeholder = placeholder {
            self.placeholder = placeholder
        } else {
            // When converting from the value entered by the participant, then the
            // locale is used to determine the preferred units.
            lengthFormatter.unitStyle = .long
            if Locale.current.usesMetricSystem {
                self.placeholder = lengthFormatter.unitString(fromValue: 250, unit: .centimeter)
            } else {
                self.placeholder = lengthFormatter.unitString(fromValue: 60, unit: .inch)
            }
            lengthFormatter.unitStyle = .short
        }
        
        self.inputUIHint = (measurementSize == .adult) && !Locale.current.usesMetricSystem ? .picker : .textfield
    }

    public func buildTextValidator() -> TextInputValidator { self }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        guard inputUIHint == .picker else { return nil }
        return RSDUSHeightPickerDataSourceObject(formatter: lengthFormatter)
    }
}

extension HeightInputItemObject : MeasurementTextInputValidator {
    var measurementFormatter: MeasurementFormatter { lengthFormatter }
}

public final class WeightInputItemBuilderObject : AbstractMeasurementInputItemObject, SerializableInputItemBuilder {
    public override class func defaultType() -> InputItemType {
        .weight
    }
    
    public let answerType: AnswerType = AnswerTypeMeasurement(unit: "kg")
    
    public func buildInputItem(for question: Question) -> InputItem {
        WeightInputItemObject(measurementRange: self.measurementRange,
                              identifier: self.identifier,
                              fieldLabel: self.fieldLabel,
                              isOptional: self.isOptional,
                              placeholder: self.placeholder)
    }
}

extension WeightInputItemBuilderObject : DocumentableStruct {
    public static func examples() -> [WeightInputItemBuilderObject] {
        [WeightInputItemBuilderObject()]
    }
}

/// Use a wrapper for the height to allow the app to vend a different formatter depending upon
/// whether or not the participant is using metric and to wrap the input item for use by BridgeSDK
/// model objects.
public struct WeightInputItemObject : KeyboardTextInputItem, TextInputValidator {

    public let identifier: String?
    public let fieldLabel: String?
    public let isOptional: Bool
    public let placeholder: String?
    
    public let isExclusive: Bool = false
    public let keyboardOptions: KeyboardOptions = KeyboardOptionsObject.measurementEntryOptions
    public let answerType: AnswerType = AnswerTypeMeasurement(unit: "kg")
    
    public let massFormatter: RSDMassFormatter
    public let inputUIHint: RSDFormUIHint
    
    public init(measurementRange: HumanMeasurementRange?,
                identifier: String?,
                fieldLabel: String?,
                isOptional: Bool,
                placeholder: String?) {
        self.identifier = identifier
        self.fieldLabel = fieldLabel
        self.isOptional = isOptional
        
        let measurementSize = (measurementRange ?? .adult)
        let massFormatter = RSDMassFormatter(forInfantUse: measurementSize == .infant, unitSymbol: nil)
        self.massFormatter = massFormatter
        
        if let placeholder = placeholder {
            self.placeholder = placeholder
        } else {
            // When converting from the value entered by the participant, then the
            // locale is used to determine the preferred units.
            massFormatter.unitStyle = .long
            if Locale.current.usesMetricSystem {
                self.placeholder = massFormatter.unitString(fromValue: 65, unit: .kilogram)
            } else {
                self.placeholder = massFormatter.unitString(fromValue: 10, unit: .pound)
            }
            massFormatter.unitStyle = .medium
        }
        
        self.inputUIHint = (measurementSize == .infant) && !Locale.current.usesMetricSystem ? .picker : .textfield
    }

    public func buildTextValidator() -> TextInputValidator { self }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        guard inputUIHint == .picker else { return nil }
        return RSDUSInfantMassPickerDataSourceObject(formatter: massFormatter)
    }
}

extension WeightInputItemObject : MeasurementTextInputValidator {
    var measurementFormatter: MeasurementFormatter { massFormatter }
}

