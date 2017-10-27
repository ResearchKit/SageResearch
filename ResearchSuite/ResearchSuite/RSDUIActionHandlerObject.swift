//
//  RSDUIActionHandlerObject.swift
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

/**
 `RSDUIActionHandlerObject` is intended as an abstract implementation of the action handler that implements the `Codable` protocol.
 */
open class RSDUIActionHandlerObject : RSDUIActionHandler {
    
    public var actions: [RSDUIActionType : RSDUIAction]?
    public var shouldHideActions: [RSDUIActionType]?
    
    public init() {
    }
    
    open func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return actions?[actionType]
    }
    
    open func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return shouldHideActions?.contains(actionType)
    }
    
    // MARK: Codable (must implement in base class in order for the overriding classes to work)
    
    private enum CodingKeys: String, CodingKey {
        case actions, shouldHideActions
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shouldHideActions = try container.decodeIfPresent([RSDUIActionType].self, forKey: .shouldHideActions)
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
    
    /// Define the encoder, but do not require protocol conformance of subclasses
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let actions = self.actions {
            var nestedContainer = container.nestedContainer(keyedBy: RSDUIActionType.self, forKey: .actions)
            for (key, action) in actions {
                let objectEncoder = nestedContainer.superEncoder(forKey: key)
                try action.encode(to: objectEncoder)
            }
        }
        try container.encodeIfPresent(shouldHideActions, forKey: .shouldHideActions)
    }
}
