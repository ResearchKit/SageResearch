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

/// `RSDUIStepObject` is the base class implementation for all UI display steps defined in this framework. Depending upon
/// the available real-estate, more than one ui step may be displayed at a time. For example, on an iPad, you may choose
/// to group a set of questions using a `RSDSectionStep`.
///
/// - seealso: `RSDActiveUIStepObject`, `RSDFormUIStepObject`, and `RSDThemedUIStep`
open class RSDUIStepObject : RSDUIActionHandlerObject, RSDThemedUIStep, RSDNavigationRule, Decodable, RSDMutableStep {

    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
    /// the UI.
    public let stepType: RSDStepType
    
    /// The primary text to display for the step in a localized string.
    public var title: String?
    
    /// Additional text to display for the step in a localized string.
    ///
    /// The additional text is often displayed in a smaller font below `title`. If you need to display a long
    /// question, it can work well to keep the title short and put the additional content in the `text` property.
    public var text: String?
    
    /// Additional detailed explanation for the step.
    ///
    /// The font size and display of this property will depend upon the device type.
    public var detail: String?
    
    /// Additional text to display for the step in a localized string at the bottom of the view.
    ///
    /// The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended to be
    /// used in order to include disclaimer, copyright, etc. that is important to display in the step but should not
    /// distract from the main purpose of the step.
    public var footnote: String?
    
    /// The view info used to create a custom step.
    open var viewTheme: RSDViewThemeElement?
    
    /// The color theme.
    open var colorTheme: RSDColorThemeElement?
    
    /// The image theme.
    open var imageTheme: RSDImageThemeElement?
    
