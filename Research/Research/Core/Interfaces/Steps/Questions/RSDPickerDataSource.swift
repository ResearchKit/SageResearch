//
//  RSDPickerDataSource.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// `RSDPickerDataSource` includes information that can be used to build a picker UI element.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDPickerDataSource {
    
    /// Returns the text answer to display for a given selected answer.
    /// - parameter selectedAnswer: The answer to convert.
    /// - returns: A text value for the answer to display to the user.
    func textAnswer(from selectedAnswer: Any?) -> String?
}

/// `RSDDatePickerMode` describes the type of UI picker to display for dates and times.
/// - seealso: `RSDDatePickerDataSource`
@available(*,deprecated, message: "Will be deleted in a future version.")
public enum RSDDatePickerMode : String, Codable, CaseIterable {
    
    /// Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
    case time
    
    /// Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
    case date
    
    /// Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting
    /// (e.g. Wed Nov 15 | 6 | 53 | PM)
    case dateAndTime = "date-time"
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDDatePickerMode {
    public var defaultCodingFormat: String {
        switch self {
        case .dateAndTime:
            return ISO8601TimestampFormatter.dateFormat
        case .date:
            return ISO8601DateOnlyFormatter.dateFormat
        case .time:
            return ISO8601TimeOnlyFormatter.dateFormat
        }
    }
}

/// A data source for selecting a date.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDDatePickerDataSource : RSDPickerDataSource {
    
    /// The type of UI picker to display for dates and times.
    var datePickerMode: RSDDatePickerMode { get }
    
    /// Specify the minimum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    var minimumDate: Date? { get }
    
    /// Specify the maximum date range. Default = `nil`. When `minimumDate` > `maximumDate`, the values are ignored.
    var maximumDate: Date? { get }
    
    /// The minute interval to display in a picker wheel or list of choices. The interval must be evenly divided into 60.
    /// For example, `5` is valid but `7` is not. Default is `1`, minimum is `1`, maximum is `30`.
    var minuteInterval: Int? { get }
    
    /// The date formatter for displaying the date in a text field or label
    var dateFormatter: DateFormatter { get }
    
    /// The date that should be set initially.
    var defaultDate: Date? { get }
}

/// A picker data source for selecting choices.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDChoicePickerDataSource : RSDPickerDataSource {
    
    /// If this is a multiple component input field, the UI can optionally define a separator.
    /// For example, blood pressure would have a separator of "/".
    var separator: String? { get }
    
    /// Returns the default answer (if any) for this picker. If `nil` then the UI should display
    /// empty rows initially, otherwise, the UI should display the default value.
    var defaultAnswer: Any? { get }
    
    /// Returns the number of 'columns' to display.
    var numberOfComponents: Int { get }
    
    /// Returns the # of rows in each component.
    /// - parameter component: The component (or column) of the picker.
    /// - returns: The number of rows in the given component.
    func numberOfRows(in component: Int) -> Int
    
    /// Returns the choice for this row/component. If this is returns `nil` then this is the "skip" choice.
    /// - parameters:
    ///     - row: The row for the selected component.
    ///     - component: The component (or column) of the picker.
    func choice(forRow row: Int, forComponent component: Int) -> RSDChoice?
    
    /// Returns the selected answer created by the union of the selected rows.
    /// - parameter selectedRows: The selected rows, where there is a selected row for each component.
    /// - returns: The answer created from the given array of selected rows.
    func selectedAnswer(with selectedRows: [Int]) -> Any?
    
    /// Returns the selected rows that match the given selected answer (if any).
    /// - parameter selectedAnswer: The selected answer.
    /// - returns: The selected rows, where there is a selected row for each component, or `nil` if not
    ///            all rows are selected.
    func selectedRows(from selectedAnswer: Any?) -> [Int]?
}

/// A picker data source for picking a number.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDNumberPickerDataSource : RSDPickerDataSource {
    
    /// Returns the minimum number allowed.
    var minimum: Decimal { get }
    
    /// Returns the maximum number allowed.
    var maximum: Decimal { get }
    
    /// Returns the step interval to use. If `nil`, then the step interval will default to advance by 1.
    var stepInterval: Decimal? { get }
    
    /// Returns the number formatter to use to format the displayed value and to parse the result.
    var numberFormatter: RSDNumberFormatterProtocol { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDNumberFormatterProtocol {
    
    /// Return the string for the given number.
    func string(from number: NSNumber) -> String?
    
    /// Return the number for the given string.
    func number(from string: String) -> NSNumber?
}

/// `RSDMultipleComponentOptions` is a data source protocol that can be used to set up a picker.
///
/// - seealso: `RSDMultipleComponentOptions` and `RSDUSMeasurementPickerDataSource`
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDMultipleComponentPickerDataSource : RSDChoicePickerDataSource {
    
    /// A list of choices for input fields that make up the multiple component option set.
    var choices : [[RSDChoice]] { get }
}

/// `RSDMultipleComponentOptions` is a data source protocol that can be used to set up a picker.
///
/// - seealso: `RSDMultipleComponentInputField` and `RSDFormStepDataSource`
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDMultipleComponentOptions : RSDMultipleComponentPickerDataSource {
}

/// `RSDChoiceOptions` is a data source protocol that can be used to set up a picker or list of choices.
///
/// - seealso: `RSDChoiceInputFieldObject` and `RSDFormStepDataSource`
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDChoiceOptions : RSDChoicePickerDataSource {
    
    /// A list of choices for the input field.
    var choices : [RSDChoice] { get }
    
    /// A Boolean value indicating whether the user can skip the input field without providing an answer.
    var isOptional: Bool { get }
}

/// Extend the choice options protocol to allow setting a default value.
@available(*,deprecated, message: "Will be deleted in a future version.")
public protocol RSDChoiceOptionsWithDefault : RSDChoiceOptions {
    
    /// The default answer (if any) to set for this choice options set.
    var defaultAnswer: Any? { get }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDChoiceOptions {
    
    /// Convenience property for whether or not the choice input field has associated images.
    public var hasImages: Bool {
        for choice in choices {
            if choice.imageData != nil {
                return true
            }
        }
        return false
    }
    
    /// The separator is not used with only one column of choices.
    public var separator: String? {
        return nil
    }
}
