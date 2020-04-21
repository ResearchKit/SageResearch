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
import JSONSchema

class JsonSchemaBuilderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJson() {
        let factory = RSDFactory()
        let baseUrl = URL(string: "http://sagebionetworks.org/jsonSchema/")!
        
        let doc = JsonDocumentBuilder(baseUrl: baseUrl,
                                      rootName: "SageResearch",
                                      factory: factory)
        
        do {
            let doc = try doc.buildSchema()
            let encoder = factory.createJSONEncoder()
            let json = try encoder.encode(doc)
            
            let filename = "SageResearch.schema.json"
            let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(filename)
            
            try json.write(to: url)
            print(url)
            
            let exs = doc.definitions?.values.flatMap { (definition) -> [[String : Any]] in
                guard case .object(let value) = definition, let ex = value.examples else {
                    return []
                }
                return ex.map { $0.dictionary }
            }
            guard let examples = exs else {
                XCTFail("Definitions should not be nil")
                return
            }
            
            let jsonSchema = try JSONSerialization.jsonObject(with: json, options: []) as! [String : Any]

            examples.forEach {
                let validationResult = JSONSchema.validate($0, schema: jsonSchema)
                XCTAssertTrue(validationResult.valid, "\(validationResult.errors ?? [])")
            }
        }
        catch let err {
            XCTFail("Failed to build the JsonSchema: \(err)")
        }
    }
}
