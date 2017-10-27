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

open class RSDUIStepObject : RSDUIStep, Codable, RSDNavigationRule {
    
    public let identifier: String
    public let type: String
    
    public var title: String?
    public var text: String?
    public var detail: String?
    public var footnote: String?
    
    public var imageBefore: RSDImageWrapper?
    public var imageAfter: RSDImageWrapper?
    
    public var actions: [RSDUIActionType : RSDUIAction]?
    public var shouldHideActions: [RSDUIActionType]?
    
    open var nextStepIdentifier: String?
    
    public init(identifier: String, type: String? = nil) {
        self.identifier = identifier
        self.type = type ?? RSDFactory.StepType.instruction.rawValue
    }
    
    // MARK: Result management
    
    open func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier)
    }
    
    // MARK: Image handling
    
    public var hasImageBefore: Bool {
        return imageBefore != nil
    }
    
    public var hasImageAfter: Bool {
        return imageAfter != nil
    }
    
    open func imageBefore(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: imageBefore, for: size, callback: callback)
    }
    
    open func imageAfter(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        RSDImageWrapper.fetchImage(image: imageAfter, for: size, callback: callback)
    }
    
    // MARK: action handling
    
    open func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return actions?[actionType]
    }
    
    open func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return shouldHideActions?.contains(actionType)
    }
    
    // MARK: validation
    
    open func validate() throws {
        // do nothing
    }
    
    // MARK: navigation
    
    open func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?) -> String? {
        return self.nextStepIdentifier
    }
    
    // MARK: Codable (must implement in base class in order for the overriding classes to work)
    
    private enum CodingKeys: String, CodingKey {
        case identifier, type, title, text, detail, footnote, imageBefore, imageAfter, actions, shouldHideActions, nextStepIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decode(String.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote)
        self.imageBefore = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .imageBefore)
        self.imageAfter = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .imageAfter)
        self.shouldHideActions = try container.decodeIfPresent([RSDUIActionType].self, forKey: .shouldHideActions)
        self.nextStepIdentifier = try container.decodeIfPresent(String.self, forKey: .nextStepIdentifier)
        
        if container.contains(.actions) {
            let nestedDecoder = try container.superDecoder(forKey: .actions)
            let nestedContainer = try nestedDecoder.container(keyedBy: AnyCodingKey.self)
            var actions: [RSDUIActionType : RSDUIAction] = [:]
            for key in nestedContainer.allKeys {
                let objectDecoder = try nestedContainer.superDecoder(forKey: key)
                let action = try decoder.factory.decodeUIAction(from: objectDecoder)
                actions[RSDUIActionType(rawValue: key.stringValue)] = action
            }
            self.actions = actions
        }
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(detail, forKey: .detail)
        try container.encodeIfPresent(footnote, forKey: .footnote)
        try container.encodeIfPresent(imageBefore, forKey: .imageBefore)
        try container.encodeIfPresent(imageAfter, forKey: .imageAfter)
        if let actions = self.actions {
            var nestedContainer = container.nestedContainer(keyedBy: RSDUIActionType.self, forKey: .actions)
            for (key, action) in actions {
                let objectEncoder = nestedContainer.superEncoder(forKey: key)
                try action.encode(to: objectEncoder)
            }
        }
        try container.encodeIfPresent(shouldHideActions, forKey: .shouldHideActions)
        try container.encodeIfPresent(nextStepIdentifier, forKey: .nextStepIdentifier)
    }
}

