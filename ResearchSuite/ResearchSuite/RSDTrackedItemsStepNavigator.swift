//
//  RSDTrackedItemsStepNavigator.swift
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

/// `RSDTrackedItemsStepNavigator` is a general-purpose navigator designed to be used for selecting tracked
/// data such as medication, triggers or symptoms.
open class RSDTrackedItemsStepNavigator : Decodable, RSDStepNavigator {
    
    /// Publicly accessible coding keys for the default structure for decoding items and sections.
    public enum ItemsCodingKeys : String, CodingKey {
        case items, sections
    }
    
    /// Publicly accessible coding keys for the steps used by this navigator.
    public enum StepIdentifiers : String, CodingKey {
        case selection, review, addDetails, logging
    }
    
    /// The list of medications.
    public var items: [RSDTrackedItem] {
        return self.selectionStep.items
    }
    
    /// The section items for mapping each medication.
    public var sections: [RSDTrackedSection]? {
        return self.selectionStep.sections
    }
    
    /// A previous result that can be used to pre-populate the data set.
    public var previousResult: RSDTrackedItemsResult? {
        didSet {
            // If the previous result is set to a non-nil value then use that as the in-memory result.
            if let result = self.previousResult {
                _inMemoryResult = result
            }
        }
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - items: The list of medications.
    ///     - sections: The section items for mapping each medication.
    public init(items: [RSDTrackedItem], sections: [RSDTrackedSection]? = nil) {
        self.selectionStep = type(of: self).buildSelectionStep(items: items, sections: sections)
        self.reviewStep = type(of: self).buildReviewStep(items: items, sections: sections)
        self.detailStepTemplates = type(of: self).buildDetailSteps(items: items, sections: sections)
        self.loggingStep = type(of: self).buildLoggingStep(items: items, sections: sections)
    }
    
    // MARK: Decodable
    
    /// Decoding uses the default steps from the class build functions, and then overwrites
    /// properties found in the decoder. Currently, this assumes that the steps inherit from
    /// `RSDUIStepObject`
    public required init(from decoder: Decoder) throws {
        let (items, sections) = try type(of: self).decodeItems(from: decoder)
        
        let container = try decoder.container(keyedBy: StepIdentifiers.self)
        
        let selectionStep = type(of: self).buildSelectionStep(items: items, sections: sections)
        if let step = selectionStep as? RSDDecodableReplacement, container.contains(.selection)  {
            let nestedDecoder = try container.superDecoder(forKey: .selection)
            try step.decode(from: nestedDecoder)
        }
        
        let reviewStep = type(of: self).buildReviewStep(items: items, sections: sections)
        if let step = reviewStep as? RSDDecodableReplacement, container.contains(.review)  {
            let nestedDecoder = try container.superDecoder(forKey: .review)
            try step.decode(from: nestedDecoder)
        }
        
        let detailStepTemplates = type(of: self).buildDetailSteps(items: items, sections: sections)
        if let step = detailStepTemplates?.first as? RSDDecodableReplacement, container.contains(.addDetails) {
            let nestedDecoder = try container.superDecoder(forKey: .addDetails)
            try step.decode(from: nestedDecoder)
        }
        
        var loggingStep = type(of: self).buildLoggingStep(items: items, sections: sections)
        if container.contains(.logging) {
            /// If there isn't a class override, but the decoder includes a logging step, then include one here.
            let step: RSDDecodableReplacement
            if let dStep = loggingStep as? RSDDecodableReplacement {
                step = dStep
            } else {
                loggingStep = RSDTrackedItemsLoggingStepObject(identifier: StepIdentifiers.logging.stringValue, items: items, sections: sections, type: .logging)
                step = loggingStep as! RSDDecodableReplacement
            }
            let nestedDecoder = try container.superDecoder(forKey: .logging)
            try step.decode(from: nestedDecoder)
        }
        
        self.selectionStep = selectionStep
        self.reviewStep = reviewStep
        self.detailStepTemplates = detailStepTemplates
        self.loggingStep = loggingStep
    }
    
    open class func decodeItems(from decoder: Decoder) throws -> (items: [RSDTrackedItem], sections: [RSDTrackedSection]?) {
        let container = try decoder.container(keyedBy: ItemsCodingKeys.self)
        let items = try container.decode([RSDTrackedItemObject].self, forKey: .items)
        let sections = try container.decodeIfPresent([RSDTrackedSectionObject].self, forKey: .sections)
        return (items, sections)
    }
    
    // MARK: Step management
    
    /// The selection step to use to model selecting the medication.
    public let selectionStep: RSDTrackedItemsStep
    
    /// The review step to display when reviewing/editing selected medication.
    public let reviewStep: RSDTrackedItemsStep?
    
    /// The detail step should be displayed for each tracked item that has additional details.
    public let detailStepTemplates: [RSDTrackedItemDetailsStep]?
    
    /// A step to display in order to log details for a set of tracked data. For example, as well
    /// as logging a user's medication, the researchers may wish to log whether or not the participant
    /// took the medication when scheduled to do so.
    public let loggingStep: RSDTrackedItemsStep?
    
    /// Build the selection step for this tracked data collection. Override to customize the step.
    open class func buildSelectionStep(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> RSDTrackedItemsStep {
        let stepId = StepIdentifiers.selection.stringValue
        let step = RSDTrackedSelectionStepObject(identifier: stepId, items: items, sections: sections)
        return step
    }
    
    /// Build the review step for this tracked data collection. Override to customize the step.
    open class func buildReviewStep(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> RSDTrackedItemsStep? {
        return nil
    }
    
    /// Build the add details steps for this tracked data collection. Override to customize the steps.
    open class func buildDetailSteps(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> [RSDTrackedItemDetailsStep]? {
        return nil
    }
    
    /// Build the logging step for this tracked data collection. Override to customize the steps.
    open class func buildLoggingStep(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> RSDTrackedItemsStep? {
        return nil
    }
    
    // MARK: Result management
    
    /// The in-memory result is the stored result that is used to set the current state before
    /// displaying any steps.
    private var _inMemoryResult: RSDTrackedItemsResult!
    
    /// Updates the in-memory result that is used to track the selection state.
    ///
    /// - parameters:
    ///     - taskResult: The current task result.
    ///     - previousStep: The previous step that was displayed and is triggering calling this function
    func updateInMemoryResult(from taskResult: RSDTaskResult, using previousStep: RSDStep?) {
        
        // Check that the in-memory result has been instantiated and do so if necessary.
        if _inMemoryResult == nil {
            _inMemoryResult = self.previousResult ?? self.instantiateReviewResult()
        }
        
        if previousStep?.identifier == self.selectionStep.identifier {
            let selectedIdentifiers = (taskResult.findResult(for: self.selectionStep) as? RSDTrackedItemsResult)?.selectedIdentifiers
            _inMemoryResult.updateSelected(to: selectedIdentifiers, with: self.items)
        }
        else if let reviewStep = self.reviewStep, previousStep?.identifier == reviewStep.identifier {
            _inMemoryResult = (taskResult.findResult(for: reviewStep) as? RSDTrackedItemsResult)
        }
        else if let detailsStep = previousStep as? RSDTrackedItemDetailsStep,
            let answer = detailsStep.answer(from: taskResult) {
            _inMemoryResult.updateDetails(to: answer)
        }
    }
    
    /// Instantiate the appropriate review result.
    open func instantiateReviewResult() -> RSDTrackedItemsResult {
        let reviewIdentifier = self.reviewStep?.identifier ?? StepIdentifiers.review.stringValue
        return RSDTrackedItemsResultObject(identifier: reviewIdentifier)
    }
    
    // MARK: Detail step management
    
    private var _detailSteps: [String : RSDStep] = [:]

    /// Find or copy the detail step specific to this identifier.
    open func getDetailStep(with identifier: String) -> (RSDStep, RSDTrackedItemAnswer)? {
        guard let selectedAnswer = _inMemoryResult.selectedAnswers.first(where: { $0.identifier == identifier}),
            let item = (self.items.first(where: { $0.identifier == identifier}) ?? (selectedAnswer as? RSDTrackedItem)),
            let detailsId = item.addDetailsIdentifier
            else {
                return nil
        }
        if let step = _detailSteps[identifier] {
            // return the previously created instance if there is one.
            return (step, selectedAnswer)
        } else if let template = self.detailStepTemplates?.first(where: { $0.identifier == detailsId }),
            let step = template.copy(from: item, with: selectedAnswer) {
            // save the created step for future calls.
            _detailSteps[identifier] = step
            return (step, selectedAnswer)
        } else {
            return nil
        }
    }
    
    /// Get the next detail step that still has details to fill in.
    open func nextDetailStep(after identifier: String) -> RSDStep? {
        guard !_inMemoryResult.hasRequiredValues else { return nil }
        return _nextDetailStep(after: identifier, previousLoop: nil)
    }
    
    func _nextDetailStep(after identifier: String, previousLoop: String?) -> RSDStep? {
        let selectedIdentifiers = _inMemoryResult.selectedIdentifiers
        guard selectedIdentifiers.count > 0 else { return nil }
        
        var previousId = identifier
        // If the previous identifier isn't in the list of selected identifiers,
        // then look to see if if it needs its details set
        if !selectedIdentifiers.contains(previousId) {
            previousId = selectedIdentifiers.first!
            if let (step, answer) = getDetailStep(with: previousId), !answer.hasRequiredValues {
                return step
            }
        }
        // Look forward to the next identifier that isn't filled.
        while let nextId = selectedIdentifiers.rsd_next(after: { $0 == previousId }), nextId != previousLoop {
            previousId = nextId
            if let (step, answer) = getDetailStep(with: nextId), !answer.hasRequiredValues {
                return step
            }
        }
        // If the starting identifier is the review, this has looped before, or there is only one selected
        // item, then we know we have gotten them all. Otherwise, go back to the beginning and loop through.
        if previousLoop != nil || selectedIdentifiers.count == 1 || !selectedIdentifiers.contains(identifier) {
            return nil
        } else {
            return _nextDetailStep(after: self.reviewStep?.identifier ?? "null", previousLoop: identifier)
        }
    }
    
    /// Get the selection step including any preparation required for this navigator.
    open func getSelectionStep() -> RSDStep {
        self.selectionStep.result = _inMemoryResult
        return self.selectionStep
    }
    
    /// Get the review step including any preparation required for this navigation.
    open func getReviewStep() -> RSDStep? {
        self.reviewStep?.result = _inMemoryResult
        return self.reviewStep
    }
    
    /// Get the logging step including any preparation required for this navigation.
    open func getLoggingStep() -> RSDStep? {
        self.loggingStep?.result = _inMemoryResult
        return self.loggingStep
    }
    
    // MARK: RSDStepNavigator
    
    /// If this is a selection or review identifier, those steps are returned, otherwise
    /// will return the appropriate detail step for the given item identifier (if any).
    open func step(with identifier: String) -> RSDStep? {
        if identifier == self.selectionStep.identifier {
            return getSelectionStep()
        } else if identifier == self.reviewStep?.identifier {
            return getReviewStep()
        } else if identifier == self.loggingStep?.identifier {
            return getLoggingStep()
        } else if let (step, _) = getDetailStep(with: identifier) {
            return step
        } else {
            return nil
        }
    }
    
    /// Returns `false`.
    open func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        return false
    }
    
    /// Returns `true` unless this is a logging step or review step with all information completed.
    open func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        guard let identifier = step?.identifier else { return true }
        guard identifier != self.loggingStep?.identifier else { return false }
        guard let reviewStep = self.reviewStep else {
            // If there isn't a review step, but there is a logging step then that
            // is the last step.
            return self.loggingStep != nil
        }
        if identifier != reviewStep.identifier {
            // If this is not a review step then there will always be a step after b/c the
            // review step is always last.
            return true
        } else {
            // There is a step after the review step if it does not have all required values.
            return !(_inMemoryResult?.hasRequiredValues ?? false)
        }
    }
    
    /// Returns `false` if and only if this is the selection or review step.
    open func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool {
        if step.identifier == self.selectionStep.identifier ||
            step.identifier == self.reviewStep?.identifier ||
            step.identifier == self.loggingStep?.identifier {
            return false
        } else {
            return true
        }
    }
    
    /// The next step in the series depends upon what information is remaining to be entered.
    open func step(after step: RSDStep?, with result: inout RSDTaskResult) -> RSDStep? {
        
        // When moving forward, always update the in-memory result before continuing.
        updateInMemoryResult(from: result, using: step)
        
        guard let identifier = step?.identifier else {
            // For the first step, return the logging step if there is a valid previous result.
            // Otherwise, return the selection step.
            if let previous = self.previousResult, previous.hasRequiredValues, previous.selectedAnswers.count > 0,
                let loggingStep = getLoggingStep() {
                return loggingStep
            } else {
                return getSelectionStep()
            }
        }
        
        // If this is a logging step, it is always the last step.
        if identifier == self.loggingStep?.identifier {
            return nil
        }

        // If there is no review step then this should return the logging step.
        guard let reviewStep = getReviewStep() else {
            return getLoggingStep()
        }
        
        if identifier == self.selectionStep.identifier {
            // Selection is always followed by review.
            return reviewStep
        } else if identifier == reviewStep.identifier,
            let navStep = reviewStep as? RSDNavigationRule,
            let nextId = navStep.nextStepIdentifier(with: result, conditionalRule: nil, isPeeking: false),
            let (detailStep, _) = getDetailStep(with: nextId) {
            // If the review step has implemented custom navigation to go to a specific step, then
            // repect that navigation rule.
            return detailStep
        } else if let nextStep = self.nextDetailStep(after: identifier) {
            // If there is a step that doesn't have details added then return that.
            return nextStep
        } else if identifier != reviewStep.identifier {
            // If this is *not* the review step then we are done adding details, so
            // return the review step.
            return reviewStep
        } else {
            // Exit.
            return nil
        }
    }
    
    /// Going back should always return to the review step (unless this *is* selection or review).
    open func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep? {
        guard let reviewStep = self.reviewStep else { return nil }
        if step.identifier == self.selectionStep.identifier ||
            step.identifier == reviewStep.identifier ||
            step.identifier == self.loggingStep?.identifier {
            return nil
        } else {
            return self.reviewStep
        }
    }
    
    /// Returns `nil`. Progress is not used by default.
    open func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)? {
        return nil
    }
}
