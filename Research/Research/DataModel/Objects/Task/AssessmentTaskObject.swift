//
//  RSDAssessmentTaskObject.swift
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


/// The serialization "type" key for decoding of the task. This is used to decode the task using a
/// `RSDFactory`.
public struct RSDTaskType : TypeRepresentable, RawRepresentable, Codable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let assessment: RSDTaskType = "assessment"
    
    fileprivate static let null: RSDTaskType = "null"
}

extension RSDTaskType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDTaskType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        [RSDTaskType.assessment.rawValue]
    }
}

public final class TaskSerializer : IdentifiableInterfaceSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `Task` is the interface for running a task. It includes information about how to
        calculate progress, validation, and the order of display for the steps.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        let examples: [SerializableTask] = [
            AssessmentTaskObject()
        ]
        self.examples = examples
    }
    
    public private(set) var examples: [RSDTask]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDTaskType.documentableType()))
    }
    
    public func add(_ example: SerializableTask) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

/// For `SerializableTask`, do not implement the typeName in an extension to allow the serializable
/// object to *also* conform to `RSDStep` for which the serializer *does* extend the protocol to
/// implement that type.
public protocol SerializableTask : RSDTask, PolymorphicRepresentable {
    var taskType: RSDTaskType { get }
}

extension AssessmentTaskObject : SerializableTask {
}

