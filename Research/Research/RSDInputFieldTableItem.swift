//
//  RSDInputFieldTableItem.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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


/// `RSDInputFieldTableItem` is an abstract base class implementation for representing an answer, or part of an
/// answer, for a given `RSDInputField`.
@available(*, deprecated, message: "Use `Question` and `InputItem` instead")
open class RSDInputFieldTableItem : RSDTableItem {
    
    /// The RSDInputField representing this tableItem.
    public let inputField: RSDInputField
    
    /// The UI hint for displaying the component of the item group.
    public let uiHint: RSDFormUIHint
    
    /// The answer associated with this table item component. Base class returns `nil`.
    open var answer: Any? {
        return nil
    }
    
    /// Initialize a new RSDInputFieldTableItem.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - inputField:    The RSDInputField representing this tableItem.
    ///     - uiHint: The UI hint for this row of the table.
    ///     - reuseIdentifier: The string to use as the reuse identifier.
    ///     - identifier: The cell identifier. If `nil`, then the inputField identifier will be used.
    public init(rowIndex: Int, inputField: RSDInputField, uiHint: RSDFormUIHint, reuseIdentifier: String? = nil, identifier: String? = nil) {
        self.inputField = inputField
        self.uiHint = uiHint
        
        // If the reuse identifier isn't passed to the initializer then set it from the ui hint.
        let reuseId: String = reuseIdentifier ?? uiHint.stringValue
        let itemId: String = identifier ?? inputField.identifier
        
        super.init(identifier: itemId, rowIndex: rowIndex, reuseIdentifier: reuseId)
    }
}
