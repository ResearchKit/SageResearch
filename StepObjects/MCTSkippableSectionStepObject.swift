//
//  MCTSkippableSectionStepObject.swift
//  MotorControl
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

/// Extend RSDSectionStepObject to implements navigation rules for each hand. These sections are
/// intended to be used when a study has results from the left and right side of the body, and
/// needs to randomize which order tests are done in.
extension RSDSectionStepObject: RSDNavigationSkipRule, RSDNavigationRule {
    
    /// Returns `true` if this step should be skipped and `false` otherwise.
    public func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        guard let myHand = MCTHandSelection(rawValue: self.identifier),
              let handSelectionResult = result?.findResult(with: MCTHandSelectionDataSource.selectionKey) as? RSDCollectionResult,
              let handOrder = handSelectionResult.findAnswerResult(with: MCTHandSelectionDataSource.handOrderKey)?.value as? [String]
            else {
                return false
        }
        
        if handOrder.first! == self.identifier {
            let previousResultForThisStep = result?.findResult(with: self.identifier)
            // If there is a previous result for this step, we should skip this step.
            return previousResultForThisStep != nil
        } else if handOrder.last! == self.identifier, let otherHand = myHand.otherHand {
            let previousResultForOther = result?.findResult(with: otherHand.stringValue)
            // If there is not a previous result for the other step, we sholud skip this step.
            return previousResultForOther == nil
        }
        
        // self.identifier isn't in the handOrder array so this section isn't for a specific hand.
        return true
        
    }
    
    /// Returns the identifier of the step to go to after this step is completed, or skipped.
    public func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        guard let handSelectionResult = result?.findResult(with: MCTHandSelectionDataSource.selectionKey) as? RSDCollectionResult,
            let handOrder : [String] = handSelectionResult.findAnswerResult(with: MCTHandSelectionDataSource.handOrderKey )?.value as? [String]
            else {
                return nil
        }
        
        if handOrder.first! == self.identifier,
            handOrder.last! != self.identifier {
            // if this step should go first, and there is a step after it return the step after it,
            // and the step after it hasn't run yet, we return the next steps identifier
            let previousResultForOtherStep = result?.findResult(with: handOrder.last!)
            if previousResultForOtherStep == nil {
                return handOrder.last!
            }
        }
        
        // in all other cases, the next step is just the defualt next step.
        return nil
    }
    
    /// Returns `true` if first is the opposite hand of second, `false` otherwise. If
    /// either first or second is .both returns `false`.
    private func _isOppositeHand(_ first: MCTHandSelection, _ second: MCTHandSelection) -> Bool {
        return first != .both && second != .both && first != second
    }
}
