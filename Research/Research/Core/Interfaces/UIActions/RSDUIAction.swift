//
//  RSDUIAction.swift
//  Research
//

import Foundation
import JsonModel

/// The `RSDUIAction` protocol can be used to customize the title and image displayed for a
/// given action of the UI.
///
/// - seealso: `RSDUIActionType` and `RSDUIActionHandler`
public protocol RSDUIAction : ResourceInfo {
    
    /// The title to display on the button associated with this action.
    var buttonTitle: String? { get }
    
        /// The name of the icon to display on the button associated with this action.
    var iconName: String? { get }
}

