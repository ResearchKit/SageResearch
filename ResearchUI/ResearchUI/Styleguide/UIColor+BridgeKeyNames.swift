//
//  UIColor+BridgeKeyNames.swift
//  ResearchUI
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

import UIKit

extension UIColor {
    
    /// Override to set a primary tint color for the app. This is used as the default dark background
    /// color for the app.
    ///
    /// Default = (80, 107, 203).
    @objc open class var primaryTintColor: UIColor {
        return UIColor(red: 80.0 / 255.0, green: 107.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
    }
    
    /// Override to set the "Light" primary tint color which can be used where the shade of the color should
    /// be lighter than the primary color, but still in the same family. This is used for selection state and
    /// the foreground on the progress bar.
    ///
    /// Default = `primaryTintColor.withSaturationMultiplier(0.5)`.
    @objc open class var lightPrimaryTintColor: UIColor {
        return primaryTintColor.withSaturationMultiplier(0.5)
    }
    
    /// Override to set the "Dark" primary tint color which can be used where the shade of the color should
    /// be darker than the primary color, but still in the same family. This is used for the background of
    /// the progress bar and a selected checkbox.
    ///
    /// Default = `primaryTintColor.withSaturationMultiplier(1.5)`.
    @objc open class var darkPrimaryTintColor: UIColor {
        return primaryTintColor.withSaturationMultiplier(1.5)
    }
    
    /// Override to set the "Very Dark" primary tint color which can be used where the shade of the color
    /// should be much darker than the primary color, but still in the same family. This is used for the
    /// background a completed progress dial on a dark background.
    ///
    /// Default = `primaryTintColor.withSaturationMultiplier(2)`.
    @objc open class var veryDarkPrimaryTintColor: UIColor {
        return primaryTintColor.withSaturationMultiplier(2)
    }
    
    /// Override to set a secondary tint color for the app. This is used for rounded buttons.
    ///
    /// Default = (255, 136, 117).
    @objc open class var secondaryTintColor: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 136.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    }
    
    /// Override to set a dark secondary tint color for the app. This is used for rounded buttons when
    /// highlighted.
    ///
    /// Default = `secondaryTintColor.withSaturationMultiplier(1.2)`.
    @objc open class var darkSecondaryTintColor: UIColor {
        return secondaryTintColor.withSaturationMultiplier(1.2)
    }
    
    /// Override to set a light secondary tint color for the app. This is used for rounded buttons when
    /// highlighted.
    ///
    /// Default = `secondaryTintColor.withSaturationMultiplier(0.5)`.
    @objc open class var lightSecondaryTintColor: UIColor {
        return secondaryTintColor.withSaturationMultiplier(0.5)
    }
    
    
    /// MARK: App background - default colors
    ///
    /// - note: The backgrounds are set to the the reverse of the `usesLightStyle` property. This property is
    /// used for *foregound* elements throughout the app to denote whether or not the element should be
    /// displayed using a dark or light color theme. For example, on a dark blue background you would set
    /// `usesLightStyle = true` to use the light elements for text, buttons, and progress indicators (white
    /// by default); while on a white background you would set `usesLightStyle = false` to use the dark
    /// elements for text, buttons, and progress indicators (dark gray or `darkPrimaryTintColor` by default).
    
    /// Background color for views that should have a light background.
    ///
    /// Default = `UIColor.white`.
    @objc open class var appBackgroundLight: UIColor {
        return UIColor.white
    }
    
    /// Background color for views that should have a dark background.
    ///
    /// Default = `UIColor.primaryTintColor`.
    @objc open class var appBackgroundDark: UIColor {
        return UIColor.primaryTintColor
    }
    
    
    /// MARK: App text - default colors
    
    /// Color for text throughout the app when presented on a dark background.
    ///
    /// Default = `UIColor.white`.
    @objc open class var appTextLight: UIColor {
        return UIColor.white
    }
    
    /// Color for text throughout the app when presented on a light background.
    ///
    /// Default = `UIColor.appDarkGray`.
    @objc open class var appTextDark: UIColor {
        return UIColor.appDarkGray
    }
    
    
    /// MARK: Shades of gray
    
    /// Override to set the dark gray color used throughout the app for elements on a light background.
    ///
    /// Default = (65, 72, 89)
    @objc open class var appDarkGray: UIColor {
        return UIColor(red: 65.0 / 255.0, green: 72.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    }
    
    /// Override to set the light gray color used throughout the app for elements on a light background.
    ///
    /// Default = (141, 147, 161)
    @objc open class var appLightGray: UIColor {
        return UIColor(red: 141.0 / 255.0, green: 147.0 / 255.0, blue: 161.0 / 255.0, alpha: 1.0)
    }
    
    /// Override to set the very light gray color used throughout the app for elements such as line
    /// separators.
    ///
    /// Default = #EDEDED (237, 237, 237).
    @objc open class var appVeryLightGray: UIColor {
        return UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    
    
    /// MARK: Status colors
    
    /// Background color for fullscreen status alert messages and quiz failure marks.
    ///
    /// Default = #FC6275 (252, 98, 117)
    @objc open class var appAlertRed: UIColor {
        return UIColor(red: 252.0 / 255.0, green: 98.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    }
    
    /// Background color for fullscreen status success messages and quiz success marks.
    ///
    /// Default = #63D49E (99, 212, 158)
    @objc open class var appSuccessGreen: UIColor {
        return UIColor(red: 99.0 / 255.0, green: 212.0 / 255.0, blue: 117.0 / 158.0, alpha: 1.0)
    }
    
    
    // -----------------------------------------------------------------------------------
    // MARK: UI Components - default theme colors
    // -----------------------------------------------------------------------------------
    
