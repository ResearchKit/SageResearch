//
//  RSDChoiceOptionsObject.swift
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

/// A simple struct that can be used to implement the `RSDChoiceOptions` protocol.
public struct RSDChoiceOptionsObject : RSDChoiceOptions {
    
    /// A list of choices for the input field.
    public let choices: [RSDChoice]
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    public let isOptional: Bool
    
    /// The default answer associated with this option set.
    public let defaultAnswer: Any?
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(choices: [RSDChoice], isOptional: Bool, defaultAnswer: Any? = nil) {
        self.choices = choices
        self.isOptional = isOptional
        self.defaultAnswer = defaultAnswer
    }
}

/// Extension of the `RSDChoiceOptions` protocol to implement the `RSDChoicePickerDataSource` protocol.
extension RSDChoiceOptions {
    
    /// Returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return 1
    }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    public func numberOfRows(in component: Int) -> Int {
        return self.choices.count
    }
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < 1, row < self.choices.count else { return nil }
        return self.choices[row]
    }
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        guard selectedRows.count == 1, let row = selectedRows.first else { return nil }
        return self.choice(forRow: row, forComponent: 0)?.answerValue
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard let index = self.choices.firstIndex(where: { RSDObjectEquality($0.answerValue, selectedAnswer) }) else { return nil }
        return [index]
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let array = selectedRows(from: selectedAnswer), let row = array.first else { return nil }
        return choices[row].text
    }
}
