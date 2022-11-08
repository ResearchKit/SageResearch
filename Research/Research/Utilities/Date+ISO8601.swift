//
//  Date+ISO8601.swift
//  Research
//

import Foundation

/// ISO 8601 timestamp formatter that includes time and date.
@available(*, deprecated, message: "Use `JsonModel.ISO8601TimestampFormatter`")
public let rsd_ISO8601TimestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

/// ISO 8601 date only formatter.
@available(*, deprecated, message: "Use `JsonModel.ISO8601DateOnlyFormatter`")
public let rsd_ISO8601DateOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

/// ISO 8601 time only formatter.
@available(*, deprecated, message: "Use `JsonModel.ISO8601TimeOnlyFormatter`")
public let rsd_ISO8601TimeOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
