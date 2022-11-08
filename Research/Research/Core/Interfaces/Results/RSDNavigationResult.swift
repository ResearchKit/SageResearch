//
//  RSDNavigationResult.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// A result that can be used to track a custom navigation as a result of user action.
public protocol RSDNavigationResult : ResultData {
    
    /// The identifier for the step to go to following this result. If non-nil, then this will be used in
    /// navigation handling.
    var skipToIdentifier: String? { get set }
}
