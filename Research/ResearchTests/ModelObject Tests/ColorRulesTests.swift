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
@testable import Research


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
        
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.white)?.normal, palette.grayScale.white)
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.primary)?.normal, palette.primary.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.secondary)?.normal, palette.secondary.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.accent)?.normal, palette.accent.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.successGreen)?.normal, palette.successGreen.normal)
        XCTAssertEqual(colorRules.mapping(for: RSDColorRules.Style.errorRed)?.normal, palette.errorRed.normal)
        XCTAssertNil(colorRules.mapping(for: RSDColorRules.Style.custom))
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
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .heading1), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .heading2), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .heading3), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .heading4), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .fieldHeader), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .body), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .microHeader), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .counter), palette.text.dark.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .bodyDetail), palette.text.normal.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.white, for: .small), palette.text.normal.color)
        
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .heading1), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .heading2), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .heading3), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .heading4), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .fieldHeader), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .body), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .microHeader), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .counter), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .bodyDetail), palette.text.light.color)
        XCTAssertEqual(colorRules.textColor(on: palette.grayScale.black, for: .small), palette.text.light.color)
    }

    func testTintedButtonColor_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.black), UIColor.white)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.white), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.veryLightGray), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.primary.normal), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.successGreen.veryLight), palette.grayScale.veryDarkGray.color)
    }
    
    func testTintedButtonColor_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.black), UIColor.white)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.white), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.grayScale.veryLightGray), palette.secondary.normal.color)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.primary.normal), UIColor.white)
        XCTAssertEqual(colorRules.tintedButtonColor(on: palette.successGreen.veryLight), palette.grayScale.veryDarkGray.color)
    }

    func testUnderlinedTextButton_v0_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette, version: 0)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.dark.color)
    }
    
    func testUnderlinedTextButton_v0_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette, version: 0)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.primary.normal.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), palette.text.light.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.dark.color)
    }
    
    func testUnderlinedTextButton_v1_LightPrimary() {
        let palette: RSDColorPalette = .beach
        let colorRules = RSDColorRules(palette: palette, version: 1)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.dark.color)
    }
    
    func testUnderlinedTextButton_v1_DarkPrimary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette, version: 1)
        
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.black, state: .normal), UIColor.white)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.white, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.grayScale.veryLightGray, state: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.primary.normal, state: .normal), palette.text.light.color)
        XCTAssertEqual(colorRules.underlinedTextButton(on: palette.successGreen.veryLight, state: .normal), palette.text.dark.color)
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
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .normal), palette.text.dark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .highlighted), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .highlighted), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .highlighted), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .highlighted), palette.text.dark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
    }
    
    func testRoundedButtonText_DarkSecondary() {
        let palette: RSDColorPalette = .midnight
        let colorRules = RSDColorRules(palette: palette)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .normal), palette.text.light.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .normal), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .normal), palette.text.dark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .highlighted), palette.text.light.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .highlighted), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .highlighted), palette.text.dark.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .highlighted), palette.text.dark.color)
        
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .primary, forState: .disabled), palette.text.light.color)
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .primary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.grayScale.white, with: .secondary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
        XCTAssertEqual(colorRules.roundedButtonText(on: palette.primary.normal, with: .secondary, forState: .disabled), palette.text.dark.color.withAlphaComponent(0.35))
    }
    
    // TODO: syoung 04/12/2019 Write tests for remaining rules
