//
//  JsonChoiceObject.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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
import JsonModel

public protocol JsonComparable : RSDComparable {
    var matchingValue: JsonElement? { get }
}

public extension JsonComparable {
    var matchingAnswer: Any? {
        matchingValue?.jsonObject()
    }
}

public protocol JsonChoice : RSDChoice, JsonComparable {
}

public extension JsonChoice {
    var answerValue: Codable? {
        matchingValue ?? JsonElement.null
    }
}

public struct JsonChoiceObject : JsonChoice, Codable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case matchingValue = "value", text, detail, _isExclusive = "exclusive", icon
    }
    
    public let matchingValue: JsonElement?
    public let text: String?
    public let detail: String?
    
    public var isExclusive: Bool {
        _isExclusive ?? false
    }
    private let _isExclusive: Bool?
    
    public var imageData: RSDImageData? {
        icon
    }
    public let icon: RSDResourceImageDataObject?
    
    public init(matchingValue: JsonElement?,
                text: String?,
                detail: String? = nil,
                isExclusive: Bool? = nil,
                icon: RSDResourceImageDataObject? = nil) {
        self.matchingValue = matchingValue
        self.text = text
        self.detail = detail
        self._isExclusive = isExclusive
        self.icon = icon
    }
    
    public init(text: String) {
        self.text = text
        self.matchingValue = .string(text)
        self.detail = nil
        self._isExclusive = nil
        self.icon = nil
    }
}

extension JsonChoiceObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .matchingValue:
            return .init(propertyType: .any, propertyDescription: "The matching value is any json element, but all json elements within the collection of choices should have the same json type.")
        case .text, .detail:
            return .init(propertyType: .primitive(.string))
        case ._isExclusive:
            return .init(propertyType: .primitive(.boolean))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        }
    }
    
    public static func examples() -> [JsonChoiceObject] {
        return [JsonChoiceObject(matchingValue: .integer(1), text: "None of the above")]
    }
}

