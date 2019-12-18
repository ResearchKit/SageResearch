//
//  CodableUIActionObjectTests.swift
//  ResearchTests_iOS
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
@testable import Research

class CodableUIActionObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUIActionObject_WithoutObjectTypes() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "actions": { "goForward": { "type": "default", "buttonTitle" : "Go, Dogs! Go!" },
                         "cancel": { "type": "default", "iconName" : "closeX" },
                         "learnMore": { "type": "webView",
                                        "iconName" : "infoIcon",
                                        "url" : "fooInfo" },
                         "skip": {  "type": "navigation",
                                    "buttonTitle" : "not applicable",
                                    "skipToIdentifier": "boo"},
                         "custom": { "type": "default",
                                     "buttonTitle" : "Custom Action" }
                        }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {

            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            
            let goForwardAction = object.action(for: .navigation(.goForward), on: object)
            XCTAssertNotNil(goForwardAction)
            XCTAssertEqual(goForwardAction?.buttonTitle, "Go, Dogs! Go!")
            
            let cancelAction = object.action(for: .navigation(.cancel), on: object)
            XCTAssertNotNil(cancelAction)
            XCTAssertEqual((cancelAction as? RSDUIActionObject)?.iconName, "closeX")
            
            let learnMoreAction = object.action(for: .navigation(.learnMore), on: object)
            XCTAssertNotNil(learnMoreAction)
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.iconName, "infoIcon")
            XCTAssertEqual((learnMoreAction as? RSDWebViewUIActionObject)?.url, "fooInfo")
            
            let skipAction = object.action(for: .navigation(.skip), on: object)
            XCTAssertNotNil(skipAction)
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.buttonTitle, "not applicable")
            XCTAssertEqual((skipAction as? RSDNavigationUIActionObject)?.skipToIdentifier, "boo")
            
            let customAction = object.action(for: .custom("custom"), on: object)
            XCTAssertNotNil(customAction)
            XCTAssertEqual(customAction?.buttonTitle, "Custom Action")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testUIActionObject_WithObjectTypes() {
        
        let json = """
        {
            "identifier": "foo",
            "type": "instruction",
            "actions": { "defaultA": {   "type": "default",
                                         "buttonTitle" : "Custom Action A" },
                         "navigationC": {   "type": "navigation",
                                            "skipToIdentifier": "toC" },
                         "reminderD": {  "type": "reminder",
                                         "reminderIdentifier": "RemindMe" },
                         "webViewE": {   "type": "webView",
                                         "buttonTitle" : "Custom Action E",
                                         "url": "fooURL" }
                        }
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(RSDUIStepObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            
            let defaultA = object.action(for: .custom("defaultA"), on: object)
            XCTAssertNotNil(defaultA)
            XCTAssertEqual(defaultA?.buttonTitle, "Custom Action A")
            XCTAssertTrue(defaultA is RSDUIActionObject)
            
            let navigationC = object.action(for: .custom("navigationC"), on: object)
            XCTAssertNotNil(navigationC)
            if let navigationAction = navigationC as? RSDNavigationUIAction {
                XCTAssertEqual(navigationAction.skipToIdentifier, "toC")
            } else {
                XCTFail("Failed to decode expected action")
            }
            
            let reminderD = object.action(for: .custom("reminderD"), on: object)
            XCTAssertNotNil(reminderD)
            if let reminderAction = reminderD as? RSDReminderUIAction {
                XCTAssertEqual(reminderAction.reminderIdentifier, "RemindMe")
            } else {
                XCTFail("Failed to decode expected action")
            }
            
            let webViewE = object.action(for: .custom("webViewE"), on: object)
            XCTAssertNotNil(webViewE)
            XCTAssertEqual(webViewE?.buttonTitle, "Custom Action E")
            if let webAction = webViewE as? RSDWebViewUIAction {
                XCTAssertEqual(webAction.url, "fooURL")
            } else {
                XCTFail("Failed to decode expected action")
            }
            
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
