//
//  RSDColorRules.swift
//  ResearchPlatformContext
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

#if os(iOS) || os(tvOS)
import UIKit
#endif
import Research

public enum RSDControlState : UInt {
    case normal = 0, highlighted = 1, disabled = 2, selected = 4
    
    #if os(iOS)
    public init(controlState: UIControl.State) {
        self = RSDControlState(rawValue: controlState.rawValue) ?? .normal
    }
    
    public var controlState: UIControl.State {
        return UIControl.State(rawValue: self.rawValue)
    }
    #endif
}


/// The color rules object is a concrete implementation of the design rules used for a given version of the
/// SageResearch frameworks. A module can use this class as-is or override the class to enforce a set of rules
/// pinned to the tasks included within a module. This is important to allow a module to be validated against
/// a given UI/UX. The frameworks can later change to reflect new devices, OS changes, and design system
/// updates to incorporate the results of more design studies.
open class RSDColorRules  {
    
    /// The version for the color rules. If the design rules change with future versions of this framework,
    /// then the current version number should be rev'd as well and any changes to this rule set that are not
    /// additive include logic to return the previous rules associated with a previous version.
    open private(set) var version: Int

    /// The color palette for this color design.
    open var palette: RSDColorPalette! {
        get {
            return _palette
        }
        set {
            guard newValue != nil else { return }
            _palette = newValue
            self.severityColorScale.grayScale = newValue.grayScale
        }
    }
    private var _palette: RSDColorPalette
    
    public init(palette: RSDColorPalette, version: Int? = nil) {
        self._palette = palette
        self.version = version ?? palette.version ?? RSDColorMatrix.shared.currentVersion
    }
    
    
    /// MARK: Default colors
    
    /// The default color to use for a given color style.
    /// - parameter style: The color style.
    /// - returns: The color mapping for that style.
    open func mapping(for style: RSDColorStyle) -> RSDColorMapping? {
        switch style {
        case .background:
            // TODO: syoung 12/10/2019 Support dark mode.
            return self.palette.grayScale.mapping(forShade: .white)
        case .black:
            return self.palette.grayScale.mapping(forColor: .black)
        case .white:
            return self.palette.grayScale.mapping(forShade: .white)
        case .primary:
            return self.palette.primary
        case .secondary:
            return self.palette.secondary
        case .accent:
            return self.palette.accent
        case .successGreen:
            return self.palette.successGreen
        case .errorRed:
            return self.palette.errorRed
        case .custom:
            return nil
        }
    }
    
    /// Look in the palette for a mapping for the given color. This method is used to allow returning a color
    /// mapping from a background color.
    ///
    /// - note: The primary use-case for this is where an app defines a view controller in a storyboard and
    /// uses @IBDesignable to render the screen in the storyboard. This allows setting colors by using the
    /// defaults and getting the color mapping from the background.
    ///
    /// - parameter style: The color (UIColor or NSColor) that maps to one of the colors defined in the palette.
    /// - returns: The color mapping if found.
    open func mapping(for color: RSDColor) -> RSDColorMapping? {
        let families: [RSDColorFamily] = [_palette.grayScale, _palette.primary.swatch, _palette.secondary.swatch, _palette.accent.swatch, _palette.successGreen.swatch, _palette.errorRed.swatch]
        for family in families {
            if let mapping = family.mapping(forColor: color) {
                return mapping
            }
        }
        return nil
    }

        
    /// Background color for views that should have a light background.
    ///
    /// - Default: `white`
    open var backgroundLight: RSDColorTile {
        return self.palette.grayScale.white
    }
    
    /// Background color for views that should use the primary color tile for the background.
    ///
    /// - Default: `primary`
    open var backgroundPrimary: RSDColorTile {
        return self.palette.primary.normal
    }
    
    /// Tinted image icon color on a given background. Typically, this is used in a collection or table view.
    ///
    /// - Default:
    /// ```
    ///     If the background uses light style
    ///         then `white`
    ///         else `accent`
    /// ```
    open func tintedIconColor(on background: RSDColorTile) -> RSDColor {
        if background.usesLightStyle {
            return self.palette.grayScale.white.color
        }
        else {
            return self.palette.accent.normal.color
        }
    }

