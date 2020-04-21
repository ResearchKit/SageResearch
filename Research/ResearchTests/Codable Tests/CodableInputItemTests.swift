//
//  CodableInputItemTests.swift
//  ResearchTests_iOS
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

class CodableInputItemTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecimalTextInputItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "decimal",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "formatOptions" : {
                         "maximumFractionDigits" : 3,
                         "usesGroupingSeparator" : false,
                         "minimumValue" : 0.0,
                         "maximumValue" : 1000.0,
                         "stepInterval" : 10.0,
                         "minInvalidMessage" : "Min is zero",
                         "maxInvalidMessage" : "Max is one thousand",
                         "invalidMessage" : "You must enter an integer between 0 and 1000"
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.decimal, DoubleTextInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<DoubleTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.decimal, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let range = object.formatOptions {
                XCTAssertEqual(0, range.minimumValue)
                XCTAssertEqual(1000, range.maximumValue)
                XCTAssertEqual(10, range.stepInterval)
                XCTAssertEqual(false, range.usesGroupingSeparator)
                XCTAssertEqual(3, range.maximumFractionDigits)
                XCTAssertEqual("Min is zero", range.minInvalidMessage)
                XCTAssertEqual("Max is one thousand", range.maxInvalidMessage)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range.invalidMessage)
            }
            else {
                XCTFail("Failed to decode formatOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("decimal", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let range = dictionary["formatOptions"] as? [String: Any] {
                XCTAssertEqual(0, range["minimumValue"] as? Double)
                XCTAssertEqual(1000, range["maximumValue"] as? Double)
                XCTAssertEqual(10, range["stepInterval"] as? Double)
                XCTAssertEqual(3, range["maximumFractionDigits"] as? Int)
                XCTAssertEqual(false, range["usesGroupingSeparator"] as? Bool)
                XCTAssertEqual("Min is zero", range["minInvalidMessage"] as? String)
                XCTAssertEqual("Max is one thousand", range["maxInvalidMessage"] as? String)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range["invalidMessage"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testDecimalTextInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "decimal"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = DoubleTextInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<DoubleTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("decimal", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testIntegerTextInputItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "integer",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "formatOptions" : {
                         "usesGroupingSeparator" : false,
                         "minimumValue" : 0,
                         "maximumValue" : 1000,
                         "stepInterval" : 10,
                         "minInvalidMessage" : "Min is zero",
                         "maxInvalidMessage" : "Max is one thousand",
                         "invalidMessage" : "You must enter an integer between 0 and 1000"
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.integer, IntegerTextInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<IntegerTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.integer, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let range = object.formatOptions {
                XCTAssertEqual(0, range.minimumValue)
                XCTAssertEqual(1000, range.maximumValue)
                XCTAssertEqual(10, range.stepInterval)
                XCTAssertEqual(false, range.usesGroupingSeparator)
                XCTAssertEqual("Min is zero", range.minInvalidMessage)
                XCTAssertEqual("Max is one thousand", range.maxInvalidMessage)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range.invalidMessage)
            }
            else {
                XCTFail("Failed to decode formatOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("integer", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let range = dictionary["formatOptions"] as? [String: Any] {
                XCTAssertEqual(0, range["minimumValue"] as? Int)
                XCTAssertEqual(1000, range["maximumValue"] as? Int)
                XCTAssertEqual(10, range["stepInterval"] as? Int)
                XCTAssertEqual(false, range["usesGroupingSeparator"] as? Bool)
                XCTAssertEqual("Min is zero", range["minInvalidMessage"] as? String)
                XCTAssertEqual("Max is one thousand", range["maxInvalidMessage"] as? String)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range["invalidMessage"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testIntegerTextInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "integer"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = IntegerTextInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<IntegerTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("integer", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testYearTextInputItemObject_Codable_Birthyear() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "year",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "formatOptions" : {
                    "allowFuture": false,
                    "minimumYear": 1900,
                     "minInvalidMessage" : "Min is zero",
                     "maxInvalidMessage" : "Max is one thousand",
                     "invalidMessage" : "You must enter an integer between 0 and 1000"
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.year, YearTextInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<YearTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.year, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let range = object.formatOptions {
                XCTAssertEqual(1900, range.minimumValue)
                XCTAssertNotNil(range.maximumValue)
                XCTAssertEqual(1, range.stepInterval)
                XCTAssertEqual(false, range.allowFuture)
                XCTAssertEqual("Min is zero", range.minInvalidMessage)
                XCTAssertEqual("Max is one thousand", range.maxInvalidMessage)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range.invalidMessage)
            }
            else {
                XCTFail("Failed to decode formatOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("year", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let range = dictionary["formatOptions"] as? [String: Any] {
                XCTAssertEqual(1900, range["minimumYear"] as? Int)
                XCTAssertEqual(false, range["allowFuture"] as? Bool)
                XCTAssertNil(range["maximumYear"])
                XCTAssertNil(range["allowPast"])
                XCTAssertEqual("Min is zero", range["minInvalidMessage"] as? String)
                XCTAssertEqual("Max is one thousand", range["maxInvalidMessage"] as? String)
                XCTAssertEqual("You must enter an integer between 0 and 1000", range["invalidMessage"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testYearTextInputItemObject_Codable_Future() {
        
        let json = """
            {
             "type": "year",
             "formatOptions" : {
                    "allowPast": false,
                    "maximumYear": 3000
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<YearTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual(.year, object.inputItemType)
            if let range = object.formatOptions {
                XCTAssertEqual(3000, range.maximumValue)
                XCTAssertNotNil(range.minimumValue)
                XCTAssertEqual(false, range.allowPast)
            }
            else {
                XCTFail("Failed to decode formatOptions")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("year", dictionary["type"] as? String)
            
            if let range = dictionary["formatOptions"] as? [String: Any] {
                XCTAssertEqual(3000, range["maximumYear"] as? Int)
                XCTAssertEqual(false, range["allowPast"] as? Bool)
                XCTAssertNil(range["minimumYear"])
                XCTAssertNil(range["allowFuture"])
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testYearTextInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "year"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = YearTextInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<YearTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("year", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testStringTextInputItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "string",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "keyboardOptions" : {
                         "autocapitalizationType" : "words",
                         "keyboardType" : "asciiCapable",
                         "isSecureTextEntry" : true },
             "regExValidator" : {
                         "pattern" : "[A:D]",
                         "invalidMessage" : "Only ABCD are valid letters."
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        XCTAssertEqual(.string, StringTextInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<StringTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.string, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let keyboardOptions = object.keyboardOptionsObject {
                XCTAssertEqual(.words, keyboardOptions.autocapitalizationType)
                XCTAssertEqual(.asciiCapable, keyboardOptions.keyboardType)
                XCTAssertTrue(keyboardOptions.isSecureTextEntry)
            }
            else {
                XCTFail("Failed to decode keyboardOptions")
            }
            if let regEx = object.regExValidator {
                XCTAssertEqual("[A:D]", regEx.pattern.pattern)
                XCTAssertEqual("Only ABCD are valid letters.", regEx.invalidMessage)
            }
            else {
                XCTFail("Failed to decode regExValidator")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("string", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let keyboardOptions = dictionary["keyboardOptions"] as? [String: Any] {
                XCTAssertEqual("words", keyboardOptions["autocapitalizationType"] as? String)
                XCTAssertEqual("asciiCapable", keyboardOptions["keyboardType"] as? String)
                XCTAssertEqual(true, keyboardOptions["isSecureTextEntry"] as? Bool)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
            if let regExValidator = dictionary["regExValidator"] as? [String: Any] {
                XCTAssertEqual("[A:D]", regExValidator["pattern"] as? String)
                XCTAssertEqual("Only ABCD are valid letters.", regExValidator["invalidMessage"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testStringTextInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "string"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = StringTextInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<StringTextInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("string", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testDateInputItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "date",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "formatOptions" : {
                         "minimumValue" : "1900-01",
                         "allowFuture" : false,
                         "codingFormat" : "yyyy-MM"
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        // TODO: syoung 04/04/2020 Figure out encoding/decoding for a survey rule for a date.
        
        XCTAssertEqual(.date, DateInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<DateInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.date, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let range = object.formatOptions {
                XCTAssertEqual(range.dateCoder?.inputFormatter.dateFormat, "yyyy-MM")
                XCTAssertNotNil(range.minDate)
                XCTAssertNil(range.maxDate)
                XCTAssertEqual(false, range.shouldAllowFuture)
                XCTAssertNil(range.shouldAllowPast)
            }
            else {
                XCTFail("Failed to decode date range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("date", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let formatOptions = dictionary["formatOptions"] as? [String : Any] {
                XCTAssertEqual("1900-01", formatOptions["minimumValue"] as? String)
                XCTAssertEqual(false, formatOptions["allowFuture"] as? Bool)
                XCTAssertEqual("yyyy-MM", formatOptions["codingFormat"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testDateInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "date"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = DateInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<DateInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("date", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTimeInputItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "time",
             "uiHint": "popover",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "formatOptions" : {
                         "minimumValue" : "08:00",
                         "allowFuture" : false,
                         "codingFormat" : "HH:mm"
             }
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        // TODO: syoung 04/04/2020 Figure out encoding/decoding for a survey rule for a date.
        
        XCTAssertEqual(.time, TimeInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<TimeInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.time, object.inputItemType)
            XCTAssertEqual(.popover, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            if let range = object.formatOptions {
                XCTAssertEqual(range.dateCoder?.inputFormatter.dateFormat, "HH:mm")
                XCTAssertNotNil(range.minDate)
                XCTAssertNil(range.maxDate)
                XCTAssertEqual(false, range.shouldAllowFuture)
                XCTAssertNil(range.shouldAllowPast)
            }
            else {
                XCTFail("Failed to decode date range")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("time", dictionary["type"] as? String)
            XCTAssertEqual("popover", dictionary["uiHint"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
            if let formatOptions = dictionary["formatOptions"] as? [String : Any] {
                XCTAssertEqual("08:00", formatOptions["minimumValue"] as? String)
                XCTAssertEqual(false, formatOptions["allowFuture"] as? Bool)
                XCTAssertEqual("HH:mm", formatOptions["codingFormat"] as? String)
            }
            else {
                XCTFail("Failed to encode formatOptions")
            }
            
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testTimeInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "time"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = TimeInputItemObject()
            let wrapper = try decoder.decode(InputItemWrapper<TimeInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("time", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testChoicePickerItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "choicePicker",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "choices" : [
                {  "value" : 0, "text" : "never"},
                {  "value" : 1, "text" : "sometimes"},
                {  "value" : 2, "text" : "often"},
                {  "value" : 3, "text" : "always"}]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        // TODO: syoung 04/04/2020 Figure out encoding/decoding for a survey rule for a date.
        
        XCTAssertEqual(.choicePicker, ChoicePickerInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<ChoicePickerInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.choicePicker, object.inputItemType)
            XCTAssertEqual(.picker, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            
            XCTAssertTrue(object.answerType is AnswerTypeInteger)
            XCTAssertEqual(object.jsonChoices.count, 4)
            if let choices = object.jsonChoices as? [JsonChoiceObject],
                let last = choices.last {
                XCTAssertEqual(last.matchingValue, .integer(3))
                XCTAssertEqual(last.text, "always")
            }
            else {
                XCTFail("Failed to decode expected choice objects")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("choicePicker", dictionary["type"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testStringChoicePickerItemObject_Codable() {
        
        let json = """
            {
             "identifier": "foo",
             "type": "stringChoicePicker",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "choices" : ["never","sometimes","often","always"]
            }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        // TODO: syoung 04/04/2020 Figure out encoding/decoding for a survey rule for a date.
        
        XCTAssertEqual(.stringChoicePicker, StringChoicePickerInputItemObject.defaultType())
        
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<StringChoicePickerInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual(.stringChoicePicker, object.inputItemType)
            XCTAssertEqual(.picker, object.inputUIHint)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            
            XCTAssertTrue(object.answerType is AnswerTypeString)
            XCTAssertEqual(object.jsonChoices.count, 4)
            if let choices = object.jsonChoices as? [JsonChoiceObject],
                let last = choices.last {
                XCTAssertEqual(last.matchingValue, .string("always"))
                XCTAssertEqual(last.text, "always")
            }
            else {
                XCTFail("Failed to decode expected choice objects")
            }
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("foo", dictionary["identifier"] as? String)
            XCTAssertEqual("stringChoicePicker", dictionary["type"] as? String)
            XCTAssertEqual("Favorite color", dictionary["fieldLabel"] as? String)
            XCTAssertEqual("Blue, no! Red!", dictionary["placeholder"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testHeightInputItemObject_Codable() {
        
        let json = """
            {
             "type": "height",
             "identifier": "foo",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "measurementRange": "infant"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<HeightInputItemBuilderObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(.height, object.inputItemType)
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testHeightInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "height"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = HeightInputItemBuilderObject()
            let wrapper = try decoder.decode(InputItemWrapper<HeightInputItemBuilderObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("height", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testWeightInputItemObject_Codable() {
        
        let json = """
            {
             "type": "weight",
             "identifier": "foo",
             "fieldLabel": "Favorite color",
             "placeholder": "Blue, no! Red!",
             "measurementRange": "infant"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let wrapper = try decoder.decode(InputItemWrapper<WeightInputItemBuilderObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(.weight, object.inputItemType)
            XCTAssertEqual("foo", object.identifier)
            XCTAssertEqual("Favorite color", object.fieldLabel)
            XCTAssertEqual("Blue, no! Red!", object.placeholder)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testWeightInputItemObject_Codable_Default() {
        
        let json = """
            {
             "type": "weight"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = WeightInputItemBuilderObject()
            let wrapper = try decoder.decode(InputItemWrapper<WeightInputItemBuilderObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original.inputItemType, object.inputItemType)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual("weight", dictionary["type"] as? String)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testCheckboxInputItemObject_Codable() {
        let json = """
            {
             "type": "checkbox",
             "identifier": "foo",
             "fieldLabel": "prefer not to answer",
             "detail": "more text"
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = CheckboxInputItemObject(fieldLabel: "prefer not to answer",
                                                   resultIdentifier: "foo",
                                                   detail: "more text")
            let wrapper = try decoder.decode(InputItemWrapper<CheckboxInputItemObject>.self, from: json)
            let object = wrapper.inputItem
            XCTAssertEqual(original, object)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(expectedDictionary, dictionary)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    struct InputItemWrapper<Value : InputItemBuilder> : Decodable {
        let inputItem : Value
        init(from decoder: Decoder) throws {
            let value = try decoder.factory.decodePolymorphicObject(InputItemBuilder.self, from: decoder)
            guard let inputItem = value as? Value else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode \(Value.self)")
                throw DecodingError.typeMismatch(Value.self, context)
            }
            self.inputItem = inputItem
        }
    }
    
    // Special-case the skip checkbox to not use the factory on iOS, but still require the "type"

    func testSkipCheckboxInputItemObject() {
        let json = """
            {
             "type": "skipCheckbox",
             "fieldLabel": "prefer not to answer",
             "value": -1
            }
        """.data(using: .utf8)! // our data in native (JSON) format
                
        do {
            
            let original = SkipCheckboxInputItemObject(fieldLabel: "prefer not to answer", matchingValue: .integer(-1))
            let object = try decoder.decode(SkipCheckboxInputItemObject.self, from: json)
            XCTAssertEqual(original, object)
            
            let jsonData = try encoder.encode(original)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            guard let expectedDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? NSDictionary
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(expectedDictionary, dictionary)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
}