/// This is an abstract implementation of `RSDTask` that handles much of the default properties
/// and polymorphism.
///
/// This class should *not* be instantiated directly. Subclass implementations are required to
/// override `defaultType()` and `copy(with identifier: String)`.
///
/// - seealso: `AssessmentTaskObject`
open class AbstractTaskObject : RSDUIActionHandlerObject, RSDCopyTask, RSDTrackingTask, Decodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case taskType = "type", identifier, steps, progressMarkers, asyncActions, schemaIdentifier, versionString, estimatedMinutes, usesTrackedData
    }
    
    private enum DeprecatedCodingKeys : String, CodingKey, CaseIterable {
        case schemaInfo
    }
    
    /// The default decoding type.
    open class func defaultType() -> RSDTaskType {
        fatalError("Abstract method. Subclass \(type(of: self)) does not override `defaultType()`.")
    }
    
    public fileprivate(set) var taskType: RSDTaskType = .null
    public var typeName: String { self.taskType.rawValue }
    
    public let identifier: String
    public let steps: [RSDStep]
    open fileprivate(set) var progressMarkers : [String]?
    open fileprivate(set) var asyncActions: [RSDAsyncActionConfiguration]?

    open var stepNavigator: RSDStepNavigator { _stepNavigator }
    lazy private var _stepNavigator: RSDStepNavigator = {
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = self.progressMarkers
        return navigator
    }()
    
    open fileprivate(set) var schemaIdentifier: String?
    open fileprivate(set) var versionString: String?
    
    open var schemaInfo: RSDSchemaInfo? { _schemaInfo }
    lazy fileprivate var _schemaInfo: RSDSchemaInfo? = {
        guard let resultId = self.schemaIdentifier else { return nil }
        let revision = self.versionString.map { ($0 as NSString).integerValue } ?? 1
        return RSDSchemaInfoObject(identifier: resultId, revision: revision)
    }()
    
    open var estimatedMinutes: Int { _estimatedMinutes ?? 2 }
    fileprivate var _estimatedMinutes: Int?
    
    open func instantiateTaskResult() -> RSDTaskResult {
        RSDTaskResultObject(identifier: identifier, schemaInfo: schemaInfo)
    }
    
    open func validate() throws {
        try steps.forEach { try $0.validate() }
        try asyncActions?.forEach { try $0.validate() }
    }
    
    // MARK: Initialization
    
    fileprivate override init() {
        self.identifier = RSDTaskType.assessment.rawValue
        self.steps = []
        
        self._initCompleted = false
        super.init()
        self.commonInit()
        self._initCompleted = true
    }
    
    public init(identifier: String,
                steps: [RSDStep],
                usesTrackedData: Bool = false,
                asyncActions: [RSDAsyncActionConfiguration]? = nil,
                progressMarkers : [String]? = nil,
                resultIdentifier: String? = nil,
                versionString: String? = nil,
                estimatedMinutes: Int? = nil,
                actions: [RSDUIActionType : RSDUIAction]? = nil,
                shouldHideActions: [RSDUIActionType]? = nil) {
        self.identifier = identifier
        self.steps = steps
        self.usesTrackedData = usesTrackedData
        self.asyncActions = asyncActions
        self.progressMarkers = progressMarkers
        self.schemaIdentifier = resultIdentifier
        self.versionString = versionString
        self._estimatedMinutes = estimatedMinutes
        
        self._initCompleted = false
        super.init()
        self.actions = actions
        self.shouldHideActions = shouldHideActions
        self.commonInit()
        self._initCompleted = true
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.taskType = try container.decode(RSDTaskType.self, forKey: .taskType)
        
        // Decode the steps.
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try decoder.factory.decodePolymorphicArray(RSDStep.self, from: stepsContainer)

        self._initCompleted = false
        try super.init(from: decoder)
        try self.decode(from: decoder)
        self._initCompleted = true
    }
    
    open func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode optional properties.
        if container.contains(.asyncActions) {
            let asyncActionsContainer = try container.nestedUnkeyedContainer(forKey: .asyncActions)
            self.asyncActions = try decoder.factory.decodePolymorphicArray(RSDAsyncActionConfiguration.self, from: asyncActionsContainer)
        }
        self.progressMarkers = try container.decodeIfPresent([String].self, forKey: .progressMarkers) ?? self.progressMarkers
        self.usesTrackedData = try container.decodeIfPresent(Bool.self, forKey: .usesTrackedData) ?? self.usesTrackedData
        self.schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier) ?? self.schemaIdentifier
        self.versionString = try container.decodeIfPresent(String.self, forKey: .versionString) ?? self.versionString
        self._estimatedMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedMinutes) ?? self._estimatedMinutes
        
        let deprecatedContainer = try decoder.container(keyedBy: DeprecatedCodingKeys.self)
        if deprecatedContainer.contains(.schemaInfo) {
            debugPrint("WARNING!!! 'schemaInfo' is deprecated for decoding. Please use 'resultIdentifier' and 'versionString' instead.")
            let schemaInfo = try deprecatedContainer.decode(RSDSchemaInfoObject.self, forKey: .schemaInfo)
            self._schemaInfo = schemaInfo
            self.schemaIdentifier = schemaInfo.schemaIdentifier
            self.versionString = "\(schemaInfo.schemaVersion)"
        }
        else if let schemaInfo = decoder.schemaInfo {
            self._schemaInfo = schemaInfo
        }
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.taskType, forKey: .taskType)
        let stepContainer = container.nestedUnkeyedContainer(forKey: .steps)
        try encoder.factory.encode(self.steps, to: stepContainer)
        try container.encodeIfPresent(self.progressMarkers, forKey: .progressMarkers)
        try container.encodeIfPresent(self.schemaIdentifier, forKey: .schemaIdentifier)
        try container.encodeIfPresent(self.versionString, forKey: .versionString)
        try container.encodeIfPresent(self._estimatedMinutes, forKey: .estimatedMinutes)
        try container.encodeIfPresent(self.usesTrackedData, forKey: .usesTrackedData)
        if let actions = self.asyncActions {
            let nestedContainer = container.nestedUnkeyedContainer(forKey: .asyncActions)
            try encoder.factory.encode(actions, to: nestedContainer)
        }
    }
    
    private func commonInit() {
        // Use of the `.null` as a placeholder is b/c of a limitation where type(of: self) cannot
        // be accessed prior to initializing super and the taskType is required.
        if self.taskType == .null {
            self.taskType = type(of: self).defaultType()
        }
    }
    private var _initCompleted: Bool
    
    // MARK: Copy methods
    
    /// Used to allow this object to "fetch" itself.
    public final func copy(with identifier: String, schemaInfo: RSDSchemaInfo?) -> Self {
        let copy = self.copy(with: identifier)
        if let schemaInfo = schemaInfo {
            copy._schemaInfo = schemaInfo
        }
        return copy
    }

    /// Used to allow transforming the identifier.
    open func copy(with identifier: String) -> Self {
        fatalError("Abstract method. Subclass \(type(of: self)) does not implement `copy(with:, schemaInfo:)`")
    }
    
    // MARK:  RSDDataTracker
    
    /// Does this task use stored data and/or include a scoring at this level?
    open fileprivate(set) var usesTrackedData: Bool = false
    
    /// Returns the task data for this task result.
    ///
    /// The default implementation will first look to see if the `stepNavigator` implements `RSDTaskData`
    /// and if so, will return the task data from the navigator.
    ///
    /// Otherwise, the task will *only* build a score if this task object has the property `usesTrackedData`
    /// set to true and the method `instantiateScoreBuilder()` returns a score builder.
    ///
    open func taskData(for taskResult: RSDTaskResult) -> RSDTaskData? {
        if let tracker = self.stepNavigator as? RSDTrackingTask {
            return tracker.taskData(for: taskResult)
        }
        
        // Only return task data if the task uses it to influence the results.
        guard usesTrackedData,
            let scoreBuilder = instantiateScoreBuilder(),
            let score = scoreBuilder.getScoringData(from: taskResult)
            else {
                return nil
        }
    
        return TaskData(identifier: self.identifier, timestampDate: taskResult.endDate, json: score)
    }
    
    /// Set up the data tracker. In the default implementation, the task object only acts as a pass-through
    /// for the step navigator if that object implements the protocol.
    open func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent) {
        if let tracker = self.stepNavigator as? RSDTrackingTask {
            tracker.setupTask(with: data, for: path)
        }
    }
    
    /// Should this step use a result from a previous run? In the default implementation, the task object
    /// acts only as a pass-through for the step navigator if that object implements the protocol.
    open func shouldSkipStep(_ step: RSDStep) -> (shouldSkip: Bool, stepResult: RSDResult?) {
        if let tracker = self.stepNavigator as? RSDTrackingTask {
            return tracker.shouldSkipStep(step)
        }
        else {
            return (false, nil)
        }
    }
    
    /// Instantiate the score builder to use to build the task data for this task result.
    ///
    /// The default behavior is to use a simple recursive builder that will look for results that implement
    /// either `RSDScoringResult` or `RSDAnswerResult` and return either a dictionary or array as applicable
    /// if more than one score is found at any given level of subtask result or collection result. For
    /// a more detailed description, go code spelunking into the unit tests for `RecursiveScoreBuilder`.
    ///
    /// This method is only called if the step navigator attached to this task does not implement the
    /// `RSDTrackingTask` protocol.
    ///
    open func instantiateScoreBuilder() -> RSDScoreBuilder? {
        return RecursiveScoreBuilder()
    }
    
    struct TaskData : RSDTaskData {
        let identifier: String
        let timestampDate: Date?
        let json: JsonSerializable
    }
    
    // MARK: Documention
    
    override open class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    override open class func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else {
            return super.isRequired(codingKey)
        }
        return key == .identifier || key == .taskType || key == .steps
    }
    
    override open class func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            return try super.documentProperty(for: codingKey)
        }
        switch key {
        case .identifier, .schemaIdentifier:
            return .init(propertyType: .primitive(.string))
        case .taskType:
            return .init(constValue: defaultType())
        case .steps:
            return .init(propertyType: .interfaceArray("\(RSDStep.self)"))
        case .progressMarkers:
            return .init(propertyType: .primitiveArray(.string))
        case .asyncActions:
            return .init(propertyType: .interfaceArray("\(RSDAsyncActionConfiguration.self)"))
        case .versionString:
            return .init(propertyType: .primitive(.string))
        case .estimatedMinutes:
            return .init(propertyType: .primitive(.integer))
        case .usesTrackedData:
            return .init(propertyType: .primitive(.boolean))
        }
    }
    
    open class func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
            "identifier": "foo",
            "type": "assessment",
            "steps": [
                [ "identifier": "step1",
                  "type": "instruction",
                  "title": "Step 1"],
                [ "identifier": "step2",
                  "type": "instruction",
                  "title": "Step 2"]
            ]
        ]
        let jsonB: [String : JsonSerializable] = [
            "identifier": "baloo",
            "type": "assessment",
            "progressMarkers": [],
            "schemaIdentifier": "ragu",
            "versionString": "2.2.22",
            "estimatedMinutes": 3,
            "usesTrackedData": true,
            "steps": [
                [ "identifier": "step1",
                  "type": "instruction",
                  "title": "Step 1"],
                [ "identifier": "step2",
                  "type": "instruction",
                  "title": "Step 2"]
            ]
        ]
        return [jsonA, jsonB]
    }
}

