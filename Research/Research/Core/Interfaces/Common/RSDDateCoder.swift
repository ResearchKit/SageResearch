//
//  RSDDateCoder.swift
//  Research
//

import JsonModel
import Foundation

/// `RSDDateCoder` is used to handle specifying date encoding/decoding. If the calendar components supported by
/// this formatter only include a subset of all the components then only those components should be displayed
/// in the UI.
public protocol RSDDateCoder : Codable {
    
    /// The formatter to use for encoding and decoding the result.
    ///
    /// - seealso: `RSDAnswerResultType`
    var resultFormatter: DateFormatter { get }
    
    /// Formatter to use for decoding dates used to set up a date range.
    ///
    /// - seealso: `RSDDateRangeObject`
    var inputFormatter: DateFormatter { get }
    
    /// Calendar components that are included for this date range.
    var calendarComponents: Set<Calendar.Component> { get }
    
    /// The calendar used by this date range when formatting a `DateComponents` object.
    var calendar: Calendar { get }
}

extension RSDDateCoder {
    
    /// Use the coder to encode a date as a string.
    ///
    /// - parameters:
    ///     - date:             The date to encode.
    ///     - isResultCoding:   Should this value be encoded using the result formatter?
    public func string(from date: Date, isResultCoding: Bool = false) -> String? {
        let formatter = isResultCoding ? resultFormatter : inputFormatter
        return formatter.string(from: date)
    }
    
    /// Use the coder to encode date components as a string.
    ///
    /// - parameters:
    ///     - dateComponents:   The date components to encode.
    ///     - isResultCoding:   Should this value be encoded using the result formatter?
    public func string(from dateComponents: DateComponents, isResultCoding: Bool = false) -> String? {
        guard let date = calendar.date(from: dateComponents)
            else {
                return nil
        }
        let formatter = isResultCoding ? resultFormatter : inputFormatter
        return formatter.string(from: date)
    }
    
    /// Use the coder to decode a date from a string.
    ///
    /// - parameters:
    ///     - string:           The string to decode.
    ///     - isResultCoding:   Should this value be encoded using the result formatter?
    public func date(from string: String, isResultCoding: Bool = false) -> Date? {
        let formatter = isResultCoding ? resultFormatter : inputFormatter
        return formatter.date(from: string)
    }
    
    /// Use the coder to decode date components from a string.
    ///
    /// - parameters:
    ///     - string:           The string to decode.
    ///     - isResultCoding:   Should this value be encoded using the result formatter?
    public func dateComponents(from string: String, isResultCoding: Bool = false) -> DateComponents? {
        let formatter = isResultCoding ? resultFormatter : inputFormatter
        guard let date = formatter.date(from: string)
            else {
                return nil
        }
        return calendar.dateComponents(calendarComponents, from: date)
    }
}

