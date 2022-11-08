//
//  RSDDeviceType.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDDeviceType` describes various devices. It can be used by a task to vend different steps or async
/// actions based upon what is supported by a given device type.
///
/// - note: This is not currently used and may be deprecated.
///
public struct RSDDeviceType : RSDFactoryTypeRepresentable, Codable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// A computer will have a keyboard and a mouse or touchpad. (Mac)
    public static let computer: RSDDeviceType = "computer"
    
    /// A phone is a handheld device with a touch screen. (iPhone, Android phone)
    public static let phone: RSDDeviceType = "phone"
    
    /// A tablet is a larger touch screen device. (iPad, Android tablet)
    public static let tablet: RSDDeviceType = "tablet"
    
    /// A tv is a device that has a larger screen with a remote control. (Apple TV)
    public static let tv: RSDDeviceType = "tv"
    
    /// A watch is a device that is worn on a person's wrist. (Apple Watch)
    public static let watch: RSDDeviceType = "watch"
    
    public static func allStandardKeys() -> [RSDDeviceType] {
        return [.computer, .phone, .tablet, .tv, .watch]
    }
}

extension RSDDeviceType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allStandardKeys().map { $0.rawValue }
    }
}

extension RSDDeviceType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDDeviceType : CodingKey {
    
    public init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
    public var intValue: Int? {
        return nil
    }
    
    public init?(intValue: Int) {
        return nil
    }
}
