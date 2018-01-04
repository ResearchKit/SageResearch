//
//  RSDTransformerStepObject.swift
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

/// `RSDTransformerStepObject` is used in decoding a step with replacement properties for some or all of the steps in a
/// section that is defined using a different resource. The factory will convert this step into an appropriate
/// `RSDSectionStep` from the decoded object.
public struct RSDTransformerStepObject : RSDTransformerStep, Decodable {

    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    public let identifier: String
    
    /// The type of the step.
    public let stepType: RSDStepType
    
    /// A list of steps keyed by identifier with replacement values for the properties in the step.
    public var replacementSteps: [RSDGenericStep]?
    
    /// The transformer for the section steps.
    public var sectionTransformer: RSDSectionStepTransformer!
        
    private enum CodingKeys : String, CodingKey {
        case identifier, stepType = "type", replacementSteps, sectionTransformer
    }
    
    /// Initialize from a `Decoder`. 
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes a transformation step. The section is created from the
    ///         // resource and then the values in the `replacementSteps` are used to mutate that step.
    ///         let json = """
    ///            {
    ///             "identifier"         : "heartRate.before",
    ///             "type"               : "transform",
    ///             "replacementSteps"   : [{   "identifier"   : "instruction",
    ///                                         "title"        : "This is a replacement title for the instruction.",
    ///                                         "text"         : "This is some replacement text." },
    ///                                     {   "identifier"   : "feedback",
    ///                                         "text"         : "Your pre run heart rate is" }
    ///                                     ],
    ///            "sectionTransformer"    : { "resourceName": "HeartrateStep.json"}
    ///            }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decodeIfPresent(RSDStepType.self, forKey: .stepType) ?? .section
        if container.contains(.replacementSteps) {
            self.replacementSteps = try container.decode([RSDGenericStepObject].self, forKey: .replacementSteps)
        }
        if container.contains(.sectionTransformer) {
            let nestedDecoder = try container.superDecoder(forKey: .sectionTransformer)
            self.sectionTransformer = try decoder.factory.decodeSectionStepTransformer(from: nestedDecoder)
        }
    }
    
    /// Required method. Returns the default for a section step.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    /// Required method. Does nothing.
    public func validate() throws {
    }
}

extension RSDTransformerStepObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .stepType, .replacementSteps, .sectionTransformer]
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
            case .replacementSteps:
                if idx != 2 { return false }
            case .sectionTransformer:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
                     "identifier"         : "heartRate.before",
                     "type"               : "transform",
                     "replacementSteps"   : [[   "identifier"   : "instruction",
                                                 "title"        : "This is a replacement title for the instruction.",
                                                 "text"         : "This is some replacement text." ],
                                             [   "identifier"   : "feedback",
                                                 "text"         : "Your pre run heart rate is" ]
                                             ],
                    "sectionTransformer"    : [ "resourceName" : "HeartrateStep.json"]
                    ]
        return [jsonA]
    }
}
