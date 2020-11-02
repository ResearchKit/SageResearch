//
//  ColorMappingThemeElementTests.swift
//  ResearchTests_iOS
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
import Research
@testable import ResearchUI

class ColorMappingThemeElementTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testColorPlacement_PrimaryHeader() {
        let designSystem = RSDDesignSystem()
        let mapping: [RSDColorPlacement : RSDColorStyle] = [.header : .primary, .body: .white, .footer: .white]
        let placement = mapping.mapKeys { $0.stringValue }
        let theme = RSDColorPlacementThemeElementObject(placement: placement)
        
        let headerColor = theme.backgroundColor(for: .header, using: designSystem.colorRules, compatibleWith: nil)
        let bodyColor = theme.backgroundColor(for: .body, using: designSystem.colorRules, compatibleWith: nil)
        let footerColor = theme.backgroundColor(for: .footer, using: designSystem.colorRules, compatibleWith: nil)
        
        XCTAssertEqual(headerColor, designSystem.colorRules.palette.primary.normal)
        XCTAssertEqual(bodyColor, designSystem.colorRules.palette.grayScale.white)
        XCTAssertEqual(footerColor, designSystem.colorRules.palette.grayScale.white)
    }
    
    func testColorPlacement_CustomHeader() {
        let designSystem = RSDDesignSystem()
        let mapping: [RSDColorPlacement : RSDColorStyle] = [.header : .custom, .body: .white, .footer: .white]
        let placement = mapping.mapKeys { $0.stringValue }
        let theme = RSDColorPlacementThemeElementObject(placement: placement,
                                                        customColorName: "#FFAABB",
                                                        usesLightStyle: true)
        
        let headerColor = theme.backgroundColor(for: .header, using: designSystem.colorRules, compatibleWith: nil)
        let bodyColor = theme.backgroundColor(for: .body, using: designSystem.colorRules, compatibleWith: nil)
        let footerColor = theme.backgroundColor(for: .footer, using: designSystem.colorRules, compatibleWith: nil)
        
        let expectedHeader = RSDColorTile(RSDColor(hexString: "#FFAABB")!, usesLightStyle: true)
        XCTAssertEqual(headerColor, expectedHeader)
        XCTAssertEqual(bodyColor, designSystem.colorRules.palette.grayScale.white)
        XCTAssertEqual(footerColor, designSystem.colorRules.palette.grayScale.white)
    }
    
    func testSingleColor_Primary() {
        let designSystem = RSDDesignSystem()
        let theme = RSDSingleColorThemeElementObject(colorStyle: .primary)
        
        let headerColor = theme.backgroundColor(for: .header, using: designSystem.colorRules, compatibleWith: nil)
        let bodyColor = theme.backgroundColor(for: .body, using: designSystem.colorRules, compatibleWith: nil)
        let footerColor = theme.backgroundColor(for: .footer, using: designSystem.colorRules, compatibleWith: nil)
        
        XCTAssertEqual(headerColor, designSystem.colorRules.palette.primary.normal)
        XCTAssertEqual(bodyColor, designSystem.colorRules.palette.primary.normal)
        XCTAssertEqual(footerColor, designSystem.colorRules.palette.primary.normal)
    }
    
    func testSingleColor_Custom() {
        let designSystem = RSDDesignSystem()
        let theme = RSDSingleColorThemeElementObject(colorStyle: nil,
                                                        customColorName: "#FFAABB",
                                                        usesLightStyle: true,
                                                        bundleIdentifier: nil)
        
        
        let headerColor = theme.backgroundColor(for: .header, using: designSystem.colorRules, compatibleWith: nil)
        let bodyColor = theme.backgroundColor(for: .body, using: designSystem.colorRules, compatibleWith: nil)
        let footerColor = theme.backgroundColor(for: .footer, using: designSystem.colorRules, compatibleWith: nil)
        
        let expectedColor = RSDColorTile(RSDColor(hexString: "#FFAABB")!, usesLightStyle: true)
        XCTAssertEqual(headerColor, expectedColor)
        XCTAssertEqual(bodyColor, expectedColor)
        XCTAssertEqual(footerColor, expectedColor)
    }
}
