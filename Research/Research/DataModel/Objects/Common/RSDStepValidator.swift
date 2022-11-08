//
//  RSDStepValidator.swift
//  Research
//

import Foundation

/// `RSDStepValidator` is a convenience protocol for validating the steps in a list as unique.
public protocol RSDStepValidator {
    
    /// An ordered list of steps, each with a unique identifier.
    var steps : [RSDStep] { get }
}

extension RSDStepValidator {
    
    /// Steps must have unique identifiers and each step within the collection must be valid.
    public func stepValidation() throws {
        let stepIds = steps.map { $0.identifier }
        let uniqueIds = Set(stepIds)
        guard stepIds.count == uniqueIds.count
            else {
                throw RSDValidationError.notUniqueIdentifiers("Step identifiers: \(stepIds.joined(separator: ","))")
        }
        
        for step in steps {
            try step.validate()
        }
    }
}
