//
//  RSDConditionalStepNavigator.swift
//  Research
//
//  Copyright © 2016-2018 Sage Bionetworks. All rights reserved.
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

/// Define the navigation rule as a protocol to allow for protocol-oriented extension (multiple
/// inheritance). Currently defined usage is to allow the `RSDConditionalStepNavigator` to check if a
/// step has a navigation rule and apply as necessary.
public protocol RSDNavigationRule : RSDStep {
    
    /// Identifier for the next step to navigate to based on the current task result and the conditional
    /// rule associated with this task.
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - conditionalRule:  The conditional rule associated with this task.
    ///     - isPeeking:        Is this navigation rule being called on a result for a step that is navigating
    ///                         forward or is it a step navigator that is peeking at the next step to set up UI
    ///                         display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step.
    func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?, isPeeking: Bool) -> String?
}

/// A navigation skip rule applies to this step to allow the step to be skipped.
public protocol RSDNavigationSkipRule : RSDStep {
    
    /// Should this step be skipped based on the current task result and the conditional rule associated
    /// with this task?
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - conditionalRule:  The conditional rule associated with this task.
    ///     - isPeeking:        Is this navigation rule being called on a result for a step that is navigating
    ///                         forward or is it a step navigator that is peeking at the next step to set up UI
    ///                         display? If peeking at the next step then this parameter will be `true`.
    /// - returns: `true` if the step should be skipped, otherwise `no`.
    func shouldSkipStep(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?, isPeeking: Bool) -> Bool
}

/// A navigation back rule applies to this step to block backward navigation.
public protocol RSDNavigationBackRule : RSDStep {
    
    /// Should this step show a back button to allow backward navigation?
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - conditionalRule:  The conditional rule associated with this task.
    /// - returns: `true` if the backward navigation is allowed, otherwise `no`.
    func allowsBackNavigation(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?) -> Bool
}

/// A conditional rule is appended to the navigable task to check a secondary source for whether or not
/// the step should be displayed.
///
/// - seealso: `RSDCohortRule`
public protocol RSDConditionalRule {
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// If *only* this step should be skipped, then return `RSDIdentifier.nextStep`. If the section should
    /// be skipped then return `RSDIdentifier.nextSection`.
    ///
    /// - parameters:
    ///     - step:      The step about to be displayed.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step to display.
    func skipToStepIdentifier(before step: RSDStep, with result: RSDTaskResult?, isPeeking: Bool) -> String?
    
    /// Asks the conditional rule what the identifier is for the next step to display after the given step
    /// is displayed.
    ///
    /// - parameters:
    ///     - step:      The step that just finished.
    ///     - result:    The current task result.
    ///     - isPeeking: Is this navigation rule being called on a result for a step that is navigating
    ///                  forward or is it a step navigator that is peeking at the next step to set up UI
    ///                  display? If peeking at the next step then this parameter will be `true`.
    /// - returns: The identifier of the next step.
    func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?, isPeeking: Bool) -> String?
}

/// A conditional **replacement** rule is a conditional rule that needs to replace a given step with a
/// different instance of a step under a set of conditions determined by the rule.
///
/// - note: `Research` does not currently implement any conditional replacement rule objects. The
///  replacement rule is included here for future implementation of data tracking across runs of a task.
///  (syoung 02/21/2018)
public protocol RSDConditionalReplacementRule : RSDConditionalRule {
    
    /// Allows the conditional rule to mutate or replace the step that the navigation rules determine
    /// should be the return step. This rule should return the original step if no replacement is
    /// required. Returning `nil` indicates that the task should end.
    ///
    /// - parameters:
    ///     - step:     The step that navigation has opted to return.
    ///     - result:   The current task result.
    /// - returns: The actual step to move to. If no action, then `step` should be returned.
    func replacementStep(for step:RSDStep?, with result: RSDTaskResult?) -> RSDStep?
}

/// A tracking rule is used to track changes that are applied during a task that should be saved at the
/// end of the the overall task. By definition, these rules can mutate and should be handled using
/// pointers rather than using structs.
public protocol RSDTrackingRule : class, RSDConditionalRule {
}

/// Implementation of a step navigator that will apply conditions and navigation based on the steps,
/// navigation rules, and conditional rules associated with this navigator.
public protocol RSDConditionalStepNavigator : RSDStepNavigator, RSDStepValidator {
    
    /// An ordered list of steps to run for this task.
    var steps : [RSDStep] { get }
    
    /// A conditional rule to optionally associate with this step navigator.
    var conditionalRule : RSDConditionalRule? { get }
    
    /// A list of step markers to use for calculating progress. If defined, progress is calculated
    /// counting only those steps that are included in the progress markers rather than inspecting the
    /// step array.
    var progressMarkers : [String]? { get }
}

