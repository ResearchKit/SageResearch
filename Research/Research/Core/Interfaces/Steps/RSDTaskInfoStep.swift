//
//  RSDTaskInfoStep.swift
//  Research
//

import Foundation

/// `RSDTaskInfoStep` is a reference interface for information about the task. This includes
/// information that can be displayed in a table or collection view before starting the task as
/// well as information that is displayed while the task is being fetched in the case where the
/// task is not fetched using an embedded resource or via a hardcoded task.
public protocol RSDTaskInfoStep : RSDStep {
    
    /// The task info for this step.
    var taskInfo: RSDTaskInfo { get }
}
