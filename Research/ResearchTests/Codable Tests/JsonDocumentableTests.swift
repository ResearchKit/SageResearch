//
//  JsonDocumentableTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research
import JsonModel
import ResultModel

class JsonDocumentableTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateJsonSchemaDocumentation() {
        let factory = RSDFactory()
        let doc = JsonDocumentBuilder(factory: factory)
        
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
        XCTAssertTrue(checkPolymorphicExamples(for: factory.buttonActionSerializer.examples,
                                                using: factory, protocolType: RSDUIAction.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.colorMappingSerializer.examples,
                                                using: factory, protocolType: RSDColorMappingThemeElement.self))
        XCTAssertTrue(checkPolymorphicExamples(for: factory.imageThemeSerializer.examples,
                                                using: factory, protocolType: RSDImageThemeElement.self))
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
