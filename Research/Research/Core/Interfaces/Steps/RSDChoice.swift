import Foundation
import JsonModel
import ResultModel

/// `RSDChoice` is used to describe a choice item for use with a multiple choice or multiple component input field.
public protocol RSDChoice {
    
    /// A JSON encodable object to return as the value when this choice is selected. A `nil` value indicates that
    /// the user has selected to skip the question or "prefers not to answer".
    var answerValue: Codable? { get }
    
    /// Localized text string to display for the choice.
    var text: String? { get }
    
    /// Additional detail text.
    var detail: String? { get }
    
    /// For a multiple choice option, is this choice mutually exclusive? For example, "none of the above".
    var isExclusive: Bool { get }
    
    /// An icon image that can be used for displaying the choice.
    var imageData: RSDImageData? { get }
    
    /// Is the choice value equal to the given result?
    /// - parameter result: A result to test for equality.
    /// - returns: `true` if the values are equal.
    func isEqualToResult(_ result: ResultData?) -> Bool
}
