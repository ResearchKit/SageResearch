//
//  RSDIdentifier.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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
        case exit, nextSection, nextStep, abbreviatedInstructions, taskRunCount, taskExitReason
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
