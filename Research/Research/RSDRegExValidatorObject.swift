//
//  RSDRegExValidatorObject.swift
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

/// The `RSDRegExValidatorObject` is a concrete implementation of the `RSDCodableRegExMatchValidator`
/// that can be used to create a regex validation of an input string using a regex pattern.
@available(*, deprecated, message: "Use `KeyboardOptions` and `TextInputValidator` instead.")
public struct RSDRegExValidatorObject : RSDCodableRegExMatchValidator {
    
    /// A localized custom regular expression that can be used to validate a string.
    public let regExPattern: String
    
    /// Default initializer.
    /// - parameter regExPattern: The regular expression pattern.
    public init(regExPattern: String) throws {
        self.regExPattern = regExPattern
    }
}

@available(*, deprecated, message: "Use `KeyboardOptions` and `TextInputValidator` instead.")
extension RSDRegExValidatorObject : RawRepresentable, Equatable {
    
    /// The `regExPattern` is used to represent the regex.
    public var rawValue: String {
        return regExPattern
    }
    
    /// Required initializer for conformance to `RawRepresentable`. This will return `nil` if the reg ex
    /// is not valid.
    public init?(rawValue: String) {
        do {
            try self.init(regExPattern: rawValue)
        } catch let err {
            assertionFailure("Failed to create reg ex: \(err)")
            return nil
        }
    }
}

@available(*, deprecated, message: "Use `KeyboardOptions` and `TextInputValidator` instead.")
extension RSDRegExValidatorObject : Decodable {
    
    /// Required initializer for conformance to `Decodable`.
    /// - parameter decoder: The decoder to use to decode this value. This is expected to have a single value container.
    /// - throws: `DecodingError` if the value is not a `String` or if the `regExPattern` throws an exception when creating
    ///          an `NSRegularExpression` using this pattern.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let pattern = try container.decode(String.self)
        let _ = try NSRegularExpression(pattern: pattern, options: [])
        self.regExPattern = pattern
    }
}

@available(*, deprecated, message: "Use `KeyboardOptions` and `TextInputValidator` instead.")
extension RSDRegExValidatorObject : Encodable {
}

