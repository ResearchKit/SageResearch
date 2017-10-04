//
//  RSDInputFieldObject.swift
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

open class RSDInputFieldObject : RSDInputField, Codable {
    
    public private(set) var identifier: String
    public private(set) var prompt: String?
    
    open private(set) var dataType: RSDFormDataType
    open private(set) var uiHint: RSDFormUIHint?
    
    open var placeholderText: String?
    open var textFieldOptions: RSDTextFieldOptions?
    open var range: RSDRange?
    open var optional: Bool = false
    
    public init(identifier: String, dataType: RSDFormDataType, prompt: String? = nil, placeholderText: String? = nil, uiHint: RSDFormUIHint? = nil) {
        self.identifier = identifier
        self.dataType = dataType
        self.prompt = prompt
        self.placeholderText = placeholderText
        self.uiHint = uiHint
    }
    
    open func validate() throws {
        // TODO: syoung 10/04/2017 Implement
    }
    
    open func validateResult(_ result: RSDAnswerResult) throws -> Bool {
        // TODO: syoung 10/04/2017 Implement
        return true
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, prompt, placeholderText, dataType, uiHint, optional
    }
    
    open class func dataType(from decoder: Decoder) throws -> RSDFormDataType {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        return try container.decode(RSDFormDataType.self, forKey: .dataType)
    }
    
    public required init(from decoder: Decoder) throws {
        self.dataType = try type(of: self).dataType(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.prompt = try container.decodeIfPresent(String.self, forKey: .prompt)
        self.placeholderText = try container.decodeIfPresent(String.self, forKey: .placeholderText)
        self.uiHint = try container.decodeIfPresent(RSDFormUIHint.self, forKey: .uiHint)
        self.optional = try container.decodeIfPresent(Bool.self, forKey: .optional) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.dataType, forKey: .dataType)
        if let obj = self.prompt { try container.encode(obj, forKey: .prompt) }
        if let obj = self.placeholderText { try container.encode(obj, forKey: .placeholderText) }
        if let obj = self.uiHint { try container.encode(obj, forKey: .uiHint) }
        try container.encode(self.optional, forKey: .optional)
    }
}