//
//        /// Checkbox button.
//        ///
//        /// - Default:
//        /// ```
//        ///     First, determine the inner color of the checkmark box using rules where
//        ///     If selected
//        ///         If the background is white then
//        ///             inner = `primary.dark`
//        ///             border = `primary`
//        ///         Else
//        ///             inner = `secondary`
//        ///             border = `secondary.light`
//        ///     Else
//        ///         inner = `white`
//        ///         border = `lightGray`
//        ///
//        ///     Next, the checkmark color is
//        ///     If the inner color uses light style then `white` else `veryDarkGray`
//        /// ```
//        ///
//        /// - parameters:
//        ///     - background: The background of the checkbox.
//        ///     - isSelected: Whether or not the checkbox is selected.
//        /// - returns:
//        ///     - checkmark: The checkmark color.
//        //      - background: The background (fill) color.
//        //      - border: The border color.
//        open func checkboxButton(on background: RSDColorTile, isSelected: Bool) ->
//            (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
//
//                let inner: RSDColorTile
//                let border: RSDColor
//
//                if isSelected {
//                    if background == self.palette.grayScale.white {
//                        inner = self.palette.primary.dark
//                        border = self.palette.primary.normal.color
//                    }
//                    else {
//                        inner = self.palette.secondary.normal
//                        border = self.palette.secondary.light.color
//                    }
//                }
//                else {
//                    inner = self.palette.grayScale.white
//                    border = self.palette.grayScale.lightGray.color
//                }
//
//                let check = isSelected
//                    ? (inner.usesLightStyle ?  self.palette.grayScale.white.color : self.palette.grayScale.veryDarkGray.color)
//                    : RSDColor.clear
//
//                return (check, inner.color, border)
//        }
//
//
//        /// MARK: Progress indicator colors
//
//        /// The colors to use with a progress bar.
//        ///
//        /// - Default:
//        /// ```
//        ///     filled = `accent`
//        ///     unfilled = `veryLightGray`
//        /// ```
//        ///
//        /// - parameter background: The background for the progress bar.
//        /// - returns:
//        ///     - filled: The fill color for the progress bar which marks progress.
//        ///     - unfilled: The unfilled (background) color for the progress bar.
//        open func progressBar(on background: RSDColorTile) -> (filled: RSDColor, unfilled: RSDColor) {
//            return (self.palette.accent.light.color, self.palette.grayScale.veryLightGray.color)
//        }
//
//        /// The colors to use with a progress dial.
//        ///
//        /// - Default:
//        /// ```
//        ///     `unfilled` is always `veryLightGray`
//        ///
//        ///     If the style is defined then
//        ///         filled = `style.light`
//        ///         inner = `style`
//        ///
//        ///     Else if the inner color is `white`
//        ///         filled = `accent`
//        ///         inner = `white`
//        ///
//        ///     Else if the inner color is `clear`
//        ///         filled = `accent`
//        ///         inner = `clear` with light style of the background
//        ///
//        ///     Else
//        ///         filled = `inner.light`
//        ///         inner = inner
//        /// ```
//        ///
//        /// - parameters:
//        ///     - background: The background color tile for the view that this view "lives" in.
//        ///     - style: The style of the dial. If non-nil, this will be used as the color of the inner circle.
//        ///     - innerColor: The inner color of the dial set by the nib or storyboard.
//        ///     - usesLightStyle: The light-style set by the nib or storyboard.
//        /// - returns:
//        ///     - filled: The fill color for the progress bar which marks progress.
//        ///     - unfilled: The unfilled (background) color for the progress bar.
//        ///     - inner: The inner color to use for the progress bar.
//        open func progressDial(on background: RSDColorTile, style: Style?,
//                               innerColor: RSDColor = RSDColor.clear,
//                               usesLightStyle: Bool = false) -> (filled: RSDColor, unfilled: RSDColor, inner: RSDColorTile) {
//
//            let filled: RSDColor
//            let unfilled: RSDColor = self.palette.grayScale.veryLightGray.color
//            let inner: RSDColorTile
//
//            if let style = style, let mapping = self.mapping(for: style) {
//                filled = mapping.light.color
//                inner = mapping.normal
//            }
//            else if let mapping = mapping(for: innerColor), mapping.normal != palette.grayScale.white {
//                filled = mapping.light.color
//                inner = mapping.normal
//            }
//            else {
//                filled = self.palette.accent.normal.color
//                let lightStyle = (innerColor == RSDColor.clear) ? background.usesLightStyle : usesLightStyle
//                inner = RSDColorTile(innerColor, usesLightStyle: lightStyle)
//            }
//            return (filled, unfilled, inner)
//        }
//
//
//        /// MARK: Completion
//
//        /// Rounded checkmarks are drawn UI elements of a checkmark with a solid background.
//        ///
//        /// - Default:
//        /// ```
//        ///     The background (fill) and border (stroke) both use `secondary` color
//        ///
//        ///     If `secondary` uses light style then
//        ///         checkmark = `white`
//        ///     Else
//        ///         checkmark = `veryDarkGray`
//        /// ```
//        ///
//        /// - parameter background: The background of the checkbox.
//        /// - returns:
//        ///     - checkmark: The checkmark color.
//        //      - background: The background (fill) color.
//        //      - border: The border color.
//        open func roundedCheckmark(on background: RSDColorTile) -> (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
//            let fill = self.palette.secondary.normal
//            let checkmark = fill.usesLightStyle ? self.palette.grayScale.white.color : self.palette.grayScale.veryDarkGray.color
//            return (checkmark, fill.color, fill.color)
//        }
//
//        /// For a completion gradient background, what are the min and max colors?
//        ///
//        /// - Default: `successGreen.light` and `successGreen`
//        ///
//        /// - returns:
//        ///     - 0: The min color tile.
//        ///     - 1: The max color tile.
//        open func completionGradient() -> (RSDColorTile, RSDColorTile) {
//            return (self.palette.successGreen.light, self.palette.successGreen.normal)
//        }
//
//        /// MARK: Choice Selection cell
//
//        /// The background color tile for the table cell.
//        ///
//        /// - Default:
//        /// ```
//        ///     If selected
//        ///         then lightest color tile within the same family as the primary color
//        ///     Else
//        ///         `white`
//        /// ```
//        ///
//        /// - parameters:
//        ///     - background: The background of the table.
//        ///     - isSelected: Whether or not the cell is selected.
//        /// - returns: The color tile for the background of the cell.
//        open func tableCellBackground(on background: RSDColorTile, isSelected: Bool) -> RSDColorTile {
//            return isSelected ?  self.palette.primary.colorTiles.first! : self.palette.grayScale.white
//        }
//
//        /// The background color tile for the table section header.
//        ///
//        /// - Default: `white`
//        ///
//        /// - parameter background: The background of the table.
//        /// - returns: The color tile for the background of the section header.
//        open func tableSectionBackground(on background: RSDColorTile) -> RSDColorTile {
//            return self.palette.grayScale.white
//        }
//
//        /// The cell separator line for a table cell or other border.
//        ///
//        /// - Default: `veryLightGray`
//        open var separatorLine: RSDColor {
//            return self.palette.grayScale.veryLightGray.color
//        }
//
//        /// The color of an underline for a text field.
//        ///
//        /// - Default: `accent`
//        ///
//        /// - parameter background: The background of the table cell.
//        /// - returns: The color of the underline.
//        open func textFieldUnderline(on background: RSDColorTile) -> RSDColor {
//            return self.palette.accent.normal.color
//        }
//
//
//        // MARK: Severity colors used for showing a scale from "normal - severe"
//
//        /// The severity color scale to use for buttons and graphics in this app.
//        open var severityColorScale : RSDSeverityColorScale = RSDSeverityColorScale()
//    }

}
