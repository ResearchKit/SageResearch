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
        
        let selectionStep = medTracker.selectionStep
        XCTAssertEqual(selectionStep.items.count, items.count)
        XCTAssertEqual(selectionStep.sections?.count ?? 0, sections.count)
        XCTAssertEqual(selectionStep.title, "What medications are you taking?")
        XCTAssertEqual(selectionStep.detail, "Select all that apply")
        
        let reviewStep = medTracker.reviewStep
        XCTAssertEqual(reviewStep.items.count, items.count)
        XCTAssertEqual(reviewStep.sections?.count ?? 0, sections.count)
        if let step = reviewStep as? RSDTrackedItemsReviewStepObject {
            XCTAssertEqual(reviewStep.title, step.addDetailsTitle)
            XCTAssertEqual(reviewStep.detail, step.addDetailsSubtitle)
            XCTAssertEqual(step.addDetailsTitle, "Add medication details")
            XCTAssertEqual(step.addDetailsSubtitle, "Select to add your medication dosing information and schedule(s).")
            XCTAssertEqual(step.reviewTitle, "Review medications")
            if let action = step.actions?[.navigation(.addMore)] {
                XCTAssertEqual(action.buttonTitle, "＋ Add medications")
            } else {
                XCTFail("Step action does not include `.addMore`")
            }
            if let action = step.actions?[.navigation(.goForward)] {
                XCTAssertEqual(action.buttonTitle, "Submit")
            } else {
                XCTFail("Step action does not include `.goForward`")
            }
        } else {
            XCTFail("\(reviewStep) not of expected type.")
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
            XCTAssertEqual(dosage.placeholder, "i.e.: 10/100 mg")
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
        
        guard let selectionStep = firstStep as? RSDTrackedSelectionStep else {
            XCTFail("Failed to create the selection step. Exiting.")
            return
        }
        
        XCTAssertNil(medTracker.step(before: selectionStep, with: &taskResult))
        XCTAssertEqual(medTracker.step(with: selectionStep.identifier)?.identifier, selectionStep.identifier)
        XCTAssertFalse(medTracker.hasStep(before: selectionStep, with: taskResult))
        XCTAssertTrue(medTracker.hasStep(after: selectionStep, with: taskResult))

        guard let firstResult = selectionStep.instantiateStepResult() as? RSDSelectionResultObject else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        var selectionResult = firstResult
        selectionResult.selectedIdentifiers = ["medA2", "medB4"]
        taskResult.appendStepHistory(with: selectionResult)
        
        // Next step after selection is review.
        let secondStep = medTracker.step(after: firstStep, with: &taskResult)
        XCTAssertNotNil(secondStep)
        
        // Check that the med tracker can navigate to any step by identifier
        XCTAssertEqual(medTracker.step(with: "medA2")?.identifier, "medA2")
        XCTAssertEqual(medTracker.step(with: "medB4")?.identifier, "medB4")
        XCTAssertNil(medTracker.step(with: "medA1"))
        
        guard let initialReviewStep = secondStep as? RSDTrackedItemsReviewStep else {
            XCTFail("Failed to create the initial review step. Exiting.")
            return
        }
    
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
        
        guard let thirdResult = medA2DetailsStep.instantiateStepResult() as? RSDCollectionResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        
        let timeFormatter = RSDDateCoderObject.hourAndMinutesOnly.inputFormatter
        
        var collectionResultA2 = thirdResult
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

        taskResult.appendStepHistory(with: collectionResultA2)
        
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
        
        guard let fourthResult = medB4DetailsStep.instantiateStepResult() as? RSDCollectionResult else {
            XCTFail("Failed to create the expected result. Exiting.")
            return
        }
        
        var collectionResultB4 = fourthResult
        var dosageB4 = RSDAnswerResultObject(identifier: "dosage", answerType: .string)
        dosageB4.value = "1/20 mg"
        collectionResultB4.appendInputResults(with: dosageB4)
        var timeB4_0 = RSDAnswerResultObject(identifier: "timeOfDay.0", answerType: RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "HH:mm"))
        timeB4_0.value = timeFormatter.date(from: "07:30")
        collectionResultB4.appendInputResults(with: timeB4_0)
        var daysB4_0 = RSDAnswerResultObject(identifier: "daysOfWeek.0", answerType: RSDAnswerResultType(baseType: .integer, sequenceType: .array))
        daysB4_0.value = Array(1...7)
        collectionResultB4.appendInputResults(with: daysB4_0)
        
        taskResult.appendStepHistory(with: collectionResultB4)
        
        // Next step after selection is review.
        let fifthStep = medTracker.step(after: fourthStep, with: &taskResult)
        XCTAssertNotNil(fifthStep)
        
        guard let finalReviewStep = fifthStep as? RSDTrackedItemsReviewStep else {
            XCTFail("Failed to return the final review step. Exiting. \(String(describing: fifthStep))")
            return
        }
        
        XCTAssertNil(medTracker.step(before: finalReviewStep, with: &taskResult))
        XCTAssertEqual(finalReviewStep.identifier, initialReviewStep.identifier)
        XCTAssertFalse(medTracker.hasStep(before: finalReviewStep, with: taskResult))
        XCTAssertFalse(medTracker.hasStep(after: finalReviewStep, with: taskResult))
        
        guard let finalResult = finalReviewStep.instantiateStepResult() as? RSDMedicationTrackingResult else {
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
    
    
    // MARK: Shared tests
    
    func checkDetailStep(_ detailStep: RSDMedicationDetailsStepObject) {
        
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
    
    // Helper methods
    
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
}
