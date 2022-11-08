//
//  RSDDocumentable.swift
//  Research
//

import Foundation
import JsonModel

@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDDocumentCreator {
    
    let allStringEnums: [DocumentableStringEnum.Type] = {
        
        var allEnums: [DocumentableStringEnum.Type] = [
        RSDCohortRuleOperator.self,
        RSDKeyboardType.self,
        RSDSurveyRuleOperator.self,
        RSDTextAutocapitalizationType.self,
        RSDTextAutocorrectionType.self,
        RSDTextSpellCheckingType.self,
        RSDWeekday.self,
        ]
        
        return allEnums
    }()
    
    let allOptionSets: [DocumentableStringOptionSet.Type] = [
        RSDActiveUIStepCommand.self,
        ]
    
    let allStringLiterals: [DocumentableStringLiteral.Type] = [
        RSDDateCoderObject.self,
        RSDDeviceType.self,
        RSDFormUIHint.self,
        RSDIdentifier.self,
        RSDStepType.self,
        ]

    let allCodableObjects: [DocumentableObject.Type] = [
        RSDAnimatedImageThemeElementObject.self,
        RSDCohortNavigationRuleObject.self,
        RSDDateRangeObject.self,
        RSDNavigationUIActionObject.self,
        RSDResourceTransformerObject.self,
        RSDTaskInfoStepObject.self,
        RSDTaskResultObject.self,
        RSDUIActionObject.self,
        RSDViewThemeElementObject.self,
        RSDWebViewUIActionObject.self,
        RSDVideoViewUIActionObject.self,
        RSDWeeklyScheduleObject.self,
        ]
    
    let allDecodableObjects: [DocumentableObject.Type] = [
        RSDAssessmentTaskObject.self,
        RSDUIStepObject.self,
        RSDActiveUIStepObject.self,
        RSDOverviewStepObject.self,
        RSDResultSummaryStepObject.self,
        RSDSectionStepObject.self,
        //RSDStepTransformerObject.self, // syoung 04/14/2020 Cannot test the step transformer as a generic.
        RSDColorPlacementThemeElementObject.self,
        RSDSingleColorThemeElementObject.self,
        RSDConditionalStepNavigatorObject.self,
        RSDTaskGroupObject.self,
        ChoiceQuestionStepObject.self,
        MultipleInputQuestionStepObject.self,
        SimpleQuestionStepObject.self,
        StringChoiceQuestionStepObject.self,
        DoubleTextInputItemObject.self,
        IntegerTextInputItemObject.self,
        StringTextInputItemObject.self,
        YearTextInputItemObject.self,
        DateTimeInputItemObject.self,
        DateInputItemObject.self,
        TimeInputItemObject.self,
        StringChoicePickerInputItemObject.self,
        ChoicePickerInputItemObject.self,
        CheckboxInputItemObject.self,
        HeightInputItemBuilderObject.self,
        WeightInputItemBuilderObject.self,
        ]
}
