//
//  RSDNavigationUIAction.swift
//  Research
//

import Foundation

/// `RSDNavigationUIAction` implements an extension of the base protocol where the action includes an identifier
/// for a step to navigate to if this action is called. This is used by the `RSDConditionalStepNavigator` to
/// navigate based on the presence of a result with the given `identifier`.
/// - seealso: `RSDNavigationRule`
public protocol RSDNavigationUIAction : RSDUIAction {
    
    /// The identifier for the step to skip to if the action is called.
    var skipToIdentifier: String { get }
}
