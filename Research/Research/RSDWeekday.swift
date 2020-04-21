//
//  RSDWeekday.swift
//  Research
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
import JsonModel

/// The weekday enum assigns an enum value to each day of the week and implements `Comparable` to allow
/// for sorting the weekdays by the order appropriate for the participant's current Locale.
public enum RSDWeekday : Int, Codable, CaseIterable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    fileprivate static let weekdayNames: [String] =
        ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    /// Set of all the weekdays (Every day).
    public static var all: Set<RSDWeekday> {
        return Set(Array(1...7).map { RSDWeekday(rawValue: $0)! })
    }
    
    /// The localized weekday symbol.
    public var text: String? {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[self.rawValue - 1].capitalized
    }
    
    /// The short localized weekday symbol.
    public var shortText: String? {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols[self.rawValue - 1]
    }
}

extension RSDWeekday {
    
    public init(date: Date) {
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        self.init(rawValue: weekday)!
    }
}

extension RSDWeekday : Comparable {
    
    /// Sort the weekdays based on the `firstWeekday` property of the current Locale.
    public static func <(lhs: RSDWeekday, rhs: RSDWeekday) -> Bool {
        let firstWeekday = Locale.current.calendar.firstWeekday
        if (lhs.rawValue >= firstWeekday && rhs.rawValue >= firstWeekday) ||
            (lhs.rawValue < firstWeekday && rhs.rawValue < firstWeekday) {
            return lhs.rawValue < rhs.rawValue
        } else {
            return !(lhs.rawValue < firstWeekday && rhs.rawValue >= firstWeekday)
        }
    }
}

/// Extend the weekday enum to implement the choice and comparable protocols.
extension RSDWeekday : RSDChoice, RSDComparable {
    
    /// Returns `rawValue`.
    public var answerValue: Codable? {
        return self.rawValue
    }
    
    /// Returns `nil`.
    public var detail: String? {
        return nil
    }
    
    /// Returns `false`.
    public var isExclusive: Bool {
        return false
    }
    
    /// Returns `nil`.
    public var imageData: RSDImageData? {
        return nil
    }
    
    /// Returns `rawValue`.
    public var matchingAnswer: Any? {
        return self.rawValue
    }
}

extension RSDWeekday : DocumentableStringEnum {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let name = try? container.decode(String.self) {
            let rawValue = RSDWeekday.weekdayNames.firstIndex(where: { $0.lowercased() == name.lowercased() })! + 1
            self.init(rawValue: rawValue)!
        }
        else {
            let rawValue = try container.decode(Int.self)
            debugPrint("WARNING!!! Decoding weekday from an Int is deprecated. Use string keywords.")
            self.init(rawValue: rawValue)!
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(self.stringValue)
    }
    
    public var stringValue: String {
        return RSDWeekday.weekdayNames[self.rawValue - 1]
    }
    
    public static func allValues() -> [String] {
        return weekdayNames
    }
}

