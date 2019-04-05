//
//  CRFTaskObject.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

extension RSDIdentifier {
    static let demographics: RSDIdentifier = "demographics"
}

public final class CRFTaskObject: RSDTaskObject, RSDTaskDesign {
    
    public enum DemographicsKeys : String, CodingKey, Codable {
        case birthYear, sex
    }
    
    /// The birth year of the participant who is doing this task.
    public var birthYear: Int? {
        get {
            return previousRunData[DemographicsKeys.birthYear.stringValue] as? Int
        }
        set {
            previousRunData[DemographicsKeys.birthYear.stringValue] = newValue
        }
    }
    
    /// The sex of the participant who doing this task.
    public var sex: Sex? {
        get {
            guard let sex = previousRunData[DemographicsKeys.sex.stringValue] as? String
                else {
                    return nil
            }
            return Sex(rawValue: sex)
        }
        set {
            previousRunData[DemographicsKeys.sex.stringValue] = newValue?.stringValue
        }
    }
    
    /// Options for the value of the demographics question about biological sex.
    public enum Sex : String, Codable {
        case male, female, other
    }
    
    private var previousRunData: [String : RSDJSONSerializable] = [:]

    /// Override task setup to get the demographics data from a previous run.
    public override func setupTask(with data: RSDTaskData?, for path: RSDTaskPathComponent) {
        if let json = data?.json as? [String : RSDJSONSerializable] {
            previousRunData[DemographicsKeys.sex.stringValue] = json[DemographicsKeys.sex.stringValue]
            previousRunData[DemographicsKeys.birthYear.stringValue] = json[DemographicsKeys.birthYear.stringValue]
        }
        super.setupTask(with: data, for: path)
    }
    
    func hasDemographics() -> Bool {
        return self.birthYear != nil && self.sex != nil
    }
    
    /// Override to check if this is one of the demographics questions.
    public override func shouldSkipStep(_ step: RSDStep) -> (shouldSkip: Bool, stepResult: RSDResult?) {
        guard hasDemographics(),
            (step.stepType == .demographics || step.identifier == RSDIdentifier.demographics.stringValue)
            else {
                return (false, nil)
        }
        if step.stepType == .demographics {
            guard let formStep = step as? RSDFormUIStep,
                let inputField = formStep.inputFields.first,
                let value = previousRunData[step.identifier]
            else {
                return (false, nil)
            }
            let answerResult = RSDAnswerResultObject(identifier: step.identifier, answerType: inputField.dataType.defaultAnswerResultType(), value: value)
            return (true, answerResult)
        }
        else {
            let result = step.instantiateStepResult()
            return (true, result)
        }
    }
    
    /// Return the design system from the factory.
    public var designSystem: RSDDesignSystem {
        return CRFFactory.designSystem
    }
}
