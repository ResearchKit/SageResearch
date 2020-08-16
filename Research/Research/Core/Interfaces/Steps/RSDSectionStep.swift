//
//  RSDSectionStep.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDSectionStep` is used to define a logical subgrouping of steps such as a section in a longer survey
/// or an active step that includes an instruction step, countdown step, and activity step.
public protocol RSDSectionStep: RSDStep, RSDTask, RSDStepNavigator {
    
    /// A list of the steps used to define this subgrouping of steps.
    var steps: [RSDStep] { get }
}

extension RSDSectionStep {
    
    /// Task info is `nil` for a section step.
    public var taskInfo: RSDTaskInfoStep? {
        return nil
    }
    
    /// Schema info is `nil` for a section step.
    public var schemaInfo: RSDSchemaInfo? {
        return nil
    }
    
    /// The step navigator is `self` for a section step.
    public var stepNavigator: RSDStepNavigator {
        return self
    }
    
    /// A section step returns a task result for both the step result and the task result
    /// This method will throw an assert if the implementation of the section step does not
    /// return a `RSDTaskResult` as its type.
    public func instantiateTaskResult() -> RSDTaskResult {
        let result = self.instantiateStepResult()
        guard let taskResult = result as? RSDTaskResult else {
            assertionFailure("Expected that a section step will return a result that conforms to RSDTaskResult protocol.")
            return SectionResultObject(identifier: identifier)
        }
        return taskResult
    }
}