    /// The next step to jump to. This is used where direct navigation is required. For example, to allow the task to display
    /// information or a question on an alternate path and then exit the task. In that case, the main branch of navigation
    /// will need to "jump" over the alternate path step and the alternate path step will need to "jump" to the "exit".
    open var nextStepIdentifier: String?
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - type: The type of the step. Default = `RSDStepType.instruction`
    public required init(identifier: String, type: RSDStepType? = nil) {
        self.identifier = identifier
        self.stepType = type ?? .instruction
        super.init()
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> Self {
        let copy = type(of: self).init(identifier: identifier, type: self.stepType)
        copyInto(copy as RSDUIStepObject)
        return copy
    }
    
    /// Swift subclass override for copying properties from the instantiated class of the `copy(with:)` method.
    /// Swift does not nicely handle casting from `Self` to a class instance for non-final classes. This is a
    /// work-around.
    open func copyInto(_ copy: RSDUIStepObject) {
        copy.title = self.title
        copy.text = self.text
        copy.detail = self.detail
        copy.footnote = self.footnote
        copy.viewTheme = self.viewTheme
        copy.colorTheme = self.colorTheme
        copy.imageTheme = self.imageTheme
        copy.nextStepIdentifier = self.nextStepIdentifier
        copy.actions = self.actions
        copy.shouldHideActions = self.shouldHideActions
    }

    // MARK: Result management
    
    /// Instantiate a step result that is appropriate for this step. Default implementation will return a `RSDResultObject`.
    /// - returns: A result for this step.
    open func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier)
    }
    
    // MARK: validation
    
    /// Required method. The base class implementation does nothing.
    open func validate() throws {
        // do nothing
    }
    
    // MARK: navigation
    
    /// Identifier for the next step to navigate to based on the current task result. All parameters are ignored by this
    /// implementation of the navigation rule. Instead, this will return `nextStepIdentifier` if defined.
    ///
    /// - returns: The identifier of the next step.
    open func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> String? {
        return self.nextStepIdentifier
    }
        
    private enum CodingKeys: String, CodingKey {
        case identifier
        case stepType = "type"
        case title
        case text
        case detail
        case footnote
        case nextStepIdentifier
        case viewTheme
        case colorTheme
        case imageTheme = "image"
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - note: The `imageTheme` can be decoded as a `RSDImageWrapper`, `RSDFetchableImageThemeElementObject`, or
    ///         `RSDAnimatedImageThemeElementObject`, depending upon the included dictionary.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON for a step with an `RSDAnimatedImageThemeElement`.
    ///         let json = """
    ///            {
    ///                "identifier": "foo",
    ///                "type": "instruction",
    ///                "title": "Hello World!",
    ///                "text": "Some text.",
    ///                "detail": "This is a test.",
    ///                "footnote": "This is a footnote.",
    ///                "nextStepIdentifier": "boo",
    ///                "actions": { "goForward": { "buttonTitle" : "Go, Dogs! Go!" },
    ///                             "cancel": { "iconName" : "closeX" },
    ///                             "learnMore": { "iconName" : "infoIcon",
    ///                                            "url" : "fooInfo" },
    ///                             "skip": { "buttonTitle" : "not applicable",
    ///                                        "skipToIdentifier": "boo"}
    ///                            },
    ///                "shouldHideActions": ["goBackward"],
    ///                "image"  : {    "imageNames" : ["foo1", "foo2", "foo3", "foo4"],
    ///                                "placementType" : "topBackground",
    ///                                "animationDuration" : 2,
    ///                                   },
    ///                "colorTheme"     : { "backgroundColor" : "sky", "foregroundColor" : "cream", "usesLightStyle" : true },
    ///                "viewTheme"      : { "viewIdentifier": "ActiveInstruction",
    ///                                     "storyboardIdentifier": "ActiveTaskSteps",
    ///                                     "bundleIdentifier": "org.example.SharedResources" }
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///         // Example JSON for a step with an `RSDFetchableImageThemeElement`.
    ///         let json = """
    ///            {
    ///                "identifier"   : "goOutside",
    ///                "type"         : "instruction",
    ///                "title"        : "Go outside",
    ///                "image"        : { "imageName": "goOutsideIcon", "placementType": "topBackground" },
    ///                "colorTheme"   : { "backgroundColor" : "robinsEggBlue", "usesLightStyle" : true },
    ///                "actions"      : { "goForward": { "buttonTitle": "I am outside" }},
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///         // Example JSON for a step with an `RSDImageWrapper`.
    ///         let json = """
    ///            {
    ///                "identifier"   : "blueDog",
    ///                "type"         : "instruction",
    ///                "title"        : "This is a blue dog",
    ///                "image"        : "blueDog",
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decode(RSDStepType.self, forKey: .stepType)
        
        self.nextStepIdentifier = try container.decodeIfPresent(String.self, forKey: .nextStepIdentifier)
        
        try super.init(from: decoder)
        
        try decode(from: decoder, for: nil)
    }
    
    func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote)
        
        self.viewTheme = try container.decodeIfPresent(RSDViewThemeElementObject.self, forKey: .viewTheme)
        self.colorTheme = try container.decodeIfPresent(RSDColorThemeElementObject.self, forKey: .colorTheme)
        if container.contains(.imageTheme) {
            let nestedDecoder = try container.superDecoder(forKey: .imageTheme)
            if let image = try? RSDImageWrapper(from: nestedDecoder) {
                self.imageTheme = image
            } else if let image = try? RSDFetchableImageThemeElementObject(from: nestedDecoder) {
                self.imageTheme = image
            } else {
                self.imageTheme = try RSDAnimatedImageThemeElementObject(from: nestedDecoder)
            }
        }
        
        if deviceType == nil {
            let subcontainer = try decoder.container(keyedBy: RSDDeviceType.self)
            let preferredType = decoder.factory.deviceType
            if subcontainer.contains(preferredType) {
                let subdecoder = try subcontainer.superDecoder(forKey: preferredType)
                try decode(from: subdecoder, for: preferredType)
            }
        }
    }
    
    /// A step to merge with this step that carries replacement info. This step will look at the replacement info
    /// in the generic step and replace properties on self as appropriate.
    ///
    /// For an `RSDUIStepObject`, the `title`, `text`, `detail`, and `footnote` properties can be replaced.
    open func replace(from step: RSDGenericStep) throws {
        self.title = step.userInfo[CodingKeys.title.stringValue] as? String ?? self.title
        self.text = step.userInfo[CodingKeys.text.stringValue] as? String ?? self.text
        self.detail = step.userInfo[CodingKeys.detail.stringValue] as? String ?? self.detail
        self.footnote = step.userInfo[CodingKeys.footnote.stringValue] as? String ?? self.footnote
    }
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = allCodingKeys()
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .stepType, .title, .text, .detail, .footnote, .nextStepIdentifier, .viewTheme, .colorTheme, .imageTheme]
        return codingKeys
    }
    
    override class func validateAllKeysIncluded() -> Bool {
        guard super.validateAllKeysIncluded() else { return false }
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .stepType:
                if idx != 1 { return false }
            case .title:
                if idx != 2 { return false }
            case .text:
                if idx != 3 { return false }
            case .detail:
                if idx != 4 { return false }
            case .footnote:
                if idx != 5 { return false }
            case .nextStepIdentifier:
                if idx != 6 { return false }
            case .viewTheme:
                if idx != 7 { return false }
            case .colorTheme:
                if idx != 8 { return false }
            case .imageTheme:
                if idx != 9 { return false }
            }
        }
        return keys.count == 10
    }
    
    class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
            "identifier": "foo",
            "type": "instruction",
            "title": "Hello World!",
            "text": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "nextStepIdentifier": "boo",
            "actions": [ "goForward": [ "buttonTitle" : "Go, Dogs! Go!" ],
                         "cancel": [ "iconName" : "closeX" ],
                         "learnMore": [ "iconName" : "infoIcon",
                                        "url" : "fooInfo" ],
                         "skip": [ "buttonTitle" : "not applicable",
                                   "skipToIdentifier": "boo"]
            ],
            "shouldHideActions": ["goBackward"],
            "image"  : [    "imageNames" : ["foo1", "foo2", "foo3", "foo4"],
                            "placementType" : "topBackground",
                            "animationDuration" : 2,
            ],
            "colorTheme"     : [ "backgroundColor" : "sky", "foregroundColor" : "cream", "usesLightStyle" : true ],
            "viewTheme"      : [ "viewIdentifier": "ActiveInstruction",
                                 "storyboardIdentifier": "ActiveTaskSteps",
                                 "bundleIdentifier": "org.example.SharedResources" ]
        ]
        
        // Example JSON for a step with an `RSDFetchableImageThemeElement`.
        let jsonB: [String : RSDJSONValue] = [
            "identifier"   : "goOutside",
            "type"         : "instruction",
            "title"        : "Go outside",
            "image"        : [ "imageName": "goOutsideIcon", "placementType": "topBackground" ],
            "colorTheme"   : [ "backgroundColor" : "robinsEggBlue", "usesLightStyle" : true ],
            "actions"      : [ "goForward": [ "buttonTitle": "I am outside" ]],
            ]
        
        // Example JSON for a step with an `RSDImageWrapper`.
        let jsonC: [String : RSDJSONValue] = [
            "identifier"   : "blueDog",
            "type"         : "instruction",
            "title"        : "This is a blue dog",
            "image"        : "blueDog",
            ]
        
        return [jsonA, jsonB, jsonC]
    }
}

extension RSDUIStepObject : RSDDocumentableDecodableObject {
}

