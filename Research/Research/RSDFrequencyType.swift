//
//  RSDFrequencyType.swift
//  Research
//
//  Created by Shannon Young on 3/4/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import Foundation

/// The frequency type can be used to indicate the frequency with which to do something within the app.
public enum RSDFrequencyType {
    
    case standard(Standard)
    
    /// Standard set of frequencies defined within this framework.
    public enum Standard : String, CaseIterable {
        case always
        case daily
        case weekly
        case monthly
        case quarterly
        case biannual
        case annual
    }
    
    /// A custom frequency. Must be handled by the app.
    case custom(String)
    
    /// The string for the custom action (if applicable).
    public var customAction: String? {
        if case .custom(let str) = self {
            return str
        } else {
            return nil
        }
    }
}

extension RSDFrequencyType: RawRepresentable, Codable, Hashable {
    
    public init(rawValue: String) {
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

extension RSDFrequencyType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
