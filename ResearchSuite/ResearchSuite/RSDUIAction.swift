//
//  RSDUIAction.swift
//  ResearchSuite
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
import UIKit

/**
 The `RSDUIAction` protocol can be used to customize the title and image displayed for a 
 given action of the UI.
 */
public protocol RSDUIAction : Codable {
    
    /**
     The title to display on the button associated with this action.
     */
    var buttonTitle: String? { get }
    
    /**
     The icon to display on the button associated with this action.
     */
    var buttonIcon: UIImage? { get }
}

/**
 `RSDWebViewUIAction` implements an extension of the base protocol where the action includes a pointer to a url that can display in a webview. The url can either be fully qualified or optionally point to an embedded resource. The resource bundle is assumed to be the main bundle if the `resourceBundle` property is `nil`.
 */
public protocol RSDWebViewUIAction : RSDUIAction {
    
    /**
     The url to load in the webview. If this is not a fully qualified url string, then it is assumed to refer to an embedded resource.
     */
    var url: String { get }
    
    /**
     The bundle identifier for the embedded resource.
     */
    var resourceBundle: String? { get }
}

/**
 `RSDSkipToUIAction` implements an extension of the base protocol where the action includes an identifier for a step to skip to if this action is called.
 */
public protocol RSDSkipToUIAction : RSDUIAction {
    
    /**
     The identifier for the step to skip to if the action is called.
     */
    var skipToIdentifier: String { get }
}


/**
 The action handler implements the custom actions of the step.
 */
public protocol RSDUIActionHandler {
    
    /**
     Customizable actions to return for a given action type. The `RSDStepController` can use these to customize the display of buttons to the user. If nil, `shouldHideAction()` will be called to determine if the default action should be used or if the action button should be hidden.
     
     @param actionType  The action type for the button.
     @param step        The step that the action is on.
     
     @return            A custom UI action for this button. If nil, the default action will be used.
     */
    func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction?
    
    /**
     Should the action button be hidden?
     
     @param actionType  The action type for the button.
     @param step        The step that the action is on.
     
     @return            Whether or not the button should be hidden or `nil` if there is no explicit action.
     */
    func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool?
}
