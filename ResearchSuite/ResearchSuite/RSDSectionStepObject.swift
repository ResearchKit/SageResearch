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

public struct RSDSectionStepObject: RSDSectionStep, RSDStepValidator, Decodable {
    
    public let type: String
    public let identifier: String
    public let steps: [RSDStep]
    
    public init(identifier: String, steps: [RSDStep], type: String? = nil) {
        self.identifier = identifier
        self.steps = steps
        self.type = type ?? RSDFactory.StepType.section.rawValue
    }
    
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    public func validate() throws {
        try stepValidation()
    }
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, steps
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.type = try container.decode(String.self, forKey: .type)
        let stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)
        self.steps = try decoder.factory.decodeSteps(from: stepsContainer)
    }
}

/**
 Extend the 
 */
extension RSDSectionStep {
    
    public var conditionalRule : RSDConditionalRule? {
        return nil
    }
    
    public var taskInfo: RSDTaskInfo? {
        return nil
    }
    
    public var schemaInfo: RSDSchemaInfo? {
        return nil
    }
    
    public var stepNavigator: RSDStepNavigator {
        return self
    }
    
    public var asyncActions: [RSDAsyncActionConfiguration]? {
        return nil
    }
    
    public func instantiateTaskResult() -> RSDTaskResult {
        let result = self.instantiateStepResult()
        if let taskResult = result as? RSDTaskResult {
            assertionFailure("Expected that a section step will return a result that conforms to RSDTaskResult protocol.")
            return taskResult
        }
        return RSDTaskResultObject(identifier: identifier)
    }
}