/// Extend the conditional step navigator to implement the step navigation using the ordered list of
/// steps and the conditional rule.
extension RSDConditionalStepNavigator {
    
    /// Returns the step associated with a given identifier.
    /// - parameter identifier:  The identifier for the step.
    /// - returns: The step with this identifier or nil if not found.
    public func step(with identifier: String) -> RSDStep? {
        return self.steps.first(where: { $0.identifier == identifier })
    }
    
    private func _checkConditionalRules(after previousStep: RSDStep?, with result: RSDTaskResult, isPeeking: Bool) -> String? {
        for rule in RSDFactory.shared.trackingRules {
            if let nextStepId = rule.nextStepIdentifier(after: previousStep, with: result, isPeeking: isPeeking) {
                return nextStepId
            }
        }
        return self.conditionalRule?.nextStepIdentifier(after: previousStep, with: result, isPeeking: isPeeking)
    }
    
    private func _checkConditionalSkipRules(before returnStep: RSDStep?, with result: RSDTaskResult, isPeeking: Bool) -> String? {
        guard let returnStep = returnStep else { return nil }
        for rule in RSDFactory.shared.trackingRules {
            if let nextStepId = rule.skipToStepIdentifier(before: returnStep, with: result, isPeeking: isPeeking) {
                return nextStepId
            }
        }
        return conditionalRule?.skipToStepIdentifier(before: returnStep, with: result, isPeeking: isPeeking)
    }
    
    private func _nextStepIdentifier(with parentResult: RSDTaskResult, isPeeking: Bool) -> String? {
        guard let sectionStep = self as? RSDStep,
              let taskResult = parentResult.findResult(for: sectionStep) as? RSDTaskResult,
              let lastResult = taskResult.stepHistory.last,
              let previousStep = self.step(with: lastResult.identifier)
              else {
                return nil
        }
        return _nextStepIdentifier(after: previousStep, with: taskResult, isPeeking: isPeeking)
    }
    
    private func _nextStepIdentifier(after previousStep: RSDStep?, with result: RSDTaskResult, isPeeking: Bool) -> String? {
        // If this is a step that conforms to RSDConditionalStepNavigator and the next step is non-nil,
        // then return this as the next step identifier
        if let sectionStep = previousStep as? RSDConditionalStepNavigator,
           let nextStepIdentifer = sectionStep._nextStepIdentifier(with: result, isPeeking: isPeeking) {
            return nextStepIdentifer
        }
        else if let navigableStep = previousStep as? RSDNavigationRule,
                let nextStepIdentifier = navigableStep.nextStepIdentifier(with: result, conditionalRule: conditionalRule, isPeeking: isPeeking) {
            // If this is a step that conforms to the RSDNavigationRule protocol and the next step is non-nil,
            // then return this as the next step identifier
            return nextStepIdentifier
        }
        else {
            // Check the conditional rule for a next step identifier
            return _checkConditionalRules(after: previousStep, with: result, isPeeking: isPeeking)
        }
    }
    
