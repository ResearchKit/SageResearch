//
//  RSDStepTransformerObject.swift
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

/// `RSDStepTransformerObject` is used in decoding a step with replacement properties for some or all of the steps in a
/// section that is defined using a different resource. The factory will convert this step into an appropriate
/// `RSDSectionStep` from the decoded object.
public struct RSDStepTransformerObject : RSDStepTransformer, Decodable {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, resourceTransformer
    }
    
    /// The transformed step.
    public let transformedStep: RSDStep!
    
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
    ///             "steps"   : [{   "identifier"   : "instruction",
    ///                                         "title"        : "This is a replacement title for the instruction.",
    ///                                         "text"         : "This is some replacement text." },
    ///                                     {   "identifier"   : "feedback",
    ///                                         "text"         : "Your pre run heart rate is" }
    ///                                     ],
    ///            "resourceTransformer"    : { "resourceName": "HeartrateStep.json"}
    ///            }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        
        // get the step from the resource.
        let resourceTransformer = try container.decode(RSDResourceTransformerObject.self, forKey: .resourceTransformer)
        let (data, resourceType) = try resourceTransformer.resourceData(ofType: nil, bundle: decoder.bundle)
        let resourceDecoder = try decoder.factory.createDecoder(for: resourceType, taskIdentifier: decoder.taskIdentifier, schemaInfo: decoder.schemaInfo, bundle: decoder.bundle)
        let stepDecoder = try resourceDecoder.decode(_StepDecoder.self, from: data)
        
        // copy to transformer
        if let copyableStep = stepDecoder.step as? RSDCopyStep {
            self.transformedStep = try copyableStep.copy(with: identifier, decoder: decoder)
        }
        else if let copyableStep = stepDecoder.step as? RSDCopyWithIdentifier {
            self.transformedStep = (copyableStep.copy(with: identifier) as! RSDStep)
        }
        else {
            self.transformedStep = stepDecoder.step
        }
    }
}

fileprivate struct _StepDecoder: Decodable {
    
    let step: RSDStep
    
    init(from decoder: Decoder) throws {
        guard let step = try decoder.factory.decodeStep(from: decoder) else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode a step from the given decoder.")
            throw DecodingError.dataCorrupted(context)
        }
        self.step = step
    }
}

extension RSDStepTransformerObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        // TODO: Add some resource examples. syoung 04/11/2018
        return []
    }
}
