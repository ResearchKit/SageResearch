//
//  RSDImagePlacementType.swift
//  Research
//

import Foundation
import JsonModel

/// A hint as to where the UI should place an image.
public struct RSDImagePlacementType : RawRepresentable, Codable, Hashable, Equatable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    enum StandardTypes : String, Codable, CaseIterable {
        case iconBefore, iconAfter, fullsizeBackground, topBackground, topMarginBackground
        
        var imagePlacementType: RSDImagePlacementType {
            return RSDImagePlacementType(rawValue: self.rawValue)
        }
    }
    
    /// Smaller presentation of an icon image before the content.
    public static let iconBefore = StandardTypes.iconBefore.imagePlacementType
    
    /// Smaller presentation of an icon image after the content.
    public static let iconAfter = StandardTypes.iconAfter.imagePlacementType
    
    /// Fullsize in the background.
    public static let fullsizeBackground = StandardTypes.fullsizeBackground.imagePlacementType
    
    /// Top half of the background contrained to the top rather than to the safe area.
    public static let topBackground = StandardTypes.topBackground.imagePlacementType
    
    /// Top half of the background constraind to the safe area.
    public static let topMarginBackground = StandardTypes.topMarginBackground.imagePlacementType
    
    public var isBackground : Bool {
        switch self {
        case .fullsizeBackground, .topBackground, .topMarginBackground:
            return true
        default:
            return false
        }
    }
    
    public static func allStandardTypes() -> [RSDImagePlacementType] {
        return StandardTypes.allCases.map { $0.imagePlacementType }
    }
}

extension RSDImagePlacementType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDImagePlacementType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}

