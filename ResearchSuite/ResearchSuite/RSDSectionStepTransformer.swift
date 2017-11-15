//
//  RSDSectionStepTransformer.swift
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

/// `RSDSectionStepTransformer` is a lightweight protocol for vending the steps in a section.
/// This object is used to allow accessing an `RSDSectionStep` for use in multiple tasks or
/// multiple times within a task.
///
/// For example, for a task where the user is going to run for 12 minutes, the researchers may wish
/// to record the user's heart rate both before and after the run. The heart rate can be defined in
/// a seperate file or model object and the transformer is used as a placeholder that can fetch and
/// replace itself with a section of steps that are used to capture the user's heartrate.
///
/// - seealso: `RSDSectionStep`, `RSDTransformerStepObject` and `RSDFactory`
public protocol RSDSectionStepTransformer {
    
    /// Fetch the steps for this section.
    ///
    /// - parameter factory: The factory to use for creating the task and steps.
    /// - returns: The steps for this section.
    func transformSteps(with factory: RSDFactory) throws -> [RSDStep]
}

/// `RSDSectionStepResourceTransformer` is an implementation of a `RSDSectionStepTransformer` that uses
/// a `RSDResourceTransformer` to support transforming the section from one resource for inclusion
/// in another task defined using a different resource.
public protocol RSDSectionStepResourceTransformer : RSDSectionStepTransformer, RSDResourceTransformer {
}

extension RSDSectionStepResourceTransformer {
    
    /// Fetch the steps for this section.
    ///
    /// - parameter factory: The factory to use for creating the task and steps.
    /// - returns: The steps for this section.
    public func transformSteps(with factory: RSDFactory) throws -> [RSDStep] {
        let (data, resourceType) = try self.resourceData()
        let decoder = try factory.createDecoder(for: resourceType)
        let stepDecoder = try decoder.decode(_StepsDecoder.self, from: data)
        return stepDecoder.steps
    }
}

fileprivate struct _StepsDecoder: Decodable {
    
    let steps: [RSDStep]
    
    private enum CodingKeys : String, CodingKey {
        case steps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try decoder.factory.decodeSteps(from: stepsContainer)
    }
    
}