    /// Color for text throughout the app.
    ///
    /// - Default: (version 0)
    /// ```
    ///     If the background uses light style then `white`
    ///     else `veryDarkGray`
    /// ```
    ///
    /// - Default: (version 1)
    /// ```
    ///     If the background uses light style then `text.light`
    ///     else if this is detail text then `text.medium`
    ///     else `text.dark`
    /// ```
    ///
    /// - Default: (version 2)
    /// ```
    ///     See the Sage Design System table.
    ///     https://www.figma.com/file/nvoSigSxbFuWzGXgUZAf8M/DigitalHealth_DesignSystem-Master?node-id=3837%3A16223
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the text UI element.
    ///     - textType: The type size of the UI element.
    /// - returns: The text color to use.
    open func textColor(on background: RSDColorTile, for textType: RSDDesignSystem.TextType) -> RSDColor {
        if self.palette.text.colorTiles.count == 5 {
            if background.usesLightStyle {
                return self.palette.text.veryLight.color
            }
            else {
                switch textType {
                case .hint:
                    return self.palette.text.normal.color
                case .bodyDetail, .microDetail:
                    return self.palette.text.dark.color
                default:
                    return self.palette.text.veryDark.color
                }
            }
        }
        else if self.palette.text.colorTiles.count > 0 {
            // Version 1 only has 3 colors defined, so need to match within that.
            if background.usesLightStyle {
                return self.palette.text.colorTiles.first!.color
            }
            else {
                switch textType {
                case .small, .bodyDetail, .hint, .microDetail:
                    return self.palette.text.normal.color
                default:
                    return self.palette.text.colorTiles.last!.color
                }
            }
        }
        else {
            // Version 0 does not have a text palette so use the gray scale.
            if background.usesLightStyle {
                return self.palette.grayScale.white.color
            }
            else {
                return self.palette.grayScale.black.color
            }
        }
    }
    
    
    /// MARK: Buttons
    
    /// Tinted button color on a given background.
    ///
    /// - Default:
    /// ```
    ///     If the background uses light style then `white`
    ///     else if the background is the primary palette color then `secondary`
    ///     else `veryDarkGray`
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the text UI element.
    /// - returns: The color to use for tinted buttons.
    open func tintedButtonColor(on background: RSDColorTile) -> RSDColor {
        if version == 0 {
            if background.usesLightStyle {
                return self.palette.grayScale.white.color
            }
            else if background == self.palette.primary.normal ||
                background == self.palette.grayScale.white ||
                background == self.palette.grayScale.veryLightGray {
                return self.palette.secondary.normal.color
            }
            else {
                return self.palette.grayScale.veryDarkGray.color
            }
        }
        else {
            return background.usesLightStyle ? self.palette.text.veryLight.color : self.palette.text.veryDark.color
        }
    }
    
    /// Underlined text button.
    ///
    /// - Default: (version 0)
    /// ```
    ///     If the background is `white` *and* the primary color uses light style then
    ///         `primary`
    ///     Else
    ///         `text color`
    /// ```
    ///
    /// - Default: (version 1)
    /// ```
    ///     The text color for `body` text on the given background.
    /// ```
    ///
    /// - seealso: `textColor(on:, for:)`
    ///
    /// - parameters:
    ///     - background: The background of the text button.
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the underlined text button.
    open func underlinedTextButton(on background: RSDColorTile, state: RSDControlState) -> RSDColor {
        switch self.version {
        case 0:
            if (background == self.palette.grayScale.white),
                self.palette.primary.normal.usesLightStyle {
                return self.palette.primary.normal.color
            }
            else {
                return textColor(on: background, for: .body)
            }
            
        default:
            return textColor(on: background, for: .body)
        }
    }
    
    /// The color mapping to use on a given background for a given button type.
    ///
    /// - Default:
    /// ```
    ///     If the button type is `primary` then
    ///         if the background is `white` then `secondary` else `white`
    ///     else `veryLightGray` color
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    /// - returns: The color mapping to use for a rounded button.
    open func roundedButton(on background: RSDColorTile, buttonType: RSDDesignSystem.ButtonType) -> RSDColorMapping {
        if buttonType == .primary {
            return (background == self.palette.grayScale.white) ? self.palette.secondary :
                self.palette.grayScale.mapping(forShade: .white)
        }
        else {
            return self.palette.grayScale.mapping(forShade: .veryLightGray)
        }
    }
    
