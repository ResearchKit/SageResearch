//
//  JsonSchemaBuilderTests.swift
//  JsonSchemaBuilderTests
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
@testable import JsonSchemaBuilder
import Research
import JsonModel

class JsonSchemaBuilderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJson() {
        let factory = RSDFactory()
        let baseUrl = URL(string: "http://sagebionetworks.org/SageResearch/jsonSchema/")!
        
        let doc = JsonDocumentBuilder(baseUrl: baseUrl,
                                      factory: factory,
                                      rootDocuments: [AssessmentTaskObject.self, RSDTaskResultObject.self])
        
        do {
            let docs = try doc.buildSchemas()
            let encoder = factory.createJSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            
            let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let schemasDirectory = downloadsDirectory.appendingPathComponent("SageResearch/jsonSchema/schemas")
            let examplesDirectory = downloadsDirectory.appendingPathComponent("SageResearch/jsonSchema/examples")

            let fileManager = FileManager.default
            try fileManager.createDirectory(at: schemasDirectory, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: examplesDirectory, withIntermediateDirectories: true, attributes: nil)
            
            try docs.forEach { (doc) in
            
                let json = try encoder.encode(doc)
                
                let filename = "\(doc.id.className).json"
                let url = schemasDirectory.appendingPathComponent(filename)
                try json.write(to: url)
                print(url)
                
                guard let definitions = doc.definitions?.values else {
                    XCTFail("Definitions should not be nil")
                    return
                }
                                
                try definitions.forEach { (definition) in
                    guard case .object(let value) = definition,
                        let interfaces = value.allOf,
                        interfaces.contains(where: { $0.ref.className == doc.id.className}),
                        let examples = value.examples
                    else {
                        return
                    }
                    
                    try examples.enumerated().forEach { (index, ex) in
                        let example = ex.dictionary
                        
                        let subdir = examplesDirectory.appendingPathComponent("\(doc.id.className)")
                        try fileManager.createDirectory(at: subdir, withIntermediateDirectories: true, attributes: nil)
                        let filename = "\(value.id.className)_\(index).json"
                        let url = subdir.appendingPathComponent(filename)
                        let exampleJson = try JSONSerialization.data(withJSONObject: example, options: [])
                        try exampleJson.write(to: url)
                        print(url)
                    }
                }
            }
        }
        catch let err {
            XCTFail("Failed to build the JsonSchema: \(err)")
        }
    }
}
