//
//  RSDFrequencyType.swift
//  Research
//
//  Created by Shannon Young on 3/4/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
    
    /// Is the given date range within the duration window for the given frequency.
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
