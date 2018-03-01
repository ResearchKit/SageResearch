//
//  MedicationTrackingTests.swift
//  ResearchSuite
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

import XCTest
@testable import ResearchSuite

class MedicationTrackingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBuildInitialSteps() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))

        let (items, sections) = buildMedicationItems()
        let medTracker = RSDMedicationTrackingStepNavigator(items: items, sections: sections)
        XCTAssertEqual(medTracker.items.count, items.count)
        XCTAssertEqual(medTracker.sections?.count ?? 0, sections.count)
        
        let selectionStep = medTracker.selectionStep as! RSDTrackedSelectionStepObject
        XCTAssertEqual(selectionStep.items.count, items.count)
        XCTAssertEqual(selectionStep.sections?.count ?? 0, sections.count)
        XCTAssertEqual(selectionStep.title, "What medications are you taking?")
        XCTAssertEqual(selectionStep.detail, "Select all that apply")
        
        guard let reviewStep = medTracker.reviewStep as? RSDTrackedItemsReviewStepObject else {
            XCTFail("Failed to build review step. Exiting.")
            return
        }
        XCTAssertEqual(reviewStep.items.count, items.count)
        XCTAssertEqual(reviewStep.sections?.count ?? 0, sections.count)
        XCTAssertEqual(reviewStep.title, reviewStep.addDetailsTitle)
        XCTAssertEqual(reviewStep.detail, reviewStep.addDetailsSubtitle)
        XCTAssertEqual(reviewStep.addDetailsTitle, "Add medication details")
        XCTAssertEqual(reviewStep.addDetailsSubtitle, "Select to add your medication dosing information and schedule(s).")
        XCTAssertEqual(reviewStep.reviewTitle, "Review medications")
        if let action = reviewStep.actions?[.navigation(.addMore)] {
            XCTAssertEqual(action.buttonTitle, "＋ Add medications")
        } else {
            XCTFail("Step action does not include `.addMore`")
        }
        
        XCTAssertEqual(medTracker.detailStepTemplates?.count ?? 0, 1)
        guard let detailStep = medTracker.detailStepTemplates?.first as? RSDMedicationDetailsStepObject else {
            XCTFail("Failed to build the detail step. \(String(describing: medTracker.detailStepTemplates)) ")
            return
        }
        
        XCTAssertEqual(detailStep.inputFields.count, 1)
        if let dosage = detailStep.inputFields.first {
            XCTAssertEqual(dosage.identifier, "dosage")
            XCTAssertEqual(dosage.inputPrompt, "Dosage")
            XCTAssertEqual(dosage.placeholder, "e.g. 10/100 mg")
            XCTAssertEqual(dosage.dataType, .base(.string))
            XCTAssertEqual(dosage.inputUIHint, .textfield)
        } else {
            XCTFail("\(detailStep.inputFields) is empty")
        }
        
        // Check defaults for the schedule time template
        let scheduleTime = detailStep.scheduleTimeTemplate
        XCTAssertEqual(scheduleTime.identifier, "timeOfDay")
        XCTAssertEqual(scheduleTime.inputPrompt, "Schedule")
        checkScheduleTime(scheduleTime, "testBuildInitialSteps")
        
        // Check defaults for the days of the week template
        let scheduleDays = detailStep.scheduleDaysTemplate
        XCTAssertEqual(scheduleDays.identifier, "daysOfWeek")
        XCTAssertEqual(scheduleDays.inputPrompt, "When do you take it at this time?")
        checkScheduleDays(scheduleDays, "testBuildInitialSteps")
        if let _ = scheduleDays as? RSDPopoverInputFieldObject {
        } else {
            XCTFail("\(String(describing: scheduleDays)) not expected type.")
        }
    }
    
    func testMedicationTrackingNavigation_FirstRun() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let (items, sections) = buildMedicationItems()
        let medTracker = RSDMedicationTrackingStepNavigator(items: items, sections: sections)
    
        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: "medication")
        
        let firstStep = medTracker.step(after: nil, with: &taskResult)
        XCTAssertNotNil(firstStep)
        
        guard let selectionStep = firstStep as? RSDTrackedSelectionStepObject else {
            XCTFail("Failed to create the selection step. Exiting.")
            return
        }
        
        XCTAssertNil(medTracker.step(before: selectionStep, with: &taskResult))
        XCTAssertEqual(medTracker.step(with: selectionStep.identifier)?.identifier, selectionStep.identifier)
        XCTAssertFalse(medTracker.hasStep(before: selectionStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: selectionStep, with: taskResult))

        guard let firstResult = selectionStep.instantiateStepResult() as? RSDTrackedItemsResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        var selectionResult = firstResult
        selectionResult.updateSelected(to: ["medA2", "medB4"], with: selectionStep.items)
        taskResult.appendStepHistory(with: selectionResult)
        
        // Next step after selection is review.
        let secondStep = medTracker.step(after: firstStep, with: &taskResult)
        XCTAssertNotNil(secondStep)
        
        // Check that the med tracker can navigate to any step by identifier
        XCTAssertEqual(medTracker.step(with: "medA2")?.identifier, "medA2")
        XCTAssertEqual(medTracker.step(with: "medB4")?.identifier, "medB4")
        XCTAssertNil(medTracker.step(with: "medA1"))
        
        guard let initialReviewStep = secondStep as? RSDTrackedItemsReviewStepObject else {
            XCTFail("Failed to create the initial review step. Exiting.")
            return
        }
        
        // The review should use the default title for forward navigation if the answers are not complete.
        XCTAssertNil(initialReviewStep.action(for: .navigation(.goForward), on: initialReviewStep))
    
        XCTAssertNil(medTracker.step(before: initialReviewStep, with: &taskResult))
        XCTAssertEqual(medTracker.step(with: initialReviewStep.identifier)?.identifier, initialReviewStep.identifier)
        XCTAssertFalse(medTracker.hasStep(before: initialReviewStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: initialReviewStep, with: taskResult))
        
        guard let secondResult = initialReviewStep.instantiateStepResult() as? RSDMedicationTrackingResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        XCTAssertEqual(secondResult.selectedAnswers.count, 2)
        XCTAssertFalse(secondResult.hasRequiredValues)
        
        taskResult.appendStepHistory(with: secondResult)
        
        let thirdStep = medTracker.step(after: secondStep, with: &taskResult)
        XCTAssertNotNil(thirdStep)
        XCTAssertEqual(thirdStep?.identifier, "medA2")
        
        guard let medA2DetailsStep = thirdStep as? RSDMedicationDetailsStepObject else {
            XCTFail("Failed to create the expected step. Exiting.")
            return
        }
        
        XCTAssertEqual(medTracker.step(before: medA2DetailsStep, with: &taskResult)?.identifier, "review")
        XCTAssertTrue(medTracker.hasStep(before: medA2DetailsStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: medA2DetailsStep, with: taskResult))
        XCTAssertTrue(medA2DetailsStep.instantiateStepResult() is RSDCollectionResult)

        taskResult.appendStepHistory(with: medA2Result())
        
        let fourthStep = medTracker.step(after: thirdStep, with: &taskResult)
        XCTAssertNotNil(fourthStep)
        XCTAssertEqual(fourthStep?.identifier, "medB4")
        
        guard let medB4DetailsStep = fourthStep as? RSDMedicationDetailsStepObject else {
            XCTFail("Failed to create the expected step. Exiting.")
            return
        }
        
        XCTAssertEqual(medTracker.step(before: medB4DetailsStep, with: &taskResult)?.identifier, "review")
        XCTAssertTrue(medTracker.hasStep(before: medB4DetailsStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: medB4DetailsStep, with: taskResult))
        XCTAssertTrue(medB4DetailsStep.instantiateStepResult() is RSDCollectionResult)

        taskResult.appendStepHistory(with: medB4Result())
        
        // Next step after selection is review.
        let fifthStep = medTracker.step(after: fourthStep, with: &taskResult)
        XCTAssertNotNil(fifthStep)
        
        guard let finalReviewStep = fifthStep as? RSDTrackedItemsReviewStepObject else {
            XCTFail("Failed to return the final review step. Exiting. \(String(describing: fifthStep))")
            return
        }
        
        XCTAssertNil(medTracker.step(before: finalReviewStep, with: &taskResult))
        XCTAssertEqual(finalReviewStep.identifier, initialReviewStep.identifier)
        XCTAssertFalse(medTracker.hasStep(before: finalReviewStep, with: taskResult))
        XCTAssertFalse(medTracker.hasStep(after: finalReviewStep, with: taskResult))
        
        checkFinalReviewStep(finalReviewStep)
    }
    
    func testMedicationTrackingNavigation_FirstRun_CustomOrder() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let (items, sections) = buildMedicationItems()
        let medTracker = RSDMedicationTrackingStepNavigator(items: items, sections: sections)
        
        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: "medication")
        
        guard let selectionStep = medTracker.step(after: nil, with: &taskResult) as? RSDTrackedSelectionStepObject else {
            XCTFail("Failed to create the selection step. Exiting.")
            return
        }
        
        guard let firstResult = selectionStep.instantiateStepResult() as? RSDTrackedItemsResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        var selectionResult = firstResult
        selectionResult.updateSelected(to: ["medA2", "medB4"], with: selectionStep.items)
        taskResult.appendStepHistory(with: selectionResult)
        
        guard let initialReviewStep = medTracker.step(after: selectionStep, with: &taskResult) as? RSDTrackedItemsReviewStepObject else {
            XCTFail("Failed to create the initial review step. Exiting.")
            return
        }
        guard let secondResult = initialReviewStep.instantiateStepResult() as? RSDMedicationTrackingResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        
        taskResult.appendStepHistory(with: secondResult)
        
        // Set up the review step with a custom order by setting the next step identifier
        initialReviewStep.nextStepIdentifier = "medB4"
        
        let thirdStep = medTracker.step(after: initialReviewStep, with: &taskResult)

        XCTAssertNotNil(thirdStep)
        XCTAssertEqual(thirdStep?.identifier, "medB4")
        
        guard let medB4DetailsStep = thirdStep as? RSDMedicationDetailsStepObject else {
            XCTFail("Failed to create the expected step. Exiting.")
            return
        }
        
        XCTAssertTrue(medB4DetailsStep.instantiateStepResult() is RSDCollectionResult)
        
        taskResult.appendStepHistory(with: medB4Result())
        
        let fourthStep = medTracker.step(after: thirdStep, with: &taskResult)
        XCTAssertNotNil(fourthStep)
        XCTAssertEqual(fourthStep?.identifier, "medA2")
        
        guard let medA2DetailsStep = fourthStep as? RSDMedicationDetailsStepObject else {
            XCTFail("Failed to create the expected step. Exiting.")
            return
        }
        
        XCTAssertEqual(medTracker.step(before: medA2DetailsStep, with: &taskResult)?.identifier, "review")
        XCTAssertTrue(medTracker.hasStep(before: medA2DetailsStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: medA2DetailsStep, with: taskResult))
        XCTAssertTrue(medA2DetailsStep.instantiateStepResult() is RSDCollectionResult)

        taskResult.appendStepHistory(with: medA2Result())
        
        // Next step after selection is review.
        let fifthStep = medTracker.step(after: fourthStep, with: &taskResult)
        XCTAssertNotNil(fifthStep)
        
        guard let finalReviewStep = fifthStep as? RSDTrackedItemsReviewStepObject else {
            XCTFail("Failed to return the final review step. Exiting. \(String(describing: fifthStep))")
            return
        }
        
        XCTAssertNil(medTracker.step(before: finalReviewStep, with: &taskResult))
        XCTAssertEqual(finalReviewStep.identifier, "review")
        XCTAssertFalse(medTracker.hasStep(before: finalReviewStep, with: taskResult))
        XCTAssertFalse(medTracker.hasStep(after: finalReviewStep, with: taskResult))
        
        checkFinalReviewStep(finalReviewStep)
    }
    
    func testMedicationTrackingNavigation_FollowupRun() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let (items, sections) = buildMedicationItems()
        let medTracker = RSDMedicationTrackingStepNavigator(items: items, sections: sections)
        
        var initialResult = RSDMedicationTrackingResult(identifier: medTracker.reviewStep!.identifier)
        var medA3 = RSDMedicationAnswer(identifier: "medA3")
        medA3.dosage = "1"
        medA3.scheduleItems = [RSDWeeklyScheduleObject(timeOfDayString: "08:00", daysOfWeek: [.monday, .wednesday, .friday])]
        var medC3 = RSDMedicationAnswer(identifier: "medC3")
        medC3.dosage = "1"
        medC3.scheduleItems = [RSDWeeklyScheduleObject(timeOfDayString: "20:00", daysOfWeek: [.sunday, .thursday])]
        initialResult.medications = [medA3, medC3]
        medTracker.previousResult = initialResult

        var taskResult: RSDTaskResult = RSDTaskResultObject(identifier: "logMedications")
        
        // Check initial state
        XCTAssertNotNil(medTracker.getSelectionStep())
        XCTAssertNotNil(medTracker.getReviewStep())
        
        if let detailsStep = medTracker.step(with: "medA3") as? RSDTrackedItemDetailsStepObject {
            XCTAssertNotNil(detailsStep.trackedItem)
            XCTAssertNotNil(detailsStep.previousAnswer)
            XCTAssertEqual(detailsStep.previousAnswer?.hasRequiredValues, true)
        } else {
            XCTFail("Step not found or not of expected type.")
        }
        if let detailsStep = medTracker.step(with: "medC3") as? RSDTrackedItemDetailsStepObject {
            XCTAssertNotNil(detailsStep.trackedItem)
            XCTAssertNotNil(detailsStep.previousAnswer)
            XCTAssertEqual(detailsStep.previousAnswer?.hasRequiredValues, true)
        } else {
            XCTFail("Step not found or not of expected type.")
        }

        // For the case where the meds have been set, this should jump to logging the medication results.
        let firstStep = medTracker.step(after: nil, with: &taskResult)
        
        guard let loggingStep = firstStep as? RSDMedicationLoggingStepObject else {
            XCTFail("First step not of expected type. For a follow-up run should start with logging step.")
            return
        }
        
        XCTAssertEqual(loggingStep.result?.selectedAnswers.count, 2)
        XCTAssertFalse(medTracker.hasStep(after: loggingStep, with: taskResult))
        XCTAssertFalse(medTracker.hasStep(before: loggingStep, with: taskResult))
        XCTAssertNil(medTracker.step(before: loggingStep, with: &taskResult))
        XCTAssertNil(medTracker.step(after: loggingStep, with: &taskResult))
    }
    
    // MARK: Shared tests
    
    func checkFinalReviewStep(_ finalReviewStep: RSDTrackedItemsReviewStepObject) {
        
        // The review should use the "Submit" title for forward navigation if the answers are not complete.
        if let action = finalReviewStep.action(for: .navigation(.goForward), on: finalReviewStep) {
            XCTAssertEqual(action.buttonTitle, "Submit")
        } else {
            XCTFail("Step action does not include `.goForward`")
        }
        
        guard let finalResult = finalReviewStep.result as? RSDMedicationTrackingResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        XCTAssertEqual(finalResult.selectedAnswers.count, 2)
        XCTAssertTrue(finalResult.hasRequiredValues)
        
        // Inspect the final result for expected values.
        guard let answerA2 = finalResult.selectedAnswers.first as? RSDMedicationAnswer,
            let answerB4 = finalResult.selectedAnswers.last as? RSDMedicationAnswer,
            answerA2.identifier != answerB4.identifier else {
                XCTFail("Failed to create the expected result. Exiting.")
                return
        }
        
        XCTAssertEqual(answerA2.identifier, "medA2")
        XCTAssertEqual(answerA2.dosage, "5 ml")
        XCTAssertEqual(answerA2.scheduleItems?.count, 2)
        if let sortedItems = answerA2.scheduleItems?.sorted() {
            XCTAssertEqual(sortedItems.first?.timeOfDayString, "08:30")
            XCTAssertEqual(sortedItems.first?.daysOfWeek, [.monday, .wednesday, .friday])
            XCTAssertEqual(sortedItems.last?.timeOfDayString, "20:00")
            XCTAssertEqual(sortedItems.last?.daysOfWeek, [.sunday])
        }
        
        XCTAssertEqual(answerB4.identifier, "medB4")
        XCTAssertEqual(answerB4.dosage, "1/20 mg")
        XCTAssertEqual(answerB4.scheduleItems?.count, 1)
        if let sortedItems = answerB4.scheduleItems?.sorted() {
            XCTAssertEqual(sortedItems.first?.timeOfDayString, "07:30")
            XCTAssertEqual(sortedItems.first?.daysOfWeek, RSDWeekday.all)
        }
    }
    
    // Check functions that should remain the same for all instances.
    func checkScheduleTime(_ scheduleTime: RSDInputField, _ debug: String) {
        XCTAssertEqual(scheduleTime.dataType, .base(.date), debug)
        XCTAssertEqual(scheduleTime.inputUIHint, .picker, debug)
        if let range = scheduleTime.range as? RSDDateRange {
            XCTAssertNotNil(range.defaultDate, debug)
            if let dateCoder = range.dateCoder as? RSDDateCoderObject {
                XCTAssertEqual(dateCoder.rawValue, "HH:mm", debug)
            } else {
                XCTFail("\(String(describing:range.dateCoder)) not expected type. \(debug)")
            }
        } else {
            XCTFail("\(String(describing: scheduleTime.range)) not expected type. \(debug)")
        }
        if let formatter = scheduleTime.formatter as? DateFormatter {
            XCTAssertEqual(formatter.dateStyle, .none, debug)
            XCTAssertEqual(formatter.timeStyle, .short, debug)
        } else {
            XCTFail("\(String(describing: scheduleTime.formatter)) not expected type. \(debug)")
        }
        XCTAssertNil(scheduleTime.textFieldOptions, debug)
    }
    
    func checkScheduleDays(_ scheduleDays: RSDInputField, _ debug: String) {
        XCTAssertEqual(scheduleDays.dataType, .collection(.multipleChoice, .integer), debug)
        XCTAssertEqual(scheduleDays.inputUIHint, .popover, debug)
        XCTAssertNil(scheduleDays.range, debug)
        XCTAssertNil(scheduleDays.textFieldOptions, debug)
        XCTAssertNotNil(scheduleDays.formatter as? RSDWeeklyScheduleFormatter,
                        "\(String(describing: scheduleDays.formatter)) not expected type. \(debug)")
        do {
            try scheduleDays.validate()
        } catch let err {
            XCTFail("Failed to validate the input field. \(err)")
        }
        if let popover = scheduleDays as? RSDPopoverInputFieldObject,
            let choiceField = popover.inputFields.first as? RSDChoiceInputFieldObject {
            XCTAssertEqual(choiceField.choices.count, 7, debug)
        } else {
            XCTFail("\(String(describing: scheduleDays)) not expected type. \(debug)")
        }
    }
}