    /// The color for a rounded button for a given state and button type.
    ///
    /// - Default:
    /// ```
    ///     If selected AND secondary
    ///         then the primary color at 25% opacity
    ///
    ///     Else
    ///
    ///     Get the "normal" tile color for the button type. This depends upon whether or not the button is
    ///     a primary button and whether or not it is displayed on a white background.
    ///
    ///     If highlighted OR selected
    ///         then if the tile is `veryLight` then one shade darker
    ///         else one shade lighter
    ///     Else If disabled
    ///         then 35% opacity
    ///     Else
    ///         return the color tile as-is.
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the background of a rounded button.
    open func roundedButton(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        if state == .selected && buttonType == .secondary {
            return self.palette.primary.normal.color.withAlphaComponent(0.25)
        }
        else {
            let tile = self.roundedButton(on: background, buttonType: buttonType)
            return coloredButton(on: background, forMapping: tile, forState: state)
        }
    }
    
    /// The color for the background of a colored button for a given state and button type.
    ///
    /// - Default:
    /// ```
    ///     Get the "normal" tile color for the button type. This depends upon whether or not the button is
    ///     a primary button and whether or not it is displayed on a white background.
    ///
    ///     If highlighted OR selected
    ///         then if the tile is `veryLight` then one shade darker
    ///         else one shade lighter
    ///     If disabled
    ///         then 35% opacity
    ///     Else
    ///         return the color tile as-is.
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - tile: The default color tile for the button background.
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the background of a rounded button.
    open func coloredButton(on background: RSDColorTile, forMapping tile:RSDColorMapping, forState state: RSDControlState) -> RSDColor {
        
        switch state {
        case .highlighted, .selected:
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
    ///
    /// - Default:
    /// ```
    ///     Get the "normal" tile color for the button type. This depends upon whether or not the button is
    ///     a primary button and whether or not it is displayed on a white background.
    ///
    ///     Next, get the text color to use on the returned tile color.
    ///
    ///     If state is `disabled` and *not* uses light style
    ///         then 35% opacity
    ///     Else
    ///         return the text color
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the button.
    ///     - buttonType: The type of button (primary or secondary).
    ///     - state: The UI control state of the button.
    /// - returns: The color to use for the text of a rounded button.
    open func roundedButtonText(on background: RSDColorTile, with buttonType: RSDDesignSystem.ButtonType, forState state: RSDControlState) -> RSDColor {
        let tile = self.roundedButton(on: background, buttonType: buttonType)
        let color = textColor(on: tile.normal, for: .body)
        if state == .disabled && !tile.normal.usesLightStyle {
            return color.withAlphaComponent(0.35)
        }
        else {
            return color
        }
    }
    
    /// Checkbox button.
    ///
    /// - Default:
    /// ```
    ///     First, determine the inner color of the checkmark box using rules where
    ///     If selected
    ///         If the background is white then
    ///             inner = `primary.dark`
    ///             border = `primary`
    ///         Else
    ///             inner = `secondary`
    ///             border = `secondary.light`
    ///     Else
    ///         inner = `white`
    ///         border = `lightGray`
    ///
    ///     Next, the checkmark color is
    ///     If the inner color uses light style then `white` else `veryDarkGray`
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the checkbox.
    ///     - isSelected: Whether or not the checkbox is selected.
    /// - returns:
    ///     - checkmark: The checkmark color.
    //      - background: The background (fill) color.
    //      - border: The border color.
    open func checkboxButton(on background: RSDColorTile, isSelected: Bool) ->
        (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
            
            let inner: RSDColorTile
            let border: RSDColor
            
            if isSelected {
                if background == self.palette.grayScale.white {
                    inner = self.palette.primary.dark
                    border = self.palette.primary.normal.color
                }
                else {
                    inner = self.palette.secondary.normal
                    border = self.palette.secondary.light.color
                }
            }
            else {
                inner = self.palette.grayScale.white
                border = self.palette.grayScale.lightGray.color
            }
            
            let check = isSelected
                ? (inner.usesLightStyle ?  self.palette.grayScale.white.color : self.palette.grayScale.veryDarkGray.color)
                : RSDColor.clear
            
            return (check, inner.color, border)
    }
    
    
    /// MARK: Progress indicator colors
    
    /// The colors to use with a progress bar.
    ///
    /// - Default:
    /// ```
    ///     filled = `accent`
    ///     unfilled = `veryLightGray`
    /// ```
    ///
    /// - parameter background: The background for the progress bar.
    /// - returns:
    ///     - filled: The fill color for the progress bar which marks progress.
    ///     - unfilled: The unfilled (background) color for the progress bar.
    open func progressBar(on background: RSDColorTile) -> (filled: RSDColor, unfilled: RSDColor) {
        return (self.palette.accent.normal.color, self.palette.grayScale.veryLightGray.color)
    }
    
    /// The colors to use with a progress dial.
    ///
    /// - Default:
    /// ```
    ///     `unfilled` is always `veryLightGray`
    ///
    ///     If the style is defined then
    ///         filled = `style.light`
    ///         inner = `style`
    ///
    ///     Else if the inner color is `white`
    ///         filled = `accent`
    ///         inner = `white`
    ///
    ///     Else if the inner color is `clear`
    ///         filled = `accent`
    ///         inner = `clear` with light style of the background
    ///
    ///     Else
    ///         filled = `inner.light`
    ///         inner = inner
    /// ```
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
    open func progressDial(on background: RSDColorTile,
                           style: RSDColorStyle? = nil,
                           innerColor: RSDColor = RSDColor.clear,
                           usesLightStyle: Bool = false) -> (filled: RSDColor, unfilled: RSDColor, inner: RSDColorTile) {
        
        let filled: RSDColor
        let unfilled: RSDColor = self.palette.grayScale.veryLightGray.color
        let inner: RSDColorTile
        
        if let style = style, let mapping = self.mapping(for: style) {
            filled = mapping.light.color
            inner = mapping.normal
        }
        else if let mapping = mapping(for: innerColor), mapping.colorTiles != palette.grayScale.colorTiles {
            filled = mapping.light.color
            inner = mapping.normal
        }
        else {
            filled = self.palette.accent.normal.color
            let lightStyle = (innerColor == RSDColor.clear) ? background.usesLightStyle : usesLightStyle
            inner = RSDColorTile(innerColor, usesLightStyle: lightStyle)
        }
        return (filled, unfilled, inner)
    }

    
    /// MARK: Completion
    
    /// Rounded checkmarks are drawn UI elements of a checkmark with a solid background.
    ///
    /// - Default:
    /// ```
    ///     The background (fill) and border (stroke) both use `secondary` color
    ///
    ///     If `secondary` uses light style then
    ///         checkmark = `white`
    ///     Else
    ///         checkmark = `veryDarkGray`
    /// ```
    ///
    /// - parameter background: The background of the checkbox.
    /// - returns:
    ///     - checkmark: The checkmark color.
    //      - background: The background (fill) color.
    //      - border: The border color.
    open func roundedCheckmark(on background: RSDColorTile) -> (checkmark: RSDColor, background: RSDColor, border: RSDColor) {
        let fill = self.palette.secondary.normal
        let checkmark = fill.usesLightStyle ? self.palette.grayScale.white.color : self.palette.grayScale.veryDarkGray.color
        return (checkmark, fill.color, fill.color)
    }
    
    /// For a completion gradient background, what are the min and max colors?
    ///
    /// - Default: `successGreen.light` and `successGreen`
    ///
    /// - returns:
    ///     - 0: The min color tile.
    ///     - 1: The max color tile.
    open func completionGradient() -> (RSDColorTile, RSDColorTile) {
        return (self.palette.successGreen.light, self.palette.successGreen.normal)
    }
    
    /// MARK: Choice Selection cell
    
    /// The background color tile for the table cell.
    ///
    /// - Default:
    /// ```
    ///     If selected
    ///         then lightest color tile within the same family as the primary color
    ///     Else
    ///         `white`
    /// ```
    ///
    /// - parameters:
    ///     - background: The background of the table.
    ///     - isSelected: Whether or not the cell is selected.
    /// - returns: The color tile for the background of the cell.
    open func tableCellBackground(on background: RSDColorTile, isSelected: Bool) -> RSDColorTile {
        if isSelected {
            let baseColor = self.palette.primary.normal.usesLightStyle ? self.palette.primary : self.palette.accent
            return baseColor.veryLight
        }
        else {
            return self.palette.grayScale.white
        }
    }
    
    /// The background color tile for the table section header.
    ///
    /// - Default: `white`
    ///
    /// - parameter background: The background of the table.
    /// - returns: The color tile for the background of the section header.
    open func tableSectionBackground(on background: RSDColorTile) -> RSDColorTile {
        return self.palette.grayScale.white
    }

    /// The cell separator line for a table cell or other border.
    ///
    /// - Default: `veryLightGray`
    open var separatorLine: RSDColor {
        return self.palette.grayScale.veryLightGray.color
    }
    
    /// The color of an underline for a text field.
    ///
    /// - Default: `accent`
    ///
    /// - parameter background: The background of the table cell.
    /// - returns: The color of the underline.
    open func textFieldUnderline(on background: RSDColorTile) -> RSDColor {
        return self.palette.accent.normal.color
    }
    
    
    // MARK: Severity colors used for showing a scale from "normal - severe"
    
    /// The severity color scale to use for buttons and graphics in this app.
    open var severityColorScale : RSDSeverityColorScale = RSDSeverityColorScale()
}

/// Color rules for defining a scale for a series of colors.
open class RSDSeverityColorScale {
    
    /// A numeric scale of 0-3 for the severity of a symptom or condition.
    public enum Scale : Int, Codable {
        case none = 0, mild, moderate, severe
    }
    
    /// The color palette that backs this rule.
    lazy public var grayScale: RSDGrayScale = RSDDesignSystem.shared.colorRules.palette.grayScale
    
    /// The fill color of the button representing this scale value.
    /// - parameters:
    ///     - value: The scale value.
    ///     - isSelected: Whether or not the button is selected.
    /// - returns: The fill color for the button.
    open func fill(for value: Int, isSelected: Bool) -> RSDColor {
        guard isSelected, value >= 0, value < severityFill.count
            else {
                return grayScale.white.color
        }
        return severityFill[value]
    }
    
    /// The stroke color of the button representing this scale value.
    /// - parameters:
    ///     - value: The scale value.
    ///     - isSelected: Whether or not the button is selected.
    /// - returns: The stroke color for the button.
    open func stroke(for value: Int, isSelected: Bool) -> RSDColor {
        guard isSelected, value >= 0, value < severityFill.count
            else {
                return grayScale.lightGray.color
        }
        return severityStroke[value]
    }
    
    /// The fill colors for the severity toggle.
    let severityFill: [RSDColor] = {
        return [
            RSDColor(red: 232 / 255.0, green: 250.0 / 255.0, blue: 232.0 / 255.0, alpha: 1),
            RSDColor(red: 255.0 / 255.0, green: 240.0 / 255.0, blue: 212.0 / 255.0, alpha: 1),
            RSDColor(red: 255.0 / 255.0, green: 232.0 / 255.0, blue: 214.0 / 255.0, alpha: 1),
            RSDColor(red: 252.0 / 255.0, green: 233.0 / 255.0, blue: 230.0 / 255.0, alpha: 1)
        ]
    }()
    
    /// The stroke colors for the severity toggle.
    let severityStroke: [RSDColor] = {
        return [
            RSDColor(red: 192.0 / 255.0, green: 235.0 / 255.0, blue: 192.0 / 255.0, alpha: 1),
            RSDColor(red: 255.0 / 255.0, green: 226.0 / 255.0, blue: 173.0 / 255.0, alpha: 1),
            RSDColor(red: 250.0 / 255.0, green: 207.0 / 255.0, blue: 175.0 / 255.0, alpha: 1),
            RSDColor(red: 255.0 / 255.0, green: 197.0 / 255.0, blue: 189.0 / 255.0, alpha: 1)
        ]
    }()
}
