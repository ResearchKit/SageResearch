//
//  RSDSurveyNavigationStep.swift
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

/**
 `RSDSurveyNavigationStep` evaluates `RSDSurveyRule` objects that are associated with each input field to determine if the step navigation should skip to another step.
 */
public protocol RSDSurveyNavigationStep : RSDNavigationRule {
    
    /**
     Identifier to skip to if all input fields have nil answers.
     */
    var skipToIfNil: String? { get }
    
    /**
     The input fields to test as a part of this navigation.
     */
    var inputFields: [RSDInputField] { get }
}

public protocol RSDSurveyInputField : RSDInputField {

    /**
     A list of survey rules associated with this input field.
     */
    var surveyRules: [RSDSurveyRule]? { get }
}

extension RSDSurveyNavigationStep {

    public func evaluateSurveyRules(with result: RSDTaskResult?, isPeeking: Bool) -> String? {
        // Do not apply rules when the navigation is only peaking
        guard !isPeeking else { return nil }
        
        // If the result is nil then return the skipToNil value
        guard let finder = result else { return skipToIfNil }

        var allAnswersNil = true
        var skipIdentifiers = Set<String>()
        for inputField in inputFields {
            let answerResult = finder.findAnswerResult(with: inputField.identifier)
            allAnswersNil = allAnswersNil && (answerResult?.value == nil)
            if let surveyInput = inputField as? RSDSurveyInputField,
                let rules = surveyInput.surveyRules {
                let skipTos = rules.rsd_mapAndFilter{ $0.evaluateRule(with: answerResult) }
                skipIdentifiers.formUnion(skipTos)
            }
        }

        return skipIdentifiers.count == 1 ? skipIdentifiers.first : (allAnswersNil ? skipToIfNil : nil)
    }
}




