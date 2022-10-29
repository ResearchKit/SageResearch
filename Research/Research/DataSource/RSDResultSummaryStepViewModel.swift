//
//  RSDResultSummaryStepViewModel.swift
//  Research
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import JsonModel

open class RSDResultSummaryStepViewModel: RSDStepViewModel {
    
    /// Text to display as the title above the result.
    open var resultTitle: String? {
        guard let resultStep = self.step as? RSDResultSummaryStep else { return nil }
        return resultStep.resultTitle
    }
    
    /// Unit (if any) for this result.
    open var unitText: String? {
        guard let resultStep = self.step as? RSDResultSummaryStep else { return nil }
        return resultStep.unitText
    }
    
    /// Formatted and localized result.
    open var resultText: String? {
        guard let resultStep = self.step as? RSDResultSummaryStep,
            let result = resultStep.answerValueAndType(from: taskResult),
            let answer = result.value
            else {
                return nil
        }
        let answerType = result.answerType ?? AnswerTypeString()
        
        if let arrayType = answerType as? AnswerTypeArray,
            let answerArray = answer as? [Any] {
            let strings = answerArray.map { "\($0)" }
            if let separator = arrayType.sequenceSeparator {
                return strings.joined(separator: separator)
            }
            else {
                return Localization.localizedAndJoin(strings)
            }
        }
        else if let num = (answer as? NSNumber) ?? (answer as? JsonNumber)?.jsonNumber() {
            return self.numberFormatter.string(from: num)
        }
        else {
            return "\(answer)"
        }
    }
    
    /// The number formatter to use to format a decimal result.
    open var numberFormatter: NumberFormatter {
        return _numberFormatter
    }
    lazy private var _numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()
}
