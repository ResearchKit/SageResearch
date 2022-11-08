//
//  RSDUIActionHandlerObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDUIActionHandlerObject` is intended as an abstract implementation of the action handler that implements
/// the `Codable` protocol.
open class RSDUIActionHandlerObject : RSDUIActionHandler {
    
    /// A mapping dictionary of action type to action.
    public var actions: [RSDUIActionType : RSDUIAction]?
    
    /// A list of action types that should be hidden by default.
    public var shouldHideActions: [RSDUIActionType]?
    
    /// Base class initializer.
    public init() {
    }
    
    /// Customizable actions to return for a given action type. The `RSDStepController` can use these to
    /// customize the display of buttons to the user. If nil, `shouldHideAction()` will be called to
    /// determine if the default action should be used or if the action button should be hidden.
    ///
    /// - parameters:
    ///     - actionType:  The action type for the button.
    ///     - step:        The step that the action is on.
    /// - returns: A custom UI action for this button. If nil, the default action will be used.
    open func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        guard let action = actions?[actionType] else { return nil }
        return action
    }
    
    /// Should the action button be hidden? This implementation will check the `shouldHideActions` array
    /// and return `true` if found. Otherwise, this implementation will return `nil`.
    ///
    /// - parameters:
    ///     - actionType:  The action type for the button.
    ///     - step:        The step that the action is on.
    /// - returns: Whether or not the button should be hidden or `nil` if there is no explicit action.
    open func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        guard let shouldHide = shouldHideActions?.contains(actionType), shouldHide
            else {
                return nil
        }
        return shouldHide
    }
    
    // MARK: Codable (must implement in base class in order for the overriding classes to work)
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case actions, shouldHideActions
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `actions`.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON for the `actions` coding.
    ///         let json = """
    ///            {
    ///                "actions": { "goForward": { "type": "default", "buttonTitle" : "Go, Dogs! Go!" },
    ///                             "cancel": { "type": "default", "iconName" : "closeX" },
    ///                             "learnMore": {  "type": "webView",
    ///                                             "iconName" : "infoIcon",
    ///                                             "url" : "fooInfo" },
    ///                             "skip": {   "type": "navigation", 
    ///                                         "buttonTitle" : "not applicable",
    ///                                         "skipToIdentifier": "boo"}
    ///                            },
    ///                "shouldHideActions": ["goBackward"]
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        try decodeActions(from: decoder)
    }
    
    /// Decode from the given decoder, replacing values on self with those from the decoder
    /// if the properties are mutable.
    internal func decodeActions(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let shouldHide = try container.decodeIfPresent([RSDUIActionType].self, forKey: .shouldHideActions) {
            var set = Set(self.shouldHideActions ?? [])
            set.formUnion(shouldHide)
            self.shouldHideActions = Array(set)
        }
        if container.contains(.actions) {
            let nestedDecoder = try container.superDecoder(forKey: .actions)
            let nestedContainer = try nestedDecoder.container(keyedBy: AnyCodingKey.self)
            var actions: [RSDUIActionType : RSDUIAction] = self.actions ?? [:]
            for key in nestedContainer.allKeys {
                let objectDecoder = try nestedContainer.superDecoder(forKey: key)
                let actionType = RSDUIActionType(rawValue: key.stringValue)
                let action = try decoder.factory.decodePolymorphicObject(RSDUIAction.self, from: objectDecoder)
                actions[actionType] = action
            }
            self.actions = actions
        }
    }
    
    /// Define the encoder, but do not require protocol conformance of subclasses.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let actions = self.actions {
            var nestedContainer = container.nestedContainer(keyedBy: RSDUIActionType.self, forKey: .actions)
            try actions.forEach { (key, action) in
                guard let encodableAction = action as? Encodable else { return }
                let objectEncoder = nestedContainer.superEncoder(forKey: key)
                try encodableAction.encode(to: objectEncoder)
            }
        }
        try container.encodeIfPresent(shouldHideActions, forKey: .shouldHideActions)
    }
    
    // DocumentableObject implementation
    
    open class func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    open class func isOpen() -> Bool { true }
    
    open class func isRequired(_ codingKey: CodingKey) -> Bool { false }
    
    open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not handled by \(self).")
        }
        switch key {
        case .actions:
            return DocumentProperty(propertyType: .interfaceDictionary("\(RSDUIAction.self)"))
        case .shouldHideActions:
            return DocumentProperty(propertyType: .referenceArray(RSDUIActionType.documentableType()))
        }
    }
}
