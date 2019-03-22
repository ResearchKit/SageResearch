//
//  RSDColorRules.swift
//  Research
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

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

public enum RSDControlState : UInt {
    case normal = 0, highlighted = 1, disabled = 2, selected = 4
    
    #if os(iOS) || os(tvOS)
    public init(controlState: UIControl.State) {
        self = RSDControlState(rawValue: controlState.rawValue) ?? .normal
    }
    
    public var controlState: UIControl.State {
        return UIControl.State(rawValue: self.rawValue)
    }
    #endif
}


/// The color rules object is a concrete implementation of the design rules used for a give version of the
/// SageResearch frameworks. A module can use this class as-is or override the class to enforce a set of rules
/// pinned to the tasks included within a module. This is important to allow a module to be validated against
/// a given UI/UX. The frameworks can later change to reflect new devices, OS changes, and design system
/// updates to incorporate the results of more design studies.
open class RSDColorRules  {
    public static let currentVersion: Int = 0
    
    /// The version for the color rules. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int

    /// The color pallette for this color design.
    open var pallette: RSDColorPallette! {
        get {
            return _pallette
        }
        set {
            guard newValue != nil else { return }
            _pallette = newValue
        }
    }
    private var _pallette: RSDColorPallette
    
    public init(pallette: RSDColorPallette, version: Int? = nil) {
        self._pallette = pallette
        self.version = version ?? pallette.version ?? RSDColorRules.currentVersion
    }
    
    
    /// MARK: Default colors
    
    /// The named category or style for a given color.
    public enum Style : String, Codable, CaseIterable {
        case white, primary, secondary, accent, successGreen, errorRed, custom
    }
    
    /// The default color to use for a given color style.
    open func mapping(for style: Style) -> RSDColorMapping? {
        switch style {
        case .white:
            return self.pallette.grayScale.mapping(for: .white)
        case .primary:
            return self.pallette.primary
        case .secondary:
            return self.pallette.secondary
        case .accent:
            return self.pallette.accent
        case .successGreen:
            return self.pallette.successGreen
        case .errorRed:
            return self.pallette.errorRed
        case .custom:
            return nil
        }
    }
    
    /// Look in the pallette for a mapping.
    open func mapping(for color: RSDColor) -> RSDColorMapping? {
        let families: [RSDColorFamily] = [_pallette.grayScale, _pallette.primary.swatch, _pallette.secondary.swatch, _pallette.accent.swatch, _pallette.successGreen.swatch, _pallette.errorRed.swatch]
        for family in families {
            if let mapping = family.mapping(for: color) {
                return mapping
            }
        }
        return nil
    }

        
    /// Background color for views that should have a light background.
    ///
    /// - Default: `white`
    open var backgroundLight: RSDColorTile {
        return self.pallette.grayScale.white
    }
    
    /// Background color for views that should use the primary color tile for the background.
    ///
    /// - Default: `primary`
    open var backgroundPrimary: RSDColorTile {
        return self.pallette.primary.normal
    }
    
    /// Tinted image icon color on a given background. Typically, this is used in a collection or table view.
    ///
    /// - Default:
    ///     If the background uses light style
    ///         then `white`
    ///         else `accent`
    open func tintedIconColor(on background: RSDColorTile) -> RSDColor {
        if background.usesLightStyle {
            return self.pallette.grayScale.white.color
        }
        else {
            return self.pallette.accent.normal.color
        }
    }

    /// Color for text throughout the app.
    ///
    /// - Default:
    ///     If the background uses light style
    ///         then `white`
    ///         else `veryDarkGray`
    open func textColor(on background: RSDColorTile, for textType: RSDDesignSystem.TextType) -> RSDColor {
        if background.usesLightStyle {
            return self.pallette.grayScale.white.color
        }
        else {
            return self.pallette.grayScale.veryDarkGray.color
        }
    }
    
    
    /// MARK: Buttons
    
