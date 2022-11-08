//
//  RSDTaskResult.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// `RSDTaskResult` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public protocol RSDTaskResult : BranchNodeResult {
}

/// The `RSDTaskRunResult` is a task result where the task run UUID can be set to allow for nested
/// results that all use the same run UUID.
@available(*, deprecated, message: "Implement `AssessmentResult` instead")
public protocol RSDTaskRunResult : AssessmentResult {
    
    /// Schema info associated with this task.
    var schemaInfo: RSDSchemaInfo? { get set }
}

@available(*, deprecated, message: "Implement `AssessmentResult` instead")
extension RSDTaskRunResult {
    public var versionString: String? {
        guard let revision = schemaInfo?.schemaVersion else { return nil }
        return "\(revision)"
    }
    
    public var assessmentIdentifier: String? {
        self.identifier
    }
    
    public var schemaIdentifier: String? {
        self.schemaInfo?.schemaIdentifier
    }
}

extension RSDTaskResult  {
    
    /// Find a result within the step history.
    /// - parameter step: The step associated with the result.
    /// - returns: The result or `nil` if not found.
    public func findResult(for step: RSDStep) -> ResultData? {
        return self.stepHistory.first(where: { $0.identifier == step.identifier })
    }
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    /// - parameter result:  The result to add to the async results.
    public func appendAsyncResult(with result: ResultData) {
        insert(result)
    }
}
