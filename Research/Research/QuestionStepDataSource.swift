//
//  QuestionStepDataSource.swift
//  Research
//
//  Created by Shannon Young on 4/7/20.
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
//

import Foundation

//open class QuestionStepDataSource : RSDStepViewModel, RSDTableDataSource {
//    
//    open weak var delegate: RSDTableDataSourceDelegate?
//    
//    public let sections: [RSDTableSection]
//    public let itemGroups: [RSDTableItemGroup]
//
//    open func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
//        itemGroups.first(where: { isMatching($0, at: indexPath) })
//    }
//    
//    func isMatching(_ itemGroup: RSDTableItemGroup, at indexPath: IndexPath) -> Bool {
//        itemGroup.sectionIndex == indexPath.section &&
//            (itemGroup.beginningRowIndex ... itemGroup.beginningRowIndex + (itemGroup.items.count - 1) ~= indexPath.item)
//    }
//    
//    public func allAnswersValid() -> Bool {
//        itemGroups.reduce(true, { $0 && $1.isAnswerValid })
//    }
//    
//    public func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
//        <#code#>
//    }
//    
//    public func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
//        guard let itemGroup = self.itemGroup(at: indexPath) as? QuestionTableItemGroup else {
//            return (false, false)
//        }
//        
//        let ret = try itemGroup.select(choiceItem, indexPath: indexPath)
//        _answerDidChange(for: itemGroup, at: indexPath)
//        return ret
//    }
//    
//}
