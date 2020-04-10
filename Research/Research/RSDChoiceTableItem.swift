//
//  RSDChoiceTableItem.swift
//  Research
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDChoiceTableItem` is used to represent a single row in a table where the user picks from a list of choices.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDChoiceTableItem : RSDInputFieldTableItem, ChoiceInputItemState {
    
    /// The choice for a single or multiple choice input field.
    open private(set) var choice: RSDChoice
    
    /// The answer associated with this choice
    open override var answer: Any? {
        return selected ? choice.answerValue : nil
    }
    
    /// Whether or not the choice is currently selected.
    open var selected: Bool = false
    
    /// Initialize a new RSDChoiceTableItem.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:    The RSDInputField representing this tableItem.
    ///     - uiHint:        The UI hint for this row of the table.
    ///     - choice:        The choice for a single or multiple choice input field.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, choice: RSDChoice) {
        self.choice = choice
        let identifier = (choice.answerValue != nil) ? "\(choice.answerValue!)" : "\(rowIndex)"
        super.init(rowIndex: rowIndex, inputField: inputField, uiHint: uiHint, reuseIdentifier: nil, identifier: identifier)
    }
}
