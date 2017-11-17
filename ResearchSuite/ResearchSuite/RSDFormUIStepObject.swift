//
//  RSDFormUIStepObject.swift
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

open class RSDFormUIStepObject : RSDUIStepObject, RSDFormUIStep, RSDSurveyNavigationStep {

    open private(set) var inputFields: [RSDInputField]
    
    open var skipToIfNil: String? {
        guard let skipAction = self.action(for: .navigation(.skip), on: self) as? RSDSkipToUIAction
            else {
                return nil
        }
        return skipAction.skipToIdentifier
    }
    
    open override func nextStepIdentifier(with result: RSDTaskResult?, conditionalRule: RSDConditionalRule?, isPeeking: Bool) -> String? {
        return self.evaluateSurveyRules(with: result, isPeeking: isPeeking) ?? self.nextStepIdentifier
    }
    
    public init(identifier: String, inputFields: [RSDInputField], type: RSDStepType? = nil) {
        self.inputFields = inputFields
        super.init(identifier: identifier, type: type ?? .form)
    }
    
    private enum CodingKeys: String, CodingKey {
        case inputFields
    }
    
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
    
    open override func instantiateStepResult() -> RSDResult {
        return RSDCollectionResultObject(identifier: self.identifier)
    }

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
}
