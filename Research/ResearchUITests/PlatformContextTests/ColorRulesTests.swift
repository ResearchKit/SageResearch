//
//  ColorRulesTests.swift
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


// - note: syoung 04/12/2019 The purpose of the tests included in this file is to check that as the rules
// change, we do not accidentally introduce mistakes that might look weird for color palettes that are not
// manually checked against the new rules. Basically, when you change something, this will break and serve
// as a reminder that you need to check all the cases visually before commiting a new rule. ;)

class ColorRulesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAssumptions() {
        XCTAssertFalse(RSDColorPalette.beach.primary.normal.usesLightStyle)
        XCTAssertFalse(RSDColorPalette.beach.secondary.normal.usesLightStyle)
        XCTAssertFalse(RSDColorPalette.beach.accent.normal.usesLightStyle)
        XCTAssertTrue(RSDColorPalette.midnight.primary.normal.usesLightStyle)
        XCTAssertTrue(RSDColorPalette.midnight.secondary.normal.usesLightStyle)
        XCTAssertTrue(RSDColorPalette.midnight.accent.normal.usesLightStyle)
    }

    func testMapping_ForStyle() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.white)?.normal, palette.grayScale.white)
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.primary)?.normal, palette.primary.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.secondary)?.normal, palette.secondary.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.accent)?.normal, palette.accent.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.successGreen)?.normal, palette.successGreen.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorStyle.errorRed)?.normal, palette.errorRed.normal)
        XCTAssertNil(colorRules.mapping(for: RSDColorStyle.custom))
    }
    
    func testMapping_ForColor() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.mapping(for: palette.grayScale.white.color)?.normal, palette.grayScale.white)
        XCTAssertEqual(colorRules.mapping(for: palette.primary.normal.color)?.normal, palette.primary.normal)
        XCTAssertEqual(colorRules.mapping(for: palette.secondary.normal.color)?.normal, palette.secondary.normal)
        XCTAssertEqual(colorRules.mapping(for: palette.accent.normal.color)?.normal, palette.accent.normal)
        XCTAssertEqual(colorRules.mapping(for: palette.successGreen.normal.color)?.normal, palette.successGreen.normal)
        XCTAssertEqual(colorRules.mapping(for: palette.errorRed.normal.color)?.normal, palette.errorRed.normal)
        XCTAssertNil(colorRules.mapping(for: UIColor.clear))
    }

    func testBackgroundLight() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        XCTAssertEqual(colorRules.backgroundLight, palette.grayScale.white)
    }

    func testBackgroundPrimary() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        XCTAssertEqual(colorRules.backgroundPrimary, palette.primary.normal)
    }

    func testTintedIconColor_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.veryLightGray), palette.accent.normal.color)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.white), palette.accent.normal.color)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.primary.normal), palette.accent.normal.color)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.veryDarkGray), UIColor.white)
    }
    
    func testTintedIconColor_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.veryLightGray), palette.accent.normal.color)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.white), palette.accent.normal.color)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.primary.normal), UIColor.white)
        XCTAssertEqual(colorRules.tintedIconColor(on: palette.grayScale.veryDarkGray), UIColor.white)
    }

    func testTextColor() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette, version: 2)
        
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .xLargeHeader), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .largeHeader), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .mediumHeader), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .smallHeader), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .body), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .microHeader), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .largeNumber), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .bodyDetail), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .small), palette.text.veryDark.color)
        
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .xLargeHeader), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .largeHeader), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .mediumHeader), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .smallHeader), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .body), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .microHeader), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .largeNumber), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .bodyDetail), UIColor.white)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .small), UIColor.white)
    }

    func testTintedButtonColor_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        let darkColor = palette.text.colorTiles.last?.color ?? UIColor.black
        let lightColor = palette.text.colorTiles.first?.color ?? UIColor.white
        
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.black), lightColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.white), darkColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.veryLightGray), darkColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.primary.normal), darkColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.successGreen.veryLight), darkColor)
    }
    
    func testTintedButtonColor_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        let darkColor = palette.text.colorTiles.last?.color ?? UIColor.black
        let lightColor = palette.text.colorTiles.first?.color ?? UIColor.white
        
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.black), lightColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.white), darkColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.veryLightGray), darkColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.primary.normal), lightColor)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.successGreen.veryLight), darkColor)
    }
    
    func testUnderlinedTextButton_v1_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette, version: 1)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.veryDark.color)
    }
    
    func testUnderlinedTextButton_v1_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette, version: 1)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.veryDark.color)
    }

    func testRoundedButton() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, buttonType: .primary).normal, palette.secondary.normal)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, buttonType: .primary).normal, palette.grayScale.white)
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, buttonType: .secondary).normal, palette.grayScale.veryLightGray)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, buttonType: .secondary).normal, palette.grayScale.veryLightGray)
    }

    func testRoundedButtonBackground() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .primary, forState: .normal), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .primary, forState: .normal), palette.grayScale.white.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .secondary, forState: .normal), palette.grayScale.veryLightGray.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .secondary, forState: .normal), palette.grayScale.veryLightGray.color)
        
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .primary, forState: .highlighted), palette.secondary.light.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .primary, forState: .highlighted), palette.grayScale.veryLightGray.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .secondary, forState: .highlighted), palette.grayScale.lightGray.color)
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .secondary, forState: .highlighted), palette.grayScale.white.color)
        
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .primary, forState: .disabled), palette.secondary.normal.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .primary, forState: .disabled), palette.grayScale.white.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButton(on: palette.grayScale.white, with: .secondary, forState: .disabled), palette.grayScale.veryLightGray.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButton(on: palette.primary.normal, with: .secondary, forState: .disabled), palette.grayScale.veryLightGray.color.withAlphaComponent(0.35))
    }

    func testRoundedButtonText_LightSecondary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .normal), palette.text.veryDark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .highlighted), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .highlighted), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .highlighted), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .highlighted), palette.text.veryDark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
    }
    
    func testRoundedButtonText_DarkSecondary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .normal), palette.text.veryLight.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .normal), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .normal), palette.text.veryDark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .highlighted), palette.text.veryLight.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .highlighted), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .highlighted), palette.text.veryDark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .highlighted), palette.text.veryDark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .disabled), palette.text.veryLight.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .disabled), palette.text.veryDark.color.withAlphaComponent(0.35))
    }
    
    func testCheckboxButton_LightColors() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let checkbox1 = colorRules.checkboxButton(on: palette.grayScale.white, isSelected: false)
        XCTAssertEqual(checkbox1.checkmark, UIColor.clear)
        XCTAssertEqual(checkbox1.background, palette.grayScale.white.color)
        XCTAssertEqual(checkbox1.border, palette.grayScale.lightGray.color)
        let checkbox2 = colorRules.checkboxButton(on: palette.grayScale.white, isSelected: true)
        XCTAssertEqual(checkbox2.checkmark, palette.grayScale.veryDarkGray.color)
        XCTAssertEqual(checkbox2.background, palette.primary.dark.color)
        XCTAssertEqual(checkbox2.border, palette.primary.normal.color)
        let checkbox3 = colorRules.checkboxButton(on: palette.primary.normal, isSelected: true)
        XCTAssertEqual(checkbox3.checkmark, palette.grayScale.veryDarkGray.color)
        XCTAssertEqual(checkbox3.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox3.border, palette.secondary.light.color)
    }
    
    func testCheckboxButton_DarkColors() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        let checkbox1 = colorRules.checkboxButton(on: palette.grayScale.white, isSelected: false)
        XCTAssertEqual(checkbox1.checkmark, UIColor.clear)
        XCTAssertEqual(checkbox1.background, palette.grayScale.white.color)
        XCTAssertEqual(checkbox1.border, palette.grayScale.lightGray.color)
        let checkbox2 = colorRules.checkboxButton(on: palette.grayScale.white, isSelected: true)
        XCTAssertEqual(checkbox2.checkmark, palette.grayScale.white.color)
        XCTAssertEqual(checkbox2.background, palette.primary.dark.color)
        XCTAssertEqual(checkbox2.border, palette.primary.normal.color)
        let checkbox3 = colorRules.checkboxButton(on: palette.primary.normal, isSelected: true)
        XCTAssertEqual(checkbox3.checkmark, palette.grayScale.white.color)
        XCTAssertEqual(checkbox3.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox3.border, palette.secondary.light.color)
    }
    
    

    func testProgressIndicator() {
        let palette: RSDColorPalette = .wireframe
        let colorRules = RSDColorRules(palette: palette)
        
        let (filled1, unfilled1) = colorRules.progressBar(on: colorRules.backgroundLight)
        XCTAssertEqual(filled1, palette.accent.normal.color)
        XCTAssertEqual(unfilled1, palette.grayScale.veryLightGray.color)
        let (filled2, unfilled2) = colorRules.progressBar(on: colorRules.backgroundLight)
        XCTAssertEqual(filled2, palette.accent.normal.color)
        XCTAssertEqual(unfilled2, palette.grayScale.veryLightGray.color)
    }
    
    func testProgressDial() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let dial1 = colorRules.progressDial(on: palette.grayScale.white, style: .primary, innerColor: palette.grayScale.white.color, usesLightStyle: false)
        XCTAssertEqual(dial1.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial1.filled, palette.primary.light.color)
        XCTAssertEqual(dial1.inner, palette.primary.normal)
        let dial2 = colorRules.progressDial(on: palette.grayScale.black, style: .primary, innerColor: palette.grayScale.black.color, usesLightStyle: true)
        XCTAssertEqual(dial2.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial2.filled, palette.primary.light.color)
        XCTAssertEqual(dial2.inner, palette.primary.normal)
        
        let dial3 = colorRules.progressDial(on: palette.grayScale.white, style: nil, innerColor: palette.grayScale.white.color, usesLightStyle: false)
        XCTAssertEqual(dial3.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial3.filled, palette.accent.normal.color)
        XCTAssertEqual(dial3.inner, palette.grayScale.white)
        let dial4 = colorRules.progressDial(on: palette.grayScale.black, style: nil, innerColor: palette.grayScale.black.color, usesLightStyle: true)
        XCTAssertEqual(dial4.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial4.filled, palette.accent.normal.color)
        XCTAssertEqual(dial4.inner, palette.grayScale.black)
        
        let dial5 = colorRules.progressDial(on: palette.grayScale.white, style: nil, innerColor: palette.primary.normal.color, usesLightStyle: palette.primary.normal.usesLightStyle)
        XCTAssertEqual(dial5.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial5.filled, palette.primary.light.color)
        XCTAssertEqual(dial5.inner, palette.primary.normal)
        let dial6 = colorRules.progressDial(on: palette.grayScale.black, style: nil, innerColor: palette.successGreen.normal.color, usesLightStyle: palette.primary.normal.usesLightStyle)
        XCTAssertEqual(dial6.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial6.filled, palette.successGreen.light.color)
        XCTAssertEqual(dial6.inner, palette.successGreen.normal)
        
        let dial7 = colorRules.progressDial(on: palette.grayScale.white)
        XCTAssertEqual(dial7.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial7.filled, palette.accent.normal.color)
        XCTAssertEqual(dial7.inner.color, UIColor.clear)
        XCTAssertEqual(dial7.inner.usesLightStyle, false)
        let dial8 = colorRules.progressDial(on: palette.grayScale.black)
        XCTAssertEqual(dial8.unfilled, palette.grayScale.veryLightGray.color)
        XCTAssertEqual(dial8.filled, palette.accent.normal.color)
        XCTAssertEqual(dial8.inner.color, UIColor.clear)
        XCTAssertEqual(dial8.inner.usesLightStyle, true)
    }
    
    
    

    func testRoundedCheckmark_LightColors() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let checkbox1 = colorRules.roundedCheckmark(on: palette.grayScale.white)
        XCTAssertEqual(checkbox1.checkmark, palette.grayScale.veryDarkGray.color)
        XCTAssertEqual(checkbox1.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox1.border, palette.secondary.normal.color)
        let checkbox3 = colorRules.roundedCheckmark(on: palette.primary.normal)
        XCTAssertEqual(checkbox3.checkmark, palette.grayScale.veryDarkGray.color)
        XCTAssertEqual(checkbox3.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox3.border, palette.secondary.normal.color)
    }
    
    func testRoundedCheckmark_DarkColors() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        let checkbox1 = colorRules.roundedCheckmark(on: palette.grayScale.white)
        XCTAssertEqual(checkbox1.checkmark, palette.grayScale.white.color)
        XCTAssertEqual(checkbox1.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox1.border, palette.secondary.normal.color)
        let checkbox3 = colorRules.roundedCheckmark(on: palette.primary.normal)
        XCTAssertEqual(checkbox3.checkmark, palette.grayScale.white.color)
        XCTAssertEqual(checkbox3.background, palette.secondary.normal.color)
        XCTAssertEqual(checkbox3.border, palette.secondary.normal.color)
    }
    
    func testCompletionGradient() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let gradient = colorRules.completionGradient()
        XCTAssertEqual(gradient.0, palette.successGreen.light)
        XCTAssertEqual(gradient.1, palette.successGreen.normal)
    }

    func testTableCellBackground() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let background1 = colorRules.tableCellBackground(on: palette.grayScale.white, isSelected: true)
        XCTAssertEqual(background1, palette.accent.colorTiles.first!)
        let background2 = colorRules.tableCellBackground(on: palette.grayScale.white, isSelected: false)
        XCTAssertEqual(background2, palette.grayScale.white)
        let background3 = colorRules.tableCellBackground(on: palette.primary.normal, isSelected: true)
        XCTAssertEqual(background3, palette.accent.colorTiles.first!)
        let background4 = colorRules.tableCellBackground(on: palette.primary.normal, isSelected: false)
        XCTAssertEqual(background4, palette.grayScale.white)
    }

    func testTableSectionBackground() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        let background2 = colorRules.tableSectionBackground(on: palette.grayScale.white)
        XCTAssertEqual(background2, palette.grayScale.white)
        let background4 = colorRules.tableSectionBackground(on: palette.primary.normal)
        XCTAssertEqual(background4, palette.grayScale.white)
    }

    func testSeparatorLine() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.separatorLine, palette.grayScale.veryLightGray.color)
    }
}
