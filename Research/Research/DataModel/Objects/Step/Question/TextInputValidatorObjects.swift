//
//  TextInputValidatorObjects.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

public struct PassThruValidator : TextInputValidator {
    public init() {}
    public func answerText(for answer: Any?) -> String? {
        let value = (answer as? JsonElement).map { $0 != .null ? $0.jsonObject() : nil } ?? answer
        return value.map { "\($0)" }
    }
    public func validateInput(answer: Any?) throws -> Any? { answer }
    public func validateInput(text: String?) throws -> Any? { text }
}

public struct RegExValidator : TextInputValidator, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case pattern, invalidMessage
    }
    
    let pattern: NSRegularExpression
    let invalidMessage: String
    
    public init(pattern: NSRegularExpression, invalidMessage: String) {
        self.pattern = pattern
        self.invalidMessage = invalidMessage
    }
    
    public func answerText(for answer: Any?) -> String? {
        answer.map { "\($0)" }
    }
    
    public func validateInput(text: String?) throws -> Any? {
        guard _regExMatches(text) == 1 else {
            let context = RSDInputFieldError.Context(identifier: nil, value: text, debugDescription: invalidMessage)
            throw RSDInputFieldError.invalidRegex(text, context)
        }
        return text
    }
    
    public func validateInput(answer: Any?) throws -> Any? {
        try answer.map { try validateInput(text: "\($0)") } ?? nil
    }
    
    private func _regExMatches(_ text: String?) -> Int {
        guard let string = text else { return 0 }
        return pattern.numberOfMatches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let pattern = try container.decode(String.self, forKey: .pattern)
        self.pattern = try NSRegularExpression(pattern: pattern, options: [])
        self.invalidMessage = try container.decode(String.self, forKey: .invalidMessage)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.pattern.pattern, forKey: .pattern)
        try container.encode(self.invalidMessage, forKey: .invalidMessage)
    }
}

extension RegExValidator : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { true }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .pattern:
            return .init(propertyType: .primitive(.string), propertyDescription: "The string value must be a valid a regex pattern.")
        case .invalidMessage:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [RegExValidator] {
        let pattern = try! NSRegularExpression(pattern: "^[0-9]*$", options: [])
        return [RegExValidator(pattern: pattern, invalidMessage: "Only entering numbers is allowed.")]
    }
}


/// `Codable` string enum for the number formatter.
public enum NumberFormatStyle : String, Codable, CaseIterable {
    case none, decimal, currency, percent, scientific, spellOut, ordinal
    
    public func formatterStyle() -> NumberFormatter.Style {
        guard let idx = NumberFormatStyle.allCases.firstIndex(of: self),
            let style = NumberFormatter.Style(rawValue: UInt(idx))
            else {
                return .none
        }
        return style
    }
}

extension NumberFormatStyle : StringEnumSet, DocumentableStringEnum {
}

public protocol NumberValidator : TextInputValidator {
    associatedtype Value : JsonNumber
    
    var numberStyle: NumberFormatStyle! { get }
    var usesGroupingSeparator: Bool! { get }
    var maximumFractionDigits: Int! { get }
    
    var minimumValue: Value? { get }
    var maximumValue: Value? { get }
    var stepInterval: Value? { get }
    
    // TODO: syoung 04/03/2020 Implement Localization strategy
    var minInvalidMessage: String? { get }
    var maxInvalidMessage: String? { get }
    var invalidMessage: String? { get }
    
    func convertToValue(from number: NSNumber) -> Value
}

public extension NumberValidator {
    
