//
//  RSDConditionalStepNavigatorObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDConditionalStepNavigatorObject` is a concrete implementation of the `RSDConditionalStepNavigator` protocol.
public struct RSDConditionalStepNavigatorObject : RSDConditionalStepNavigator, RSDCopyStepNavigator, Decodable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case steps, progressMarkers, insertAfterIdentifier
    }
    
    /// An ordered list of steps to run for this task.
    public let steps : [RSDStep]
    
    /// A list of step markers to use for calculating progress.
    public var progressMarkers : [String]?
    
    /// The identifier of the step **after** which any sections or subtasks should be inserted.
    public var insertAfterIdentifier: String?
    
    /// Default initializer.
    /// - parameter steps: An ordered list of steps to run for this task.
    public init(with steps: [RSDStep]) {
        self.steps = steps
    }
    
    /// Return a copy of the step navigator that includes the desired section inserted in a position that
    /// is appropriate to this navigator.
    public func copyAndInsert(_ section: RSDSectionStep) -> RSDConditionalStepNavigatorObject {
        return _copyAndInsert(section)
    }
    
    /// Return a copy of the step navigator that includes the desired subtask inserted in a position that
    /// is appropriate to this navigator.
    public func copyAndInsert(_ subtask: RSDTaskInfoStep) -> RSDConditionalStepNavigatorObject {
        return _copyAndInsert(subtask)
    }
    
    private func _copyAndInsert(_ step: RSDStep) -> RSDConditionalStepNavigatorObject {
        
        /// Mutate the step array.
        let idx = self.index(of: self.insertAfterIdentifier)?.advanced(by: 1) ?? 1
        var steps = self.steps
        steps.insert(step, at: idx)
    
        // Create the navigator.
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.insertAfterIdentifier = step.identifier
        
        // Mutate the progress markers.
        if let markers = self.progressMarkers {
            var progressMarkers = markers
            let searchRange = self.steps[..<idx].map { $0.identifier }
            if let lastIdentifier = searchRange.last(where: { markers.contains($0) }),
                let progressIndex = markers.firstIndex(of: lastIdentifier) {
                // If the marker is found then insert after it.
                progressMarkers.insert(step.identifier, at: progressIndex + 1)
            } else {
                // Otherwise insert at the beginning.
                progressMarkers.insert(step.identifier, at: 0)
            }
            navigator.progressMarkers = progressMarkers
        }
        
        return navigator
    }
    
    public func copyAndRemove(_ stepIdentifiers: [String]) -> RSDConditionalStepNavigatorObject {
        let steps = self.steps.filter { !stepIdentifiers.contains($0.identifier) }
        var navigator = RSDConditionalStepNavigatorObject(with: steps)
        navigator.progressMarkers = self.progressMarkers?.filter { !stepIdentifiers.contains($0) }
        navigator.insertAfterIdentifier = self.insertAfterIdentifier
        return navigator
    }
    
    /// Find the index of the step with the given identifier.
    public func index(of identifier: String?) -> Int? {
        guard let identifier = identifier else { return nil }
        return self.steps.firstIndex(where: { $0.identifier == identifier })
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `steps`.
    ///
    /// - example:
    ///
    ///     ```
    ///         let json = """
    ///            {
    ///                "progressMarkers": ["step1", "step2", "step3"],
    ///                "steps": [
    ///                           { "identifier" : "step1",
    ///                             "type" : "instruction",
    ///                             "title" : "Step 1" },
    ///                           { "identifier" : "step2",
    ///                             "type" : "instruction",
    ///                             "title" : "Step 2" },
    ///                           { "identifier" : "step2b",
    ///                             "type" : "instruction",
    ///                             "title" : "Step 2b" },
    ///                           { "identifier" : "step3",
    ///                             "type" : "instruction",
    ///                             "title" : "Step 3" }
    ///                         ]
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the steps
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try decoder.factory.decodePolymorphicArray(RSDStep.self, from: stepsContainer)
        
        // Decode the markers
        self.progressMarkers = try container.decodeIfPresent([String].self, forKey: .progressMarkers)
    }
}

extension RSDConditionalStepNavigatorObject : DocumentableObject {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isOpen() -> Bool {
        return false
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .steps
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .steps:
            return .init(propertyType: .interfaceArray("\(RSDStep.self)"))
        case .progressMarkers:
            return .init(propertyType: .primitiveArray(.string))
        case .insertAfterIdentifier:
            return .init(propertyType: .primitive(.string))
        }
    }
    
    public static func jsonExamples() throws -> [[String : JsonSerializable]] {
        let json: [String : JsonSerializable] = [
                        "insertAfterIdentifier": "foo",
                        "progressMarkers": ["step1", "step2", "step3"],
                        "steps": [
                                   [ "identifier" : "step1",
                                     "type" : "instruction",
                                     "title" : "Step 1" ],
                                   [ "identifier" : "step2",
                                     "type" : "instruction",
                                     "title" : "Step 2" ],
                                   [ "identifier" : "step2b",
                                     "type" : "instruction",
                                     "title" : "Step 2b" ],
                                   [ "identifier" : "step3",
                                     "type" : "instruction",
                                     "title" : "Step 3" ]
                                 ]
                    ]
        return [json]
    }
}
