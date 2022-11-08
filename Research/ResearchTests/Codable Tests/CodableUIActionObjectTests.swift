//
//  CodableUIActionObjectTests.swift
//  ResearchTests_iOS
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
