//
//  Result.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

/// The `BranchNodeResult` is the result created for a given level of navigation of a node tree.
public extension BranchNodeResult {
    
    /// The path traversed by this branch. The `nodePath` is specific to the navigation implemented
    /// on iOS and is different from the `path` implementation in the Kotlin-native framework.
    var nodePath: [String] {
        get {
            self.path.map { $0.identifier }
        }
        set {
            self.path = newValue.map { .init(identifier: $0, direction: .forward) }
        }
    }
}

extension AssessmentResultObject : RSDTaskResult {
}

extension BranchNodeResultObject : RSDTaskResult {
}