    /// Tinted button color on a given background.
    ///
    /// - Default:
    ///     If the background uses light style then `white`
    ///     else if the background is the primary pallette color then `secondary`
    ///     else `veryDarkGray`
    open func tintedButtonColor(on background: RSDColorTile) -> RSDColor {
        if background.usesLightStyle {
            return self.pallette.grayScale.white.color
        }
        else if background == self.pallette.primary.normal {
            return self.pallette.secondary.normal.color
        }
        else {
            return self.pallette.grayScale.veryDarkGray.color
        }
    }
    
    /// Underlined text button.
    ///
    /// - Default:
    ///     If the background is `white` or `veryLightGray`
    ///         then if the primary color uses light style return `primary`
    ///         else `tinted button color`
    ///     else `text color`
    open func underlinedTextButton(on background: RSDColorTile, state: RSDControlState) -> RSDColor {
        if background == self.pallette.grayScale.white || background == self.pallette.grayScale.veryLightGray {
            if self.pallette.primary.normal.usesLightStyle {
                return self.pallette.primary.normal.color
            }
            else {
                return self.tintedButtonColor(on: background)
            }
        }
        else {
            return textColor(on: background, for: .body)
        }
    }
    
    /// The color tile to use on a given background for a given button type.
    open func roundedButton(on background: RSDColorTile, buttonType: RSDDesignSystem.ButtonType) -> RSDColorMapping {
        if background == self.pallette.grayScale.white && buttonType == .primary {
            return self.pallette.secondary
        }
        else {
            return self.pallette.grayScale.mapping(for: .veryLightGray)
        }
    }
    
    /// The color for a rounded button for a given state and button type.
    open func roundedButton(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        let tile = self.roundedButton(on: background, buttonType: buttonType)
        switch state {
        case .highlighted:
            if tile.index > 0, tile.colorTiles[tile.index - 1] != background {
                return tile.colorTiles[tile.index - 1].color
            }
            else if tile.index + 1 < tile.colorTiles.count {
                return tile.colorTiles[tile.index + 1].color
            }
            else {
                return tile.normal.color
            }
            
        case .disabled:
            return tile.normal.color.withAlphaComponent(0.35)
            
        default:
            return tile.normal.color
        }
    }
    
    /// The text color for a rounded button.
    open func roundedButtonText(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        let tile = self.roundedButton(on: background, buttonType: buttonType)
        let color = textColor(on: tile.normal, for: .heading4)
        if state == .disabled && !tile.normal.usesLightStyle {
            return color.withAlphaComponent(0.35)
        }
        else {
            return color
        }
    }
    
    /// Checkboxes button.
    open func checkboxButton(on background: RSDColorTile, isSelected: Bool) ->
        (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
            let check = isSelected ? self.pallette.grayScale.white.color : RSDColor.clear
            if background == self.pallette.grayScale.white {
                let inner = isSelected ? self.pallette.primary.dark.color : self.pallette.grayScale.white.color
                let border = isSelected ? self.pallette.primary.normal.color : self.pallette.grayScale.veryLightGray.color
                return (check, inner, border)
            }
            else {
                let inner = isSelected ? self.pallette.secondary.normal.color : self.pallette.grayScale.white.color
                let border = isSelected ? self.pallette.secondary.light.color : self.pallette.grayScale.veryLightGray.color
                return (check, inner, border)
            }
    }
    
    
    /// MARK: Progress indicator colors
    
    /// The colors to use with a progress bar.
    /// - returns:
    ///     - filled: The fill color for the progress bar which marks progress.
    ///     - unfilled: The unfilled (background) color for the progress bar.
    open func progressBar(on background: RSDColorTile) -> (filled: RSDColor, unfilled: RSDColor) {
        return (self.pallette.accent.light.color, self.pallette.grayScale.veryLightGray.color)
    }
    
