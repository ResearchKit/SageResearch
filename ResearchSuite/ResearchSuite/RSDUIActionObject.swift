//
//  RSDUIActionObject.swift
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

open class RSDUIActionObject : RSDUIAction, Codable {
    
    public var buttonTitle: String?
    public var iconName: String?
    
    public var buttonIcon: UIImage? {
        guard let name = iconName else { return nil }
        return UIImage(named: name)
    }
    
    public init(buttonTitle: String) {
        self.buttonTitle = buttonTitle
        self.iconName = nil
    }
    
    public init(iconName: String) {
        self.buttonTitle = nil
        self.iconName = iconName
    }
    
    // MARK: Codable implementation (auto synthesized implementation does not work with subclassing)
    
    private enum CodingKeys : String, CodingKey {
        case  buttonTitle, iconName
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buttonTitle = try container.decodeIfPresent(String.self, forKey: .buttonTitle)
        self.iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let buttonTitle = self.buttonTitle { try container.encode(buttonTitle, forKey: .buttonTitle) }
        if let iconName = self.iconName { try container.encode(iconName, forKey: .iconName) }
    }
}

public final class RSDSkipToUIActionObject : RSDUIActionObject, RSDSkipToUIAction {
    
    public let skipToIdentifier: String
    
    public init(buttonTitle: String, skipToIdentifier: String) {
        self.skipToIdentifier = skipToIdentifier
        super.init(buttonTitle: buttonTitle)
    }
    
    public init(iconName: String, skipToIdentifier: String) {
        self.skipToIdentifier = skipToIdentifier
        super.init(iconName: iconName)
    }
    
    // MARK: Codable implementation (auto synthesized implementation does not work with subclassing)
    
    private enum CodingKeys : String, CodingKey {
        case skipToIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.skipToIdentifier = try container.decode(String.self, forKey: .skipToIdentifier)
        try super.init(from: decoder)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(skipToIdentifier, forKey: .skipToIdentifier)
    }
    
}

public final class RSDWebViewUIActionObject : RSDUIActionObject, RSDWebViewUIAction, RSDResourceTransformer {
    public let url: String
    public let resourceBundle: String?
    
    public var resourceName: String {
        return url
    }
    
    public var classType: String? {
        return nil
    }
    
    public init(buttonTitle: String, url: String, resourceBundle: String? = nil) {
        self.url = url
        self.resourceBundle = resourceBundle
        super.init(buttonTitle: buttonTitle)
    }
    
    public init(iconName: String, url: String, resourceBundle: String? = nil) {
        self.url = url
        self.resourceBundle = resourceBundle
        super.init(iconName: iconName)
    }
    
    // MARK: Codable implementation (auto synthesized implementation does not work with subclassing)
    
    private enum CodingKeys : String, CodingKey {
        case  url, resourceBundle
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.resourceBundle = try container.decodeIfPresent(String.self, forKey: .resourceBundle)
        try super.init(from: decoder)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(resourceBundle, forKey: .resourceBundle)
    }
}
