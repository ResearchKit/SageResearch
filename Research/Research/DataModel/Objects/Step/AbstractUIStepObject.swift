//
//  AbstractUIStepObject.swift
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

/// `AbstractUIStepObject` is an alternative pattern to `RSDUIStepObject`. This class is not used
/// within this framework and is provided as-is as a simpler abstract class to the `RSDUIStepObject`
/// that implements an expanding set of features provided by all the UI steps registered by
/// default with the `StepSerializer`.
///
/// Generally speaking, if you are interested in using a simpler class that only implements the
/// action handling and designable step protocols, you should consider writing your own
/// implementation that does not inherit from this class. That way, you can more easily control
/// which features you want to expose.
///
/// - seealso: `RSDUIStepObject`
open class AbstractUIStepObject : RSDUIActionHandlerObject, RSDDesignableUIStep, Decodable {

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier
        case stepType = "type"
        case title
        case subtitle
        case detail
        case footnote
        case viewTheme
        case colorMapping
        case image
    }

    /// A short string that uniquely identifies the step within the task. The identifier is
    /// reproduced in the results of a step history.
    public let identifier: String
    
    /// The type of the step. This is used to decode the step using an `RSDFactory`. It can also be
    /// used to customize the UI.
    public let stepType: RSDStepType
    
    /// The primary text to display for the step in a localized string.
    open private(set) var title: String?
    
    /// Additional text to display for the step in a localized string.
    open private(set) var subtitle: String?
    
    /// The detailed text to display for the step in a localized string.
    open private(set) var detail: String?
    
    /// Additional text to display for the step in a localized string at the bottom of the view.
    ///
    /// The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended
    /// to be used in order to include disclaimer, copyright, etc. that is important to display in the step
    /// but should not distract from the main purpose of the step.
    open private(set) var footnote: String?
    
    /// The view info used to create a custom step.
    open private(set) var viewTheme: RSDViewThemeElement?
    
    /// The color theme.
    open private(set) var colorMapping: RSDColorMappingThemeElement?
    
    /// The image theme.
    open private(set) var imageTheme: RSDImageThemeElement?
    
    /// Default initializer.

    public init(identifier: String,
                stepType: RSDStepType,
                title: String? = nil,
                subtitle: String? = nil,
                detail: String? = nil,
                footnote: String? = nil,
                viewTheme: RSDViewThemeElement? = nil,
                colorMapping: RSDColorMappingThemeElement? = nil,
                imageTheme: RSDImageThemeElement? = nil) {
        
        self.identifier = identifier
        self.stepType = stepType
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.footnote = footnote
        self.viewTheme = viewTheme
        self.colorMapping = colorMapping
        self.imageTheme = imageTheme
        
        super.init()
    }


    // MARK: Result management
    
    /// Instantiate a step result that is appropriate for this step. Default implementation will return an `RSDResultObject`.
    /// - returns: A result for this step.
    open func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier)
    }
    
    // MARK: validation
    
    /// Required method. The base class implementation does nothing.
    open func validate() throws {
        // do nothing
    }
    
    // MARK: Decodable
    
    /// Initialize from a `Decoder`.
    ///
    /// - note: The `imageTheme` can be decoded as a `RSDFetchableImageThemeElementObject` or
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
    ///                "subtitle": "Some text.",
    ///                "detail": "This is a test.",
    ///                "footnote": "This is a footnote.",
    ///                "actions": { "goForward": { "type": "default", "buttonTitle" : "Go, Dogs! Go!" },
    ///                             "cancel": { "type": "default", "iconName" : "closeX" }
    ///                            },
    ///                "shouldHideActions": ["goBackward"],
    ///                "image"  : {    "type" : "animated",
    ///                                "imageNames" : ["foo1", "foo2", "foo3", "foo4"],
    ///                                "placementType" : "topBackground",
    ///                                "animationDuration" : 2,
    ///                                   },
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
    ///                "image"        : {   "type" : "fetchable",
    ///                                     "imageName": "goOutsideIcon",
    ///                                     "placementType": "topBackground" },
    ///                "colorMapping"   : { "customColor": {"backgroundColor" : "robinsEggBlue", "usesLightStyle" : true }},
    ///                "actions"      : { "goForward": { "type": "default", "buttonTitle": "I am outside" }},
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decode(RSDStepType.self, forKey: .stepType)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote)
        
        if container.contains(.viewTheme) {
            let nestedDecoder = try container.superDecoder(forKey: .viewTheme)
            self.viewTheme = try decoder.factory.decodePolymorphicObject(RSDViewThemeElement.self, from: nestedDecoder)
        }
        if container.contains(.colorMapping) {
            let nestedDecoder = try container.superDecoder(forKey: .colorMapping)
            self.colorMapping = try decoder.factory.decodePolymorphicObject(RSDColorMappingThemeElement.self, from: nestedDecoder)
        }
        if container.contains(.image) {
            let nestedDecoder = try container.superDecoder(forKey: .image)
            self.imageTheme = try decoder.factory.decodePolymorphicObject(RSDImageThemeElement.self, from: nestedDecoder)
        }
        
        try super.init(from: decoder)
    }
}
