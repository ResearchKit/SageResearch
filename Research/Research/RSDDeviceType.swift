//
//  RSDDeviceType.swift
//  Research
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

/// `RSDDeviceType` describes various devices. It can be used by a task to vend different steps or async
/// actions based upon what is supported by a given device type.
///
/// - note: This is not currently used and may be deprecated.
///
public struct RSDDeviceType : RawRepresentable, Codable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    
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
}

extension RSDDeviceType : RSDStringEnumSet {
    /// List of all the standard types.
    public static var all: Set<RSDDeviceType> {
        return [.computer, .phone, .tablet, .tv, .watch]
    }
}

extension RSDDeviceType : RSDDocumentableStringEnum {
}

extension RSDDeviceType : Equatable {
    public static func ==(lhs: RSDDeviceType, rhs: RSDDeviceType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDDeviceType) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDDeviceType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDDeviceType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDDeviceType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
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
