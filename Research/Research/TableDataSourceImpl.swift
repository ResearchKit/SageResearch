//
//  TableDataSourceImpl.swift
//  Research
//
//  Created by Shannon Young on 4/8/20.
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
//

import Foundation

public final class RSDUIStepTableDataSourceImpl : RSDStepViewModel, RSDTableDataSource {
    
    /// The delegate associated with this data source.
    public weak var delegate: RSDTableDataSourceDelegate?

    /// The table sections for this data source.
    public let sections: [RSDTableSection]

    /// Initialize a new `TableDataSourceImpl`.
    /// - parameters:
    ///     - step:             The RSDStep for this data source.
    ///     - taskViewModel:         The current task path for this data source.
    public override init(step: RSDStep, parent: RSDPathComponent?) {
        self.sections = (step as? RSDUIStep)?.buildFooterTableItems().map {
            [RSDTableSection(identifier: "0", sectionIndex: 0, tableItems: $0)] } ?? []
        super.init(step: step, parent: parent)
    }
    
    // MARK: RSDTableDataSource implementation
    
    func isMatching(_ itemGroup: RSDTableItemGroup, at indexPath: IndexPath) -> Bool {
        return itemGroup.sectionIndex == indexPath.section &&
            (itemGroup.beginningRowIndex ... itemGroup.beginningRowIndex + (itemGroup.items.count - 1) ~= indexPath.item)
    }
    
    public func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        return nil
    }
    
    public func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        // Do nothing
    }
    
    public func selectAnswer(item: RSDTableItem, at indexPath: IndexPath) throws -> (isSelected: Bool, reloadSection: Bool) {
        // Do nothing
        return (false, false)
    }
    
    public func allAnswersValid() -> Bool {
        return true
    }
}


