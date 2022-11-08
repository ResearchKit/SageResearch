//
//  ColorMappingThemeElementTests.swift
//  ResearchTests_iOS
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
