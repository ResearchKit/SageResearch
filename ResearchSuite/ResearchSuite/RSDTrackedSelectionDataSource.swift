//
//  RSDTrackedSelectionDataSource.swift
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

/// `RSDTrackedSelectionDataSource` is a concrete implementation of the `RSDTableDataSource` protocol
/// that is designed to be used with a `RSDTrackedSelectionStep`.
open class RSDTrackedSelectionDataSource : RSDTableDataSource {

    /// The delegate associated with this data source.
    open weak var delegate: RSDTableDataSourceDelegate?
    
    /// The step associated with this data source.
    public let step: RSDStep
    
    /// The current task path.
    public private(set) var taskPath: RSDTaskPath
    
    /// The table sections for this data source.
    open private(set) var sections: [RSDTableSection]
    
    /// The initial result when the data source was first displayed.
    open private(set) var initialResult: RSDSelectionResult?
    
    /// Initialize a new `RSDFormStepDataSourceObject`.
    /// - parameters:
    ///     - step:             The RSDTrackedSelectionStep for this data source.
    ///     - taskPath:         The current task path for this data source.
    public init(step: RSDTrackedSelectionStep, taskPath: RSDTaskPath) {
        
        self.step = step
        self.taskPath = taskPath
        self.sections =  []
        
        // Set the initial result if available.
        if let result = initialResult {
            self.initialResult = result
        }
    }
    
    open func buildSections() {
        // TODO: implement syoung 02/25/2018

//        let sections = sectionItems ?? []
//        let dataType: RSDFormDataType = .collection(.multipleChoice, .string)
//        var meds = items
//        
//        var inputFields: [RSDInputField] = sections.map { (section) -> RSDInputField in
//            let choices = meds.remove(where: { $0.sectionIdentifier == section.identifier })
//            let field = RSDChoiceInputFieldObject(identifier: section.identifier, choices: choices, dataType: dataType, uiHint: .list, prompt: section.text, defaultAnswer: nil)
//            field.placeholder = section.detail
//            return field
//        }
//
//        if meds.count > 0 {
//            let prompt = inputFields.count > 0 ? Localization.localizedString("OTHER_SECTION_TITLE") : nil
//            let field = RSDChoiceInputFieldObject(identifier: stepId, choices: meds, dataType: dataType, uiHint: .list, prompt: prompt, defaultAnswer: nil)
//            inputFields.append(field)
//        }
    }
    
    // MARK: RSDTableDataSource implementation
    
    public func tableItem(at indexPath: IndexPath) -> RSDTableItem? {
        // TODO: implement syoung 02/25/2018
        return nil
    }
    
    public func itemGroup(at indexPath: IndexPath) -> RSDTableItemGroup? {
        // TODO: implement syoung 02/25/2018
        return nil
    }
    
    public func nextItem(after indexPath: IndexPath) -> RSDTableItemGroup? {
        // TODO: implement syoung 02/25/2018
        return nil
    }
    
    public func indexPath(for itemGroup: RSDTableItemGroup) -> IndexPath? {
        // TODO: implement syoung 02/25/2018
        return nil
    }
    
    public func allAnswersValid() -> Bool {
        // TODO: implement syoung 02/25/2018
        return true
    }
    
    public func saveAnswer(_ answer: Any, at indexPath: IndexPath) throws {
        // TODO: implement syoung 02/25/2018
    }
    
    public func selectAnswer(item: RSDChoiceTableItem, at indexPath: IndexPath) throws {
        // TODO: implement syoung 02/25/2018
    }
}
