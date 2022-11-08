//
//  RSDOverviewStepObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDOverviewStepObject` extends the `RSDUIStepObject` to include information about an activity including
/// what permissions are required by this task. Without these preconditions, the task cannot measure or
/// collect the data needed for this task.
@available(*,deprecated, message: "Will be deleted in a future version. To replace, consider overriding `RSDUIStepObject` and override the `defaultType()` method with `.overview` as the type.")
open class RSDOverviewStepObject : RSDUIStepObject, RSDOverviewStep, Encodable {

    private enum CodingKeys: String, OrderedEnumCodingKey, OpenOrderedCodingKey {
        case icons
        var relativeIndex: Int { 1 }
    }
    
    /// For this implementation of the overview step, the learn more action is included in the
    /// readwrite dictionary of actions.
    open var learnMoreAction: RSDUIAction? {
        get {
            return self.actions?[.navigation(.learnMore)]
        }
        set {
            guard let action = newValue else {
                self.actions?[.navigation(.learnMore)] = nil
                return
            }
            var actions = self.actions ?? [:]
            actions[.navigation(.learnMore)] = action
            self.actions = actions
        }
    }
    
    /// The icons that are used to define the list of things you will need for an active task.
    /// These should *not* be readwrite since "What you will need" should be consistent across
    /// uses of the activity.
    open private(set) var icons: [RSDIconInfo]?
    
    /// Default type is `.overview`.
    open override class func defaultType() -> RSDStepType {
        return .overview
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDOverviewStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.icons = self.icons
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.icons = try container.decodeIfPresent([RSDIconInfo].self, forKey: .icons) ?? self.icons
        if container.contains(.icons) {
            debugPrint("WARNING! Decoding from \(self) is a deprecated. You will need to include CodingKey `icons` in your own serializations.")
        }
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.icons, forKey: .icons)
    }
    
    // Overrides must be defined in the base implementation
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .icons:
            return .init(propertyType: .referenceArray(RSDIconInfo.documentableType()))
        }
    }
    
    override open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "detail": "Some text.",
            "permissions" : [["permissionType": "location"]],
            "icons": [ [ "icon":"Foo1", "title": "A SMOOTH SURFACE"] ]
        ]
        
        return [jsonA]
    }
}
