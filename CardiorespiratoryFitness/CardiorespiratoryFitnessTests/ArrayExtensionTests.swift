//
//  ArrayExtensionTests.swift
//  CardiorespiratoryFitnessTests
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
@testable import CardiorespiratoryFitness


/// Mathlab tests for old algorithm - leaving in b/c some of the array extensions might prove
/// useful for other projects.
class ArrayExtensionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testXCorr() {
        let input = Array(1...10).map { Double($0) }
        
        let output = xcorr(input)
        let expectedAnswer: [Double] = [10.0, 29.0, 56.0, 90.0, 130.0, 175.0, 224.0, 276.0, 330.0, 385.0, 330.0, 276.0, 224.0, 175.0, 130.0, 90.0, 56.0, 29.0, 10.0]
        XCTAssertEqual(output, expectedAnswer)
    }
    
    func testConv() {
        let u = Array(1...10).map { Double($0) }
        let v = Array(1...15).map { Double($0) }
        
        let output1 = conv(u, v, .same)
        let expectedAnswer1: [Double] = [120, 165, 220, 275, 330, 385, 440, 495, 534, 556]
        XCTAssertEqual(output1, expectedAnswer1)
        
        let output2 = conv(v, u, .same)
        let expectedAnswer2: [Double] = [56, 84, 120, 165, 220, 275, 330, 385, 440, 495, 534, 556, 560, 545, 510]
        XCTAssertEqual(output2, expectedAnswer2)
        
        let input1 = u.zeroPadBefore(count: 9)
        let input2 = u.zeroPadAfter(count: 9)
        
        let expectedAnswer3: [Double] = [1.0, 4.0, 10.0, 20.0, 35.0, 56.0, 84.0, 120.0, 165.0, 220.0, 264.0, 296.0, 315.0, 320.0, 310.0, 284.0, 241.0, 180.0, 100.0]
        let conv_nopad = conv(u, u)
        let conv_pad = conv(input1, input2, .same)
        XCTAssertEqual(conv_nopad, expectedAnswer3)
        XCTAssertEqual(conv_pad, expectedAnswer3)
    }
}
