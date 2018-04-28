//
//  ORKTask+Research.swift
//  RK1Translator
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

extension ORKTask {
    
    public func step(with identifier: String) -> RSDStep? {
        return self.step?(withIdentifier: identifier) as? RSDStep
    }
    
    public func shouldExit(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        return false
    }
    
    public func hasStep(after step: RSDStep?, with result: RSDTaskResult) -> Bool {
        var temp = result
        return self.step(after: step, with: &temp) != nil
    }
    
    public func hasStep(before step: RSDStep, with result: RSDTaskResult) -> Bool {
        var temp = result
        return self.step(before: step, with: &temp) != nil
    }
    
    public func step(after step: RSDStep?, with result: inout RSDTaskResult) -> (step: RSDStep?, direction: RSDStepDirection)? {
        let taskResult = result as? ORKTaskResult ?? ORKTaskResult(identifier: self.identifier)
        let thisStep = step as? ORKStep
        let nextStep = self.step(after: thisStep, with: taskResult)
        guard nextStep != nil else { return nil }
        guard let gotoStep = nextStep as? RSDStep
            else {
                assertionFailure("\(nextStep!) does not implement the `RSDStep` protocol")
                return nil
        }
        return (gotoStep, .forward)
    }
    
    public func step(before step: RSDStep, with result: inout RSDTaskResult) -> RSDStep? {
        let taskResult = result as? ORKTaskResult ?? ORKTaskResult(identifier: self.identifier)
        let thisStep = step as? ORKStep
        let nextStep = self.step(before: thisStep, with: taskResult)
        guard nextStep != nil else { return nil }
        guard let gotoStep = nextStep as? RSDStep
            else {
                assertionFailure("\(nextStep!) does not implement the `RSDStep` protocol")
                return nil
        }
        return gotoStep
    }
    
    public func progress(for step: RSDStep, with result: RSDTaskResult?) -> (current: Int, total: Int, isEstimated: Bool)? {
        guard let taskResult = result as? ORKTaskResult, let thisStep = step as? ORKStep,
            let currentProgress = self.progress?(ofCurrentStep: thisStep, with: taskResult)
            else {
                return nil
        }
        return (Int(currentProgress.current), Int(currentProgress.total), (self is ORKNavigableOrderedTask))
    }
    
    public var taskInfo: RSDTaskInfoStep? {
        return nil
    }
    
    public var schemaInfo: RSDSchemaInfo? {
        return nil
    }
    
    public var asyncActions: [RSDAsyncActionConfiguration]? {
        return nil
    }
    
    public func instantiateTaskResult() -> RSDTaskResult {
        return ORKTaskResult(identifier: identifier)
    }
    
    public func validate() throws {
        try RSDExceptionHandler.try {
            self.validateParameters?()
        }
    }
    
    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
}

extension ORKOrderedTask : RSDTask, RSDStepNavigator {
    
    public var copyright: String? {
        return nil
    }
    
    public var stepNavigator: RSDStepNavigator {
        return self
    }
}