    var formatter : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = self.usesGroupingSeparator
        formatter.numberStyle = self.numberStyle.formatterStyle()
        formatter.maximumFractionDigits = self.maximumFractionDigits
        return formatter
    }
    
    var defaultInvalidMessage : String {
        invalidMessage ?? Localization.localizedString("The number entered is not valid.")
    }
    
    func answerText(for answer: Any?) -> String? {
        guard let num = (answer as? JsonNumber)?.jsonNumber() else { return nil }
        return self.formatter.string(from: num)
    }
    
    func validateInput(answer: Any?) throws -> Any? {
        guard let answer = answer else { return nil }
        if let str = answer as? String {
            return try validateInput(text: str)
        }
        else if let num = (answer as? NSNumber) ?? (answer as? JsonNumber)?.jsonNumber() {
            return try validateNumber(num)
        }
        else {
            let context = RSDInputFieldError.Context(identifier: nil, value: answer, debugDescription: "\(answer) is not a String or a Number")
            throw RSDInputFieldError.invalidType(context)
        }
    }
    
    func validateInput(text: String?) throws -> Any? {
        guard let str = text, let num = self.formatter.number(from: str) else {
            try validateNil()
            return nil
        }
        return try validateNumber(num)
    }
    
    func validateNumber(_ num: NSNumber) throws -> Any? {
        if let min = self.minimumValue?.jsonNumber(), num.decimalValue < min.decimalValue {
            let message = self.minInvalidMessage ?? defaultInvalidMessage
            let context = RSDInputFieldError.Context(identifier: nil, value: num, debugDescription: message)
            throw RSDInputFieldError.lessThanMinimumValue(min.decimalValue, context)
        }
        if let max = self.maximumValue?.jsonNumber(), num.decimalValue > max.decimalValue {
            let message = self.maxInvalidMessage ?? defaultInvalidMessage
            let context = RSDInputFieldError.Context(identifier: nil, value: num, debugDescription: message)
            throw RSDInputFieldError.greaterThanMaximumValue(max.decimalValue, context)
        }
        return convertToValue(from: num)
    }
    
    func validateNil() throws {
        guard minimumValue == nil && maximumValue == nil else {
            let context = RSDInputFieldError.Context(identifier: nil, value: nil, debugDescription: self.defaultInvalidMessage)
            throw RSDInputFieldError.invalidType(context)
        }
    }
}

public struct IntegerFormatOptions : Codable, NumberValidator {
    public typealias Value = Int
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case _numberStyle = "numberStyle",
        _usesGroupingSeparator = "usesGroupingSeparator",
        minimumValue, maximumValue, stepInterval,
        minInvalidMessage, maxInvalidMessage, invalidMessage
    }
    
    public var numberStyle: NumberFormatStyle! {
        get { _numberStyle ?? NumberFormatStyle.none }
        set(newValue) { _numberStyle = newValue }
    }
    private var _numberStyle: NumberFormatStyle?
    
    public var usesGroupingSeparator: Bool! {
        get { _usesGroupingSeparator ?? true }
        set(newValue) { _usesGroupingSeparator = newValue }
    }
    private var _usesGroupingSeparator: Bool?
    
    public var maximumFractionDigits: Int! { 0 }
    
    public var minimumValue: Int?
    public var maximumValue: Int?
    public var stepInterval: Int?
    
    public var minInvalidMessage: String?
    public var maxInvalidMessage: String?
    public var invalidMessage: String?
    
    public func convertToValue(from number: NSNumber) -> Int {
        number.intValue
    }
    
    public init() {
    }
}

extension IntegerFormatOptions : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case ._numberStyle:
            return .init(propertyType: .reference(NumberFormatStyle.documentableType()))
        case ._usesGroupingSeparator:
            return .init(propertyType: .primitive(.boolean))
        case .minimumValue, .maximumValue, .stepInterval:
            return .init(propertyType: .primitive(.integer))
        case .minInvalidMessage, .maxInvalidMessage, .invalidMessage:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [IntegerFormatOptions] {
        let exA = IntegerFormatOptions()
        var exB = IntegerFormatOptions()
        exB._numberStyle = .currency
        exB._usesGroupingSeparator = false
        exB.invalidMessage = "This number is not valid"
        exB.maximumValue = 200
        exB.minimumValue = 0
        exB.stepInterval = 5
        exB.minInvalidMessage = "Minimum value is zero"
        exB.maxInvalidMessage = "Maximum value is $200"
        return [exA, exB]
    }
}

public struct YearFormatOptions : Codable, NumberValidator {
    public typealias Value = Int
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case allowFuture, allowPast, minimumYear, maximumYear,
            minInvalidMessage, maxInvalidMessage, invalidMessage
    }

    public var allowFuture: Bool?
    public var allowPast: Bool?
    public var minimumYear: Int?
    public var maximumYear: Int?
    
    public var minInvalidMessage: String?
    public var maxInvalidMessage: String?
    public var invalidMessage: String?
    
    public init() {
    }
    
    public var numberStyle: NumberFormatStyle! { NumberFormatStyle.none }
    public var usesGroupingSeparator: Bool! { false }
    public var maximumFractionDigits: Int! { 0 }
    
    public var minimumValue: Int? {
        minimumYear ?? ((allowPast ?? true) ? nil : Date().year)
    }
    public var maximumValue: Int? {
        maximumYear ?? ((allowFuture ?? true) ? nil : Date().year)
    }
    public var stepInterval: Int? { 1 }
    
    public func convertToValue(from number: NSNumber) -> Int {
        number.intValue
    }
}

