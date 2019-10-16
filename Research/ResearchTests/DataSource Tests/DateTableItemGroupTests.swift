//
//  DateTableItemGroupTests.swift
//  ResearchTests_iOS
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

import XCTest
@testable import Research

class DateTableItemGroupTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetPreviousAnswer_TimeOnly() {
        NSLocale.setCurrentTest(Locale(identifier: "en_US"))
        
        let json = """
        {
        "identifier": "reminderTime",
        "type": "date",
        "prompt": "Set reminder",
        "range" : {
           "defaultDate" : "09:00",
           "minuteInterval" : 15,
           "codingFormat" : "HH:mm" }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            let inputField = try decoder.decode(RSDInputFieldObject.self, from: json)
            let itemGroup = RSDDateTableItemGroup(beginningRowIndex: 0, inputField: inputField, uiHint: .picker)
            
            // Previous answer is encoded using the default "time-only" formatter for the given app.
            // This is based on using a date coding where the input formatter and the result
            // formatter are different.
            let previousAnswer = "08:30:00"
            try itemGroup.setPreviousAnswer(from: previousAnswer)
            
            XCTAssertNotNil(itemGroup.answer)
            guard let dateAnswer = itemGroup.answer as? Date else {
                XCTFail("Failed to set the previous answer to the expected type. \(String(describing: itemGroup.answer))")
                return
            }
            
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute], from: dateAnswer)
            XCTAssertEqual(dateComponents.hour, 8)
            XCTAssertEqual(dateComponents.minute, 30)

        } catch let err {
            XCTFail("Failed to decode object or set previous answer: \(err)")
            return
        }
    }
}
