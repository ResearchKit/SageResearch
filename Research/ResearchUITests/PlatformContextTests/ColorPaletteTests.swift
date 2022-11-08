//
//  ColorPaletteTests.swift
//  Research (iOS)
//

import XCTest
import Research
@testable import ResearchUI

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
