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

public struct InputItemType : RSDFactoryTypeRepresentable, Codable, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(jsonType: JsonType) {
        self.rawValue = jsonType.rawValue
    }
}

extension InputItemType : ExpressibleByStringLiteral {
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
    
    public static let choicePicker: InputItemType = "choicePicker"
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
        case surveyRules
    }
    
    public private(set) var inputItemType: InputItemType
    public private(set) var identifier: String?
    public var fieldLabel: String?
    public var placeholder: String?
    
    public var inputUIHint: RSDFormUIHint {
        get { _inputUIHint ?? type(of: self).defaultUIHint()}
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
    
    open class func defaultUIHint() -> RSDFormUIHint {
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
}

// MARK: TextInputItem

public struct KeyboardOptionsObject : KeyboardOptions, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case _isSecureTextEntry = "isSecureTextEntry"
        case _autocapitalizationType = "autocapitalizationType"
        case _autocorrectionType = "autocorrectionType"
        case _spellCheckingType = "spellCheckingType"
        case _keyboardType = "keyboardType"
    }
    
    public var isSecureTextEntry: Bool { _isSecureTextEntry ?? false }
    private var _isSecureTextEntry: Bool?
    
    public var autocapitalizationType: RSDTextAutocapitalizationType { _autocapitalizationType ?? .none }
    private var _autocapitalizationType: RSDTextAutocapitalizationType?
    
    public var autocorrectionType: RSDTextAutocorrectionType { _autocorrectionType ?? .no }
    private var _autocorrectionType: RSDTextAutocorrectionType?
    
    public var spellCheckingType: RSDTextSpellCheckingType { _spellCheckingType ?? .no }
    private var _spellCheckingType: RSDTextSpellCheckingType?
    
    public var keyboardType: RSDKeyboardType { _keyboardType ?? .default }
    private var _keyboardType: RSDKeyboardType?
    
    public init(isSecureTextEntry: Bool = false,
                autocapitalizationType: RSDTextAutocapitalizationType = .none,
                autocorrectionType: RSDTextAutocorrectionType = .no,
                spellCheckingType: RSDTextSpellCheckingType = .no,
                keyboardType: RSDKeyboardType = .default) {
        _isSecureTextEntry = isSecureTextEntry
        _autocapitalizationType = autocapitalizationType
        _autocorrectionType = autocorrectionType
        _spellCheckingType = spellCheckingType
        _keyboardType = keyboardType
    }
    
    public static let integerEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                 autocapitalizationType: .none,
                                                                 autocorrectionType: .no,
                                                                 spellCheckingType: .no,
                                                                 keyboardType: .numberPad)

    public static let decimalEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                  autocapitalizationType: .none,
                                                                  autocorrectionType: .no,
                                                                  spellCheckingType: .no,
                                                                  keyboardType: .decimalPad)
    
    public static let dateTimeEntryOptions = KeyboardOptionsObject(isSecureTextEntry: false,
                                                                   autocapitalizationType: .none,
                                                                   autocorrectionType: .no,
                                                                   spellCheckingType: .no,
                                                                   keyboardType: .numbersAndPunctuation)
}

public final class DoubleTextInputItemObject : AbstractInputItemObject, KeyboardTextInputItem, Codable {
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
    
    public let answerType: AnswerType = AnswerTypeNumber()
    public let keyboardOptions: KeyboardOptions = KeyboardOptionsObject.decimalEntryOptions
    
