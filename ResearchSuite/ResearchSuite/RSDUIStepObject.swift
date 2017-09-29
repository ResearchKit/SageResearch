//
//  RSDUIStepObject.swift
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

open class RSDUIStepObject : RSDUIStep, Codable {
    
    public private(set) var identifier: String
    
    public var title: String?
    public var text: String?
    public var detail: String?
    public var footnote: String?
    
    public var imageBefore: RSDImageWrapper?
    public var imageAfter: RSDImageWrapper?
    
    public var actions: [RSDUIActionType : RSDUIActionObject]?
    public var shouldHideActions: [RSDUIActionType]?
    
    public required init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: Image handling
    
    open func imageBefore(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: imageBefore, for: size, callback: callback)
    }
    
    open func imageAfter(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: imageAfter, for: size, callback: callback)
    }
    
    // MARK: action handling
    
    open func action(for actionType: RSDUIActionType) -> RSDUIAction? {
        return actions?[actionType]
    }
    
    open func shouldHideAction(for actionType: RSDUIActionType) -> Bool {
        return shouldHideActions?.contains(actionType) ?? false
    }
    
    // MARK: validation
    
    open func validate() throws {
        // do nothing
    }
    
    // MARK: Codable (must implement in base class in order for the overriding classes to work)
    
    private enum CodingKeys: String, CodingKey {
        case identifier, title, text, detail, footnote, imageBefore, imageAfter, actions, shouldHideActions
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote)
        self.imageBefore = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .imageBefore)
        self.imageAfter = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .imageAfter)
        if let dictionary = try container.decodeIfPresent([String : RSDUIActionObject].self, forKey: .actions) {
            self.actions = dictionary.mapKeys { RSDUIActionType(stringLiteral: $0) }
        }
        self.shouldHideActions = try container.decodeIfPresent([RSDUIActionType].self, forKey: .shouldHideActions)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        if let title = self.title { try container.encode(title, forKey: .title) }
        if let text = self.text { try container.encode(text, forKey: .text) }
        if let detail = self.detail { try container.encode(detail, forKey: .detail) }
        if let footnote = self.footnote { try container.encode(footnote, forKey: .footnote) }
        if let imageBefore = self.imageBefore { try container.encode(imageBefore, forKey: .imageBefore) }
        if let imageAfter = self.imageAfter { try container.encode(imageAfter, forKey: .imageAfter) }
        if let actions = self.actions {
            let dictionary = actions.mapKeys{ $0.rawValue }
            try container.encode(dictionary, forKey: .actions)
        }
        if let shouldHideActions = self.shouldHideActions { try container.encode(shouldHideActions, forKey: .shouldHideActions) }
    }
}

