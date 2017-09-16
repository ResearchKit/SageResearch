//
//  CodableObjectTests.swift
//  SageResearchSDKTests
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
import SageResearchSDK

/**

// MARK: Example codeable subclasses

class ClassA : SRSCodableObject {
}

class ClassB : SRSCodableObject {
}

class ClassC : SRSCodableObject {
    var count: Int = 0
        
    override var hashValue: Int {
        return super.hashValue ^ count
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let castObject = object as? ClassC else { return false }
        return super.isEqual(object) && castObject.count == count
    }
}


// MARK: Tests

class CodableObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassEquality() {
        let objACat1 = ClassA(identifier: "cat")
        let objACat2 = ClassA(identifier: "cat")
        let objADog = ClassA(identifier: "dog")
        let objBCat = ClassB(identifier: "cat")
        
        XCTAssertEqual(objACat1, objACat2)
        XCTAssertNotEqual(objACat1, objADog)
        XCTAssertNotEqual(objACat1, objBCat)
    }
    
    func testOverrideEquality() {
        let objCat1 = ClassC(identifier: "cat")
        objCat1.count = 1
        
        let objCat2 = ClassC(identifier: "cat")
        objCat2.count = 2
        
        let objCat2_2 = ClassC(identifier: "cat")
        objCat2_2.count = 2
        
        let objDog1 = ClassC(identifier: "dog")
        objDog1.count = 1
        
        XCTAssertEqual(objCat2, objCat2_2)
        XCTAssertNotEqual(objCat1, objCat2)
        XCTAssertNotEqual(objCat1, objDog1)
    }
    
    func testDecode() {
        
        let jsonA = """
        {
         "identifier": "test1",
         "count": 2
        }
        """.data(using: .utf8)!
        
        do {
            let objA1 = try JSONDecoder().decode(ClassC.self, from: jsonA)
            
            XCTAssertEqual(objA1.identifier, "test1")
            XCTAssertEqual(objA1.count, 2)
        }
        catch let err {
            XCTFail("Failed with \(err)")
        }
    }
    
}
 
 */
