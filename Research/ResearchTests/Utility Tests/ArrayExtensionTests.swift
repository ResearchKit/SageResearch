//
//  ArrayExtensionTests.swift
//  ResearchTests_iOS
//

import XCTest
@testable import Research

class ArrayExtensionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRemoveWhere() {
        var array = [0,1,2,3,4,5,6,7,8]
        let removed = array.remove(where: { $0 % 2 == 0 })
        XCTAssertEqual(removed, [0,2,4,6,8])
    }

}