extension YearFormatOptions : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .allowFuture, .allowPast:
            return .init(propertyType: .primitive(.boolean))
        case .maximumYear, .minimumYear:
            return .init(propertyType: .primitive(.integer))
        case .minInvalidMessage, .maxInvalidMessage, .invalidMessage:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [YearFormatOptions] {
        let exA = YearFormatOptions()
        var exB = YearFormatOptions()
        exB.allowPast = false
        exB.maximumYear = 2030
        var exC = YearFormatOptions()
        exC.allowFuture = false
        exC.minimumYear = 1900
        return [exA, exB, exC]
    }
}

extension Date {
    fileprivate var year: Int {
        Calendar.iso8601.component(.year, from: self)
    }
}

public struct DoubleFormatOptions : Codable, NumberValidator {
    public typealias Value = Double
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case _numberStyle = "numberStyle",
        _usesGroupingSeparator = "usesGroupingSeparator",
        _maximumFractionDigits = "maximumFractionDigits",
        minimumValue, maximumValue, stepInterval,
        minInvalidMessage, maxInvalidMessage, invalidMessage
    }
    
    public var numberStyle: NumberFormatStyle! {
        get { _numberStyle ?? NumberFormatStyle.none }
        set(newValue) { _numberStyle = newValue }
    }
    private var _numberStyle: NumberFormatStyle?
    
    public var usesGroupingSeparator: Bool! {
        get { _usesGroupingSeparator ?? true }
        set(newValue) { _usesGroupingSeparator = newValue }
    }
    private var _usesGroupingSeparator: Bool?
    
    public var maximumFractionDigits: Int! {
        get { _maximumFractionDigits ?? 2 }
        set(newValue) { _maximumFractionDigits = newValue }
    }
    private var _maximumFractionDigits: Int?
    
    public var minimumValue: Double?
    public var maximumValue: Double?
    public var stepInterval: Double?
    
    public var minInvalidMessage: String?
    public var maxInvalidMessage: String?
    public var invalidMessage: String?
    
    public init() {
    }
    
    public func convertToValue(from number: NSNumber) -> Double {
        number.doubleValue
    }
}

extension DoubleFormatOptions : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case ._numberStyle:
            return .init(propertyType: .reference(NumberFormatStyle.documentableType()))
        case ._usesGroupingSeparator:
            return .init(propertyType: .primitive(.boolean))
        case ._maximumFractionDigits:
            return .init(propertyType: .primitive(.integer))
        case .minimumValue, .maximumValue, .stepInterval:
            return .init(propertyType: .primitive(.number))
        case .minInvalidMessage, .maxInvalidMessage, .invalidMessage:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [DoubleFormatOptions] {
        let exA = DoubleFormatOptions()
        var exB = DoubleFormatOptions()
        exB._maximumFractionDigits = 2
        exB._numberStyle = .currency
        exB._usesGroupingSeparator = false
        exB.invalidMessage = "This number is not valid"
        exB.maximumValue = 200.0
        exB.minimumValue = 0.0
        exB.stepInterval = 0.01
        exB.minInvalidMessage = "Minimum value is zero"
        exB.maxInvalidMessage = "Maximum value is $200"
        return [exA, exB]
    }
}

public struct DateTimeValidator : TextInputValidator {
    let pickerMode: RSDDatePickerMode
    let range: RSDDateRange?
    let localizedFormatter: DateFormatter
    let codingFormatter: DateFormatter
    
