//
//  RSDOrderedStepNavigator.swift
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


/// Implementation of a step navigator that will apply conditions and navigation based on the steps,
/// navigation rules, and conditional rules associated with this navigator.
public protocol RSDOrderedStepNavigator : RSDStepNavigator, RSDStepValidator {
    
    /// An ordered list of steps to run for this task.
    var steps : [RSDStep] { get }
    
    /// A list of step markers to use for calculating progress. If defined, progress is calculated
    /// counting only those steps that are included in the progress markers rather than inspecting the
    /// step array.
    var progressMarkers : [String]? { get }
    
    /// A list of the tracking rules that apply to this navigator.
    var trackingRules : [RSDTrackingRule] { get }
    
    /// The navigation rule (if any) associated with this step.
    func navigationRule(for step: RSDStep) -> RSDNavigationRule?
    
    /// The navigation skip rule (if any) associated with this step.
    func navigationSkipRule(for step: RSDStep) -> RSDNavigationSkipRule?
    
    /// The navigation back rule (if any) associated with this step.
    func navigationBackRule(for step: RSDStep) -> RSDNavigationBackRule?
}


/// Extend the conditional step navigator to implement the step navigation using the ordered list of
/// steps and the conditional rule.
extension RSDOrderedStepNavigator {
    
    /// Returns the step associated with a given identifier.
    /// - parameter identifier:  The identifier for the step.
    /// - returns: The step with this identifier or nil if not found.
    public func step(with identifier: String) -> RSDStep? {
        return self.steps.first(where: { $0.identifier == identifier })
    }
    
    private func _checkConditionalRules(after previousStep: RSDStep?, with result: RSDTaskResult, isPeeking: Bool) -> String? {
        for rule in self.trackingRules {
            if let nextStepId = rule.nextStepIdentifier(after: previousStep, with: result, isPeeking: isPeeking) {
                return nextStepId
            }
        }
        return nil
    }
    
    private func _checkConditionalSkipRules(before returnStep: RSDStep?, with result: RSDTaskResult, isPeeking: Bool) -> String? {
        guard let returnStep = returnStep else { return nil }
        for rule in self.trackingRules {
            if let nextStepId = rule.skipToStepIdentifier(before: returnStep, with: result, isPeeking: isPeeking) {
                return nextStepId
            }
        }
        return nil
    }
    
    private func _nextStepIdentifier(with parentResult: RSDTaskResult, isPeeking: Bool) -> String? {
        guard let sectionStep = self as? RSDStep,
            let taskResult = parentResult.findResult(for: sectionStep) as? RSDTaskResult,
            let lastResult = taskResult.nodePath.last ?? taskResult.stepHistory.last?.identifier,
            let previousStep = self.step(with: lastResult)
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
        else if let navigableStep = previousStep,
            let navigationRule = self.navigationRule(for: navigableStep),
            let nextStepIdentifier = navigationRule.nextStepIdentifier(with: result, isPeeking: isPeeking) {
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
        return _step(before: step, with: result) != nil
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
                    returnStep = steps.rsd_next(after: {$0.identifier == returnStep?.identifier})
                } else {
                    returnStep = steps.first(where: {$0.identifier == nextId})
                }
            }
            if !shouldSkip, (returnStep != nil), let navigationSkipStep = self.navigationSkipRule(for: returnStep!) {
                shouldSkip = navigationSkipStep.shouldSkipStep(with: result, isPeeking: isPeeking)
            }
            if (shouldSkip) {
                previousStep = returnStep
            }
            
        } while (shouldSkip)
        
        return (returnStep, stepDirection)
    }
    
    /// Return the step to go to before the given step.
    ///
    /// - parameters:
    ///     - step:    The current step.
    ///     - result:  The current result set for this task.
    /// - returns: The previous step or nil if the task does not support backward navigation or this is the first step.
    public func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep? {
        return _step(before: step, with: result)
    }
    
    private func _step(before step: RSDStep, with result: RSDTaskResult) -> RSDStep? {
        
        // Check if this step does not allow backwards navigation.
        if let navRule = self.navigationBackRule(for: step), !navRule.allowsBackNavigation(with: result) {
            return nil
        }
        
        let nodePath = result.nodePath.count > 0 ? result.nodePath : result.stepHistory.map { $0.identifier }
        
        guard let pathMarker: String = {
            if let _ = nodePath.last(where: { step.identifier == $0 }) {
                // Look to see if the step being tested is in the step history and if so, look for the step
                // before that step.
                return nodePath.rsd_previous(before: {$0 == step.identifier})
            }
            else {
                // Otherwise, the step being tested is the current step and has not yet been added
                // to the result step so instead return the last result in the history.
                return nodePath.last
            }
        }() else { return nil }
        
        return self.step(with: pathMarker)
    }
    
    /// Return the progress through the task for a given step with the current result.
    ///
    /// - parameters:
    ///     - step:         The current step.
    ///     - result:       The current result set for this task.
    /// - returns:
    ///     - current:      The current progress. This indicates progress within the task.
    ///     - total:        The total number of steps.
    ///     - isEstimated:  Whether or not the progress is an estimate (if the task has variable navigation).
    public func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)? {
        if let markers = self.progressMarkers {
            guard let branchResult = result else { return nil }
            
            // Get the list of steps that have been shown and add the step under test in case this is
            // called before that step is added to the step history.
            var stepList = branchResult.nodePath.count > 0 ? branchResult.nodePath : branchResult.stepHistory.map { $0.identifier }
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
            let resultSet: Set<String> = {
                guard let branchResult = result else { return [] }
                return branchResult.nodePath.count > 0 ?
                    Set(branchResult.nodePath) :
                    Set(branchResult.stepHistory.map { $0.identifier })
            }()
            let stepSet = Set(steps.map({ $0.identifier }))
            let total = stepSet.union(resultSet).count
            let current = resultSet.subtracting([step.identifier]).count
            return (current + 1, total, true)
        }
    }
}

