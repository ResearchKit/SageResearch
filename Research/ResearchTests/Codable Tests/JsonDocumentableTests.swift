//
//  JsonDocumentableTests.swift
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
import JsonModel

class JsonDocumentableTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateJsonSchemaDocumentation() {
        let factory = RSDFactory()
        let baseUrl = URL(string: "http://sagebionetworks.org/SageResearch/jsonSchema/")!
        
        let doc = JsonDocumentBuilder(baseUrl: baseUrl,
                                      factory: factory,
                                      rootDocuments: [AssessmentTaskObject.self, RSDTaskResultObject.self])
        
        do {
            let _ = try doc.buildSchemas()  
        }
        catch let err {
            XCTFail("Failed to build the JsonSchema: \(err)")
        }
    }
    
    func testSerializers() {
        let factory = RSDFactory()
        
        XCTAssertTrue(checkPolymorphicExamples(for: factory.answerTypeSerializer.examples,
                                                using: factory, protocolType: AnswerType.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.asyncActionSerializer.examples,
                                                using: factory, protocolType: RSDAsyncActionConfiguration.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.buttonActionSerializer.examples,
                                                using: factory, protocolType: RSDUIAction.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.colorMappingSerializer.examples,
                                                using: factory, protocolType: RSDColorMappingThemeElement.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.imageThemeSerializer.examples,
                                                using: factory, protocolType: RSDImageThemeElement.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.inputItemSerializer.examples,
                                                using: factory, protocolType: InputItemBuilder.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.resultSerializer.examples,
                                                using: factory, protocolType: RSDResult.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.resultNodeSerializer.examples,
                                                using: factory, protocolType: ResultNode.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.stepSerializer.examples,
                                                using: factory, protocolType: RSDStep.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.taskSerializer.examples,
                                                using: factory, protocolType: RSDTask.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.viewThemeSerializer.examples,
                                                using: factory, protocolType: RSDViewThemeElement.self))
    }
    
    func checkPolymorphicExamples<ProtocolType>(for objects: [ProtocolType], using factory: RSDFactory, protocolType: ProtocolType.Type) -> Bool {
        var success = true
        objects.forEach {
            guard let original = $0 as? DocumentableObject else {
                XCTFail("Object does not conform to DocumentableObject. \($0)")
                success = false
                return
            }
            // Cannot test decoding an `RSDStepTransformerObject` using this check b/c it doesn't
            // return itself as the type.
            guard !(original is RSDStepTransformerObject) else { return }

            do {
                let decoder = factory.createJSONDecoder()
                let examples = try type(of: original).jsonExamples()
                examples.forEach { example in
                    do {
                        // Check that the example can be decoded without errors.
                        let wrapper = example.jsonObject()
                        let encodedObject = try JSONSerialization.data(withJSONObject: wrapper, options: [])
                        let decodingWrapper = try decoder.decode(_DecodablePolymorphicWrapper.self, from: encodedObject)
                        let decodedObject = try factory.decodePolymorphicObject(protocolType, from: decodingWrapper.decoder)
                        
                        // Check that the decoded object is the same Type as the original.
                        let originalType = type(of: original as Any)
                        let decodedType = type(of: decodedObject as Any)
                        let isSameType = (originalType == decodedType)
                        XCTAssertTrue(isSameType, "\(decodedType) is not equal to \(originalType)")
                        success = success && isSameType
                        
                        // Check that the decoded type name is the same as the original type name
                        guard let decodedTypeName = (decodedObject as? PolymorphicRepresentable)?.typeName
                            else {
                                XCTFail("Decoded object does not conform to PolymorphicRepresentable. \(decodedObject)")
                                return
                        }
                        guard let originalTypeName = (original as? PolymorphicRepresentable)?.typeName
                            else {
                                XCTFail("Example object does not conform to PolymorphicRepresentable. \(original)")
                                return
                        }
                        XCTAssertEqual(originalTypeName, decodedTypeName)
                        success = success && (originalTypeName == decodedTypeName)
                        
                    } catch let err {
                        XCTFail("Failed to decode \(example) for \(protocolType). \(err)")
                        success = false
                    }
                }
            }
            catch let err {
                XCTFail("Failed to decode \(original). \(err)")
                success = false
            }
        }
        return success
    }
    
    fileprivate struct _DecodablePolymorphicWrapper : Decodable {
        let decoder: Decoder
        init(from decoder: Decoder) throws {
            self.decoder = decoder
        }
    }
}