    public init(pickerMode: RSDDatePickerMode, range: RSDDateRange?) {
        self.pickerMode = pickerMode
        self.range = range
        let codingFormatter = DateFormatter()
        codingFormatter.dateFormat = pickerMode.defaultCodingFormat
        self.codingFormatter = codingFormatter
        let localizedFormatter = DateFormatter()
        switch pickerMode {
        case .dateAndTime:
            localizedFormatter.dateStyle = .short
            localizedFormatter.timeStyle = .short
        case .date:
            localizedFormatter.dateStyle = .short
            localizedFormatter.timeStyle = .none
        case .time:
            localizedFormatter.dateStyle = .none
            localizedFormatter.timeStyle = .short
        }
        self.localizedFormatter = localizedFormatter
    }
    
    public func answerText(for answer: Any?) -> String? {
        if let str = answer as? String, let date = codingFormatter.date(from: str) {
            return localizedFormatter.string(from: date)
        }
        else if let date = answer as? Date {
            return localizedFormatter.string(from: date)
        }
        else {
            return nil
        }
    }
    
    public func validateInput(text: String?) throws -> Any? {
        guard let text = text else { return nil }
        guard let date = localizedFormatter.date(from: text) else {
            let context = RSDInputFieldError.Context(identifier: nil, value: text, debugDescription: "'\(text)' could not be converted to a date.")
            throw RSDInputFieldError.invalidFormatter(localizedFormatter, context)
        }
        try validateDate(date: date)
        return date
    }
    
    public func validateInput(answer: Any?) throws -> Any? {
        guard let answer = answer else { return nil }
        if let text = answer as? String {
            return try validateInput(text: text)
        }
        else if let json = answer as? JsonElement, case .string(let text) = json {
            return try validateInput(text: text)
        }
        else if let date = answer as? Date {
            try validateDate(date: date)
            return date
        }
        else {
            let context = RSDInputFieldError.Context(identifier: nil, value: answer, debugDescription: "\(answer) is not supported for \(self)")
            throw RSDInputFieldError.invalidType(context)
        }
    }
    
    func validateDate(date: Date) throws {
        if let minDate = range?.minimumDate, date < minDate {
            let context = RSDInputFieldError.Context(identifier: nil,
                                                     value: date,
                                                     debugDescription: "\(date) is is less than \(minDate)")
            throw RSDInputFieldError.lessThanMinimumDate(minDate, context)
        }
        else if let maxDate = range?.maximumDate, date > maxDate {
            let context = RSDInputFieldError.Context(identifier: nil,
                                                     value: date,
                                                     debugDescription: "\(date) is is greater than \(maxDate)")
            throw RSDInputFieldError.greaterThanMaximumDate(maxDate, context)
        }
    }
}

extension Formatter {
    func convertString(from string: String) throws -> Any? {
        var obj: AnyObject?
        var err: NSString?
        self.getObjectValue(&obj, for: string, errorDescription: &err)
        if err != nil {
            let context = RSDInputFieldError.Context(identifier: nil, value: string, debugDescription: (err! as String))
            throw RSDInputFieldError.invalidFormatter(self, context)
        } else {
            return obj
        }
    }
}

protocol MeasurementFormatter {
    func convertString(from string: String) throws -> Any?
    func string(for obj: Any?) -> String?
}

extension MeasurementFormatter {
    func measurement(from string: String) throws -> NSMeasurement {
        guard let value = try convertString(from: string) as? NSMeasurement else {
            let context = RSDInputFieldError.Context(identifier: nil, value: string, debugDescription: "'\(string)' could not be converted to a length of measurement")
            throw RSDInputFieldError.invalidType(context)
        }
        return value
    }
}

extension RSDLengthFormatter : MeasurementFormatter {
}

extension RSDMassFormatter : MeasurementFormatter {
}

protocol MeasurementTextInputValidator : TextInputValidator {
    var answerType: AnswerType { get }
    var measurementFormatter : MeasurementFormatter { get }
}

extension MeasurementTextInputValidator {
    
    public func answerText(for answer: Any?) -> String? {
        guard let answer = answer else { return nil }
        if let jsonValue = answer as? JsonElement,
            let value = try? self.answerType.decodeAnswer(from: jsonValue) {
            return measurementFormatter.string(for: value)
        }
        else {
            return measurementFormatter.string(for: answer)
        }
    }
    
    public func validateInput(text: String?) throws -> Any? {
        guard let text = text else { return nil }
        return try self.measurementFormatter.measurement(from: text)
    }
    
    public func validateInput(answer: Any?) throws -> Any? {
        return answer
    }
}

