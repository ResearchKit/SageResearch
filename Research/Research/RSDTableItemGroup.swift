//
//  RSDTableItemGroup.swift
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

/// `RSDTableItemGroup` is a generic table item group object that can be used to display information in a tableview
/// that does not have an associated input field.
open class RSDTableItemGroup {
    
    /// The list of items (or rows) included in this group. A table group can be used to represent one or more rows.
    public let items: [RSDTableItem]
    
    /// The section index for this group.
    public var sectionIndex: Int = 0
    
    /// The row index for the first row in the group.
    public let beginningRowIndex: Int
    
    /// A unique identifier that can be used to track the group.
    public let uuid = UUID()
    
    /// Determine if the current answer is valid. Also checks the case where answer is required but one has not
    /// been provided.
    open var isAnswerValid: Bool {
        return true
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - beginningRowIndex: The row index for the first row in the group.
    ///     - items: The list of items (or rows) included in this group.
    public init(beginningRowIndex: Int, items: [RSDTableItem]) {
        self.beginningRowIndex = beginningRowIndex
        self.items = items
    }
}
