//
//  RSDNumberPickerDataSourceObject.swift
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
import JsonModel
import Formatters

/// A simple struct that can be used to implement the `RSDNumberPickerDataSource` protocol.
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

extension NumberFormatter : RSDNumberFormatterProtocol {
}

extension RSDFractionFormatter : RSDNumberFormatterProtocol {
}

extension RSDDurationFormatter : RSDNumberFormatterProtocol {
}