    public func buildTextValidator() -> TextInputValidator {
        formatOptions ?? DoubleFormatOptions()
    }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: max,
                                               maximum: min,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public final class IntegerTextInputItemObject : AbstractInputItemObject, KeyboardTextInputItem, Codable {
    public override class func defaultType() -> InputItemType {
        return .integer
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions, keyboardOptions
    }
    
    public var formatOptions: IntegerFormatOptions?
    
    public let answerType: AnswerType = AnswerTypeInteger()
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

    public func buildTextValidator() -> TextInputValidator {
        formatOptions ?? IntegerFormatOptions()
    }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: max,
                                               maximum: min,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public final class YearTextInputItemObject : AbstractInputItemObject, KeyboardTextInputItem, Codable {
    public override class func defaultType() -> InputItemType {
        return .year
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions
    }
    
    public var formatOptions: YearFormatOptions?
    
    public let answerType: AnswerType = AnswerTypeInteger()
    public var keyboardOptions: KeyboardOptions { KeyboardOptionsObject.integerEntryOptions }
        
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

    public func buildTextValidator() -> TextInputValidator {
        formatOptions ?? YearFormatOptions()
    }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        guard let options = formatOptions else { return nil }
        let max = options.maximumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let min = options.minimumValue.map { ($0 as NSNumber).decimalValue } ?? 0
        let stepInterval = options.stepInterval.map { ($0 as NSNumber).decimalValue }
        return RSDNumberPickerDataSourceObject(minimum: max,
                                               maximum: min,
                                               stepInterval: stepInterval,
                                               numberFormatter: options.formatter)
    }
}

public final class StringTextInputItemObject : AbstractInputItemObject, KeyboardTextInputItem, Codable {
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
}

public protocol ChoicePickerInputItem : KeyboardTextInputItem, RSDChoiceOptions {
    var jsonChoices: [JsonChoice] { get }
}

public extension ChoicePickerInputItem {
    var choices: [RSDChoice] { jsonChoices }
    var keyboardOptions: KeyboardOptions { KeyboardOptionsObject() }
    func buildTextValidator() -> TextInputValidator { PassThruValidator() }
    func buildPickerSource() -> RSDPickerDataSource? { self }
}

open class ChoicePickerInputItemObject : AbstractInputItemObject, ChoicePickerInputItem, Codable {
    open override class func defaultType() -> InputItemType {
        return .choicePicker
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case jsonChoices = "choices"
    }
    
    open private(set) var jsonChoices: [JsonChoice]
    open private(set) var answerType: AnswerType
    
    open var defaultAnswer: Any? { nil }
    
    open override class func defaultUIHint() -> RSDFormUIHint { .picker }
    
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
            let nestedEncoder = nestedContainer.superEncoder()
            try $0.encode(to: nestedEncoder)
        }
    }
}

internal func defaultBaseType(for jsonChoices: [JsonChoice]) -> JsonType {
    jsonChoices.first(where: {
        $0.matchingValue != nil && $0.matchingValue != JsonElement.null
    })?.matchingValue!.jsonType ?? .string
}

// Note: syoung 04/10/2020 - These classes are included to support parity with Kotlin where there
// isn't a class for "Date" that includes both date and time.

public class DateTimeInputItemObject : AbstractInputItemObject, KeyboardTextInputItem, Codable {
    public override class func defaultType() -> InputItemType {
        return .dateTime
    }
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case formatOptions
    }
    
    fileprivate var pickerMode: RSDDatePickerMode {
        RSDDatePickerMode(rawValue: self.inputItemType.rawValue) ?? .dateAndTime
    }

    public var formatOptions: RSDDateRangeObject?
    public let keyboardOptions: KeyboardOptions = KeyboardOptionsObject.dateTimeEntryOptions

    public var answerType: AnswerType {
        let codingFormat = formatOptions?.dateCoder?.inputFormatter.dateFormat ?? pickerMode.defaultCodingFormat
        return AnswerTypeDateTime(codingFormat: codingFormat)
    }
    
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

    public func buildTextValidator() -> TextInputValidator {
        DateTimeValidator(pickerMode: pickerMode, range: formatOptions)
    }
    
    public func buildPickerSource() -> RSDPickerDataSource? {
        formatOptions.map { $0.dataSource().0 } ?? nil 
    }
}

public final class DateInputItemObject : DateTimeInputItemObject {
    override public class func defaultType() -> InputItemType {
        return .date
    }
}

public final class TimeInputItemObject : DateTimeInputItemObject {
    override public class func defaultType() -> InputItemType {
        return .time
    }
}

// MARK: SkipCheckboxInputItem

public struct SkipCheckboxInputItemObject : SkipCheckboxInputItem, Codable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case classType = "type", fieldLabel, matchingValue = "value"
    }
    // This private field is a work-around for kotlin serialization which requires a "type" field
    // for polymorphic decoding and does not allow for decoding using a default type. syoung 04/06/2020
    private var classType: String? = "skipCheckbox"
    
    public let fieldLabel: String
    public let matchingValue: JsonElement?
    
    public var text: String? {
        return fieldLabel
    }
    
    public init(fieldLabel: String, matchingValue: JsonElement? = nil) {
        self.fieldLabel = fieldLabel
        self.matchingValue = matchingValue
    }
}

// MARK: CheckboxInputItem

// TODO: syoung 04/10/2020 Add checkbox item type support. Data type = boolean?? kinda fits.
//@Serializable
//@SerialName("checkbox")
//data class CheckboxInputItemObject(@SerialName("identifier")
//                                   override val resultIdentifier: String,
//                                   override val fieldLabel: String) : CheckboxInputItem

// TODO: syoung 04/04/2020 Add support for measurement types.
