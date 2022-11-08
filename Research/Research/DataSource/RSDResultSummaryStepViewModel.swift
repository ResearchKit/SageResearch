//
//  RSDResultSummaryStepViewModel.swift
//  Research
//

import Foundation
import JsonModel
import ResultModel

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
