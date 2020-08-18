//
//  QuestionStepDataSource.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

public final class QuestionStepDataSource : RSDStepViewModel, RSDTableDataSource {

    public weak var delegate: RSDTableDataSourceDelegate?
    
    public let sections: [RSDTableSection]
    public let itemGroup: QuestionTableItemGroup
    
    public init(step: QuestionStep, parent: RSDPathComponent?, supportedHints: Set<RSDFormUIHint>? = nil) {
        
        let previousValue: JsonElement? = {
            guard let taskVM = parent as? RSDTaskViewModel else { return nil }
            if let previousResult = taskVM.previousResult(for: step) {
                return (previousResult as? AnswerResult)?.jsonValue
            }
            guard let dataManager = taskVM.dataManager,
                (dataManager.shouldUsePreviousAnswers?(for: taskVM.identifier) ?? false),
                let dictionary = taskVM.previousTaskData?.json as? [String : JsonSerializable],
                let value = dictionary[step.identifier] as? JsonValue
                else {
                    return nil
            }
            return JsonElement(value)
        }()

        let idx = 0
        let itemGroup = QuestionTableItemGroup(beginningRowIndex: idx,
                                               question: step,
                                               supportedHints: supportedHints,
                                               initialValue: previousValue)
        var sections = [RSDTableSection(identifier: step.identifier, sectionIndex: idx, tableItems: itemGroup.items)]
        step.buildFooterTableItems().map {
            sections.append(RSDTableSection(identifier: "footer", sectionIndex: idx + 1, tableItems: $0))
        }
        
        self.sections = sections
        self.itemGroup = itemGroup
        
        parent?.taskResult.appendStepHistory(with: itemGroup.answerResult)
        
        super.init(step: step, parent: parent)
    }
    
    /// Specifies whether the next button should be enabled based on the validity of the answers for
    /// all form items.
    override public var isForwardEnabled: Bool {
        return super.isForwardEnabled && allAnswersValid()
    }

    public func allAnswersValid() -> Bool {
        itemGroup.isAnswerValid
    }
    
    public func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        indexPath.section == itemGroup.sectionIndex ? itemGroup : nil
    }
    
    public func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        guard indexPath.section == itemGroup.sectionIndex else { return }
        try itemGroup.saveAnswer(answer, at: indexPath.item)
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
    }
    
    public func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        guard indexPath.section == itemGroup.sectionIndex else {
            return (false, false)
        }
        let ret = try itemGroup.toggleSelection(at: indexPath.item)
        delegate?.tableDataSource(self, didChangeAnswersIn: indexPath.section)
        return ret
    }
}
