//
//  RSDStep.swift
//  Research
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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

/// `RSDStep` is the base protocol for the steps that can compose a task for presentation using a
/// controller appropriate to the device and application. Each `RSDStep` object represents one logical
/// piece of data entry, information, or activity in a larger task.
///
/// Implementations included in this SDK include:
/// 1. `RSDSectionStep` is used to define a logical subgroup of steps.
/// 2. `RSDUIStep` is used to define a display step.
/// 3. `RSDTaskInfoStep` is used to combine tasks into a single flow. For example, if the researcher wishes
///     to ask for survey responses before an activity.
///
/// A step can be a question, an active test, or a simple instruction. An `RSDStep` subclass is usually
/// paired with an `RSDStepController` that controls the actions of the step.
///
public protocol RSDStep {
    
    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in
    /// the results  of a step history.
    ///
    /// In some cases, it can be useful to link the step identifier to a unique identifier in a database;
    /// in other cases, it can make sense to make the identifier human readable.
    var identifier: String { get }
    
    /// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to
    /// customize the UI.
    var stepType: RSDStepType { get }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: A result for this step.
    func instantiateStepResult() -> RSDResult
    
    /// Validate the step to check for any configuration that should throw an error.
    /// - throws: An error if validation fails.
    func validate() throws
}

/// `RSDCopyStep` is a step that supports creating a copy of itself that has specified properties mutated
/// to return a new instance and/or includes mutated properties.
public protocol RSDCopyStep : RSDStep, RSDCopyWithIdentifier {

    /// Copy the step to a new instance with the given identifier and user info.
    /// - parameters:
    ///     - identifier: The new identifier.
    ///     - decoder: A decoder that can be used to decode properties on this step.
    func copy(with identifier: String, decoder: Decoder?) throws -> Self
}

extension Array where Element == RSDStep {
    public func deepCopy() -> [RSDStep] {
        self.map { (step) -> RSDStep in
            (step as? RSDCopyStep)?.copy(with: step.identifier) ?? step
        }
    }
}
