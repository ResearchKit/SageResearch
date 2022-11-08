//
//  RSDColorStyle.swift
//  Research
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
