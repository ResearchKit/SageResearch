//
//  RSDNavigableTask.swift
//  ResearchSuite
//
//  Copyright © 2016-2017 Sage Bionetworks. All rights reserved.
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

/**
 Define the navigation rule as a protocol to allow for protocol-oriented extention (multiple inheritance).
 Currently defined usage is to allow the SBANavigableOrderedTask to check if a step has a navigation rule.
 */
public protocol RSDNavigationRule : RSDStep {
    
    /**
     Identifier for the next step to navigate to based on the current task result and the conditional rule associated with this task.
     
     @param result              The current task result.
     @param conditionalRule     The conditional rule associated with this task.
     
     @return                    The identifier of the next step.
     */
    func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?) -> String?
}

/**
 A navigation skip rule applies to this step to allow that step to be skipped.
 */
public protocol RSDNavigationSkipRule : RSDStep {
    
    /**
     Should this step be skipped based on the current task result and the conditional rule associated with this task?
     
     @param result              The current task result.
     @param conditionalRule     The conditional rule associated with this task.
     
     @return                    `true` if the step should be skipped, otherwise `no`.
     */
    func shouldSkipStep(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?) -> Bool
}

/**
 A navigation back rule applies to this step to block backward navigation.
 */
public protocol RSDNavigationBackRule : RSDStep {
    
    /**
     Should this step show a back button to allow backward navigation?
     
     @param result              The current task result.
     @param conditionalRule     The conditional rule associated with this task.
     
     @return                    `true` if the backward navigation is allowed, otherwise `no`.
     */
    func allowsBackNavigation(with result: RSDTaskResult?, conditionalRule : RSDConditionalRule?) -> Bool
}

/**
 A conditional rule is appended to the navigable task to check a secondary source for whether or not the
 step should be displayed.
 */
public protocol RSDConditionalRule {
    
    /**
     Should the given step be skipped, based on the current result set?

     @param step                The step about to be displayed.
     @param result              The current task result.
     
     @return                    `true` if the step should be skipped, otherwise `no`.
     */
    func shouldSkip(step: RSDStep, with result: RSDTaskResult?) -> Bool
    
    /**
     Asks the conditional rule what the next identifier is for the step to display after the previous step.
     
     @param step        The step that just finished.
     @param result      The current task result.
     
     @return            The identifier of the next step.
     */
    func nextStepIdentifier(after step: RSDStep?, with result: RSDTaskResult?) -> String?
    
    /**
     Allows the conditional rule to mutate or replace the step that the navigation rules determine should be the return step.
     
     @param step    The step that navigation has opted to return.
     @param result  The current task result.
     
     @return        The actual step to move to. If no action, then `step` should be returned.
     */
    func replacementStep(for step:RSDStep?, with result: RSDTaskResult?) -> RSDStep?
}

/**
 Implementation of a step navigator that will apply conditions and navigation based on the steps, navigation rules and conditional rules associated with this navigator.
 */
public protocol RSDConditionalStepNavigator : RSDStepNavigator {
    
    /**
     An ordered list of steps to run for this task.
     */
    var steps : [RSDStep] { get }
    
    /**
     A conditional rule to optionally associate with this step navigator.
     */
    var conditionalRule : RSDConditionalRule? { get }
}

extension RSDConditionalStepNavigator {
    
    // MARK: Convenience methods
    
    /**
     Steps must have unique identifiers and each step within the collection must be valid.
     */
    public func stepValidation() throws {
        let stepIds = steps.map { $0.identifier }
        let uniqueIds = Set(stepIds)
        guard stepIds.count == uniqueIds.count
            else {
                throw RSDValidationError.notUniqueIdentifiers("Step identifiers: \(stepIds.joined(separator: ","))")
        }
        
        for step in steps {
            try step.validate()
        }
    }
    
    
    // MARK: RSDStepNavigator
    
    public func step(with identifier: String) -> RSDStep? {
        return self.steps.first(where: { $0.identifier == identifier })
    }
    
    public func step(after step: RSDStep?, with result: RSDTaskResult?) -> RSDStep? {
        
        var returnStep: RSDStep?
        var previousStep: RSDStep? = step
        var shouldSkip = false
        
        repeat {
            
            let nextStepIdentifier: String? = {
                guard let navigableStep = previousStep as? RSDNavigationRule,
                    let nextStepIdentifier = navigableStep.nextStepIdentifier(with: result, conditionalRule: conditionalRule)
                    else {
                        // Check the conditional rule for a next step identifier
                        return conditionalRule?.nextStepIdentifier(after: previousStep, with: result)
                }
                // If this is a step that conforms to the RSDNavigationRule protocol and the next step is non-nil,
                // then return this as the next step identifier
                return nextStepIdentifier
            }()
            
            if let nextIdentifier = nextStepIdentifier {
                if nextIdentifier == RSDIdentifier.exit {
                    // If the next identifier equals "exit" then exit the task
                    return nil
                }
                else {
                    // Otherwise, get the step with that identifier
                    returnStep = self.step(with: nextIdentifier)
                }
            }
            else if let previousIdentifier = previousStep?.identifier {
                // If we've dropped through without setting the return step to something non-nil
                // then look for the next step.
                returnStep = steps.next(after: {$0.identifier == previousIdentifier})
            }
            
            // Check if this is a skipable step
            shouldSkip = (returnStep != nil) && (conditionalRule?.shouldSkip(step: returnStep!, with: result) ?? false)
            if !shouldSkip, let navigationSkipStep = returnStep as? RSDNavigationSkipRule {
                shouldSkip = navigationSkipStep.shouldSkipStep(with: result, conditionalRule: conditionalRule)
            }
            if (shouldSkip) {
                previousStep = returnStep
            }
            
        } while (shouldSkip)
            
        // If there is a conditionalRule, then check to see if the step should be mutated or replaced.
        if let conditionalRule = self.conditionalRule {
            returnStep = conditionalRule.replacementStep(for: returnStep, with: result)
        }
        
        return returnStep
    }
    
    public func step(before step: RSDStep, with result: RSDTaskResult?) -> RSDStep? {
        
        // Check if this step does not allow backwards navigation.
        if let navRule = step as? RSDNavigationBackRule, !navRule.allowsBackNavigation(with: result, conditionalRule: conditionalRule) {
            return nil
        }
        
        // First look in the step history for the step result that matches this one. If not found, then
        // check the list of steps.
        guard let beforeResult = result?.stepHistory.previous(before: {$0.identifier == step.identifier}),
            let beforeStep = self.step(with: beforeResult.identifier)
            else {
            return self.steps.previous(before: {$0.identifier == step.identifier})
        }
        
        return beforeStep
    }
    
    public func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: UInt, total: UInt, isEstimated: Bool)? {
        
        // Look at the total number of steps and the result. This is estimated if the step index does not match
        // the result step history count.
        let total = UInt(steps.count)
        let current = UInt(result?.stepHistory.count ?? 0)
        let isEstimated: Bool = {
            guard let stepIndex = steps.index(where: { $0.identifier == step.identifier }) else { return true }
            return current != stepIndex
        }()
        
        return (current + 1, total, isEstimated)
    }
}
