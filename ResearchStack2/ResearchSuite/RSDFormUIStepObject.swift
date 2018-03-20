//
//  RSDFormUIStepObject.swift
//  ResearchSuite
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

/// `RSDFormUIStepObject` is a concrete implementation of the `RSDFormUIStep` and
/// `RSDSurveyNavigationStep` protocols. It is a subclass of `RSDUIStepObject` and can be used to display
/// a navigable survey.
open class RSDFormUIStepObject : RSDUIStepObject, RSDFormUIStep, RSDSurveyNavigationStep, RSDCohortAssignmentStep {
    
    private enum CodingKeys: String, CodingKey {
        case inputFields
    }

    /// The `inputFields` array is used to hold a logical subgrouping of input fields.
    open private(set) var inputFields: [RSDInputField]
    
    /// Initializer required for `copy(with:)` implementation.
    public required init(identifier: String, type: RSDStepType?) {
        self.inputFields = []
        super.init(identifier: identifier, type: type ?? .form)
    }
    
    /// Override to set the properties of the subclass.
    override open func copyInto(_ copy: RSDUIStepObject, userInfo: [String : Any]?) throws {
        try super.copyInto(copy, userInfo: userInfo)
        guard let subclassCopy = copy as? RSDFormUIStepObject else {
            assertionFailure("Superclass implementation of the `copy(with:)` protocol should return an instance of this class.")
            return
        }
        subclassCopy.inputFields = self.inputFields
    }

    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the step.
    ///     - inputFields: The input fields used to create this step.
    ///     - type: The type of the step. Default = `RSDStepType.form`
    public init(identifier: String, inputFields: [RSDInputField], type: RSDStepType? = nil) {
        self.inputFields = inputFields
        super.init(identifier: identifier, type: type ?? .form)
    }
    
    /// Look to the input fields and return true if any are choice type that include an image.
    override open var hasImageChoices: Bool {
        for item in inputFields {
            if let picker = item.pickerSource as? RSDChoiceOptions, picker.hasImages {
                return true
            }
        }
        return false
    }
    
    /// Identifier to skip to if all input fields have nil answers.
    open var skipToIfNil: String? {
        guard let skipAction = self.action(for: .navigation(.skip), on: self) as? RSDSkipToUIAction
            else {
                return nil
        }
        return skipAction.skipToIdentifier
    }
    
    /// Identifier for the next step to navigate to based on the current task result.
    ///
    /// - note: The conditional rule is ignored by this implementation of the navigation rule. Instead,
    /// this will evaluate any survey rules and the direct navigation rule inherited from
    /// `RSDUIStepObject`.
    ///
    /// - parameters:
    ///     - result:           The current task result.
    ///     - conditionalRule:  The conditional rule associated with this task. (Ignored)
    ///     - isPeeking:        Is this navigation rule being called on a result for a step that is
    ///                         navigating forward or is it a step navigator that is peeking at the next
    ///                         step to set up UI display? If peeking at the next step then this
    ///                         parameter will be `true`.
    /// - returns: The identifier of the next step.
    open override func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> String? {
        return self.evaluateSurveyRules(with: result, isPeeking: isPeeking) ?? self.nextStepIdentifier
    }
    
    /// Evaluate the task result and return the set of cohorts to add and remove. Default implementation
    /// calls
    /// `evaluateCohortsToApply(with:)`.
    ///
    /// - parameter result: The task result to evaluate.
    /// - returns: The cohorts to add/remove or `nil` if no rules apply.
    open func cohortsToApply(with result: RSDTaskResult) -> (add: Set<String>, remove: Set<String>)? {
        return self.evaluateCohortsToApply(with: result)
    }
    