    /// Should the task exit early from the entire task?
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should exit.
    public func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        guard let nextIdentifier = _nextStepIdentifier(after: step, with: result, isPeeking: false)
            else {
                return false
        }
        return nextIdentifier == RSDIdentifier.exit
    }
    
    /// Given the current task result, is there a step after the current step?
    ///
    /// This method is checked when first displaying a step to determine if the UI should display
    /// this as the last step. By default, the UI defined in ResearchUI will change the text
    /// on the continue button from "Next" to "Done", unless customized.
    ///
    /// - note: the task result may or may not include a result for the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a next button.
    public func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        var temp = result
        return _step(after: step, with: &temp, isPeeking: true)?.step != nil
    }

    /// Given the current task result, is there a step before the current step?
    ///
    /// This method is checked when first displaying a step to determine if the UI should display
    /// this as the first step. By default, the UI defined in ResearchUI will hide the "Back"
    /// button if there is no step before the given step.
    ///
    /// - note: the task result may or may not include a result for the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: `true` if the task view controller should show a back button.
    public func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool {
        var temp = result
        return self.step(before: step, with: &temp) != nil
    }
    
    /// Return the step to go to after completing the given step.
    ///
    /// - parameters:
    ///     - step:    The previous step or nil if this is the first step.
    ///     - result:  The current result set for this task.
    /// - returns: The next step to display or nil if this is the end of the task.
    public func step(after step: RSDStep?, with result: inout RSDTaskResult) -> (step: RSDStep?, direction: RSDStepDirection) {
        guard let ret = _step(after: step, with: &result, isPeeking: false) else { return (nil, .forward) }
        return ret
    }
    
    private func _step(after step: RSDStep?, with result: inout RSDTaskResult, isPeeking: Bool) -> (step: RSDStep?, direction: RSDStepDirection)? {
        
        var returnStep: RSDStep?
        var stepDirection: RSDStepDirection = .forward
        var previousStep: RSDStep? = step
        var shouldSkip = false
        
        repeat {
            
            if let nextIdentifier = _nextStepIdentifier(after: previousStep, with: result, isPeeking: isPeeking) {
                if nextIdentifier == RSDIdentifier.exit {
                    // If the next identifier equals "exit" then exit the task
                    return nil
                }
                else {
                    // Since the conditional step navigator uses an ordered array of steps to determine the
                    // step order, *if* the result set includes the next step identifier, then the navigation
                    // must actually be going back to a previous step. This should only be applied to the case
                    // where skip and next navigation rules are being applied. syoung 04/12/2018
                    if result.findResult(with: nextIdentifier) != nil {
                        stepDirection = .reverse
                    }
                    returnStep = self.step(with: nextIdentifier)
                }
            }
            else if let previousIdentifier = previousStep?.identifier {
                // If we've dropped through without setting the return step to something non-nil
                // then look for the next step.
                returnStep = steps.rsd_next(after: {$0.identifier == previousIdentifier})
            }
            else {
                returnStep = steps.first
            }
            
            shouldSkip = false
            if let nextId = _checkConditionalSkipRules(before: returnStep, with: result, isPeeking: isPeeking) {
                if nextId == RSDIdentifier.nextStep {
                    shouldSkip = true
                } else {
                    returnStep = steps.rsd_next(after: {$0.identifier == nextId})
                }
            }
            if !shouldSkip, (returnStep != nil), let navigationSkipStep = returnStep as? RSDNavigationSkipRule {
                shouldSkip = navigationSkipStep.shouldSkipStep(with: result, conditionalRule: conditionalRule, isPeeking: isPeeking)
            }
            if (shouldSkip) {
                previousStep = returnStep
            }
            
        } while (shouldSkip)
            
        // If there is a conditionalRule, then check to see if the step should be mutated or replaced.
        if let conditionalRule = self.conditionalRule as? RSDConditionalReplacementRule {
            returnStep = conditionalRule.replacementStep(for: returnStep, with: result)
        }
        
        return (returnStep, stepDirection)
    }
    
    /// Return the step to go to before the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: The previous step or nil if the task does not support backward navigation or this is the first step.
    public func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep? {
        
        // Check if this step does not allow backwards navigation.
        if let navRule = step as? RSDNavigationBackRule, !navRule.allowsBackNavigation(with: result, conditionalRule: conditionalRule) {
            return nil
        }
        
        // First look in the step history for the step result that matches this one. If not found, then
        // check the list of steps.
        guard let beforeResult = result.stepHistory.rsd_previous(before: {$0.identifier == step.identifier}),
            let beforeStep = self.step(with: beforeResult.identifier)
            else {
            return self.steps.rsd_previous(before: {$0.identifier == step.identifier})
        }
        
        return beforeStep
    }
    
    /// Return the progress through the task for a given step with the current result.
    ///
    /// - parameters:
    ///     - step:         The current step.
    ///     - result:       The current result set for this task.
    /// - returns:
    ///     - current:      The current progress. This indicates progress within the task.
    ///     - total:        The total number of steps.
    ///     - isEstimated:  Whether or not the progress is an estimate (if the task has variable navigation)
    public func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)? {
        if let markers = self.progressMarkers {
            // Get the list of steps that have been shown and add the step under test in case this is
            // called before that step is added to the step history.
            guard let stepHistory = result?.stepHistory.map({ $0.identifier }) else { return nil }
            var stepList = stepHistory
            stepList.append(step.identifier)

            // Look for last index into the markers where the step has been displayed.
            guard let idx = markers.lastIndex(where: { stepList.contains($0) })
                else {
                    return nil
            }
            
            let current = idx + 1
            if current == markers.count, !markers.contains(step.identifier) {
                // If this is the last step in the list of markers and we are beyond that step,
                // then return nil
                return nil
            } else {
                // Otherwise, this is a step included in the list of markers so return the
                // progress based on this step.
                return (current, markers.count, false)
            }
        }
        else {
            // Look at the total number of steps and the result.
            let resultSet = Set(result?.stepHistory.map({ $0.identifier }) ?? [])
            let stepSet = Set(steps.map({ $0.identifier }))
            let total = stepSet.union(resultSet).count
            let current = resultSet.subtracting([step.identifier]).count
            return (current + 1, total, true)
        }
    }
}
