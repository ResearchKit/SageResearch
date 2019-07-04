//
//  ColorPaletteTests.swift
//  Research (iOS)
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

class ColorPaletteTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTextColor() {
        // The text special key was added with version 1.
        
        let palette = RSDColorPalette.wireframe
        
        XCTAssertEqual(palette.text.index, 2)
        
        let textKey = RSDColorMatrix.shared.colorKey(for: .special(.text), shade: .medium)
        XCTAssertEqual(textKey.index, 2)
        
        let textSwatch = RSDColorMatrix.shared.colorSwatch(for: .special(.text), version: 0)
        XCTAssertNotNil(textSwatch)
        XCTAssertEqual(textSwatch?.colorTiles.count, 3)
        
        let textKey2 = RSDColorMatrix.shared.colorKey(for: .special(.text), version: 1, index: 2)
        XCTAssertNotNil(textKey2)
        XCTAssertEqual(textKey2.index, 2)
    }
    
    func testErrorRed() {
        let palette = RSDColorPalette.wireframe
        
        XCTAssertEqual(palette.errorRed.index, 2)
        
        let textKey = RSDColorMatrix.shared.colorKey(for: .special(.errorRed), shade: .medium)
        XCTAssertEqual(textKey.index, 2)
        
        let textSwatch = RSDColorMatrix.shared.colorSwatch(for: .special(.errorRed), version: 0)
        XCTAssertNotNil(textSwatch)
        XCTAssertEqual(textSwatch?.colorTiles.count, 1)
        
        let textKey2 = RSDColorMatrix.shared.colorKey(for: .special(.errorRed), version: 0, index: 2)
        XCTAssertNotNil(textKey2)
        XCTAssertEqual(textKey2.index, 0)
        
        let found = RSDColorMatrix.shared.findColorTile(for: textKey2.normal.color)
        XCTAssertNotNil(found)
        XCTAssertEqual(found, textKey2.normal)
    }
    
    func testWhite() {
        let palette = RSDColorPalette.wireframe
        
        XCTAssertEqual(palette.grayScale.white.color, RSDColor.white)
        
        let found = RSDColorMatrix.shared.findColorTile(for: RSDColor.white)
        XCTAssertNotNil(found)
        XCTAssertEqual(found, palette.grayScale.white)
        
        let mapping0 = RSDColorMatrix.shared.colorMapping(for: .white, version: 0)
        let mapping = RSDColorMatrix.shared.colorMapping(for: .white)
        XCTAssertEqual(mapping.index, mapping0.index)
        XCTAssertEqual(mapping.normal, mapping0.normal)
    }
}