    /// Initialize from a `Decoder`. This implementation will query the `RSDFactory` attached to the
    /// decoder for the appropriate implementation for each input field in the array.
    ///
    /// - note: This method will also check for both an array of input fields and in order to support
    /// existing serialization methods defined prior to the development of the Swift 4 `Decodable`
    /// protocol, it will also recognize a single input field defined inline as a single question.
    ///
    /// - example:
    ///
    ///     ```
    ///         // Example JSON dictionary that includes a date, integer, and multiple choice question
    ///         // defined in an array of dictionaries keyed to "inputFields".
    ///         let json = """
    ///             {
    ///             "identifier": "step3",
    ///             "type": "form",
    ///             "title": "Step 3",
    ///             "text": "Some text.",
    ///             "inputFields": [
    ///                             {
    ///                             "identifier": "foo",
    ///                             "dataType": "date",
    ///                             "uiHint": "picker",
    ///                             "prompt": "Foo",
    ///                             "range" : { "minimumDate" : "2017-02-20",
    ///                                         "maximumDate" : "2017-03-20",
    ///                                         "codingFormat" : "yyyy-MM-dd" }
    ///                             },
    ///                             {
    ///                             "identifier": "bar",
    ///                             "dataType": "integer",
    ///                             "prompt": "Bar"
    ///                             },
    ///                             {
    ///                             "identifier": "goo",
    ///                             "dataType": "multipleChoice",
    ///                             "choices" : ["never", "sometimes", "often", "always"]
    ///                             }
    ///                            ]
    ///             }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///
    ///         // Example JSON dictionary that includes a multiple choice question where the input field
    ///         // properties are defined inline and *not* using an array.
    ///         let json = """
    ///             {
    ///             "identifier": "step3",
    ///             "type": "form",
    ///             "title": "Step 3",
    ///             "dataType": "multipleChoice",
    ///             "choices" : ["never", "sometimes", "often", "always"]
    ///             }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the input fields
        let factory = decoder.factory
        var decodedFields : [RSDInputField] = []
        if container.contains(.inputFields) {
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .inputFields)
            while !nestedContainer.isAtEnd {
                let nestedDecoder = try nestedContainer.superDecoder()
                if let field = try factory.decodeInputField(from: nestedDecoder) {
                    decodedFields.append(field)
                }
            }
        }
        else if let field = try factory.decodeInputField(from: decoder) {
            decodedFields.append(field)
        }
        self.inputFields = decodedFields
        
        try super.init(from: decoder)
    }
    
    /// Instantiate a step result that is appropriate for this step. The default for this class is a
    /// `RSDCollectionResultObject`.
    /// - returns: A result for this step.
    open override func instantiateStepResult() -> RSDResult {
        return RSDCollectionResultObject(identifier: self.identifier)
    }

    /// Validate the step to check for any configuration that should throw an error. This class will
    /// check that the input fields have unique identifiers and will call the `validate()` method on each
    /// input field.
    ///
    /// - throws: An error if validation fails.
    open override func validate() throws {
        try super.validate()
        
        // Check if the identifiers are unique
        let inputIds = inputFields.map({ $0.identifier })
        let uniqueIds = Set(inputIds)
        if inputIds.count != uniqueIds.count {
            throw RSDValidationError.notUniqueIdentifiers("Input field identifiers: \(inputIds.joined(separator: ","))")
        }
        
        // And validate the fields
        for inputField in inputFields {
            try inputField.validate()
        }
    }
    
    
    // Overrides must be defined in the base implementation
    
    override class func codingKeys() -> [CodingKey] {
        var keys = super.codingKeys()
        let thisKeys: [CodingKey] = allCodingKeys()
        keys.append(contentsOf: thisKeys)
        return keys
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.inputFields]
        return codingKeys
    }
    
    override class func validateAllKeysIncluded() -> Bool {
        guard super.validateAllKeysIncluded() else { return false }
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .inputFields:
                if idx != 0 { return false }
            }
        }
        return keys.count == 1
    }
    
    override class func examples() -> [[String : RSDJSONValue]] {
        let jsonA: [String : RSDJSONValue] = [
             "identifier": "step3",
             "type": "form",
             "title": "Step 3",
             "text": "Some text.",
             "inputFields": [
                             [
                             "identifier": "foo",
                             "dataType": "date",
                             "uiHint": "picker",
                             "prompt": "Foo",
                             "range" : [ "minimumDate" : "2017-02-20",
                                         "maximumDate" : "2017-03-20",
                                         "codingFormat" : "yyyy-MM-dd" ]
                             ],
                             [
                             "identifier": "bar",
                             "dataType": "integer",
                             "prompt": "Bar"
                             ],
                             [
                             "identifier": "goo",
                             "dataType": "multipleChoice",
                             "choices" : ["never", "sometimes", "often", "always"]
                             ]
                            ]
             ]
        
        let jsonB: [String : RSDJSONValue] = [
             "identifier": "step3",
             "type": "form",
             "title": "Step 3",
             "dataType": "multipleChoice",
             "choices" : ["never", "sometimes", "often", "always"]
             ]
        
        return [jsonA, jsonB]
    }
}
