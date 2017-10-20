//
//  RSDFormUIHint.swift
//  ResearchSuite
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

/**
 The `RSDFormUIHint` enum is a key word that can be used to describe the preferred UI for a form input field.  Not all ui hints are applicable to all data types.
 */
public enum RSDFormUIHint {
    
    /**
     Standard ui hints
     */
    case standard(Standard)
    public enum Standard : String {
        case checkbox       // list with a checkbox next to each item
        case combobox       // drop-down with a textfield for "other"
        case list           // list
        case multipleLine   // multiple line text field
        case picker         // picker wheel
        case popover        // Text entry using a modal popover box
        case radioButton    // radio button
        case slider         // slider
        case textfield      // text field
        case toggle         // toggle/segmented button
        
        public static var all: [Standard] {
            return [.checkbox, .combobox, .list, .multipleLine, .picker, .radioButton, .slider, .textfield, .toggle]
        }
    }
    
    case custom(String)
    
    public var standardType: Standard? {
        guard case .standard(let type) = self else { return nil }
        return type
    }
    
    public static var allStandardHints: Set<RSDFormUIHint> {
        let all: [RSDFormUIHint] = Standard.all.map { return .standard($0) }
        return Set(all)
    }
}

extension RSDFormUIHint: RawRepresentable, Codable {
    public typealias RawValue = String

    public init(rawValue: RawValue) {
        if let subtype = Standard(rawValue: rawValue) {
            self = .standard(subtype)
        }
        else {
            self = .custom(rawValue)
        }
    }
    
    public var rawValue: String {
        switch (self) {
        case .standard(let value):
            return value.rawValue
            
        case .custom(let value):
            return value
        }
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

