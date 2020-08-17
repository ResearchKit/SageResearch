//
//  RSDDocumentable.swift
//  Research
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
import JsonModel

public struct RSDDocumentCreator {
    
    let allStringEnums: [DocumentableStringEnum.Type] = {
        
        var allEnums: [DocumentableStringEnum.Type] = [
        RSDCohortRuleOperator.self,
        RSDKeyboardType.self,
        RSDMotionRecorderType.self,
        RSDStandardPermissionType.self,
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
        RSDAsyncActionType.self,
        RSDDateCoderObject.self,
        RSDDeviceType.self,
        RSDFormUIHint.self,
        RSDIdentifier.self,
        RSDResultType.self,
        RSDStepType.self,
        ]

    let allCodableObjects: [DocumentableObject.Type] = [
        RSDAnimatedImageThemeElementObject.self,
        RSDCohortNavigationRuleObject.self,
        RSDCollectionResultObject.self,
        RSDDateRangeObject.self,
        RSDDistanceRecorderConfiguration.self,
        RSDFileResultObject.self,
        RSDMotionRecorderConfiguration.self,
        RSDNavigationUIActionObject.self,
        RSDResourceTransformerObject.self,
        RSDResultObject.self,
        RSDTaskInfoStepObject.self,
        RSDTaskResultObject.self,
        RSDUIActionObject.self,
        RSDViewThemeElementObject.self,
        RSDWebViewUIActionObject.self,
        RSDVideoViewUIActionObject.self,
        RSDWeeklyScheduleObject.self,
        ]
    
    let allDecodableObjects: [DocumentableObject.Type] = [
        AssessmentTaskObject.self,
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
