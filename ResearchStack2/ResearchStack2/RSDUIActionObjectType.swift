//
//  RSDUIActionObjectType.swift
//  ResearchStack2
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

/// The type of the ui action. This is used to decode a `RSDUIAction` using a `RSDFactory`. It can also be used
/// to customize the UI.
public struct RSDUIActionObjectType : RawRepresentable, Codable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDUIActionObject`.
    public static let defaultNavigation: RSDUIActionObjectType = "default"
    
    /// Defaults to creating a `RSDNavigationUIActionObject`.
    public static let navigation: RSDUIActionObjectType = "navigation"
    
    /// Defaults to creating a `RSDReminderUIActionObject`.
    public static let reminder: RSDUIActionObjectType = "reminder"
    
    /// Defaults to creating a `RSDWebViewUIActionObject`.
    public static let webView: RSDUIActionObjectType = "webView"
    
    public static func allStandardTypes() -> [RSDUIActionObjectType] {
        return [.defaultNavigation, .webView, .navigation, .reminder]
    }
}

extension RSDUIActionObjectType : Equatable {
    public static func ==(lhs: RSDUIActionObjectType, rhs: RSDUIActionObjectType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDUIActionObjectType) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDUIActionObjectType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDUIActionObjectType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDUIActionObjectType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDUIActionObjectType : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}