    /// MARK: Crosshatch view
    
    @objc open class var rsd_crosshatchLight: UIColor {
        return UIColor.appBackgroundLight.withAlphaComponent(0.3)
    }
    
    @objc open class var rsd_crosshatchDark: UIColor {
        return UIColor.appBackgroundDark.withAlphaComponent(0.3)
    }
    
    
    /// MARK: Status bar
    
    @objc open class var rsd_statusBarOverlayLightStyle: UIColor {
        return UIColor.black.withAlphaComponent(0.1)
    }
    
    @objc open class var rsd_statusBarOverlay: UIColor {
        return UIColor.clear
    }

    
    /// MARK: Underlined button
    
    @objc open class var rsd_underlinedButtonTextLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_underlinedButtonText: UIColor {
        return UIColor.darkPrimaryTintColor
    }
    
    
    /// MARK: Rounded button
    
    @objc open class var rsd_roundedButtonBackground: UIColor {
        return UIColor.secondaryTintColor
    }
    
    @objc open class var rsd_roundedButtonText: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_roundedButtonBackgroundLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_roundedButtonTextLightStyle: UIColor {
        return UIColor.appTextDark
    }
    
    @objc open class var rsd_secondaryRoundedButtonBackground: UIColor {
        return UIColor.appVeryLightGray
    }
    
    @objc open class var rsd_secondaryRoundedButtonText: UIColor {
        return UIColor.appTextDark
    }
    
    @objc open class var rsd_secondaryRoundedButtonBackgroundLightStyle: UIColor {
        return UIColor.appVeryLightGray
    }
    
    @objc open class var rsd_secondaryRoundedButtonTextLightStyle: UIColor {
        return UIColor.appTextDark
    }
    
    
    /// MARK: Progress bar and ring colors
    
    @objc open class var rsd_dialRing : UIColor {
        return UIColor.lightPrimaryTintColor
    }
    
    @objc open class var rsd_dialInnerBackground: UIColor {
        return UIColor.clear
    }
    
    @objc open class var rsd_dialInnerBackgroundLightStyle: UIColor {
        return UIColor.clear
    }
    
    @objc open class var rsd_dialRingBackgroundLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_dialRingBackground: UIColor {
        return UIColor.appVeryLightGray
    }
    
    @objc open class var rsd_progressBar: UIColor {
        return UIColor.lightPrimaryTintColor
    }
    
    @objc open class var rsd_progressBarBackgroundLightStyle: UIColor {
        return (darkPrimaryTintColor != rsd_progressBar) ? darkPrimaryTintColor : UIColor.white
    }
    
    @objc open class var rsd_progressBarBackground: UIColor {
        return appVeryLightGray
    }
    
    @objc open class var rsd_stepCountLabelLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_stepCountLabel: UIColor {
        return UIColor.appDarkGray
    }
    
    
    /// MARK: Completion Step
    
    /// Left side of gradient.
    ///
    /// Default = #91EDC1 (145, 237, 193).
    @objc open class var rsd_completionGradientLeft: UIColor {
        return UIColor(red: 145.0 / 255.0, green: 237.0 / 255.0, blue: 193.0 / 255.0, alpha: 1)
    }
    
    /// Right side of gradient.
    ///
    /// Default = #63D49E (99, 212, 158).
    @objc open class var rsd_completionGradientRight: UIColor {
        return UIColor(red: 99.0 / 255.0, green: 212.0 / 255.0, blue: 158.0 / 255.0, alpha: 1)
    }
    
    
    /// MARK: Table step view controller - header/footer view
    
    @objc open class var rsd_headerTitleLabel: UIColor {
        return UIColor.appDarkGray
    }
    
    @objc open class var rsd_headerTextLabel: UIColor {
        return UIColor.appDarkGray
    }
    
    @objc open class var rsd_headerDetailLabel: UIColor {
        return UIColor.appLightGray
    }
    
    @objc open class var rsd_headerTitleLabelLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_headerTextLabelLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_headerDetailLabelLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_footnoteLabel: UIColor {
        return UIColor.appLightGray
    }

    
    /// MARK: Choice Selection cell
    
    @objc open class var rsd_choiceCellBackground: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_choiceCellBackgroundHighlighted: UIColor {
        return UIColor.lightPrimaryTintColor.withAlphaComponent(0.25)
    }

    @objc open class var rsd_choiceCellLabel: UIColor {
        return UIColor.appDarkGray
    }
    
    @objc open class var rsd_choiceCellLabelHighlighted: UIColor {
        return UIColor.appDarkGray
    }
    
    @objc open class var rsd_choiceCellDetailLabel: UIColor {
        return UIColor.appLightGray
    }
    
    @objc open class var rsd_choiceCellDetailLabelHighlighted: UIColor {
        return UIColor.appLightGray
    }
    
    @objc open class var rsd_cellSeparatorLine: UIColor {
        return UIColor.appVeryLightGray
    }
    
    
    /// MARK: Textfield cell
    
    @objc open class var rsd_textFieldCellText: UIColor {
        return UIColor.appDarkGray
    }
    
    @objc open class var rsd_textFieldCellBorder: UIColor {
        return UIColor.appDarkGray
    }

    @objc open class var rsd_textFieldCellLabel: UIColor {
        return UIColor.appLightGray
    }
    
    @objc open class var rsd_textFieldCellTextLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_textFieldCellBorderLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_textFieldCellLabelLightStyle: UIColor {
        return UIColor.white
    }
}
