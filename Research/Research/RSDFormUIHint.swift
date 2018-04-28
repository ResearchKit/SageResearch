//
//  RSDFormUIHint.swift
//  ResearchStack2
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

/// The `RSDFormUIHint` enum is a key word that can be used to describe the preferred UI for a form input field.
/// This is intended as a "hint" that the designers and developers can use to indicate the preferred input style
/// for an input field. Not all ui hints are applicable to all data types or devices, and therefore the ui hint
/// may be ignored by the application displaying the input field to the user.
///
public struct RSDFormUIHint : RawRepresentable, Codable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// List with a checkbox next to each item.
    public static let checkbox: RSDFormUIHint = "checkbox"
    
    /// Drop-down with a textfield for "other".
    public static let combobox: RSDFormUIHint = "combobox"
    
    /// List of selectable cells.
    public static let list: RSDFormUIHint = "list"
    
    /// Multiple line text field.
    public static let multipleLine: RSDFormUIHint = "multipleLine"
    
    /// Text field with a picker wheel as the keyboard.
    public static let picker: RSDFormUIHint = "picker"
    
    /// Text entry using a modal popover box.
    public static let popover: RSDFormUIHint = "popover"
    
    /// Radio button.
    public static let radioButton: RSDFormUIHint = "radioButton"
    
    /// Slider.
    public static let slider: RSDFormUIHint = "slider"
    
    /// Text field.
    public static let textfield: RSDFormUIHint = "textfield"
    
    /// Toggle (segmented) button.
    public static let toggle: RSDFormUIHint = "toggle"
    
    /// Modal step displayed with a secondary button cell.
    public static let modalButton: RSDFormUIHint = "modalButton"
    
    /// Modal step displayed with selection cell.
    public static let modalSelection: RSDFormUIHint = "modalSelection"

    /// The standard type for this ui hint, if applicable.
    public var standardType: RSDFormUIHint? {
        return RSDFormUIHint.allStandardHints.contains(self) ? self : nil
    }
    
    /// A list of all the `RSDFormUIHint` values that are standard hints.
    public static var allStandardHints: Set<RSDFormUIHint> {
        return [.checkbox, .combobox, .list, .multipleLine, .picker, .radioButton, .slider, .textfield, .toggle, .modalButton, .modalSelection]
    }
}

extension RSDFormUIHint : Equatable {
    public static func ==(lhs: RSDFormUIHint, rhs: RSDFormUIHint) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDFormUIHint) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDFormUIHint, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDFormUIHint : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDFormUIHint : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDFormUIHint : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardHints.map{ $0.rawValue }
    }
}

