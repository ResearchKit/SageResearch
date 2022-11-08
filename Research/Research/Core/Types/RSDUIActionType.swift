//
//  RSDUIActionType.swift
//  Research
//

import Foundation
import JsonModel

/// The `RSDUIActionType` enum describes standard navigation actions that are common to a
/// given UI step. It is extendable using the custom field.
public enum RSDUIActionType {
    
    /// Standard navigation elements that are common to most steps.
    case navigation(Navigation)
    
    /// Standard navigation elements that are common to most steps.
    public enum Navigation : String, CaseIterable {
        
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
        
        /// Go back in the navigation to review the instructions.
        case reviewInstructions
        
        /// Abandon running the Assessment. This is similar to a "cancel" action, but where that
        /// action assumes that the participant will "come back and do it later", the "abandon"
        /// action suggests that Assessment should be considered "done" for the purposes of the
        /// protocol.
        ///
        /// While typically, this type of navigation is handled by having the `RSDStepNavigator`
        /// send the participant down a path where you, perhaps, ask them why they want to quit,
        /// and then add those screens to the step history, this allows a button callback to
        /// the `RSDStepViewModel` with no UI/UX for those assessment creators who want to force
        /// quit without allowing the navigator to influence the results. syoung 11/25/2020
        case abandonAssessment
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

extension RSDUIActionType: RawRepresentable, Codable, Hashable {
    
    public init(rawValue: String) {
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

extension RSDUIActionType : ExpressibleByStringLiteral {
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

extension RSDUIActionType : DocumentableStringEnum {
    public static func allValues() -> [String] {
        Navigation.allCases.map { $0.rawValue }
    }
}
