//
//  RSDStepTransformer.swift
//  Research
//

import Foundation


/// `RSDStepTransformer` is used in decoding a step with replacement properties for some or all of the
/// properties that is defined using a different resource.
public protocol RSDStepTransformer {
    
    /// The step transformed by this object for inclusion into a task.
    var transformedStep: RSDStep! { get }
}
