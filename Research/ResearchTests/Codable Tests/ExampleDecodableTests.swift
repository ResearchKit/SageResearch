//
//  ExampleDecodableTests.swift
//  ResearchTests
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
import JsonModel
@testable import Research

class ExampleDecodableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAllCodableObjects() {
        let documentCreator = RSDDocumentCreator()
        for objectType in documentCreator.allCodableObjects {
            XCTAssertTrue(decodeExamples(for: objectType))
        }
    }
    
    func testAllDecodableObjects() {
        let documentCreator = RSDDocumentCreator()
        for objectType in documentCreator.allDecodableObjects {
            XCTAssertTrue(decodeExamples(for: objectType))
        }
    }
    
    func decodeExamples(for objectType: DocumentableObject.Type) -> Bool {
        do {
            let decoder = RSDFactory.shared.createJSONDecoder()
            let examples = try objectType.jsonExamples()
            for example in examples {
                do {
                    let wrapper = example.jsonObject()
                    let encodedObject = try JSONSerialization.data(withJSONObject: wrapper, options: [])
                    _DecodableObjectWrapper._unboxType = (objectType as! Decodable.Type)
                    let decodedObject = try decoder.decode(_DecodableObjectWrapper.self, from: encodedObject)
                    XCTAssertTrue(type(of: decodedObject.value) == objectType)
                } catch let err {
                    XCTFail("Failed to encode/decode \(example) for \(objectType). \(err)")
                }
            }
            return true
        }
        catch let err {
            XCTFail("Failed to decode \(objectType). \(err)")
            return false
        }
    }
    
    func testAllStringLiterals() {
        let documentCreator = RSDDocumentCreator()
        documentCreator.allStringLiterals.forEach {
            XCTAssertTrue(decodeDocumentableStringLiteral(for: $0), "\($0)")
        }
    }
    func decodeDocumentableStringLiteral(for objectType: DocumentableStringLiteral.Type) -> Bool {
        let encoder = RSDFactory.shared.createJSONEncoder()
        let decoder = RSDFactory.shared.createJSONDecoder()
        
        var success = true
        let examples = objectType.examples()
        do {
            let wrapper = _EncodableWrapper(encodableObject: examples)
            let encodedObject = try encoder.encode(wrapper)
            _DecodableArrayWrapper._unboxType = objectType
            let decodedObject = try decoder.decode(_DecodableArrayWrapper.self, from: encodedObject)
            XCTAssertEqual(decodedObject.items.count, examples.count)
            for (idx, value) in decodedObject.items.enumerated() {
                XCTAssertTrue(type(of: value) == objectType)
                if let obj = value as? DocumentableStringLiteral, idx < examples.count {
                    let expectedValue = examples[idx]
                    XCTAssertEqual(obj.stringValue, expectedValue)
                } else {
                    XCTFail("Failed to decode to expected type for \(value)")
                    success = false
                }
            }
        } catch let err {
            XCTFail("Failed to encode/decode \(examples) for \(objectType). \(err)")
            success = false
        }
        return success
    }
    
    func testAllStringEnums() {
        let documentCreator = RSDDocumentCreator()
        documentCreator.allStringEnums.forEach {
            XCTAssertTrue(decodeDocumentableStringEnum(for: $0), "\($0)")
        }
    }
    func decodeDocumentableStringEnum(for objectType: DocumentableStringEnum.Type) -> Bool {
        let encoder = RSDFactory.shared.createJSONEncoder()
        let decoder = RSDFactory.shared.createJSONDecoder()
        
        var success = true
        let examples = Array(objectType.allValues())
        do {
            let wrapper = _EncodableWrapper(encodableObject: examples)
            let encodedObject = try encoder.encode(wrapper)
            _DecodableArrayWrapper._unboxType = objectType
            let decodedObject = try decoder.decode(_DecodableArrayWrapper.self, from: encodedObject)
            XCTAssertEqual(decodedObject.items.count, examples.count)
            for (idx, value) in decodedObject.items.enumerated() {
                XCTAssertTrue(type(of: value) == objectType)
                if let obj = value as? DocumentableStringEnum, idx < examples.count {
                    let expectedValue = examples[idx]
                    XCTAssertEqual(obj.stringValue, expectedValue)
                } else {
                    XCTFail("Failed to decode to expected type for \(value)")
                    success = false
                }
            }
        } catch let err {
            XCTFail("Failed to encode/decode \(examples) for \(objectType). \(err)")
            success = false
        }
        return success
    }
    
    func testAllOptionSets() {
        let documentCreator = RSDDocumentCreator()
        documentCreator.allOptionSets.forEach {
            XCTAssertTrue(decodeDocumentableOptionSet(for: $0), "\($0)")
        }
    }
    func decodeDocumentableOptionSet(for objectType: DocumentableStringOptionSet.Type) -> Bool {
        let encoder = RSDFactory.shared.createJSONEncoder()
        let decoder = RSDFactory.shared.createJSONDecoder()
        
        var success = true
        for option in objectType.examples() {
            let examples = [option]
            do {
                let wrapper = _EncodableWrapper(encodableObject: examples)
                let encodedObject = try encoder.encode(wrapper)
                _DecodableObjectWrapper._unboxType = objectType
                let decodedObject = try decoder.decode(_DecodableObjectWrapper.self, from: encodedObject)
                XCTAssertTrue(type(of: decodedObject.value) == objectType)
                
            } catch let err {
                XCTFail("Failed to encode/decode \(examples) for \(objectType). \(err)")
                success = false
            }
        }
        return success
    }
    
    func testFactoryExamples() {
        let factory = RSDFactory()
        factory.serializerMap.forEach { (key, serializer) in
            serializer.documentableExamples().forEach { (exampleObject) in
                if let obj = exampleObject as? DocumentableStringLiteral {
                    XCTAssertTrue(decodeDocumentableStringLiteral(for: type(of: obj)), "\(key):\(obj)")
                }
                else if let obj = exampleObject as? DocumentableStringEnum {
                    XCTAssertTrue(decodeDocumentableStringEnum(for: type(of: obj)), "\(key):\(obj)")
                }
                else if let obj = exampleObject as? DocumentableStringOptionSet {
                    XCTAssertTrue(decodeDocumentableOptionSet(for: type(of: obj)), "\(key):\(obj)")
                }
                else if exampleObject is Decodable {
                    guard !(exampleObject is RSDStepTransformerObject) else { return }
                    let obj = exampleObject
                    XCTAssertTrue(decodeExamples(for: type(of: obj)), "\(key):\(obj)")
                }
                else {
                    XCTFail("Failed to find the documentable type for \(key) : \(exampleObject)")
                }
            }
        }
    }
}

fileprivate struct _EncodableWrapper: Encodable {
    let encodableObject: Encodable
    
    func encode(to encoder: Encoder) throws {
        try encodableObject.encode(to: encoder)
    }
}

fileprivate struct _DecodableObjectWrapper : Decodable {
    static var _unboxType: Decodable.Type!
    let value: Any
    
    init(from decoder: Decoder) throws {
        value = try _DecodableObjectWrapper._unboxType.init(from: decoder)
    }
}

fileprivate struct _DecodableArrayWrapper : Decodable {
    static var _unboxType: Decodable.Type!
    let items: [Any]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var items: [Any] = []
        while !container.isAtEnd {
            let nestedDecoder = try container.superDecoder()
            let value = try _DecodableArrayWrapper._unboxType.init(from: nestedDecoder)
            items.append(value)
        }
        self.items = items
    }
}
