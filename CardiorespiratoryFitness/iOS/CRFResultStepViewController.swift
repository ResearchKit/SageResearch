//
//  CRFResultStepViewController.swift
//  CardiorespiratoryFitness
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

import UIKit

open class CRFResultStepViewController: RSDStepViewController {
    
    @IBOutlet public var textLabel: UILabel?
    @IBOutlet public var resultLabel: UILabel!
    @IBOutlet public var unitLabel: UILabel?
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textLabel?.text = self.uiStep?.text
        self.resultLabel.text = resultText
        self.unitLabel?.text = unitText
    }
    
    open var unitText: String? {
        return self.unitLabel?.text
    }
    
    open var resultText: String? {
        return self.resultLabel.text
    }
    
    open var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()
}

public class CRFHeartRateResultStepViewController: CRFResultStepViewController {
    
    override public var resultText: String? {
        
        let resultStepIdentifier = "heartRate"
        let taskPath = self.taskController.taskPath!
        let sResult = taskPath.result.stepHistory.first { $0.identifier == resultStepIdentifier}
        guard let stepResult = sResult as? RSDCollectionResult
            else {
                return nil
        }
        
        let aResult = stepResult.inputResults.first { $0.identifier == resultStepIdentifier }
        guard let result = aResult as? RSDAnswerResult,
            let answer = result.value as? RSDJSONNumber, let num = answer.jsonNumber()
            else {
                return nil
        }
        
        return numberFormatter.string(from: num)
    }
}

public class CRFCompletionResultStepViewController : CRFResultStepViewController {
    
    @IBOutlet public var doneButton: RSDRoundedButton?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doneButton?.setTitle(Localization.buttonDone(), for: .normal)
    }
}

public class CRFRunDistanceResultStepViewController : CRFCompletionResultStepViewController {
    
    let usesMetricSystem: Bool = Locale.current.usesMetricSystem
    
    let unitFormatter: LengthFormatter = {
        let unitFormatter = LengthFormatter()
        unitFormatter.unitStyle = .long
        return unitFormatter
    }()
    
    override public var unitText: String? {
        guard let distance = resultAnswer else { return nil }
        if usesMetricSystem {
            return unitFormatter.unitString(fromValue: distance.doubleValue, unit: .meter).localizedUppercase
        } else {
            return unitFormatter.unitString(fromValue: distance.doubleValue, unit: .foot).localizedUppercase
        }
    }
    
    override public var resultText: String? {
        guard let distance = resultAnswer else { return nil }
        return numberFormatter.string(from: distance)
    }
    
    public var resultAnswer : NSNumber? {
        
        let resultStepIdentifier = "run"
        let taskPath = self.taskController.taskPath!
        let secResult = taskPath.result.stepHistory.first { $0.identifier == resultStepIdentifier}
        guard let sectionResult = secResult as? RSDTaskResult
            else {
                return nil
        }
        
        let resultIdentifier = "runDistance"
        let aResult = sectionResult.stepHistory.first { $0.identifier == resultIdentifier }
        guard let result = aResult as? RSDAnswerResult,
            let num = result.value as? RSDJSONNumber,
            let answer = num.jsonNumber()?.doubleValue
            else {
                return nil
        }
        
        return usesMetricSystem ? NSNumber(value: answer) : NSNumber(value: answer * 3.28084)
    }
}

public class CRFStairStepResultStepViewController : CRFCompletionResultStepViewController {
    
    override public var resultText: String? {
        guard let before = result(with: "heartRate.before"), let after = result(with: "heartRate.after")
            else {
                return nil
        }
        
        let difference = after - before
        return numberFormatter.string(from: NSNumber(value: difference))
    }
    
    func result(with identifier:String) -> Int? {
        
        let taskPath = self.taskController.taskPath!
        let secResult = taskPath.result.stepHistory.first { $0.identifier == identifier}
        guard let sectionResult = secResult as? RSDTaskResult
            else {
                return nil
        }
        
        let resultStepIdentifier = "heartRate"
        let sResult = sectionResult.stepHistory.first { $0.identifier == resultStepIdentifier}
        guard let stepResult = sResult as? RSDCollectionResult
            else {
                return nil
        }
        
        let resultIdentifier = resultStepIdentifier
        let aResult = stepResult.inputResults.first { $0.identifier == resultIdentifier }
        guard let result = aResult as? RSDAnswerResult,
            let answer = result.value as? RSDJSONNumber
            else {
                return nil
        }
        
        return Int(round(answer.jsonNumber()?.doubleValue ?? 0))
    }
}