    /// The colors to use with a progress dial.
    ///
    /// - parameters:
    ///     - background: The background color tile for the view that this view "lives" in.
    ///     - style: The style of the dial. If non-nil, this will be used as the color of the inner circle.
    ///     - innerColor: The inner color of the dial set by the nib or storyboard.
    ///     - usesLightStyle: The light-style set by the nib or storyboard.
    /// - returns:
    ///     - filled: The fill color for the progress bar which marks progress.
    ///     - unfilled: The unfilled (background) color for the progress bar.
    ///     - inner: The inner color to use for the progress bar.
    open func progressDial(on background: RSDColorTile, style: Style?,
                           innerColor: RSDColor = RSDColor.clear,
                           usesLightStyle: Bool = false) -> (filled: RSDColor, unfilled: RSDColor, inner: RSDColorTile) {
        if let style = style, let mapping = self.mapping(for: style) {
            return (mapping.light.color, self.pallette.grayScale.veryLightGray.color, mapping.normal)
        }
        else if let mapping = mapping(for: innerColor) {
            return (mapping.light.color, self.pallette.grayScale.veryLightGray.color, mapping.normal)
        }
        else {
            let filled = self.pallette.accent.light.color
            let unfilled = self.pallette.grayScale.veryLightGray.color
            let lightStyle = (innerColor == RSDColor.clear) ? background.usesLightStyle : usesLightStyle
            let inner = RSDColorTile(innerColor, usesLightStyle: lightStyle)
            return (filled, unfilled, inner)
        }
    }

    
    /// MARK: Completion
    
    open func roundedCheckmark(on background: RSDColorTile) -> (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
        return (self.pallette.grayScale.white.color,
                self.pallette.secondary.normal.color,
                self.pallette.secondary.normal.color)
    }
    
    /// For a completion gradient background, what are the min and max colors?
    open func completionGradient() -> (RSDColorTile, RSDColorTile) {
        return (self.pallette.successGreen.light, self.pallette.successGreen.normal)
    }
    
    /// MARK: Choice Selection cell
    
    /// The background color tile for the table cell.
    open func tableCellBackground(on background: RSDColorTile, isSelected: Bool) -> RSDColorTile {
        return isSelected ?  self.pallette.primary.colorTiles.first! : self.pallette.grayScale.white
    }
    
    /// The background color tile for the table cell.
    open func tableSectionBackground(on background: RSDColorTile) -> RSDColorTile {
        return self.pallette.grayScale.white
    }

    /// The cell separator line for a table cell or other border.
    open var separatorLine: RSDColor {
        return self.pallette.grayScale.veryLightGray.color
    }
    
    /// The color of an underline for a text field.
    open func textFieldUnderline(on background: RSDColorTile) -> RSDColor {
        return background.usesLightStyle ? self.pallette.grayScale.darkGray.color : self.pallette.grayScale.white.color
    }
    
    
    /**
    TODO: syoung 03/18/2019 Continue defining rules in the design system for the components within a step view.
    
    /// MARK: Table step view controller - header/footer view
    
//    open var headerTitleLabel: RSDColor {
//        return RSDColor.appDarkGray
//    }
//
//    open var headerTextLabel: RSDColor {
//        return RSDColor.appDarkGray
//    }
//
//    open var headerDetailLabel: RSDColor {
//        return RSDColor.appLightGray
//    }
//
//    open var headerTitleLabelLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var headerTextLabelLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var headerDetailLabelLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var footnoteLabel: RSDColor {
//        return RSDColor.appLightGray
//    }
    
    
    /// MARK: Textfield cell
    
//    open var textFieldCellText: RSDColor {
//        return RSDColor.appDarkGray
//    }
//
//    open var textFieldCellBorder: RSDColor {
//        return RSDColor.appDarkGray
//    }
//
//    open var textFieldCellLabel: RSDColor {
//        return RSDColor.appLightGray
//    }
//
//    open var textFieldCellTextLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var textFieldCellBorderLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var textFieldCellLabelLightStyle: RSDColor {
//        return RSDColor.white
//    }
    
    /// MARK: TextView cell
    
//    open var textViewCellText: RSDColor {
//        return RSDColor.appDarkGray
//    }
//
//    open var textViewCellBorder: RSDColor {
//        return RSDColor.appLightGray
//    }
//
//    open var textViewCellLabel: RSDColor {
//        return RSDColor.appLightGray
//    }
//
//    open var textViewCellTextLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var textViewCellBorderLightStyle: RSDColor {
//        return RSDColor.white
//    }
//
//    open var textViewCellLabelLightStyle: RSDColor {
//        return RSDColor.white
//    }
 */
}
