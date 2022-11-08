//
//  QuestionStepDataSource.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

@available(*,deprecated, message: "Will be deleted in a future version.")
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
