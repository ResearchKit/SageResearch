//
//  RSDSectionStepObject.swift
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

/// `RSDSectionStepObject` is used to define a logical subgrouping of steps such as a section in a longer survey or an active
/// step that includes an instruction step, countdown step, and activity step.
public struct RSDSectionStepObject: RSDSectionStep, RSDConditionalStepNavigator, RSDStepValidator, RSDCopyStep, Decodable {

    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, stepType = "type", steps, progressMarkers, asyncActions
    }
    
    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step.
    public private(set) var stepType: RSDStepType = .section
    
    /// A list of the steps used to define this subgrouping of steps.
    public let steps: [RSDStep]
    
    /// A list of step markers to use for calculating progress.
    public var progressMarkers: [String]?
    
    /// A list of asynchronous actions to run on the task.
    public var asyncActions: [RSDAsyncActionConfiguration]?
    

    @available(*, deprecated, message: "Kotlin serialzation requires a one-to-one mapping of 'type' to a class.")
    public init(identifier: String, steps: [RSDStep], type: RSDStepType?) {
        self.identifier = identifier
        self.steps = steps
        self.stepType = type ?? .section
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - steps: The steps included in this section.
    public init(identifier: String, steps: [RSDStep]) {
        self.identifier = identifier
        self.steps = steps
    }
    
    /// Instantiate a step result that is appropriate for this step. The default for this struct is a `RSDTaskResultObject`.
    /// - returns: A result for this step.
    public func instantiateStepResult() -> RSDResult {
        return SectionResultObject(identifier: identifier)
    }
    
    /// Validate the steps in this section. The steps are valid if their identifiers are unique and if each step is valid.
    public func validate() throws {
        try stepValidation()
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDSectionStepObject {
        return try! copy(with: identifier, decoder: nil)
    }
    
    private init(_ identifier: String, _ steps: [RSDStep], _ type: RSDStepType) {
        self.identifier = identifier
        self.steps = steps
        self.stepType = type
    }
    
    /// Copy this step with replacement values from the given decoder (if any).
    public func copy(with identifier: String, decoder: Decoder?) throws -> RSDSectionStepObject {
        
        // Look in the decoder for the replacement step properties.
        var copySteps = self.steps
        var copyAsyncActions = self.asyncActions
        if let decoder = decoder {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.steps) {
                var stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
                while !stepsContainer.isAtEnd {
                    let stepDecoder = try stepsContainer.superDecoder()
                    let nestedContainer = try stepDecoder.container(keyedBy: CodingKeys.self)
                    let identifier = try nestedContainer.decode(String.self, forKey: .identifier)
                    if let idx = copySteps.firstIndex(where: { $0.identifier == identifier }),
                        let copyableStep = copySteps[idx] as? RSDCopyStep {
                        let replacementStep = try copyableStep.copy(with: identifier, decoder: stepDecoder)
                        copySteps.replaceSubrange(idx...idx, with: [replacementStep])
                    }
                }
            }
            copyAsyncActions = try self.decodeAsyncActions(from: decoder, initialActions: copyAsyncActions)
        }
        
        // Copy self with replacement steps.
        var copy = RSDSectionStepObject(identifier, copySteps, self.stepType)
        copy.progressMarkers = self.progressMarkers
        copy.asyncActions = copyAsyncActions
        return copy
    }

    
    /// Initialize from a `Decoder`. This implementation will query the `RSDFactory` attached to the decoder for the
    /// appropriate implementation for each step in the array.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes two instruction steps.
    ///         let json = """
    ///            {
    ///                "identifier": "foobar",
    ///                "type": "section",
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
    ///                ],
    ///                "asyncActions" : [
    ///                     { "identifier" : "location", "type" : "location" }
    ///                ]
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decode(RSDStepType.self, forKey: .stepType)
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try decoder.factory.decodePolymorphicArray(RSDStep.self, from: stepsContainer)
        self.progressMarkers = try container.decodeIfPresent([String].self, forKey: .progressMarkers)
        self.asyncActions = try self.decodeAsyncActions(from: decoder, initialActions: nil)
    }
    
    private func decodeAsyncActions(from decoder: Decoder, initialActions: [RSDAsyncActionConfiguration]?) throws -> [RSDAsyncActionConfiguration]? {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.contains(.asyncActions) else { return initialActions }
        
        let factory = decoder.factory
        var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asyncActions)
        var decodedActions : [RSDAsyncActionConfiguration] = initialActions ?? []
        while !nestedContainer.isAtEnd {
            let actionDecoder = try nestedContainer.superDecoder()
            let action = try factory.decodePolymorphicObject(RSDAsyncActionConfiguration.self,
                                                             from: actionDecoder)
            if let idx = decodedActions.firstIndex(where: { $0.identifier == action.identifier}) {
                decodedActions.remove(at: idx)
            }
            decodedActions.append(action)
        }
        return decodedActions
    }
    
    /// Required implementation for `RSDTask`. This method always returns `nil`.
    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    /// Required implementation for `RSDTask`. This method always returns `nil`.
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
}

extension RSDSectionStepObject : DocumentableObject {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isOpen() -> Bool {
        return false
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .identifier, .steps, .stepType:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .stepType:
            return .init(constValue: RSDStepType.section)
        case .steps:
            return .init(propertyType: .interfaceArray("\(RSDStep.self)"))
        case .progressMarkers:
            return .init(propertyType: .primitiveArray(.string))
        case .asyncActions:
            return .init(propertyType: .interfaceArray("\(RSDAsyncActionConfiguration.self)"))
        }
    }
    
    public static func jsonExamples() throws -> [[String : JsonSerializable]] {
        let jsonA: [String : JsonSerializable] = [
                "identifier": "foobar",
                "type": "section",
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
                    ],
                ]
            ]
        return [jsonA]
    }
}
