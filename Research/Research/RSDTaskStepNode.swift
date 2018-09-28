//
//  RSDTaskStepNode.swift
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

/// `RSDTaskStepNode` is a subclass of `RSDTaskViewModel` that implements the `RSDNodePathComponent`
/// protocol and holds a pointer to an associated "hidden" step. It is hidden in the sense that the
/// base class navigation doesn't show this with a step view controller.
open class RSDTaskStepNode : RSDTaskViewModel, RSDNodePathComponent {
    
    /// The associated step used in navigation.
    public let step : RSDStep
    
    override open var identifier: String {
        return step.identifier
    }
    
    public init(sectionStep: RSDSectionStep, parentPath: RSDPathComponent) {
        self.step = sectionStep
        super.init(task: sectionStep, parentPath: parentPath)
    }
    
    public init(taskInfoStep: RSDTaskInfoStep, parentPath: RSDPathComponent) {
        self.step = taskInfoStep
        super.init(taskInfo: taskInfoStep.taskInfo, parentPath: parentPath)
    }
    
    public init(step: RSDStep, task: RSDTask, parentPath: RSDPathComponent) {
        self.step = step
        super.init(task: task, parentPath: parentPath)
    }
    
    public init(node: RSDTaskStepNode) {
        self.step = node.step
        if let task = node.task {
            super.init(task: task, parentPath: node.parent)
        }
        else if let taskInfo = node.taskInfo {
            super.init(taskInfo: taskInfo, parentPath: node.parent)
        }
        else {
            fatalError("Cannot instantiate without either a task or taskInfo set on the node.")
        }
    }
}
