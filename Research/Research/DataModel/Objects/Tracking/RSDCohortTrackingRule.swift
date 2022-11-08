//
//  RSDCohortTrackingRule.swift
//  Research
//

import Foundation
import JsonModel

/// A cohort rule can be used to mutate a list of cohorts of which the participant is a member. A cohort
/// is a data group that participants are added to based on the results of survey questions.
@available(*,deprecated, message: "Will be deleted in a future version.")
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
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDCohortNavigationRuleObject : RSDCohortNavigationRule, Codable {
    
    /// The list of cohorts that are tested for this navigation rule.
    public let requiredCohorts: Set<String>
    
    /// What type of operator to apply.
    public let cohortOperator: RSDCohortRuleOperator?
    
    /// The identifier for the string to skip to.
    public let skipToIdentifier: String?
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
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

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDCohortRuleOperator : DocumentableStringEnum, StringEnumSet {
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDCohortNavigationRuleObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }

    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .requiredCohorts
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .requiredCohorts:
            return .init(propertyType: .primitiveArray(.string))
        case .cohortOperator:
            return .init(propertyType: .reference(RSDCohortRuleOperator.documentableType()))
        case .skipToIdentifier:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func examples() -> [RSDCohortNavigationRuleObject] {
        let exampleA = RSDCohortNavigationRuleObject(requiredCohorts: ["foo", "goo"], cohortOperator: nil, skipToIdentifier: nil)
        let exampleB = RSDCohortNavigationRuleObject(requiredCohorts: ["blue", "moo"], cohortOperator: .any, skipToIdentifier: "magoo")
        return [exampleA, exampleB]
    }
}
