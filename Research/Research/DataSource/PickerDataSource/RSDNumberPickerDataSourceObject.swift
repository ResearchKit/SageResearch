//
//  RSDNumberPickerDataSourceObject.swift
//  Research
//

import Foundation
import JsonModel
import Formatters

/// A simple struct that can be used to implement the `RSDNumberPickerDataSource` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDNumberPickerDataSourceObject : RSDNumberPickerDataSource {
    
    /// Returns the minimum number allowed.
    public let minimum: Decimal
    
    /// Returns the maximum number allowed.
    public let maximum: Decimal
    
    /// Returns the step interval to use. If `nil`, then the step interval will default to advance by 1.
    public let stepInterval: Decimal?
    
    /// Returns the number formatter to use to format the displayed value and to parse the result.
    public let numberFormatter: RSDNumberFormatterProtocol
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(minimum: Decimal, maximum: Decimal, stepInterval: Decimal?, numberFormatter: RSDNumberFormatterProtocol) {
        self.minimum = minimum
        self.maximum = maximum
        self.stepInterval = stepInterval
        self.numberFormatter = numberFormatter
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDNumberPickerDataSource {
    
    /// Returns the decimal number answer for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func numberAnswer(from selectedAnswer: Any?) -> Decimal? {
        // Check that the answer is a number in range
        let number: Decimal
        if let decimal = selectedAnswer as? Decimal {
            number = decimal
        } else if let num = (selectedAnswer as? NSNumber) ?? (selectedAnswer as? JsonNumber)?.jsonNumber() {
            number = Decimal(num.doubleValue)
        } else {
            return nil
        }
        guard number <= maximum, number >= minimum else {
            return nil
        }
        return number
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let number = numberAnswer(from: selectedAnswer) else { return nil }
        return numberFormatter.string(from: number as NSNumber)
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension NumberFormatter : RSDNumberFormatterProtocol {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDFractionFormatter : RSDNumberFormatterProtocol {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDDurationFormatter : RSDNumberFormatterProtocol {
}

