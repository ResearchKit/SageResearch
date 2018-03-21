//
//  UIColor+BridgeKeyNames.swift
//  ResearchStack2UI
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
    
    /// Override to set a primary tint color for the app.
    @objc open class var primaryTintColor: UIColor {
        return UIColor(hexString: "#5A478F")!
    }
    
    /// Override to set the "Light" primary tint color which can be used where the shade of the color should
    /// be lighter than the primary color. This is used for selection state and the foreground on the
    /// progress bar.
    @objc open class var lightPrimaryTintColor: UIColor {
        return UIColor(hexString: "#907FBA")!
    }
    
    /// Override to set the "Dark" primary tint color which can be used where the shade of the color should
    /// be darker than the primary color, but still in the same family. This is used for the background of
    /// the progress bar and a selected checkbox.
    @objc open class var darkPrimaryTintColor: UIColor {
        return UIColor(hexString: "#332069")!
    }
    
    /// Override to set a secondary tint color for the app.
    @objc open class var secondaryTintColor: UIColor {
        return UIColor(red: 1.0, green: 136.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    }
    
    
    // MARK: App background - default colors
    
    @objc open class var appBackgroundLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var appBackgroundDark: UIColor {
        return UIColor.primaryTintColor
    }
    
    @objc open class var appCrosshatchLight: UIColor {
        return UIColor.appBackgroundLight.withAlphaComponent(0.3)
    }
    
    @objc open class var appCrosshatchDark: UIColor {
        return UIColor.appBackgroundDark.withAlphaComponent(0.3)
    }
    
    @objc open class var rsd_statusBar: UIColor {
        return UIColor.black.withAlphaComponent(0.1)
    }
    
    // MARK: App text - default colors
    
    @objc open class var appTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var appTextDark: UIColor {
        return UIColor.appDarkGrayText
    }
    
    
    // MARK: Underlined button - default colors
    
    @objc open class var rsd_underlinedButtonTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_underlinedButtonTextDark: UIColor {
        return UIColor.appButtonTintBlue
    }
    
    
    // MARK: Rounded button - default colors
    
    @objc open class var rsd_roundedButtonBackgroundDark: UIColor {
        return UIColor.secondaryTintColor
    }
    
    @objc open class var rsd_roundedButtonTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_roundedButtonBackgroundLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_roundedButtonTextDark: UIColor {
        return UIColor.appBackgroundDark
    }
    
    
    // MARK: Dial colors
    
    @objc open class var rsd_dialRing : UIColor {
        return UIColor.lightPrimaryTintColor
    }
    
    
    // MARK: Generic step view controller - header view
    
    @objc open class var rsd_headerTitleLabelDark: UIColor {
        return UIColor.appDarkGrayText
    }
    
    @objc open class var rsd_headerTextLabelDark: UIColor {
        return UIColor.appDarkGrayText
    }
    
    @objc open class var rsd_headerDetailLabelDark: UIColor {
        return UIColor.appLightGrayText
    }
    
    @objc open class var rsd_headerTitleLabelLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_headerTextLabelLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_headerDetailLabelLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_footnoteLabel: UIColor {
        return UIColor.appLightGrayText
    }
    
    @objc open class var rsd_progressBar: UIColor {
        return UIColor.lightPrimaryTintColor
    }
    
    @objc open class var rsd_progressBarBackgroundLight: UIColor {
        return UIColor.darkPrimaryTintColor
    }
    
    @objc open class var rsd_progressBarBackgroundDark: UIColor {
        return UIColor.darkPrimaryTintColor
    }

    @objc open class var rsd_stepCountLabelLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_stepCountLabelDark: UIColor {
        return UIColor.appDarkGrayText
    }
    
    
    // MARK: Generic step view controller - choice cell
    
    @objc open class var rsd_choiceCellBackground: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_choiceCellBackgroundHighlighted: UIColor {
        return UIColor.lightPrimaryTintColor.withAlphaComponent(0.25)
    }

    @objc open class var rsd_choiceCellLabel: UIColor {
        return UIColor.appDarkGrayText
    }
    
    @objc open class var rsd_choiceCellLabelHighlighted: UIColor {
        return UIColor.appDarkGrayText
    }
    
    @objc open class var rsd_choiceCellDetailLabel: UIColor {
        return UIColor.appLightGrayText
    }
    
    @objc open class var rsd_choiceCellDetailLabelHighlighted: UIColor {
        return UIColor.appLightGrayText
    }
    
    @objc open class var rsd_cellSeparatorLine: UIColor {
        return UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    
    
    // MARK: Generic step view controller - text field cell
    
    @objc open class var rsd_textFieldCellText: UIColor {
        return UIColor.appDarkGrayText
    }
    
    @objc open class var rsd_textFieldCellBorder: UIColor {
        return UIColor.appDarkGrayText
    }

    @objc open class var rsd_textFieldCellLabel: UIColor {
        return UIColor.appLightGrayText
    }
    
    
    // MARK: Shared style colors
    
    @objc open class var appDarkGrayText: UIColor {
        return UIColor(red: 65.0 / 255.0, green: 72.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appLightGrayText: UIColor {
        return UIColor(red: 141.0 / 255.0, green: 147.0 / 255.0, blue: 161.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appButtonTintBlue: UIColor {
        return UIColor(red: 33.0 / 255.0, green: 150.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appTintGreen: UIColor {
        return UIColor(red: 94.0 / 255.0, green: 173.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appSoftGreen: UIColor {
        return UIColor(red: 104.0 / 255.0, green: 191.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)
    }
}
