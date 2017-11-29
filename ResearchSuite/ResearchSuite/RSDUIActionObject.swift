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

/// `RSDEmbeddedResourceUIAction` is a convenience protocol for returning an image using an encodable strings for the
/// name and bundle identifier.
public protocol RSDEmbeddedResourceUIAction: RSDUIAction, RSDDecodableBundleInfo {
    
    /// The name of the icon to display on the button associated with this action.
    var iconName: String? { get }
}

extension RSDEmbeddedResourceUIAction {
    
    /// The icon to display on the button associated with this action.
    public var buttonIcon: UIImage? {
        guard let name = iconName else { return nil }
        #if os(watchOS)
            return UIImage(named: name)
        #else
            return UIImage(named: name, in: bundle, compatibleWith: nil)
        #endif
    }
}

/// `RSDUIActionObject` is a concrete implementation of `RSDUIAction` that can be used to customize the
/// title and image displayed for a given action of the UI.
public struct RSDUIActionObject : RSDEmbeddedResourceUIAction, Codable {
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// Default initializer for a button with text.
    /// - parameter buttonTitle: The title to display on the button associated with this action.
    public init(buttonTitle: String) {
        self.buttonTitle = buttonTitle
        self.iconName = nil
    }
    
    /// Default initializer for a button with an image.
    /// - parameters:
    ///     - iconName: The name of the image to display on the button.
    ///     - bundleIdentifier: The bundle identifier for the resource bundle that contains the image.
    public init(iconName: String, bundleIdentifier: String? = nil) {
        self.buttonTitle = nil
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
    }
    
    private enum CodingKeys : String, CodingKey {
        case buttonTitle, iconName, bundleIdentifier
    }
}

/// `RSDSkipToUIActionObject` implements an action that includes an identifier for a step to skip to if this
/// action is called. This is used by the `RSDConditionalStepNavigator` to navigate based on a `nil` result.
/// - seealso: `RSDSurveyNavigationStep`
public struct RSDSkipToUIActionObject : RSDEmbeddedResourceUIAction, RSDSkipToUIAction {
    
    /// The identifier for the step to skip to if the action is called.
    public let skipToIdentifier: String
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - skipToIdentifier: The identifier for the step to skip to if the action is called.
    ///     - buttonTitle: The title to display on the button associated with this action.
    public init(skipToIdentifier: String, buttonTitle: String) {
        self.skipToIdentifier = skipToIdentifier
        self.buttonTitle = buttonTitle
    }
    
    /// Default initializer for a button with an image.
    /// - parameters:
    ///     - skipToIdentifier: The identifier for the step to skip to if the action is called.
    ///     - iconName: The name of the image to display on the button.
    ///     - bundleIdentifier: The bundle identifier for the resource bundle that contains the image.
    public init(skipToIdentifier: String, iconName: String, bundleIdentifier: String? = nil) {
        self.skipToIdentifier = skipToIdentifier
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
    }
    
    // MARK: Codable implementation (auto synthesized implementation does not work with subclassing)
    
    private enum CodingKeys : String, CodingKey {
        case skipToIdentifier, buttonTitle, iconName, bundleIdentifier
    }
}

/// `RSDWebViewUIActionObject` implements an action that includes a pointer to a url that can display in a
/// webview. The url can either be fully qualified or optionally point to an embedded resource. The resource
/// bundle is assumed to be the main bundle if the `bundleIdentifier` property is `nil`.
public struct RSDWebViewUIActionObject : RSDEmbeddedResourceUIAction, RSDWebViewUIAction {

    /// The url to load in the webview. If this is not a fully qualified url string, then it is assumed to refer
    /// to an embedded resource.
    public let url: String
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// The `url` is the resource name.
    public var resourceName: String {
        return url
    }
    
    /// Returns nil. This value is ignored.
    public var classType: String? {
        return nil
    }
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - buttonTitle: The title to display on the button associated with this action.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. Default = `nil`.
    public init(url: String, buttonTitle: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.buttonTitle = buttonTitle
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Default initializer for a button with an image.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - iconName: The name of the image to display on the button.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. This is also used
    ///       as the bundle for the image. Default = `nil`.
    public init(url: String, iconName: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
    }
    
    // MARK: Codable implementation (auto synthesized implementation does not work with subclassing)
    
    private enum CodingKeys : String, CodingKey {
        case  url, buttonTitle, iconName, bundleIdentifier
    }
}


extension RSDUIActionObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.buttonTitle, .iconName, .bundleIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .buttonTitle:
                if idx != 0 { return false }
            case .iconName:
                if idx != 1 { return false }
            case .bundleIdentifier:
                if idx != 2 { return false }
            }
        }
        return keys.count == 3
    }
    
    static func actionExamples() -> [RSDUIActionObject] {
        let titleAction = RSDUIActionObject(buttonTitle: "Go, Dogs! Go")
        let imageAction = RSDUIActionObject(iconName: "closeX", bundleIdentifier: "org.example.SharedResources")
        return [titleAction, imageAction]
    }
    
    static func examples() -> [Encodable] {
        return actionExamples()
    }
}

extension RSDSkipToUIActionObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.buttonTitle, .iconName, .bundleIdentifier, .skipToIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .buttonTitle:
                if idx != 0 { return false }
            case .iconName:
                if idx != 1 { return false }
            case .bundleIdentifier:
                if idx != 2 { return false }
            case .skipToIdentifier:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func actionExamples() -> [RSDSkipToUIActionObject] {
        let titleAction = RSDSkipToUIActionObject(skipToIdentifier: "nextSection", buttonTitle: "Go, Dogs! Go")
        let imageAction = RSDSkipToUIActionObject(skipToIdentifier: "nextSection", iconName: "closeX", bundleIdentifier: "org.example.SharedResources")
        return [titleAction, imageAction]
    }
    
    static func examples() -> [Encodable] {
        return actionExamples()
    }
}

extension RSDWebViewUIActionObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.buttonTitle, .iconName, .bundleIdentifier, .url]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .buttonTitle:
                if idx != 0 { return false }
            case .iconName:
                if idx != 1 { return false }
            case .bundleIdentifier:
                if idx != 2 { return false }
            case .url:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func actionExamples() -> [RSDWebViewUIActionObject] {
        let titleAction = RSDWebViewUIActionObject(url: "About_Dogs.html", buttonTitle: "Go, Dogs! Go")
        let imageAction = RSDWebViewUIActionObject(url: "About_Dogs.html", iconName: "iconInfo", bundleIdentifier: "org.example.SharedResources")
        return [titleAction, imageAction]
    }
    
    static func examples() -> [Encodable] {
        return actionExamples()
    }
}
