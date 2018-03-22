//
//  UIColor+CRFDefaults.swift
//  CardiorespiratoryFitness
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

import Foundation
import ResearchStack2UI

extension UIColor {
    
    // MARK: Primary Tint
    
    @objc open class var primaryTintColor: UIColor {
        return UIColor(named: "dodgerBlue", in: Bundle(for: CRFFactory.self), compatibleWith: nil)!
    }
    
    // MARK: Secondary Tint
    
    @objc open class var secondaryTintColor: UIColor {
        return UIColor(named: "salmon", in: Bundle(for: CRFFactory.self), compatibleWith: nil)!
    }
    
    // MARK: Progress indicators
    
    @objc open class var rsd_dialRing : UIColor {
        return UIColor(named: "tealGreen", in: Bundle(for: CRFFactory.self), compatibleWith: nil)!
    }
    
    @objc open class var rsd_dialRingBackgroundLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_dialRingBackground: UIColor {
        return UIColor.appVeryLightGray
    }
    
    @objc open class var rsd_progressBarBackgroundLightStyle: UIColor {
        return UIColor.white
    }
    
    @objc open class var rsd_progressBarBackground: UIColor {
        return UIColor.appVeryLightGray
    }
}
