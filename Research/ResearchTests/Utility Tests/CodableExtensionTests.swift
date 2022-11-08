//
//  CodableExtensionTests.swift
//  ResearchTests_iOS
//

import XCTest

//class CodableExtensionTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//
//    func testArrayDecode() {
//        let input = [["name":"Foo", "value":2], ["name":"Goo", "value":5]]
//        do {
//            let output = try input.rsd_decode([TestObject].self, bundle: nil)
//            let expected = [TestObject(name: "Foo", value: 2), TestObject(name: "Goo", value: 5)]
//            XCTAssertEqual(output, expected)
//        }
//        catch let err {
//            XCTFail("Failed to decode the objects. \(err)")
//        }
//    }
//}
//
//struct TestObject : Decodable, Equatable, Hashable {
//    let name: String
//    let value: Int
//}
