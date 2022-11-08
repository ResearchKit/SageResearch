//
//  RSDIdentifier.swift
//  Research
//

import Foundation
import JsonModel


/// `RSDIdentifier` is intended to allow a developer to define constants for the identifiers
/// that are used to define the tasks, steps, input fields, and async actions associated with
/// a given task or task group.
public struct RSDIdentifier : RawRepresentable, Codable, Hashable {    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    enum RestrictedIdentifiers : String, Codable, CaseIterable {
        case exit, nextSection, nextStep, abbreviatedInstructions, taskRunCount, taskExitReason, abandonAssessment
    }
    
    /// Exit the activity.
    public static let exit = RestrictedIdentifiers.exit.identifierValue
    
    /// Continue to the next section.
    public static let nextSection = RestrictedIdentifiers.nextSection.identifierValue
    
    /// Continue to the next step.
    public static let nextStep = RestrictedIdentifiers.nextStep.identifierValue
    
    /// Identifier for a result that indicates the number of times the task has been run.
    public static let taskRunCount = RestrictedIdentifiers.taskRunCount.identifierValue
    
    /// Identifier for a result that indicates the reason why a task was exited.
    public static let taskExitReason = RestrictedIdentifiers.taskRunCount.identifierValue
    
    /// Identifier for a special flag that indicates that the assessment should be abandoned.
    public static let abandonAssessment = RestrictedIdentifiers.abandonAssessment.identifierValue
    
    public static func allGlobalIdentifiers() -> [RSDIdentifier] {
        return RestrictedIdentifiers.allCases.map { $0.identifierValue }
    }
}

extension RawRepresentable where Self.RawValue == String {
    
    public var identifierValue: RSDIdentifier {
        return RSDIdentifier(rawValue: self.rawValue)
    }
}

extension RSDIdentifier : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDIdentifier : Equatable {
    public static func ==(lhs: RSDIdentifier, rhs: RSDIdentifier) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDIdentifier) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: String?, rhs: RSDIdentifier) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDIdentifier, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
    public static func ==(lhs: RSDIdentifier, rhs: String?) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDIdentifier : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allGlobalIdentifiers().map{ $0.rawValue }
    }
}
