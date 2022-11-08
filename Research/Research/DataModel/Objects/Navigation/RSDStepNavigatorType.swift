//
//  RSDStepNavigatorType.swift
//  Research
//

import Foundation
import JsonModel

/// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
/// the UI.
public struct RSDStepNavigatorType : RSDFactoryTypeRepresentable, Codable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDConditionalStepNavigatorObject`.
    public static let conditional: RSDStepNavigatorType = "conditional"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDStepNavigatorType] {
        return [.conditional]
    }
}

extension RSDStepNavigatorType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDStepNavigatorType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}
