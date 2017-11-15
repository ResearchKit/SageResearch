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

open class RSDUIStepObject : RSDUIActionHandlerObject, RSDThemedUIStep, RSDNavigationRule, Decodable, RSDMutableStep {

    public private(set) var identifier: String
    public private(set) var type: String
    
    public var title: String?
    public var text: String?
    public var detail: String?
    public var footnote: String?
    
    public var viewTheme: RSDViewThemeElement?
    public var colorTheme: RSDColorThemeElement?
    public var imageTheme: RSDImageThemeElement?
    
    open var nextStepIdentifier: String?
    
    public init(identifier: String, type: String? = nil) {
        self.identifier = identifier
        self.type = type ?? RSDFactory.StepType.instruction.rawValue
        super.init()
    }
    
    // MARK: Result management
    
    open func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier)
    }
    
    // MARK: validation
    
    open func validate() throws {
        // do nothing
    }
    
    // MARK: navigation
    
    open func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> String? {
        return self.nextStepIdentifier
    }
    
    // MARK: Codable (must implement in base class in order for the overriding classes to work)
    
    private enum CodingKeys: String, CodingKey {
        case identifier, replacementIdentifier, type, title, text, detail, footnote, actions, shouldHideActions, nextStepIdentifier, viewTheme, colorTheme, image
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decode(String.self, forKey: .type)
        
        self.nextStepIdentifier = try container.decodeIfPresent(String.self, forKey: .nextStepIdentifier)
        
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote)
        
        self.viewTheme = try container.decodeIfPresent(RSDViewThemeElementObject.self, forKey: .viewTheme)
        self.colorTheme = try container.decodeIfPresent(RSDColorThemeElementObject.self, forKey: .colorTheme)
        if container.contains(.image) {
            let nestedDecoder = try container.superDecoder(forKey: .image)
            if let imageWrapper = try? RSDImageWrapper(from: nestedDecoder) {
                self.imageTheme = imageWrapper
            } else {
                self.imageTheme = try RSDAnimatedImageThemeElementObject(from: nestedDecoder)
            }
        }
        
        try super.init(from: decoder)
    }
    
    open func replace(from step: RSDGenericStep) throws {
        self.title = step.userInfo?[CodingKeys.title.stringValue] as? String ?? self.title
        self.text = step.userInfo?[CodingKeys.text.stringValue] as? String ?? self.text
        self.detail = step.userInfo?[CodingKeys.detail.stringValue] as? String ?? self.detail
        self.footnote = step.userInfo?[CodingKeys.footnote.stringValue] as? String ?? self.footnote
    }
}