// Helper methods

func medB4Result() -> RSDCollectionResult {
    let timeFormatter = RSDDateCoderObject.hourAndMinutesOnly.inputFormatter
    
    var collectionResultB4 = RSDCollectionResultObject(identifier: "medB4")
    var dosageB4 = RSDAnswerResultObject(identifier: "dosage", answerType: .string)
    dosageB4.value = "1/20 mg"
    collectionResultB4.appendInputResults(with: dosageB4)
    var timeB4_0 = RSDAnswerResultObject(identifier: "timeOfDay.0", answerType: RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "HH:mm"))
    timeB4_0.value = timeFormatter.date(from: "07:30")
    collectionResultB4.appendInputResults(with: timeB4_0)
    var daysB4_0 = RSDAnswerResultObject(identifier: "daysOfWeek.0", answerType: RSDAnswerResultType(baseType: .integer, sequenceType: .array))
    daysB4_0.value = Array(1...7)
    collectionResultB4.appendInputResults(with: daysB4_0)
    
    return collectionResultB4
}

func medA2Result() -> RSDCollectionResult {
    let timeFormatter = RSDDateCoderObject.hourAndMinutesOnly.inputFormatter
    
    var collectionResultA2 = RSDCollectionResultObject(identifier: "medA2")
    var dosageA2 = RSDAnswerResultObject(identifier: "dosage", answerType: .string)
    dosageA2.value = "5 ml"
    collectionResultA2.appendInputResults(with: dosageA2)
    var timeA2_0 = RSDAnswerResultObject(identifier: "timeOfDay.0", answerType: RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "HH:mm"))
    timeA2_0.value = timeFormatter.date(from: "08:30")
    collectionResultA2.appendInputResults(with: timeA2_0)
    var daysA2_0 = RSDAnswerResultObject(identifier: "daysOfWeek.0", answerType: RSDAnswerResultType(baseType: .integer, sequenceType: .array))
    daysA2_0.value = [2, 4, 6]
    collectionResultA2.appendInputResults(with: daysA2_0)
    var timeA2_1 = RSDAnswerResultObject(identifier: "timeOfDay.1", answerType: RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "HH:mm"))
    timeA2_1.value = timeFormatter.date(from: "20:00")
    collectionResultA2.appendInputResults(with: timeA2_1)
    var daysA2_1 = RSDAnswerResultObject(identifier: "daysOfWeek.1", answerType: RSDAnswerResultType(baseType: .integer, sequenceType: .array))
    daysA2_1.value = [1]
    collectionResultA2.appendInputResults(with: daysA2_1)
    
    return collectionResultA2
}

