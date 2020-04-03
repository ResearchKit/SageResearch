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

public struct PassThruValidator : TextInputValidator {
    public func answerText(for answer: Any?) -> String? {
        answer.map { "\($0)" }
    }
    
    public func validateInput(text: String?) throws -> Any? {
        text
    }
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
            throw RSDValidationError.invalidValue(text, invalidMessage)
        }
        return text
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

/// `Codable` string enum for the number formatter.
public enum NumberFormatStyle : String, Codable, CaseIterable, RSDStringEnumSet {
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

extension NumberFormatStyle : RSDDocumentableStringEnum {
}

public protocol NumberValidator : TextInputValidator {
    associatedtype Value : RSDJSONNumber
    
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
        guard let num = (answer as? RSDJSONNumber)?.jsonNumber() else { return nil }
        return self.formatter.string(from: num)
    }
    
    func validateInput(text: String?) throws -> Any? {
        guard let str = text, let num = self.formatter.number(from: str) else {
            try validateNil()
            return nil
        }
        if let min = self.minimumValue?.jsonNumber(), num.decimalValue < min.decimalValue {
            let message = self.minInvalidMessage ?? defaultInvalidMessage
            throw RSDValidationError.invalidValue(num, message)
        }
        if let max = self.maximumValue?.jsonNumber(), num.decimalValue > max.decimalValue {
            let message = self.maxInvalidMessage ?? defaultInvalidMessage
            throw RSDValidationError.invalidValue(num, message)
        }
        return num
    }
    
    func validateNil() throws {
        guard minimumValue == nil && maximumValue == nil else {
            throw RSDValidationError.invalidValue(nil, self.defaultInvalidMessage)
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
    
    public init() {
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
        fatalError("TODO: Not implemented. syoung 04/03/2020")
    }
    
    public func validateInput(text: String?) throws -> Any? {
        fatalError("TODO: Not implemented. syoung 04/03/2020")
    }
}
