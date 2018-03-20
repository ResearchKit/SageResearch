//
//  RSDStepNavigatorType.swift
//  ResearchSuite
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

/// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
/// the UI.
public struct RSDStepNavigatorType : RawRepresentable, Codable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDConditionalStepNavigatorObject`.
    public static let conditional: RSDStepNavigatorType = "conditional"
    
    /// Defaults to creating a `RSDMedicationTrackingStepNavigator`.
    public static let medicationTracking: RSDStepNavigatorType = "medicationTracking"
    
    /// Defaults to creating a `RSDTrackedItemsStepNavigator`.
    public static let tracking: RSDStepNavigatorType = "tracking"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDStepNavigatorType] {
        return [.conditional, .tracking, .medicationTracking]
    }
}

extension RSDStepNavigatorType : Equatable {
    public static func ==(lhs: String, rhs: RSDStepNavigatorType) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDStepNavigatorType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDStepNavigatorType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDStepNavigatorType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDStepNavigatorType : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}
