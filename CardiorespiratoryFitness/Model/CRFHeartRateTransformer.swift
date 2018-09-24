//
//  CRFHeartRateTransformer.swift
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

/// `CRFHeartRateTransformer` is used in decoding a step with replacement properties for some or all of the steps in a
/// section that is defined using a different resource. The factory will convert this step into an appropriate
/// `RSDSectionStep` from the decoded object.
struct CRFHeartRateTransformer : RSDStepTransformer, Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case identifier, asyncActions
    }
    
    /// The transformed step.
    public let transformedStep: RSDStep!
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(String.self, forKey: .identifier)
        
        // get the step from the resource.
        let bundle = Bundle(for: CRFFactory.self)
        let resourceTransformer = RSDResourceTransformerObject(resourceName: "HeartrateStep.json",
                                                               bundle: bundle)
        let (data, resourceType) = try resourceTransformer.resourceData(ofType: nil, bundle: decoder.bundle)
        let resourceDecoder = try decoder.factory.createDecoder(for: resourceType, taskIdentifier: decoder.taskIdentifier, schemaInfo: decoder.schemaInfo, bundle: bundle)
        let decodedStep = try resourceDecoder.decode(RSDSectionStepObject.self, from: data)
        var transformedStep = try decodedStep.copy(with: identifier, decoder: decoder)
        
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
            transformedStep.asyncActions = decodedActions
        }
        
        self.transformedStep = transformedStep
    }
}
