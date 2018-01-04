//
//  RSDStep.swift
//  ResearchSuite
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

/// `RSDStep` is the base protocol for the steps that can compose a task for presentation using a controller appropriate
/// to the device and application. Each `RSDStep` object represents one logical piece of data entry, information, or
/// activity in a larger task.
///
/// Implementations included in this SDK include:
/// 1. `RSDGenericStep` is used by `RSDFactory` to create a step that does not include a recognized subtype.
/// 2. `RSDSectionStep` is used to define a logical subgroup of steps.
/// 3. `RSDUIStep` is used to define a display step.
/// 4. `RSDTaskInfoStep` is used to combine tasks into a single flow. For example, if the researcher wishes to ask
///     for survey responses before an activity.
///
/// A step can be a question, an active test, or a simple instruction. An `RSDStep` subclass is usually paired with an
/// `RSDStepController` that controls the actions of the step.
///
public protocol RSDStep {
    
    /// A short string that uniquely identifies the step within the task. The identifier is reproduced in the results
    /// of a step history.
    ///
    /// In some cases, it can be useful to link the step identifier to a unique identifier in a database; in other cases,
    /// it can make sense to make the identifier human readable.
    var identifier: String { get }
    
    /// The type of the step. This is used to decode the step using a `RSDFactory`. It can also be used to customize
    /// the UI.
    var stepType: RSDStepType { get }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: A result for this step.
    func instantiateStepResult() -> RSDResult
    
    /// Validate the step to check for any configuration that should throw an error.
    /// - throws: An error if validation fails.
    func validate() throws
}

/// `RSDGenericStep` is a step with key/value pairs decoded from a dictionary. This is the default step returned by
/// `RSDFactory` for an unrecoginized type.
public protocol RSDGenericStep : RSDStep {
    
    /// The decoded dictionary.
    var userInfo: [String : Any] { get }
}

/// `RSDSectionStep` is used to define a logical subgrouping of steps such as a section in a longer survey or an active
/// step that includes an instruction step, countdown step, and activity step.
public protocol RSDSectionStep: RSDStep, RSDTask, RSDConditionalStepNavigator {
    
    /// A list of the steps used to define this subgrouping of steps.
    var steps: [RSDStep] { get }
}

extension RSDSectionStep {
    
    /// Conditional rule is `nil` for a section step.
    public var conditionalRule : RSDConditionalRule? {
        return nil
    }
    
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
            return RSDTaskResultObject(identifier: identifier)
        }
        return taskResult
    }
}

/// `RSDUIStep` is used to define a single "display unit". Depending upon the available real-estate, more than one
/// ui step may be displayed at a time. For example, on an iPad, you may choose to group a set of questions using
/// a `RSDSectionStep`.
public protocol RSDUIStep: RSDStep, RSDUIActionHandler {
    
    /// The primary text to display for the step in a localized string.
    var title: String? { get }
    
    /// Additional text to display for the step in a localized string.
    ///
    /// The additional text is often displayed in a smaller font below `title`. If you need to display a long
    /// question, it can work well to keep the title short and put the additional content in the `text` property.
    var text: String? { get }
    
    /// Additional detailed explanation for the step.
    ///
    /// The font size and display of this property will depend upon the device type.
    var detail: String? { get }
    
    /// Additional text to display for the step in a localized string at the bottom of the view.
    ///
    /// The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended to be
    /// used in order to include disclaimer, copyright, etc. that is important to display in the step but should not
    /// distract from the main purpose of the step.
    var footnote: String? { get }
}

/// `RSDMutableStep` is a step that supports copying information from a dictionary into this step. Because this step
/// can be mutated, it must be implemented as a class.
///
/// - seealso: `RSDUIStepObject` for an example implementation.
public protocol RSDMutableStep: class, RSDStep {
    
    /// A step to merge with this step that carries replacement info. This step will look at the replacement info
    /// in the generic step and replace properties on self as appropriate.
    func replace(from step: RSDGenericStep) throws
}

/// `RSDThemedUIStep` is a UI step that supports theme customization of the color and/or images used.
public protocol RSDThemedUIStep : RSDUIStep {
    
    /// The view info used to create a custom step.
    var viewTheme: RSDViewThemeElement? { get }
    
    /// The color theme.
    var colorTheme: RSDColorThemeElement? { get }
    
    /// The image theme.
    var imageTheme: RSDImageThemeElement? { get }
}

/// `RSDFormUIStep` implements additional properties used in creating a form input.
public protocol RSDFormUIStep: RSDUIStep {
    
    /// The `inputFields` array is used to hold a logical subgrouping of input fields. If this array holds more
    /// than one input field, those fields should describe an input that is uses a logical subgrouping
    /// such as birth month/year or given/family name.
    var inputFields: [RSDInputField] { get }
}

/// `RSDActiveUIStep` extends the `RSDUIStep` to include a duration and commands. This is used for the case where an
/// `RSDUIStep` has an action such as "start walking" or "stop walking"; the step may also implement the `RSDActiveUIStep`
/// protocol to allow for spoken instruction.
public protocol RSDActiveUIStep: RSDUIStep {
    
    /// The duration of time to run the step. If `0`, then this value is ignored.
    var duration: TimeInterval { get }
    
    /// The set of commands to apply to this active step. These indicate actions to fire at the beginning and end of
    /// the step such as playing a sound as well as whether or not to automatically start and finish the step.
    var commands: RSDActiveUIStepCommand { get }
    
    /// Localized text that represents an instructional voice prompt. Instructional speech begins when the step
    /// passes the time indicated by the given time.  If `timeInterval` is greater than or equal to `duration`
    /// or is equal to `Double.infinity`, then the spoken instruction returned should be for when the step is finished.
    ///
    /// - parameter timeInterval: The time interval at which to speak the instruction.
    /// - returns: The localized instruction to speak or `nil` if there isn't an instruction.
    func spokenInstruction(at timeInterval: TimeInterval) -> String?
}

/// `RSDTransformerStep` is used in decoding a step with replacement properties for some or all of the steps in a
/// section that is defined using a different resource.
public protocol RSDTransformerStep: RSDStep {
    
    /// A list of steps keyed by identifier with replacement values for the properties in the step.
    var replacementSteps: [RSDGenericStep]? { get }
    
    /// The transformer for the section steps.
    var sectionTransformer: RSDSectionStepTransformer! { get }
}
