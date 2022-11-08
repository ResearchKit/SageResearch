//
//  RSDTaskStepNode.swift
//  Research
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
