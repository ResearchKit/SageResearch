//
//  RSDChoiceObject.swift
//  ResearchSuite
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

public struct RSDChoiceObject<T : Codable> : RSDChoice, RSDEmbeddedIconVendor, Codable {
    public typealias Value = T
    
    private let _value: Value
    public var value: Codable {
        return _value
    }
    
    public let text: String?
    public let detail: String?
    public let icon: RSDImageWrapper?
    public let isExclusive: Bool
    
    public var hasIcon: Bool {
        return icon != nil
    }
    
    public init(value: Value, text: String? = nil, iconName: String? = nil, detail: String? = nil, isExclusive: Bool = false) throws {
        _value = value
        if text == nil && iconName == nil && value is String {
            // If both the text and the icon are nil, then see if the value is a string and if so, set that as the text.
            self.text = "\(value)"
        }
        else {
            self.text = text
        }
        self.detail = detail
        self.icon = (iconName != nil) ? try RSDImageWrapper(imageName: iconName!) : nil
        self.isExclusive = isExclusive
    }
    
    // MARK: Codable
    
    private enum CodingKeys : String, CodingKey {
        case value, text, detail, icon, isExclusive
    }

    public init(from decoder: Decoder) throws {
        
        var value: Value
        var text: String?
        var detail: String?
        var icon: RSDImageWrapper?
        var isExclusive = false
        
        do {
            // Look to see if the container is a dictionary and parse the keys
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(Value.self, forKey: .value)
            text = try container.decodeIfPresent(String.self, forKey: .text)
            detail = try container.decodeIfPresent(String.self, forKey: .detail)
            icon = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .icon)
            isExclusive = try container.decodeIfPresent(Bool.self, forKey: .isExclusive) ?? false
        }
        catch DecodingError.typeMismatch(let type, let context) {
            // If attempting to get a dictionary fails, then look to see if this is a single String value
            if Value.self == String.self {
                do {
                    let container = try decoder.singleValueContainer()
                    value = try container.decode(Value.self)
                    text = value as? String
                }
                catch {
                    // If we did not succeed in creating a single value/text String from the decoder, then rethrow the error
                    throw DecodingError.typeMismatch(type, context)
                }
            }
            else {
                throw DecodingError.typeMismatch(type, context)
            }
        }
        
        _value = value
        self.text = text
        self.detail = detail
        self.icon = icon
        self.isExclusive = isExclusive
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_value, forKey: .value)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(detail, forKey: .detail)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encode(isExclusive, forKey: .isExclusive)
    }
}
