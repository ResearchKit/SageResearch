//
//  RSDUIActionHandler.swift
//  Research
//

import Foundation


/// `RSDUIActionHandler` implements the custom actions of the step.
public protocol RSDUIActionHandler {
    
    /// Customizable actions to return for a given action type. The `RSDStepController` can use these to
    /// customize the display of buttons to the user. If nil, `shouldHideAction()` will be called to
    /// determine if the default action should be used or if the action button should be hidden.
    ///
    /// - parameters:
    ///     - actionType:  The action type for the button.
    ///     - step:        The step that the action is on.
    /// - returns: A custom UI action for this button. If nil, the default action will be used.
    func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction?
    
    /// Should the action button be hidden?
    ///
    /// - parameters:
    ///     - actionType:  The action type for the button.
    ///     - step:        The step that the action is on.
    /// - returns: Whether or not the button should be hidden or `nil` if there is no explicit action.
    func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool?
}
