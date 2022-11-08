//
//  RSDMultipleComponentOptionsObject.swift
//  Research
//

import Foundation

/// A simple struct that can be used to implement the `RSDMultipleComponentOptions` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
@available(*,deprecated, message: "Will be deleted in a future version.")
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
@available(*,deprecated, message: "Will be deleted in a future version.")
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
