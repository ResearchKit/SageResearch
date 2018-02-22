//
//  RSDCohortTrackingRule.swift
//  ResearchSuite
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

/// `RSDCohortAssignmentStep` evaluates a task result and returns the cohorts to apply for a given
/// result.
public protocol RSDCohortAssignmentStep : RSDStep {
    
    /// Evaluate the task result and return the set of cohorts to add and remove.
    /// - parameter result: The task result to evaluate.
    /// - returns: The cohorts to add/remove or `nil` if no rules apply.
    func cohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)?
}

/// List of the rules to apply when navigating based on the currently applied cohorts.
public enum RSDCohortRuleOperator : String, Codable {
    /// Require all the cohorts to match.
    case all
    /// Require any of the cohorts to match.
    case any
}

/// A cohort navigation rule is used by the `RSDCohortTrackingRule` to determine if a step should either
/// be skipped or skip to a step based on the currently applied cohorts.
public protocol RSDCohortNavigationRule {
    
    /// The list of cohorts that are tested for this navigation rule.
    var requiredCohorts : Set<String> { get }
    
    /// What type of operator to apply. If `nil`, then `.all` is assumed.
    var cohortOperator : RSDCohortRuleOperator? { get }
    
    /// Optional skip identifier for this rule.
    ///
    /// If this rule is applied *after* displaying the step, then this will be used as the identifier to
    /// skip to. If `nil` then the skip to identifier will be assumed to be `RSDIdentifier.exit`.
    ///
    /// If this rule is applied *before* displaying the step, then this is the identifier to skip to. If
    /// `nil` then just this step will be skipped.
    var skipToIdentifier : String? { get }
}

/// A cohort navigation step is a step that carries information about navigation rules to apply either
/// before or after displaying this step based on the currently applied cohorts.
public protocol RSDCohortNavigationStep : RSDStep {
    
    /// The navigation cohort rules to apply *before* displaying the step.
    var beforeCohortRules : [RSDCohortNavigationRule]? { get }
    
    /// The navigation cohort rules to apply *after* displaying the step.
    var afterCohortRules : [RSDCohortNavigationRule]? { get }
}

/// A cohort rule can be used to mutate a list of cohorts of which the participant is a member. A cohort
/// is a data group that participants are added to based on the results of survey questions.
open class RSDCohortTrackingRule : RSDTrackingRule, Codable {

    /// The initial cohorts before the task starts.
    public let initialCohorts : Set<String>
    
    /// The current set of cohorts.
    open private(set) var currentCohorts : Set<String>
    
    public init(initialCohorts : Set<String> = []) {
        self.initialCohorts = initialCohorts
        self.currentCohorts = initialCohorts
    }
    
    /// MARK: RSDConditionalRule
    
    /// Check if the step implements `RSDCohortNavigationStep` and apply the before rules for the step to
    /// the current cohorts.
    public func skipToStepIdentifier(before step: RSDStep, with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        guard let cohortStep = step as? RSDCohortNavigationStep, let rules = cohortStep.beforeCohortRules else { return nil }
        return applyRules(rules, isBefore: true)
    }
    
    /// This method is used to test whether or not to mutate the current cohorts. This will look to see
    /// if the step implements the `RSDCohortAssignmentStep` and if so, apply the new cohorts.
    ///
    /// Then it will check if the step implements `RSDCohortNavigationStep` and apply the after rules for
    /// the step to the current cohorts.
    open func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        guard !isPeeking else { return nil }
        
        // Add and remove the subset of new cohorts.
        if let taskResult = result,
            let cohortStep = step as? RSDCohortAssignmentStep,
            let cohorts = cohortStep.cohortsToApply(with: taskResult) {
            self.currentCohorts.formUnion(cohorts.add)
            self.currentCohorts.subtract(cohorts.remove)
        }
        
        guard let cohortStep = step as? RSDCohortNavigationStep, let rules = cohortStep.afterCohortRules else { return nil }
        return applyRules(rules, isBefore: false)
    }
    
    func applyRules(_ rules: [RSDCohortNavigationRule], isBefore: Bool) -> String? {
        for rule in rules {
            // Special-case an empty set for the required cohorts. Rule should not be applied if there
            // are no cohorts to test against.
            guard rule.requiredCohorts.count > 0 else { continue }
            
            // Test the rule for whether or not it should be applied.
            let op = rule.cohortOperator ?? .all
            let shouldSkip: Bool = {
                let intersect = self.currentCohorts.intersection(rule.requiredCohorts)
                switch op {
                case .all:
                    return intersect == rule.requiredCohorts
                case .any:
                    return intersect.count > 0
                }
            }()
            
            // If applicable, then skip to the appropriate next step. The default behavior for this
            // depends upon whether or not the rule is applied before or after displaying the step.
            if shouldSkip {
                return rule.skipToIdentifier ?? (isBefore ? RSDIdentifier.nextStep.stringValue : RSDIdentifier.nextSection.stringValue)
            }
        }
        return nil
    }
}

/// Concrete implementation of the `RSDCohortNavigationRule`.
public struct RSDCohortNavigationRuleObject : RSDCohortNavigationRule, Codable {
    
    /// The list of cohorts that are tested for this navigation rule.
    public let requiredCohorts: Set<String>
    
    /// What type of operator to apply.
    public let cohortOperator: RSDCohortRuleOperator?
    
    /// The identifier for the string to skip to.
    public let skipToIdentifier: String?
    
    private enum CodingKeys : String, CodingKey {
        case requiredCohorts, cohortOperator = "operator", skipToIdentifier
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - requiredCohorts: The list of cohorts that are tested for this navigation rule.
    ///     - cohortOperator: What type of operator to apply.
    ///     - skipToIdentifier: The identifier for the string to skip to.
    public init(requiredCohorts: Set<String>, cohortOperator: RSDCohortRuleOperator?, skipToIdentifier: String?) {
        self.requiredCohorts = requiredCohorts
        self.cohortOperator = cohortOperator
        self.skipToIdentifier = skipToIdentifier
    }
}


// Documentable implementations

extension RSDCohortRuleOperator : RSDDocumentableEnum {
    static func allCodingKeys() -> [String] {
        let allKeys: [RSDCohortRuleOperator] = [.all, .any]
        return allKeys.map { $0.stringValue }
    }
}

extension RSDCohortNavigationRuleObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.requiredCohorts, .cohortOperator, .skipToIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .requiredCohorts:
                if idx != 0 { return false }
            case .cohortOperator:
                if idx != 1 { return false }
            case .skipToIdentifier:
                if idx != 2 { return false }
            }
        }
        return keys.count == 3
    }
    
    static func _examples() -> [RSDCohortNavigationRuleObject] {
        let exampleA = RSDCohortNavigationRuleObject(requiredCohorts: ["foo", "goo"], cohortOperator: nil, skipToIdentifier: nil)
        let exampleB = RSDCohortNavigationRuleObject(requiredCohorts: ["blue", "moo"], cohortOperator: .any, skipToIdentifier: "magoo")
        return [exampleA, exampleB]
    }
    
    static func examples() -> [Encodable] {
        return _examples()
    }
}
