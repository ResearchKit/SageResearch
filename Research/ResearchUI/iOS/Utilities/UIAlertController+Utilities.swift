//
//  UIAlertController+Utilities.swift
//  ResearchUI
//

import UIKit
import Research

/// Utility for presenting alerts
@objc
public protocol RSDAlertPresenter: NSObjectProtocol {
    
    /// Present a view controller using a modal presentation.
    func presentModal(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}

extension UIViewController: RSDAlertPresenter {
    
    /// Present a view controller using a modal presentation.
    public func presentModal(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        self.present(viewController, animated: animated, completion: completion)
    }
}

public extension RSDAlertPresenter {
    
    /// Present a pop-up alert with only an "OK" button.
    ///
    /// - parameters:
    ///     - title:            The title to display in the popup.
    ///     - message:          The message to display in the popup.
    ///     - actionHandler:    The action handler to call when completed.
    func presentAlertWithOk(title: String?, message: String, actionHandler: ((UIAlertAction) -> Void)?) {
        
        let okAction = UIAlertAction(title:Localization.buttonOK(), style: .default, handler: actionHandler)
        presentAlertWithActions(title: title, message: message, preferredStyle: .alert, actions: [okAction])
    }
    
    /// Present a pop-up alert with a "Yes" and "No" button. The alert will be presented with yes and no buttons.
    /// The handler will be called with `false` if the user selected "No" and `true` if the user selected "Yes".
    ///
    /// - parameters:
    ///     - title:            The title to display in the popup.
    ///     - message:          The message to display in the popup.
    ///     - actionHandler:    The action handler to call when completed.
    func presentAlertWithYesNo(title: String?, message: String, actionHandler: @escaping ((Bool) -> Void)) {
        
        let noAction = UIAlertAction(title: Localization.buttonNo(), style: .default, handler: { _ in
            actionHandler(false)
        })
        let yesAction = UIAlertAction(title: Localization.buttonYes(), style: .default, handler: { _ in
            actionHandler(true)
        })
        
        presentAlertWithActions(title: title, message: message, preferredStyle: .alert, actions: [noAction, yesAction])
    }
    
    /// Present an alert with the provided list of actions.
    ///
    /// - parameters:
    ///     - title:            The title to display in the popup.
    ///     - message:          The message to display in the popup.
    ///     - preferredStyle:   The preferred style of the alert.
    ///     - actions:          The actions to add to the alert controller.
    func presentAlertWithActions(title: String?, message: String, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        self.presentModal(alert, animated: true, completion: nil)
    }
}