func buildMedicationItems() -> (items: [RSDMedicationItem], sections: [RSDTrackedSection]) {
    let items = [   RSDMedicationItem(identifier: "medA1", sectionIdentifier: "section1"),
                    RSDMedicationItem(identifier: "medA2", sectionIdentifier: "section2"),
                    RSDMedicationItem(identifier: "medA3", sectionIdentifier: "section3"),
                    RSDMedicationItem(identifier: "medA4", sectionIdentifier: "section4"),
                    RSDMedicationItem(identifier: "medB1", sectionIdentifier: "section1"),
                    RSDMedicationItem(identifier: "medB2", sectionIdentifier: "section2"),
                    RSDMedicationItem(identifier: "medB3", sectionIdentifier: "section3"),
                    RSDMedicationItem(identifier: "medB4", sectionIdentifier: "section4"),
                    RSDMedicationItem(identifier: "medC1", sectionIdentifier: "section1"),
                    RSDMedicationItem(identifier: "medC2", sectionIdentifier: "section2"),
                    RSDMedicationItem(identifier: "medC3", sectionIdentifier: "section3"),
                    RSDMedicationItem(identifier: "medC4", sectionIdentifier: "section4"),
                    RSDMedicationItem(identifier: "medNoSection1", sectionIdentifier: nil),
                    RSDMedicationItem(identifier: "medNoSection2", sectionIdentifier: nil),
                    RSDMedicationItem(identifier: "medNoSection3", sectionIdentifier: nil),
                    RSDMedicationItem(identifier: "medFooSection1", sectionIdentifier: "Foo"),
                    RSDMedicationItem(identifier: "medFooSection2", sectionIdentifier: "Foo"),
                    ]
    
    let sections = [    RSDTrackedSectionObject(identifier: "section1"),
                        RSDTrackedSectionObject(identifier: "section2"),
                        RSDTrackedSectionObject(identifier: "section3"),
                        RSDTrackedSectionObject(identifier: "section4"),
                        ]
    
    return (items, sections)
}
