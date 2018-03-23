//
//  UIColor+StyleGuide.swift
//  RSDCatalog
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import ResearchStack2UI

/// This extension will override the color values set ResearchStack2UI.
extension UIColor {
    
    
    // MARK: Primary Tint
    
    @objc open class var primaryTintColor: UIColor {
        return UIColor.royal500
    }
    
    @objc open class var lightPrimaryTintColor: UIColor {
        return UIColor.royal400
    }
    
    @objc open class var darkPrimaryTintColor: UIColor {
        return UIColor.royal600
    }
    
    @objc open class var veryDarkPrimaryTintColor: UIColor {
        return UIColor.royal700
    }
    
    // MARK: Secondary Tint
    
    @objc open class var secondaryTintColor: UIColor {
        return UIColor.butterscotch500
    }
    
    @objc open class var darkSecondaryTintColor: UIColor {
        return UIColor.butterscotch600
    }
    
    // MARK: Override of specific elements
    
    @objc open class var rsd_roundedButtonText: UIColor {
        return UIColor.appTextDark
    }
    
    
    // MARK: Royal Purple
    
    //    Light Purple (filled progress bar, etc.):
    //    Royal 400
    //    #907FBA
    //    144, 127, 186
    class var royal400: UIColor {
        return UIColor(red: 144.0 / 255.0, green: 127.0 / 255.0, blue: 186.0 / 255.0, alpha: 1)
    }
    
    //    Primary Color (action bars, fills, background, certain selections,
    //    Royal 500
    //    #5A478F
    //    90, 71, 143
    class var royal500: UIColor {
        return UIColor(red: 90.0 / 255.0, green: 71.0 / 255.0, blue: 143.0 / 255.0, alpha: 1)
    }
    
    //    Accent Colors:
    //    Dark Purple (unfilled progress bar, selected radio button fill, etc.):
    //    Royal 600
    //    #47337D
    //    71, 51, 125
    class var royal600: UIColor {
        return UIColor(red: 71.0 / 255.0, green: 51.0 / 255.0, blue: 125.0 / 255.0, alpha: 1)
    }
    
    //    Large Circle Progress Bar Within Activity Complete:
    //    Royal 700
    //    #332069
    //    51, 32, 105
    class var royal700: UIColor {
        return UIColor(red: 51.0 / 255.0, green: 32.0 / 255.0, blue: 105.0 / 255.0, alpha: 1)
    }
    
    // MARK: Butterscotch
    
    //    Secondary Color:
    //    Butterscotch 500
    //    #F5B33C
    //    245, 179, 60
    class var butterscotch500: UIColor {
        return UIColor(red: 245.0 / 255.0, green: 179.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
    }
    
    //    Tap Pressed State:
    //    Butterscotch 600
    //    #DE9A1F
    //    222, 154, 31
    class var butterscotch600: UIColor {
        return UIColor(red: 222.0 / 255.0, green: 154.0 / 255.0, blue: 31.0 / 255.0, alpha: 1)
    }
    
}
