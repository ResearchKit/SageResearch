//
//  RSDSectionStepObject.swift
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

/// `RSDSectionStepObject` is used to define a logical subgrouping of steps such as a section in a longer survey or an active
/// step that includes an instruction step, countdown step, and activity step.
public struct RSDSectionStepObject: RSDSectionStep, RSDStepValidator, Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case identifier, stepType = "type", steps, progressMarkers, asyncActions
    }
    
    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step.
    public let stepType: RSDStepType
    
    /// A list of the steps used to define this subgrouping of steps.
    public let steps: [RSDStep]
    
    /// A list of step markers to use for calculating progress.
    public var progressMarkers: [String]?
    
    /// A list of asynchronous actions to run on the task.
    public var asyncActions: [RSDAsyncActionConfiguration]?
    
    /// Copyright is undefined for a task section. Always `nil`.
    public let copyright: String? = nil
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - steps: The steps included in this section.
    ///     - type: The type of the step. Default = `RSDStepType.section`
    public init(identifier: String, steps: [RSDStep], type: RSDStepType? = nil) {
        self.identifier = identifier
        self.steps = steps
        self.stepType = type ?? .section
    }
    
    /// Instantiate a step result that is appropriate for this step. The default for this struct is a `RSDTaskResultObject`.
    /// - returns: A result for this step.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    /// Validate the steps in this section. The steps are valid if their identifiers are unique and if each step is valid.
    public func validate() throws {
        try stepValidation()
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDSectionStepObject {
        var copy = RSDSectionStepObject(identifier: identifier, steps: steps, type: self.stepType)
        copy.progressMarkers = self.progressMarkers
        copy.asyncActions = self.asyncActions
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
        self.steps = try decoder.factory.decodeSteps(from: stepsContainer)
        self.progressMarkers = try container.decodeIfPresent([String].self, forKey: .progressMarkers)
        
        // Decode the async actions
        let factory = decoder.factory
        if container.contains(.asyncActions) {
            var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .asyncActions)
            var decodedActions : [RSDAsyncActionConfiguration] = []
            while !nestedContainer.isAtEnd {
                let actionDecoder = try nestedContainer.superDecoder()
                if let action = try factory.decodeAsyncActionConfiguration(from: actionDecoder) {
                    decodedActions.append(action)
                }
            }
            self.asyncActions = decodedActions
        } else {
            self.asyncActions = nil
        }
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

extension RSDSectionStepObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .stepType, .steps, .progressMarkers, .asyncActions]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .stepType:
                if idx != 1 { return false }
            case .steps:
                if idx != 2 { return false }
            case .progressMarkers:
                if idx != 3 { return false }
            case .asyncActions:
                if idx != 4 { return false }
            }
        }
        return keys.count == 5
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
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
