//
//  RSDDateCoderObject.swift
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
 `RSDDateCoderObject` provides a concrete implementation of a date coder.
 */
public struct RSDDateCoderObject : RSDDateCoder {
    
    public private(set) var formatter: DateFormatter
    public private(set) var calendarComponents: Set<Calendar.Component>
    public private(set) var calendar: Calendar
    
    public init() {
        let (formatter, components, calendar) = RSDDateCoderObject.getProperties(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")!
        self.formatter = formatter
        self.calendar = calendar
        self.calendarComponents = components
    }
    
    public init?(format: String) {
        guard let (formatter, components, calendar) = RSDDateCoderObject.getProperties(format: format)
            else {
                return nil
        }
        self.formatter = formatter
        self.calendar = calendar
        self.calendarComponents = components
    }
    
    public init(formatter: DateFormatter, calendarComponents: Set<Calendar.Component>, calendar: Calendar) {
        self.formatter = formatter
        self.calendarComponents = calendarComponents
        self.calendar = calendar
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let format = try container.decode(String.self)
        guard let (formatter, components, calendar) = RSDDateCoderObject.getProperties(format: format)
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to get the calendar components from the decoded format \(format)"))
        }
        self.formatter = formatter
        self.calendarComponents = components
        self.calendar = calendar
    }
    
    fileprivate static func getProperties(format: String) -> (DateFormatter, Set<Calendar.Component>, Calendar)? {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.calendarComponents(from: format)
        guard components.count > 0 else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return (formatter, components, calendar)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.formatter.dateFormat)
    }
}

extension Calendar {
    public func calendarComponents(from format: String) -> Set<Calendar.Component> {
        var components: Set<Calendar.Component> = []
        if format.range(of: "yyyy") != nil {
            components.insert(.year)
        }
        if format.range(of: "MM") != nil {
            components.insert(.month)
        }
        if format.range(of: "dd") != nil {
            components.insert(.day)
        }
        if format.range(of: "HH") != nil {
            components.insert(.hour)
        }
        if format.range(of: "mm") != nil {
            components.insert(.minute)
        }
        if format.range(of: "ss") != nil {
            components.insert(.second)
        }
        if format.range(of: "ss.SSS") != nil {
            components.insert(.nanosecond)
        }
        return components
    }
}
