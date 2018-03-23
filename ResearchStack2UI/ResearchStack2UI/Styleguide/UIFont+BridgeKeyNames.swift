//
//  UIFont+BridgeKeyNames.swift
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

extension UIFont {

    // MARK: Rounded button
    
    @objc open class var roundedButtonTitle: UIFont {
        return UIFont.systemFont(ofSize: 19.0, weight: .semibold)
    }
    
    // MARK: Generic step view controller - header view labels

    @objc open class var rsd_headerTitleLabel: UIFont {
        return UIFont.systemFont(ofSize: 24.0, weight: .bold)
    }
    
    @objc open class var rsd_headerTextLabel: UIFont {
        return UIFont.systemFont(ofSize: 18.0, weight: .semibold)
    }
    
    @objc open class var rsd_headerDetailLabel: UIFont {
        return UIFont.italicSystemFont(ofSize: 16.0)
    }
    
    @objc open class var rsd_footnoteLabel: UIFont {
        return UIFont.italicSystemFont(ofSize: 16.0)
    }

    @objc open class var rsd_stepCountLabel: UIFont {
        return UIFont.systemFont(ofSize: 12.0, weight: .bold)
    }
    
    @objc open class var rsd_boldStepCountLabel: UIFont {
        return UIFont.systemFont(ofSize: 14.0, weight: .bold)
    }
    
    // MARK: Generic step view controller - choice cell

    @objc open class var rsd_choiceCellLabel: UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .regular)
    }
    
    @objc open class var rsd_choiceCellDetailLabel: UIFont {
        return UIFont.rsd_choiceCellLabel
    }
    
    @objc open class var rsd_choiceSectionLabel: UIFont {
        return UIFont.systemFont(ofSize: 18.0, weight: .bold)
    }
    
    @objc open class var rsd_choiceSectionDetailLabel: UIFont {
        return UIFont.rsd_choiceCellLabel
    }
    
    // MARK: Generic step view controller - text field cell

    @objc open class var rsd_textFieldCellLabel: UIFont {
        return UIFont.systemFont(ofSize: 15.0, weight: .regular)
    }

    @objc open class var rsd_textFieldCellText: UIFont {
        return UIFont.systemFont(ofSize: 19.0, weight: .regular)
    }

    @objc open class var rsd_textFieldFeaturedCellText: UIFont {
        return UIFont.systemFont(ofSize: 33.0, weight: .regular)
    }
}
