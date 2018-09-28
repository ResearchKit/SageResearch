//
//  RSDTableItem.swift
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

/// `RSDTableItem` can be used to represent the type of the row to display.
open class RSDTableItem {
    
    /// A unique identifier for the table item.
    public let identifier: String
    
    /// The index of this item relative to all rows in the section in which this item resides.
    public var rowIndex: Int
    
    /// A unique identifier for the section.
    public internal(set) var sectionIdentifier: String!
    
    /// The section index for this group.
    public internal(set) var sectionIndex: Int = 0
    
    /// The string to use as the reuse identifier.
    public let reuseIdentifier: String
    
    /// Return the index path of the item.
    public var indexPath: IndexPath {
        return IndexPath(item: rowIndex, section: sectionIndex)
    }
    
    /// Initialize a new RSDTableItem.
    /// - parameters:
    ///     - identifier: The cell identifier.
    ///     - rowIndex: The index of this item relative to all rows in the section in which this item resides.
    ///     - reuseIdentifier: The string to use as the reuse identifier.
    public init(identifier: String, rowIndex: Int, reuseIdentifier: String) {
        self.identifier = identifier
        self.rowIndex = rowIndex
        self.reuseIdentifier = reuseIdentifier
    }
    
    /// The `ReuseIdentifier` is a list of reuse identifiers used by this framework
    /// to register table cells in a table.
    ///
    /// In addition to the values listed here, the default behavior for the `RSDTableItem`
    /// subclasses includes optional support for all standard `RSDFormUIHint` values.
    ///
    public enum ReuseIdentifier : String, Codable {
        
        /// Display a label (text that cannot be edited). This is used for
        /// text in a footnote or other additional detail information.
        case label = "label"
        
        /// Display an image.
        case image = "image"
    }
    
    /// A list of all the `RSDTableItem.reuseIdentifier` values that are standard to this framework.
    public static var allStandardReuseIdentifiers: [String] {
        let baseIds: [ReuseIdentifier] = [.label, .image]
        var reuseIds = baseIds.map { $0.stringValue }
        reuseIds.append(contentsOf: RSDFormUIHint.allStandardHints.map { $0.stringValue })
        return reuseIds
    }
}

extension RSDTableItem : Hashable {
    
    public var hashValue: Int {
        return self.identifier.hashValue ^ (self.sectionIdentifier?.hashValue ?? 0)
    }
    
    public static func ==(lhs: RSDTableItem, rhs: RSDTableItem) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.sectionIdentifier == rhs.sectionIdentifier
    }
}

extension RSDTableItem : CustomStringConvertible {
    
    open var description: String {
        return "<\(String(describing: type(of: self))) \(rowIndex) {\(String(describing: self.sectionIdentifier)) : \(self.identifier)} >"
    }
}

/// `RSDTextTableItem` is used to represent a item row that has static text.
public final class RSDTextTableItem : RSDTableItem {
    
    /// The text to display.
    public let text: String
    
    /// Initialize a new `RSDTextTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - text:          The text to display.
    public init(rowIndex: Int, text: String) {
        self.text = text
        super.init(identifier: text, rowIndex: rowIndex, reuseIdentifier: RSDTableItem.ReuseIdentifier.label.rawValue)
    }
}

/// `RSDImageTableItem` is used to represent a item row that has a static image.
public final class RSDImageTableItem : RSDTableItem {
    
    /// The image to display.
    public let imageTheme: RSDImageThemeElement
    
    /// Initialize a new `RSDImageTableItem`.
    /// parameters:
    ///     - rowIndex:      The index of this item relative to all rows in the section in which this item resides.
    ///     - imageTheme:    The image to display.
    public init(rowIndex: Int, imageTheme: RSDImageThemeElement) {
        self.imageTheme = imageTheme
        super.init(identifier: imageTheme.imageIdentifier, rowIndex: rowIndex, reuseIdentifier: RSDTableItem.ReuseIdentifier.image.rawValue)
    }
}

/// `RSDInputFieldTableItem` is an abstract base class implementation for representing an answer, or part of an
/// answer for a given `RSDInputField`.
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
