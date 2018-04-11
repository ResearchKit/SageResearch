//
//  MCTHandSelectionStepOjbect.swift
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

/// A Subclass of RSDFormUIStepObject which uses MCTHandSelectionDataSource.
public class MCTHandSelectionStepObject : RSDFormUIStepObject {
    override public func instantiateDataSource(with taskPath: RSDTaskPath, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        return MCTHandSelectionDataSource(step: self, taskPath: taskPath, supportedHints: supportedHints)
    }
}

/// An enum that represents the choices the user has for which hands they can use.
public enum MCTHandSelection : String, Codable {
    case left, right, both
    
    public var otherHand: MCTHandSelection? {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        default:
            return nil
        }
    }
}

/// The object that serves as the data soruce for an MCTHandSelectionStep
public class MCTHandSelectionDataSource : RSDFormStepDataSourceObject {
    
    /// Key for the randomized hand order in the task result.
    public static let handOrderKey = "handOrder"
    
    /// Key for which hands the user said they could use in the task result.
    public static let selectionKey = "handSelection"
    
    /// Override the initial result to look for the user's previous answer to this quesiton in
    /// UserDefaults.
    override open var initialResult : RSDCollectionResult? {
        let initialResultKey : String = "\(self.taskPath.task!.identifier)_lastHandSelection"
        let defaults = UserDefaults.standard
        guard let handSelection = defaults.string(forKey: initialResultKey) else { return nil }
        var ret = self.instantiateCollectionResult()
        var answerResult = RSDAnswerResultObject(identifier: MCTHandSelectionDataSource.selectionKey, answerType: .string)
        answerResult.value = handSelection
        ret.appendInputResults(with: answerResult)
        return ret
    }
    
    /// Override populateInitialResults to also write a randomized handOrder result.
    override open func populateInitialResults() {
        super.populateInitialResults()
        _updateHandOrder()
    }
    
    /// Override select answer to write the user's choice to UserDefaults, and to write a randomized handOrder result.
    override open func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        let ret = try super.selectAnswer(item: item, at: indexPath)
        guard let handSelection = _updateHandOrder()
               else {
            assertionFailure("_updateHandOrder() failed")
            return ret
        }
       
        let defaults = UserDefaults.standard
        defaults.set(handSelection, forKey: "\(self.taskPath.task!.identifier)_lastHandSelection")

        return ret
    }
    
    /// Writes a randomized hand order result to the task result.
    @discardableResult
    private func _updateHandOrder() -> String? {
        var stepResult: RSDCollectionResult = self.collectionResult()
        guard let selectionResult = stepResult.findAnswerResult(with: MCTHandSelectionDataSource.selectionKey),
              let handSelection = selectionResult.value as? String
              else {
                return nil
        }
        
        let handOrderResultType = RSDAnswerResultType(baseType: .string, sequenceType: .array)
        var handOrderResult = RSDAnswerResultObject(identifier: MCTHandSelectionDataSource.handOrderKey, answerType: handOrderResultType)
        switch handSelection {
        case "both":
            let handOrder: [MCTHandSelection] = arc4random_uniform(2) == 0 ? [.left, .right] : [.right, .left]
            handOrderResult.value = handOrder.map { $0.stringValue }
        default:
            handOrderResult.value = [handSelection]
        }
        
        stepResult.appendInputResults(with: handOrderResult)
        self.taskPath.appendStepHistory(with: stepResult)
        
        return handSelection
    }
}
