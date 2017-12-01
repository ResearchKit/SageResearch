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


/// The `RSDUIAction` protocol can be used to customize the title and image displayed for a
/// given action of the UI.
///
/// - seealso: `RSDUIActionType` and `RSDUIActionHandler`
public protocol RSDUIAction : Codable {
    
    /// The title to display on the button associated with this action.
    var buttonTitle: String? { get }
    
    /// The icon to display on the button associated with this action.
    var buttonIcon: UIImage? { get }
}

/// `RSDWebViewUIAction` implements an extension of the base protocol where the action includes a pointer
/// to a url that can display in a webview. The url can either be fully qualified or optionally point to
/// an embedded resource. The resource bundle is assumed to be the main bundle if the `bundleIdentifier`
/// property is `nil`.
public protocol RSDWebViewUIAction : RSDUIAction, RSDResourceTransformer {
    
    /// The url to load in the webview. If this is not a fully qualified url string, then it is assumed to refer
    /// to an embedded resource.
    var url: String { get }
}

/// `RSDSkipToUIAction` implements an extension of the base protocol where the action includes an identifier for
/// a step to skip to if this action is called. This is used by the `RSDConditionalStepNavigator` to navigate
/// based on a `nil` result.
/// - seealso: `RSDSurveyNavigationStep`
public protocol RSDSkipToUIAction : RSDUIAction {
    
    /// The identifier for the step to skip to if the action is called.
    var skipToIdentifier: String { get }
}


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


/// The `RSDUIActionType` enum describes standard navigation actions that are common to a
/// given UI step. It is extendable using the custom field.
///
public enum RSDUIActionType {
    
    /// Standard navigation elements that are common to most steps.
    case navigation(Navigation)
    
    /// Standard navigation elements that are common to most steps.
    public enum Navigation : String {
        
        /// Navigate to the next step.
        case goForward
        
        /// Navigate to the previous step.
        case goBackward
        
        /// Skip the step and immediately go forward.
        case skip
        
        /// Cancel the task.
        case cancel
        
        /// Display additional information about the step.
        case learnMore
    }
    
    /// A custom action on the step. Must be handled by the app.
    case custom(String)
    
    /// The string for the custom action (if applicable).
    public var customAction: String? {
        if case .custom(let str) = self {
            return str
        } else {
            return nil
        }
    }
}

extension RSDUIActionType: RawRepresentable, Codable {
    public typealias RawValue = String
    
    public init(rawValue: RawValue) {
        if let subtype = Navigation(rawValue: rawValue) {
            self = .navigation(subtype)
        }
        else {
            self = .custom(rawValue)
        }
    }
    
    public var rawValue: String {
        switch (self) {
        case .navigation(let value):
            return value.rawValue
            
        case .custom(let value):
            return value
        }
    }
}

extension RSDUIActionType : Equatable {
    public static func ==(lhs: RSDUIActionType, rhs: RSDUIActionType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDUIActionType) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDUIActionType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDUIActionType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDUIActionType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDUIActionType : CodingKey {
    public var stringValue: String {
        return self.rawValue
    }
    
    public init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
    public var intValue: Int? {
        return nil
    }
    
    public init?(intValue: Int) {
        return nil
    }
}
