//
//  RSDMultipleComponentOptionsObject.swift
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

/// A simple struct that can be used to implement the `RSDMultipleComponentOptions` protocol.
public struct RSDMultipleComponentOptionsObject : RSDMultipleComponentOptions {

    /// A list of choices for the input field.
    public let choices : [[RSDChoice]]
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    public let isOptional: Bool
    
    /// If this is a multiple component input field, the UI can optionally define a separator.
    /// For example, blood pressure would have a separator of "/".
    public let separator: String?
    
    /// The default answer associated with this option set.
    public let defaultAnswer: Any?
    
    /// Default initializer. Auto-synthesized init is not public.
    public init(choices: [[RSDChoice]], separator: String?, isOptional: Bool, defaultAnswer: Any? = nil) {
        self.choices = choices
        self.separator = separator
        self.isOptional = isOptional
        self.defaultAnswer = defaultAnswer
    }
}

/// Extension of the `RSDMultipleComponentPickerDataSource` protocol to implement part of the
/// `RSDChoicePickerDataSource` protocol.
extension RSDMultipleComponentPickerDataSource {
    
    /// Returns the number of 'columns' to display.
    public var numberOfComponents: Int {
        return self.choices.count
    }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    public func numberOfRows(in component: Int) -> Int {
        guard component < self.choices.count else { return 0 }
        return self.choices[component].count
    }
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    public func choice(forRow row: Int, forComponent component: Int) -> RSDChoice? {
        guard component < self.choices.count, row < self.choices[component].count else { return nil }
        return self.choices[component][row]
    }
}

/// Extension of the `RSDMultipleComponentOptions` implementation to implement selected
/// answer conversion.
extension RSDMultipleComponentOptions {
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    public func selectedAnswer(with selectedRows: [Int]) -> Any? {
        let choices = selectedRows.enumerated().compactMap { (component, selectedRow) -> Any? in
            return self.choice(forRow: selectedRow, forComponent: component)?.answerValue
        }
        guard choices.count == self.numberOfComponents
            else {
                return nil
        }
        return choices
    }
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    public func selectedRows(from selectedAnswer: Any?) -> [Int]? {
        guard selectedAnswer != nil else { return nil }
        let answers:[Any] = (selectedAnswer! as? [Any]) ?? [selectedAnswer!]
        guard answers.count == self.numberOfComponents else { return nil }
        
        // Filter through and look for the current answer
        let selected: [Int] = answers.enumerated().compactMap { (component, value) -> Int? in
            return choices[component].firstIndex(where: { RSDObjectEquality($0.answerValue, value) })
        }
        
        return selected.count == self.numberOfComponents ? selected : nil
    }
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    public func textAnswer(from selectedAnswer: Any?) -> String? {
        guard let array = selectedRows(from: selectedAnswer) else { return nil }
        let strings = array.enumerated().compactMap { choice(forRow: $0.element, forComponent: $0.offset)?.text }
        let separator = self.separator ?? " "
        return strings.joined(separator: separator)
    }
}
