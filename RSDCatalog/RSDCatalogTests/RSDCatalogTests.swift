//
//  RSDCatalogTests.swift
//  RSDCatalogTests
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
@testable import RSDCatalog
import Research

class RSDCatalogTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// Test decoding all the task info objects.
    func testDecodeJSON() {
        guard let jsonData = jsonDataForResource("TaskGroups") else {
            XCTFail("Failed to get data from resource file.")
            return
        }
        let factory = CatalogFactory()
        let jsonDecoder = factory.createJSONDecoder()
        do {
            let taskGroups = try jsonDecoder.decode([RSDTaskGroupObject].self, from: jsonData)
            for taskGroup in taskGroups {
                for taskInfo in taskGroup.tasks {
                    if let taskTransformer = taskInfo.resourceTransformer {
                        let expect = expectation(description: "Fetch Task \(taskInfo.identifier)")
                        taskTransformer.fetchTask(with: taskInfo.identifier, schemaInfo:taskInfo.schemaInfo) { (task, err)  in
                            if let task = task {
                                do {
                                    try task.validate()
                                } catch let err {
                                    XCTFail("Failed to validate task \(task.identifier): \(err)")
                                }
                            } else {
                                XCTFail("Failed to decode task \(taskInfo.identifier): \(String(describing: err))")
                            }
                            expect.fulfill()
                        }
                        waitForExpectations(timeout: 2) { (err) in
                            print(String(describing: err))
                        }
                    } else {
                        XCTFail("\(taskInfo.identifier) does not have a transformable task.")
                    }
                }
            }
        } catch let err {
            XCTFail("Failed to decode task \(err)")
        }
    }
    
    // MARK: Helper methods
    
    func jsonDataForResource(_ resourceName: String) -> Data? {
        let resourcePath = Bundle(for: self.classForCoder).path(forResource: resourceName, ofType:"json") ??
            Bundle.main.path(forResource: resourceName, ofType: "json")
        
        guard let path = resourcePath, let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            XCTAssert(false, "Resource not found: \(resourceName)")
            return nil
        }
        return jsonData
    }
}
