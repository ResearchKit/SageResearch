//
//  RSDColorStyle.swift
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
import JsonModel

/// The named category or style for a given color. The use of this enum allows for coding the
/// "style" of a given view element without setting the hexcode or name for the color to use.
public enum RSDColorStyle : String, Codable, CaseIterable, StringEnumSet {
    
    /// This style *explicitly* defines the color as WHITE and should display as white whether or
    /// not the app is in dark mode.
    ///
    /// - note: Depending upon the definition of "white" as defined by the app's color rules, this
    /// may *not* be #FFFFFF.
    case white
    
    /// This style *explicitly* defines the color as BLACK and should display as black whether or
    /// not the app is in dark mode.
    ///
    /// - note: Depending upon the definition of "black" as defined by the app's color rules, this
    /// may *not* be #000000.
    case black
    
    /// The background color for the application. This will be "black" if the user has the OS in
    /// dark mode and "white" if not, or if the app does not support dark mode.
    case background
    
    /// The primary color for the application.
    case primary
    
    /// The secondary color for the application.
    case secondary
    
    /// The accent color for the application.
    case accent
    
    /// The color to use on screens and icons that indicate success.
    case successGreen
    
    /// The color to use on screens and icons that indicate an error or alert.
    case errorRed
    
    /// A custom color should be defined for a given screen or icon. For example, a picture that
    /// shows someone running outside would have a "sky blue" background color that is defined
    /// independently of the branding colors used by an app.
    case custom
}

extension RSDColorStyle : DocumentableStringEnum {
}
