//
//  UIColor+BridgeKeyNames.swift
//  ResearchSuite-UI
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
    
    /**
     Override to set a primary tint color for the app.
     */
    @objc open class var primaryTintColor: UIColor? {
        return nil
    }
    
    /**
     Override to set a secondary tint color for the app.
     */
    @objc open class var secondaryTintColor: UIColor? {
        return nil
    }
    
    /**
     The green tint color is used for red buttons and checkmarks.
     */
    @objc open class var greenTintColor: UIColor {
        return UIColor(red:0.267, green:0.824, blue:0.306, alpha:1.000)
    }
    
    /**
     The red tint color is used for red buttons and warnings.
     */
    @objc open class var redTintColor: UIColor {
        return UIColor.red
    }
    
    // MARK: App background - default colors
    
    @objc open class var appBackgroundLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var appBackgroundDark: UIColor {
        return UIColor.primaryTintColor ?? UIColor(red: 65.0 / 255.0, green: 72.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appBackgroundGreen: UIColor {
        return UIColor.greenTintColor
    }
    
    @objc open class var appCrosshatchLight: UIColor {
        return UIColor.appBackgroundLight.withAlphaComponent(0.3)
    }
    
    @objc open class var appCrosshatchDark: UIColor {
        return UIColor.appBackgroundDark.withAlphaComponent(0.3)
    }
    
    @objc open class var appCrosshatchGreen: UIColor {
        return UIColor.appBackgroundGreen.withAlphaComponent(0.3)
    }
    
    
    // MARK: App text - default colors
    
    @objc open class var appTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var appTextDark: UIColor {
        return UIColor(red: 65.0 / 255.0, green: 72.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var appTextGreen: UIColor {
        return UIColor.white
    }
    
    
    // MARK: Underlined button - default colors
    
    @objc open class var underlinedButtonTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var underlinedButtonTextDark: UIColor {
        return UIColor(red: 73.0 / 255.0, green: 91.0 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)
    }
    
    
    // MARK: Rounded button - default colors
    
    @objc open class var roundedButtonBackgroundDark: UIColor {
        return UIColor(red: 1.0, green: 136.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var roundedButtonShadowDark: UIColor {
        return UIColor(red: 242.0 / 255.0, green: 128.0 / 255.0, blue: 111.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var roundedButtonTextLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var roundedButtonBackgroundLight: UIColor {
        return UIColor.white
    }
    
    @objc open class var roundedButtonShadowLight: UIColor {
        return UIColor(white: 245.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var roundedButtonTextDark: UIColor {
        return UIColor.appBackgroundDark
    }
    
    // MARK: Generic step view controller - header view
    
    @objc open class var headerViewHeaderLabel: UIColor {
        return UIColor.darkGray
    }
    
    @objc open class var headerViewDetailsLabel: UIColor {
        return UIColor.gray
    }
    
    @objc open class var headerViewPromptLabel: UIColor {
        return UIColor.lightGray
    }
    
    @objc open class var headerViewProgressBar: UIColor {
        return UIColor(red: 103.0 / 255.0, green: 191.0 / 255.0, blue: 95.0 / 255.0, alpha: 1.0)
    }
    
    @objc open class var headerViewProgressBackground: UIColor {
        return UIColor.darkGray
    }

    @objc open class var headerViewStepCountLabel: UIColor {
        return UIColor.darkGray
    }
    
    // MARK: Generic step view controller - choice cell
    
    @objc open class var choiceCellBackground: UIColor {
        return UIColor.white
    }
    
    @objc open class var choiceCellBackgroundHighlighted: UIColor {
        return UIColor.lightGray
    }

    @objc open class var choiceCellLabel: UIColor {
        return UIColor.darkGray
    }
    
    @objc open class var choiceCellLabelHighlighted: UIColor {
        return UIColor.darkGray
    }
    
    // MARK: Generic step view controller - text field cell
    
    @objc open class var textFieldCellText: UIColor {
        return UIColor.darkGray
    }
    
    @objc open class var textFieldCellBorder: UIColor {
        return UIColor.darkGray
    }

    @objc open class var textFieldCellLabel: UIColor {
        return UIColor.lightGray
    }
}