/// Concrete implementation of the an `RSDTask`.
open class AssessmentTaskObject : AbstractTaskObject {
    override open class func defaultType() -> RSDTaskType {
        .assessment
    }
    
    fileprivate override init() {
        super.init()
    }
    
    public override init(identifier: String,
                         steps: [RSDStep],
                         usesTrackedData: Bool = false,
                         asyncActions: [RSDAsyncActionConfiguration]? = nil,
                         progressMarkers: [String]? = nil,
                         resultIdentifier: String? = nil,
                         versionString: String? = nil,
                         estimatedMinutes: Int? = nil,
                         actions: [RSDUIActionType : RSDUIAction]? = nil,
                         shouldHideActions: [RSDUIActionType]? = nil) {
        super.init(identifier: identifier, steps: steps, usesTrackedData: usesTrackedData, asyncActions: asyncActions, progressMarkers: progressMarkers, resultIdentifier: resultIdentifier, versionString: versionString, estimatedMinutes: estimatedMinutes, actions: actions, shouldHideActions: shouldHideActions)
    }
    
    public required init(identifier: String, steps: [RSDStep]) {
        super.init(identifier: identifier, steps: steps)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: Copy methods

    /// Used to allow transforming the identifier.
    override public final func copy(with identifier: String) -> Self {
        let copy = type(of: self).init(identifier: identifier, steps: steps.deepCopy())
        copyInto(copy as AssessmentTaskObject)
        return copy
    }
    
    /// Swift subclass override for copying properties from the instantiated class of the `copy(with:)`
    /// method. Swift does not nicely handle casting from `Self` to a class instance for non-final classes.
    /// This is a work around.
    open func copyInto(_ copy: AssessmentTaskObject) {
        copy.actions = self.actions
        copy.shouldHideActions = self.shouldHideActions
        copy.asyncActions = self.asyncActions
        copy.progressMarkers = self.progressMarkers
        copy.schemaIdentifier = self.schemaIdentifier
        copy.versionString = self.versionString
        copy._estimatedMinutes = self.estimatedMinutes
        copy._schemaInfo = self.schemaInfo
        copy.usesTrackedData = self.usesTrackedData
    }
}

extension AssessmentTaskObject : DocumentableObject {
}
