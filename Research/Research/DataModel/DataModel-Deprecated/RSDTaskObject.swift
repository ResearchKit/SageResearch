//
//  RSDTaskObject.swift
//  Research
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
import JsonModel

/// `RSDTaskObject` is the interface for running a task. It includes information about how to calculate progress,
/// validation, and the order of display for the steps.
@available(*, deprecated, message: "Inherit from `RSDAssessmentTaskObject` instead.")
open class RSDTaskObject : RSDUIActionHandlerObject, RSDCopyTask, RSDTrackingTask, Decodable {

    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, copyright, schemaInfo, asyncActions, usesTrackedData
    }

    /// A short string that uniquely identifies the task.
    public let identifier: String
    
    /// Copyright information about the task.
    @available(*, deprecated, message: "This property has been removed from the serialization strategy.")
    open private(set) var copyright: String?
    
    /// Information about the result schema.
    open private(set) var schemaInfo: RSDSchemaInfo?
    
    /// The step navigator for this task.
    public let stepNavigator: RSDStepNavigator
    
    /// A list of asynchronous actions to run on the task.
    public let asyncActions: [RSDAsyncActionConfiguration]?
    
    /// Does this task use stored data and/or include a scoring at this level?
    open private(set) var usesTrackedData: Bool = false
    
    /// Default initializer.
    /// - parameters:
    ///     - taskInfo: Additional information about the task.
    ///     - stepNavigator: The step navigator for this task.
    ///     - schemaInfo: Information about the result schema.
    ///     - asyncActions: A list of asynchronous actions to run on the task.
    ///     - usesTrackedData: Does this task use stored data and/or include a scoring at this level?
    public required init(identifier: String, stepNavigator: RSDStepNavigator, schemaInfo: RSDSchemaInfo? = nil, asyncActions: [RSDAsyncActionConfiguration]? = nil) {
        self.identifier = identifier
        self.schemaInfo = schemaInfo
        self.stepNavigator = stepNavigator
        self.asyncActions = asyncActions
        super.init()
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///     ```
    ///        let json = """
    ///            {
    ///            "identifier" : "foo",
    ///            "usesTrackedData" : false,
    ///            "schemaInfo" : {
    ///                            "identifier" : "foo.1.2",
    ///                            "revision" : 3 },
    ///                "steps": [
    ///                    {
    ///                        "identifier": "step1",
    ///                        "type": "instruction",
    ///                        "title": "Step 1"
    ///                    },
    ///                    {
    ///                        "identifier": "step2",
    ///                        "type": "instruction",
    ///                        "title": "Step 2"
    ///                    },
    ///                ]
    ///                "asyncActions" : [
    ///                     { "identifier" : "location", "type" : "location" }
    ///                ]
    ///            }
    ///        """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError` if there is a decoding error.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Set the identifier and
        let identifier: String
        if let taskIdentifier = decoder.taskIdentifier {
            identifier = taskIdentifier
        } else {
            identifier = try container.decode(String.self, forKey: .identifier)
        }
        
        self.identifier = identifier
        self.schemaInfo = try container.decodeIfPresent(RSDSchemaInfoObject.self, forKey: .schemaInfo) ?? decoder.schemaInfo
        
        // Get the step navigator
        let factory = decoder.factory
        self.stepNavigator = try factory.decodeStepNavigator(from: decoder)
        
        // Decode the async actions
        if container.contains(.asyncActions) {
            var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asyncActions)
            var decodedActions : [RSDAsyncActionConfiguration] = []
            while !nestedContainer.isAtEnd {
                let actionDecoder = try nestedContainer.superDecoder()
                let action = try factory.decodePolymorphicObject(RSDAsyncActionConfiguration.self,
                                                                 from: actionDecoder)
                decodedActions.append(action)
            }
            self.asyncActions = decodedActions
        } else {
            self.asyncActions = nil
        }
        
        try super.init(from: decoder)
        
        try self.decode(from: decoder)
    }
    
    /// Allow subclasses to decode additional properties without having to override both
    /// initializers. This method is called by `init(from:)` *after* calling through to super.
    /// If you add properties to the base class, also override `copy(into:)` to set those properties
    /// when a copy is made of the task.
    ///
    /// - seealso: `copy(into:)`
    open func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.usesTrackedData = try container.decodeIfPresent(Bool.self, forKey: .usesTrackedData) ?? self.usesTrackedData
    }
    
    
    // MARK: RSDTask methods
    
    /// Instantiate a task result that is appropriate for this task.
    ///
    /// - returns: A task result for this task.
    open func instantiateTaskResult() -> RSDTaskResult {
        return RSDTaskResultObject(identifier: self.identifier, schemaInfo: self.schemaInfo)
    }
    
    /// Validate the task to check for any model configuration that should throw an error.
    /// - throws: An error appropriate to the failed validation.
    open func validate() throws {
        // Check if the step navigator implements step validation
        if let stepValidator = stepNavigator as? RSDStepValidator {
            try stepValidator.stepValidation()
        }
        
        // Check if the async action identifiers are unique
        if let actionIds = asyncActions?.map({ $0.identifier }) {
            let uniqueIds = Set(actionIds)
            if actionIds.count != uniqueIds.count {
                throw RSDValidationError.notUniqueIdentifiers("Action identifiers: \(actionIds.joined(separator: ","))")
            }
            // Loop through the async actions and validate them
            for asyncAction in asyncActions! {
                try asyncAction.validate()
                if let startIdentifier = asyncAction.startStepIdentifier {
                    guard stepNavigator.step(with: startIdentifier) != nil else {
                        throw RSDValidationError.identifierNotFound(asyncAction, startIdentifier, "Start step \(startIdentifier) not found for Async Action \(asyncAction.identifier).")
                    }
                }
            }
        }
    }
    
    
    // MARK:  RSDDataTracker {
    
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
    
    /// Setup the data tracker. In the default implementation, the task object only acts as a pass-through
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

    
    // MARK: Copy methods
    
    public final func copy(with identifier: String, schemaInfo: RSDSchemaInfo?) -> Self {
        let copy = type(of: self).init(identifier: identifier, stepNavigator: stepNavigator, schemaInfo: schemaInfo, asyncActions: asyncActions)
        copyInto(copy as RSDTaskObject)
        return copy
    }

    public final func copy(with identifier: String) -> Self {
        let copy = type(of: self).init(identifier: identifier, stepNavigator: stepNavigator, schemaInfo: schemaInfo, asyncActions: asyncActions)
        copyInto(copy as RSDTaskObject)
        return copy
    }
    
    /// Swift subclass override for copying properties from the instantiated class of the `copy(with:)`
    /// method. Swift does not nicely handle casting from `Self` to a class instance for non-final classes.
    /// This is a work around.
    open func copyInto(_ copy: RSDTaskObject) {
        copy.actions = self.actions
        copy.shouldHideActions = self.shouldHideActions
        copy.usesTrackedData = self.usesTrackedData
    }
    
    // Overrides must be defined in the base implementation
    
    override public class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = CodingKeys.allCases
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    class func examples() -> [[String : JsonValue]] {
        let json: [String : JsonValue] = [
                "identifier": "foo",
                "schemaInfo": [ "identifier": "foo.1.2", "revision": 2 ],
                "steps": [
                    [
                        "identifier": "step1",
                        "type": "instruction",
                        "title": "Step 1"
                    ],
                    [
                        "identifier": "step2",
                        "type": "instruction",
                        "title": "Step 2"
                    ]
                ],
                "asyncActions" : [["identifier" : "location", "type" : "location" ]]
            ]
        return [json]
    }
}

// TODO: syoung 04/14/2020 This task is not Kotlin-serializable. Refactor to a serializable type.
//extension RSDTaskObject : DocumentableObject {
//}
