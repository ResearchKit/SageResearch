//
//  RSDResultSummaryStepObject.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// A result summary step is used to display a result that is calculated or measured earlier in the task.
@available(*,deprecated, message: "Will be deleted in a future version. To replace, consider overriding `RSDUIStepObject` and override the `defaultType()` method with `.feedback` as the type.")
open class RSDResultSummaryStepObject: RSDActiveUIStepObject, RSDResultSummaryStep, RSDNavigationSkipRule {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case unitText, resultIdentifier, stepResultIdentifier, resultTitle
    }
    
    /// Text to display as the title above the result.
    open private(set) var resultTitle: String?
    
    /// The localized unit text to display for this step.
    open private(set) var unitText: String?
    
    /// The identifier for the step result that contains the answer result.
    open private(set) var stepResultIdentifier: String?
    
    /// The identifier for the answer result.
    open private(set) var resultIdentifier: String?
    
    /// By default, if the `resultIdentifier` is non-nil, then the step should be skipped if
    /// the result is not in the result set.
    open func shouldSkipStep(with result: RSDTaskResult?, isPeeking: Bool) -> Bool {
        guard resultIdentifier != nil else { return false }
        guard let taskResult = result else { return true }
        let value = self.answerValueAndType(from: taskResult)?.value
        return (value == nil)
    }
    
    // MARK: Initializers
    
    public required init(identifier: String, type: RSDStepType? = nil) {
        super.init(identifier: identifier, type: type)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init(identifier: String, resultIdentifier: String, unitText: String? = nil, stepResultIdentifier: String? = nil) {
        super.init(identifier: identifier, type: nil)
        self.resultIdentifier = resultIdentifier
        self.unitText = unitText
        self.stepResultIdentifier = stepResultIdentifier
    }
    
    
    // MARK: Subclass copy and decoding.
    
    /// Default type is `.completion`.
    open override class func defaultType() -> RSDStepType {
        return .feedback
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? RSDResultSummaryStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.resultTitle = self.resultTitle
        subclassCopy.unitText = self.unitText
        subclassCopy.resultIdentifier = self.resultIdentifier
        subclassCopy.stepResultIdentifier = self.stepResultIdentifier
    }
    
    /// Override the decoder per device type b/c the task may require a different set of permissions depending upon the device.
    open override func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultTitle = try container.decodeIfPresent(String.self, forKey: .resultTitle) ?? self.resultTitle
        self.unitText = try container.decodeIfPresent(String.self, forKey: .unitText) ?? self.unitText
        self.resultIdentifier = try container.decodeIfPresent(String.self, forKey: .resultIdentifier) ?? self.resultIdentifier
        self.stepResultIdentifier = try container.decodeIfPresent(String.self, forKey: .stepResultIdentifier) ?? self.stepResultIdentifier
    }
    
    // Overrides must be defined in the base implementation
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let _ = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        return .init(propertyType: .primitive(.string))
    }
    
    override open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type" : self.defaultType().rawValue,
            "title": "Hello World!",
            "detail": "Some text.",
            "resultTitle": "This is a title",
            "resultIdentifier" : "boo",
            "unitText" : "lala"
        ]
        
        return [jsonA]
    }
}

/// Kotlin serialization requires a one-to-one mapping of the "type" key to a class.
/// Since on iOS the `completion` step has the same functionality as the `feedback` step, but a
/// subtly different meaning in terms of the UI, these need to have different values for `stepType`
/// so that the call to save results happens with the appropriate timing.
@available(*,deprecated, message: "Will be deleted in a future version.")
public final class RSDCompletionStepObject : RSDResultSummaryStepObject {
    public override class func defaultType() -> RSDStepType {
        return .completion
    }
}
