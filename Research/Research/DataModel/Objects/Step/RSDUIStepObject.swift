//
//  RSDUIStepObject.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

extension RSDStepType {
    fileprivate static let nullStepType: RSDStepType = "null"
}

/// `RSDUIStepObject` is the base class implementation for all UI display steps defined in this framework.
/// Depending upon the available real-estate, more than one ui step may be displayed at a time. For
/// example, on an iPad, you may choose to group a set of questions using a `RSDSectionStep`.
///
/// - seealso: `RSDActiveUIStepObject`, `RSDFormUIStepObject`, and `RSDThemedUIStep`
open class RSDUIStepObject : RSDUIActionHandlerObject, RSDDesignableUIStep, RSDTableStep, RSDNavigationRule, RSDCohortNavigationStep, Decodable, RSDCopyStep, RSDDecodableReplacement, RSDStandardPermissionsStep, RSDOptionalStep {

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier
        case stepType = "type"
        case title
        case subtitle
        case detail
        case footnote
        case fullInstructionsOnly
        case nextStepIdentifier
        case permissions
        case viewTheme
        case colorMapping
        case image
        case beforeCohortRules
        case afterCohortRules
    }
    
    private enum DeprecatedCodingKeys: String, CodingKey {
        case colorTheme
        case text
    }

    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to
    /// customize the UI.
    public private(set) var stepType: RSDStepType
    
    /// The primary text to display for the step in a localized string.
    open var title: String?
    
    /// Additional text to display for the step in a localized string.
    open var subtitle: String?
    
    @available(*, deprecated, message: "This should map to either `detail` or `subtitle`")
    open var text: String?
    
    /// The detailed text to display for the step in a localized string.
    open var detail: String?
    
    /// Additional text to display for the step in a localized string at the bottom of the view.
    ///
    /// The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended
    /// to be used in order to include disclaimer, copyright, etc. that is important to display in the step
    /// but should not distract from the main purpose of the step.
    open var footnote: String?
    
    /// The permissions used by this task that are described by this step.
    open var standardPermissions: [RSDStandardPermission]?
    
    /// Should this step be displayed if and only if the flag has been set for displaying the full
    /// instructions?
    open var fullInstructionsOnly: Bool {
        get { _fullInstructionsOnly ?? false }
        set { _fullInstructionsOnly = newValue }
    }
    private var _fullInstructionsOnly: Bool?
    
    /// The view info used to create a custom step.
    open var viewTheme: RSDViewThemeElement?
    
    /// The color theme.
    open var colorMapping: RSDColorMappingThemeElement?
    
    /// The image theme.
    open var imageTheme: RSDImageThemeElement?
    
    /// The next step to jump to. This is used where direct navigation is required. For example, to allow the
    /// task to display information or a question on an alternate path and then exit the task. In that case,
    /// the main branch of navigation will need to "jump" over the alternate path step and the alternate path
    /// step will need to "jump" to the "exit".
    ///
    /// This step is not intended for "optional" navigation where the result might change the intended
    /// navigation. For the case where a user action might result in a different navigation path, you can
    /// have the step controller set the step result to a result that implements `RSDNavigationResult` and
    /// then set the `skipToIdentifier` on that result. `RSDResultObject` and `RSDCollectionResultObject`
    /// both implement this protocol. The reason for doing this is that each time a step is visited in a
    /// a navigation path, the **result** of that step is replaced with an immutable result and will **not**
    /// use the previous result navigation unless specifically set by the step controller.
    ///
    /// - seealso: `RSDStepViewController.assignSkipToIdentifier()`
    open private(set) var nextStepIdentifier: String?
    
    /// The navigation cohort rules to apply *before* displaying the step.
    public var beforeCohortRules: [RSDCohortNavigationRule]?
    
    /// The navigation cohort rules to apply *after* displaying the step.
    public var afterCohortRules: [RSDCohortNavigationRule]?
    
    /// The default step type.
    open class func defaultType() -> RSDStepType {
        return .instruction
    }
    
    private func commonInit() {
        // Use of the `.nullStepType` as a placeholder is b/c of a limitation where type(of: self) cannot
        // be accessed prior to initializing super and the stepType is required.
        if self.stepType == .nullStepType {
            self.stepType = type(of: self).defaultType()
        }
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - type: The type of the step. Default = `RSDStepType.instruction`
    public required init(identifier: String, type: RSDStepType? = nil) {
        self.identifier = identifier
        self.stepType = type ?? .nullStepType
        self._initCompleted = false
        super.init()
        self.commonInit()
        self._initCompleted = true
    }
    
    /// Initializer for setting the immutable next step identifier.
    ///
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - nextStepIdentifier: The next step to jump to. This is used where direct navigation is required.
    ///     - type: The type of the step. Default = `RSDStepType.instruction`
    public init(identifier: String, nextStepIdentifier: String?, type: RSDStepType? = nil) {
        self.identifier = identifier
        self.stepType = type ?? .nullStepType
        self.nextStepIdentifier = nextStepIdentifier
        self._initCompleted = false
        super.init()
        self.commonInit()
        self._initCompleted = true
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public final func copy(with identifier: String) -> Self {
        return try! copy(with: identifier, decoder: nil)
    }
    
    /// Copy the step to a new instance with the given identifier and user info.
    /// - parameters:
    ///     - identifier: The new identifier.
    ///     - decoder: A decoder that can be used to decode properties on this step.
    public final func copy(with identifier: String, decoder: Decoder?) throws -> Self {
        let copy = type(of: self).init(identifier: identifier, type: self.stepType)
        self.copyInto(copy)
        if let decoder = decoder {
            try copy.decode(from: decoder, for: nil)
            try copy.decodeActions(from: decoder)
        }
        return copy
    }
    
    /// Swift subclass override for copying properties from the instantiated class of the `copy(with:)`
    /// method. Swift does not nicely handle casting from `Self` to a class instance for non-final classes.
    /// This is a work around.
    open func copyInto(_ copy: RSDUIStepObject) {
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.footnote = self.footnote
        copy.viewTheme = self.viewTheme
        copy.colorMapping = self.colorMapping
        copy.imageTheme = self.imageTheme
        copy.nextStepIdentifier = self.nextStepIdentifier
        copy.actions = self.actions
        copy.shouldHideActions = self.shouldHideActions
        copy.beforeCohortRules = self.beforeCohortRules
        copy.afterCohortRules = self.afterCohortRules
        copy.standardPermissions = self.standardPermissions
        copy._fullInstructionsOnly = self._fullInstructionsOnly
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
    
    // MARK: Navigation
    
    /// Identifier for the next step to navigate to based on the current task result. By default, if there is
    /// a navigation `skipToIdentifier` for this step, then that will be honored. Otherwise, this will return
    /// `nextStepIdentifier`.
    ///
    /// - returns: The identifier of the next step.
    open func nextStepIdentifier(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        if let navigationResult = result?.findResult(for: self) as? RSDNavigationResult,
            let skipTo = navigationResult.skipToIdentifier,
            !isPeeking {
            return skipTo
        }
        else {
            return self.nextStepIdentifier
        }
    }
    
    // MARK: Table source
    
    open func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        return RSDUIStepTableDataSourceImpl(step: self, parent: parent)
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
    ///                "nextStepIdentifier": "boo",
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
    ///                                     "bundleIdentifier": "org.example.SharedResources" },
    ///                "beforeCohortRules" : { "requiredCohorts" : ["boo", "goo"],
    ///                                        "skipToIdentifier" : "blueGu",
    ///                                        "operator" : "any" },
    ///                "afterCohortRules" : { "requiredCohorts" : ["boo", "goo"],
    ///                                        "skipToIdentifier" : "blueGu",
    ///                                        "operator" : "any" }
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
        
        self.nextStepIdentifier = try container.decodeIfPresent(String.self, forKey: .nextStepIdentifier)

        self._initCompleted = false
        try super.init(from: decoder)
        try decode(from: decoder, for: nil)
        self.commonInit()
        self._initCompleted = true
    }
    private var _initCompleted: Bool
    
    /// Decode from the given decoder, replacing values on self with those from the decoder
    /// if the properties are mutable.
    public final func decode(from decoder: Decoder) throws {
        try decode(from: decoder, for: nil)
        try decodeActions(from: decoder)
    }
    
    /// Decode from the given decoder, replacing values on self with those from the decoder
    /// if the properties are mutable. This function is designed to loop through a second
    /// pass to replace any values that should be decoded for a specific device type.
    open func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let deprecatedContainer = try decoder.container(keyedBy: DeprecatedCodingKeys.self)
        
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? self.title
        
        if let text = try deprecatedContainer.decodeIfPresent(String.self, forKey: .text) {
            debugPrint("WARNING!!! `text` keyword on a UIStepObject decoding is deprecated and will be deleted in future versions.")
            self.subtitle = text
        }
        else {
            self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? self.subtitle
        }
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? self.detail

        self.footnote = try container.decodeIfPresent(String.self, forKey: .footnote) ?? self.footnote
        self.standardPermissions = try container.decodeIfPresent([RSDStandardPermission].self, forKey: .permissions) ?? self.standardPermissions
        self._fullInstructionsOnly = try container.decodeIfPresent(Bool.self, forKey: .fullInstructionsOnly) ?? self._fullInstructionsOnly
    
        self.beforeCohortRules = try container.decodeIfPresent([RSDCohortNavigationRuleObject].self, forKey: .beforeCohortRules) ?? self.beforeCohortRules
        self.afterCohortRules = try container.decodeIfPresent([RSDCohortNavigationRuleObject].self, forKey: .afterCohortRules) ?? self.afterCohortRules
        
        if container.contains(.viewTheme) {
            let nestedDecoder = try container.superDecoder(forKey: .viewTheme)
            self.viewTheme = try decoder.factory.decodePolymorphicObject(RSDViewThemeElement.self, from: nestedDecoder)
        }
        if container.contains(.colorMapping) {
            let nestedDecoder = try container.superDecoder(forKey: .colorMapping)
            self.colorMapping = try decoder.factory.decodePolymorphicObject(RSDColorMappingThemeElement.self, from: nestedDecoder)
        }
        else if deprecatedContainer.contains(.colorTheme) {
            throw DecodingError.dataCorruptedError(forKey: DeprecatedCodingKeys.colorTheme, in: deprecatedContainer, debugDescription: "Use of `colorTheme` JSON key is unavailable. Please convert your JSON files to use `colorMapping` instead.")
        }
        if container.contains(.image) {
            let nestedDecoder = try container.superDecoder(forKey: .image)
            self.imageTheme = try decoder.factory.decodePolymorphicObject(RSDImageThemeElement.self, from: nestedDecoder)
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
    
    /// Define the encoder, but do not require protocol conformance of subclasses.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.stepType, forKey: .stepType)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.subtitle, forKey: .subtitle)
        try container.encodeIfPresent(self.detail, forKey: .detail)
        try container.encodeIfPresent(self.footnote, forKey: .footnote)
        try container.encodeIfPresent(self.nextStepIdentifier, forKey: .nextStepIdentifier)
        try container.encodeIfPresent(self._fullInstructionsOnly, forKey: .fullInstructionsOnly)
        try container.encodeIfPresent(self.standardPermissions, forKey: .permissions)
        try _encode(object: self.viewTheme, to: encoder, forKey: .viewTheme)
        try _encode(object: self.imageTheme, to: encoder, forKey: .image)
        try _encode(object: self.colorMapping, to: encoder, forKey: .colorMapping)
        try _encode(cohortRules: self.beforeCohortRules, to: encoder, forKey: .beforeCohortRules)
        try _encode(cohortRules: self.afterCohortRules, to: encoder, forKey: .afterCohortRules)
    }
    
    private func _encode(object: Any?, to encoder: Encoder, forKey: CodingKeys) throws {
        guard let obj = object else { return }
        guard let encodable = obj as? Encodable else {
            var codingPath = encoder.codingPath
            codingPath.append(forKey)
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "\(obj) does not conform to the `Encodable` protocol")
            throw EncodingError.invalidValue(obj, context)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        let nestedEncoder = container.superEncoder(forKey: forKey)
        try encodable.encode(to: nestedEncoder)
    }
    
    private func _encode(cohortRules: [RSDCohortNavigationRule]?, to encoder: Encoder, forKey: CodingKeys) throws {
        guard let rules = cohortRules else { return }
        guard let encodableRules = rules as? [RSDCohortNavigationRuleObject] else {
            var codingPath = encoder.codingPath
            codingPath.append(forKey)
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "\(rules) does not conform to the `RSDCohortNavigationRuleObject` protocol")
            throw EncodingError.invalidValue(rules, context)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(encodableRules, forKey: forKey)
    }

    // Overrides must be defined in the base implementation
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func isRequired(_ codingKey: CodingKey) -> Bool {
        if super.isRequired(codingKey) { return true }
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .identifier || key == .stepType
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .stepType:
            return .init(constValue: self.defaultType())
        case .title,.subtitle,.detail,.footnote:
            return .init(propertyType: .primitive(.string))
        case .fullInstructionsOnly:
            return .init(propertyType: .primitive(.boolean))
        case .nextStepIdentifier:
            return .init(propertyType: .primitive(.string))
        case .permissions:
            return .init(propertyType: .referenceArray(RSDStandardPermission.documentableType()))
        case .viewTheme:
            return .init(propertyType: .interface("\(RSDViewThemeElement.self)"))
        case .colorMapping:
            return .init(propertyType: .interface("\(RSDColorMappingThemeElement.self)"))
        case .image:
            return .init(propertyType: .interface("\(RSDImageThemeElement.self)"))
        case .beforeCohortRules, .afterCohortRules:
            return .init(propertyType: .referenceArray(RSDCohortNavigationRuleObject.documentableType()))
        }
    }
    
    open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "subtitle": "Some text.",
            "detail": "This is a test.",
            "footnote": "This is a footnote.",
            "nextStepIdentifier": "boo",
            "actions": [ "goForward": [ "type": "default", "buttonTitle" : "Go, Dogs! Go!" ],
                         "cancel": [ "type": "default", "iconName" : "closeX" ],
                         "learnMore": [ "type": "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" ],
                         "skip": [  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"]
            ],
            "shouldHideActions": ["goBackward"],
            "image"  : [    "type" : "animated",
                            "imageNames" : ["foo1", "foo2", "foo3", "foo4"],
                            "placementType" : "topBackground",
                            "animationDuration" : 2,
            ],
            "colorMapping"     : [  "type" : "singleColor",
                                    "customColor" : ["color" : "sky", "usesLightStyle" : true ]],
            "viewTheme"      : [ "type": "default",
                                 "viewIdentifier": "ActiveInstruction",
                                 "storyboardIdentifier": "ActiveTaskSteps",
                                 "bundleIdentifier": "org.example.SharedResources" ],
            "beforeCohortRules" : [["requiredCohorts" : ["boo", "goo"],
                                    "skipToIdentifier" : "blueGu",
                                    "operator" : "any" ]],
            "afterCohortRules" : [[ "requiredCohorts" : ["boo", "goo"],
                                    "skipToIdentifier" : "blueGu",
                                    "operator" : "any" ]],
            "permissions" : [["permissionType": "location"]],
            "fullInstructionsOnly" : true
        ]
        
        // Example JSON for a step with an `RSDFetchableImageThemeElement`.
        let jsonB: [String : JsonSerializable] = [
            "identifier"   : "goOutside",
            "type"         : "instruction",
            "title"        : "Go outside",
            "image"        : [  "type": "fetchable",
                                "imageName": "goOutsideIcon",
                                "placementType": "topBackground" ],
            "actions"      : [ "goForward": [ "type": "default", "buttonTitle": "I am outside" ]],
            ]
        
        return [jsonA, jsonB]
    }
}

extension RSDUIStepObject : DocumentableObject {
}
