//
//  CRFHeartRateSectionStep.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

public struct CRFHeartRateSectionStep : RSDSectionStep, RSDConditionalStepNavigator, RSDStepValidator, Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case identifier, asyncActions, timing, stepType
    }
    
    /// The identifier for the section.
    public let identifier: String
    
    /// The section type is `.heartRateSection`.
    public var stepType: RSDStepType
    
    /// The steps in the section.
    public let steps: [RSDStep]
    
    /// List of async actions associated with this step.
    public let asyncActions: [RSDAsyncActionConfiguration]?
    
    /// The timing for when the measurement is being taken.
    public let timing: Timing
    
    /// The timing references to whether or not this is before an active step, after an active step, or a
    /// standalone heart rate measurement.
    public enum Timing : String, Codable {
        case before, after, standalone
    }
    
    /// Returns a task result.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: self.identifier)
    }
    
    /// Validate that the steps are unique.
    public func validate() throws {
        try self.stepValidation()
    }
    
    /// Copyright is ignored.
    public var copyright: String? {
        return nil
    }
    
    /// Do not include any progress markers for this section.
    public var progressMarkers: [String]? {
        return []
    }
    
    /// Initialize with the default embedded resource.
    public init(with identifier: String) {
        do {
            try self.init(with: identifier, nil, nil)
        }
        catch let err {
            fatalError("Failed to decode the embedded resource. \(err)")
        }
    }
    
    /// Initialize the step with a transformable section.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        let timing = try container.decodeIfPresent(Timing.self, forKey: .timing)
        try self.init(with: identifier, timing, decoder)
    }
    
    private init(with identifier: String,_ timing: Timing?, _ decoder: Decoder?) throws {
        
        // get the step from the resource and copy in the bits from this decoder.
        let transformedStep = try CRFHeartRateSectionStep._decodedSectionStep(with: identifier, decoder)

        // Copy the properties from the transformed section step to this step.
        self.identifier = transformedStep.identifier
        self.stepType = transformedStep.stepType
        self.steps = transformedStep.steps
        self.asyncActions = transformedStep.asyncActions
        self.timing = timing ?? .standalone
    }
    
    private static func _decodedSectionStep(with identifier: String, _ decoder: Decoder? = nil) throws -> RSDSectionStepObject {
        let bundle = Bundle(for: CRFFactory.self)
        let factory = CRFFactory()
        let resourceTransformer = RSDResourceTransformerObject(resourceName: "HeartrateStep.json",
                                                               bundle: bundle)
        let (data, resourceType) = try resourceTransformer.resourceData(ofType: nil, bundle: bundle)
        let resourceDecoder = try factory.createDecoder(for: resourceType, taskIdentifier: nil, schemaInfo: nil, bundle: bundle)
        let decodedStep = try resourceDecoder.decode(RSDSectionStepObject.self, from: data)
        return try decodedStep.copy(with: identifier, decoder: decoder)
    }
}
