//
//  RSDResultType.swift
//  ResearchStack2
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

/// `RSDResultType` is an extendable string enum used by `RSDFactory` to create the appropriate
/// result type.
public struct RSDResultType : RawRepresentable, Codable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to creating a `RSDResult`.
    public static let base: RSDResultType = "base"
    
    /// Defaults to creating a `RSDAnswerResult`.
    public static let answer: RSDResultType = "answer"
    
    /// Defaults to creating a `RSDCollectionResult`.
    public static let collection: RSDResultType = "collection"
    
    /// Defaults to creating a `RSDMedicationTrackingResult`.
    public static let medication: RSDResultType = "medication"
    
    /// Defaults to creating a `RSDSelectionResult`.
    public static let selection: RSDResultType = "selection"
    
    /// Defaults to creating a `RSDTaskResult`.
    public static let task: RSDResultType = "task"
    
    /// Defaults to creating a `RSDFileResult`.
    public static let file: RSDResultType = "file"
    
    /// Defaults to creating a `RSDErrorResult`.
    public static let error: RSDResultType = "error"
    
    /// Defaults to creating a `RSDNavigationResult`.
    public static let navigation: RSDResultType = "navigation"
    
    /// List of all the standard types.
    public static func allStandardTypes() -> [RSDResultType] {
        return [.base, .answer, .collection, .task, .file, .error]
    }
}

extension RSDResultType : Equatable {
    public static func ==(lhs: RSDResultType, rhs: RSDResultType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDResultType) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDResultType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDResultType : Hashable {
    public var hashValue : Int {
        return self.rawValue.hashValue
    }
}

extension RSDResultType : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDResultType : RSDDocumentableStringEnum {
    static func allCodingKeys() -> [String] {
        return allStandardTypes().map{ $0.rawValue }
    }
}
