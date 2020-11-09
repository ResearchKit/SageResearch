//
//  UIAlertController+Utilities.swift
//  ResearchUI
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
