//
//  RSDFrequencyType.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// The frequency type can be used to indicate the frequency with which to do something within the app.
public enum RSDFrequencyType: String, CaseIterable {
    
    case always
    case daily
    case weekly
    case monthly
    case quarterly
    case biannual
    case annual
    
    /// Is the given date range within the duration window for the given frequency?
    /// - returns: `true` if `date1 + frequency > date2`
    public func withinDuration(between date1: Date, and date2: Date) -> Bool {
        let calendar = Calendar.init(identifier: .iso8601)
        let next: Date? = {
            switch self {
            case .always:
                return nil
            case .daily:
                return calendar.date(byAdding: .day, value: 1, to: date1)
            case .weekly:
                return calendar.date(byAdding: .day, value: 7, to: date1)
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: date1)
            case .quarterly:
                return calendar.date(byAdding: .month, value: 3, to: date1)
            case .biannual:
                return calendar.date(byAdding: .month, value: 6, to: date1)
            case .annual:
                return calendar.date(byAdding: .year, value: 1, to: date1)
            }
        }()
        guard let windowEnd = next else { return false }
        return windowEnd > date2
    }
}

extension RSDFrequencyType: RawRepresentable, Codable, Hashable {
}

extension RSDFrequencyType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = RSDFrequencyType(rawValue: value) ?? .always
    }
}
