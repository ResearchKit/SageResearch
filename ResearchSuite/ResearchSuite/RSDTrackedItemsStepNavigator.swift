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
        case selection, review, addDetails
    }
    
    /// The list of medications.
    open private(set) var items: [RSDTrackedItem]
    
    /// The section items for mapping each medication.
    open private(set) var sections: [RSDTrackedSection]?
    
    /// Default initializer.
    /// - parameters:
    ///     - items: The list of medications.
    ///     - sections: The section items for mapping each medication.
    public init(items: [RSDTrackedItem], sections: [RSDTrackedSection]? = nil) {
        self.items = items
        self.sections = sections
        self.selectionStep = type(of: self).buildSelectionStep(items: items, sections: sections)
        self.reviewStep = type(of: self).buildReviewStep(items: items, sections: sections)
        self.detailStepTemplates = type(of: self).buildDetailSteps()
    }
    
    // MARK: Decodable
    
    public required init(from decoder: Decoder) throws {
        let (items, sections) = try type(of: self).decodeItems(from: decoder)
        self.items = items
        self.sections = sections
        
        // TODO: syoung 02/27/2018 Decode any replacement values defined in the decoder.
        // https://github.com/ResearchKit/SageResearch/issues/42
        self.selectionStep = type(of: self).buildSelectionStep(items: items, sections: sections)
        self.reviewStep = type(of: self).buildReviewStep(items: items, sections: sections)
        self.detailStepTemplates = type(of: self).buildDetailSteps()
    }
    
    open class func decodeItems(from decoder: Decoder) throws -> (items: [RSDTrackedItem], sections: [RSDTrackedSection]?) {
        let container = try decoder.container(keyedBy: ItemsCodingKeys.self)
        let items = try container.decode([RSDTrackedItemObject].self, forKey: .items)
        let sections = try container.decodeIfPresent([RSDTrackedSectionObject].self, forKey: .sections)
        return (items, sections)
    }
    
    // MARK: Step management
    
    /// The selection step to use to model selecting the medication.
    public let selectionStep: RSDTrackedSelectionStep
    
    /// The review step to display when reviewing/editing selected medication.
    public let reviewStep: RSDTrackedItemsReviewStep?
    
    /// The detail step should be displayed for each tracked item that has additional details.
    public let detailStepTemplates: [RSDTrackedItemDetailsStep]?
    
    /// Build the selection step for this tracked data collection. Override to customize the step.
    open class func buildSelectionStep(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> RSDTrackedSelectionStep {
        let stepId = StepIdentifiers.selection.stringValue
        let step = RSDTrackedSelectionStepObject(identifier: stepId, items: items, sections: sections)
        return step
    }
    
    /// Build the review step for this tracked data collection. Override to customize the step.
    open class func buildReviewStep(items: [RSDTrackedItem], sections: [RSDTrackedSection]?) -> RSDTrackedItemsReviewStep {
        let stepId = StepIdentifiers.review.stringValue
        let step = RSDTrackedItemsReviewStepObject(identifier: stepId, items: items, sections: sections)
        return step
    }
    
    /// Build the add details steps for this tracked data collection. Override to customize the steps.
    open class func buildDetailSteps() -> [RSDTrackedItemDetailsStep]? {
        return nil
    }
    
    /// Returns the existing task result (if there is one) and otherwise calls `instantiateReviewResult()`.
    /// - parameter taskResult: The current task result.
    /// - returns: Found or instantiated review result.
    public func reviewResult(from taskResult: RSDTaskResult) -> RSDTrackedItemsResult? {
        guard let reviewIdentifier = self.reviewStep?.identifier else { return nil }
        
        var result = taskResult.findResult(with: reviewIdentifier) as? RSDTrackedItemsResult ?? self.instantiateReviewResult()
        let selected = selectedIdentifiers(from: taskResult)
        result.updateSelected(to: selected, with: self.items, from: taskResult)
        return result
    }
    
    /// Get the selected identifiers from the given task result
    public func selectedIdentifiers(from taskResult: RSDTaskResult) -> [String]? {
        return (taskResult.findResult(for: self.selectionStep) as? RSDSelectionResult)?.selectedIdentifiers
    }
    
    /// Instantiate the appropriate review result.
    open func instantiateReviewResult() -> RSDTrackedItemsResult {
        let reviewIdentifier = self.reviewStep?.identifier ?? StepIdentifiers.review.stringValue
        return RSDTrackedItemsResultObject(identifier: reviewIdentifier)
    }
    
    // MARK: Detail step management
    
    private var _detailSteps: [String : RSDStep] = [:]

    /// Find or copy the detail step specific to this identifier.
    open func detailStep(with identifier: String) -> (RSDStep, RSDTrackedItemAnswer)? {
        guard let selectedAnswer = self.reviewStep?.result?.selectedAnswers.first(where: { $0.identifier == identifier}),
            let item = (self.items.first(where: { $0.identifier == identifier}) ?? (selectedAnswer as? RSDTrackedItem)),
            let detailsId = item.addDetailsIdentifier
            else {
                return nil
        }
        if let step = _detailSteps[identifier] {
            // return the previously created instance if there is one.
            return (step, selectedAnswer)
        } else if let template = self.detailStepTemplates?.first(where: { $0.identifier == detailsId }),
            let step = template.copy(from: item) {
            // save the created step for future calls.
            _detailSteps[identifier] = step
            return (step, selectedAnswer)
        } else {
            return nil
        }
    }
    
    /// Get the next detail step that still has details to fill in.
    public func nextDetailStep(after identifier: String) -> RSDStep? {
        guard let selectedIdentifiers = self.reviewStep?.result?.selectedIdentifiers,
            selectedIdentifiers.count > 0
            else {
                return nil
        }
        var previousId = identifier
        // If the previous identifier isn't in the list of selected identifiers,
        // then look to see if if it needs its details set
        if !selectedIdentifiers.contains(identifier) {
            previousId = selectedIdentifiers.first!
            if let (step, answer) = detailStep(with: previousId), !answer.hasRequiredValues {
                return step
            }
        }
        while let nextId = selectedIdentifiers.rsd_next(after: { $0 == previousId }) {
            previousId = nextId
            if let (step, answer) = detailStep(with: nextId), !answer.hasRequiredValues {
                return step
            }
        }
        return nil
    }
    
    // MARK: RSDStepNavigator
    
    /// If this is a selection or review identifier, those steps are returned, otherwise
    /// will return the appropriate detail step for the given item identifier (if any).
    open func step(with identifier: String) -> RSDStep? {
        if identifier == self.selectionStep.identifier {
            return self.selectionStep
        } else if identifier == self.reviewStep?.identifier {
            return self.reviewStep
        } else if let (step, _) = detailStep(with: identifier) {
            return step
        } else {
            return nil
        }
    }
    
    /// Returns `false`.
    open func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        return false
    }
    
    /// Returns `true` unless this is a review step with all information completed.
    open func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        guard let identifier = step?.identifier else { return true }
        guard let reviewStep = self.reviewStep else { return false }
        if identifier != reviewStep.identifier {
            // If this is not a review step then there will always be a step after b/c the
            // review step is always last.
            return true
        } else {
            // There is a step after the review step if it does not have all required values.
            return !(reviewStep.result?.hasRequiredValues ?? false)
        }
    }
    
    /// Returns `false` if and only if this is the selection or review step.
    open func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool {
        if step.identifier == self.selectionStep.identifier || step.identifier == self.reviewStep?.identifier {
            return false
        } else {
            return true
        }
    }
    
    /// The next step in the series depends upon what information is remaining to be entered.
    open func step(after step: RSDStep?, with result: inout RSDTaskResult) -> RSDStep? {
        guard let identifier = step?.identifier else {
            // For `nil` return the selection step.
            return self.selectionStep
        }
        
        guard let reviewStep = self.reviewStep else {
            // If there is no review step then the selection is always the final step.
            return nil
        }
        
        // If this is not the review step then update the review result
        if identifier != reviewStep.identifier, let reviewResult = self.reviewResult(from: result) {
            result.appendStepHistory(with: reviewResult)
            self.reviewStep?.result = reviewResult
        }
        
        if identifier == self.selectionStep.identifier {
            // Selection is always followed by review.
            return self.reviewStep
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
        if step.identifier == self.selectionStep.identifier || step.identifier == reviewStep.identifier {
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
