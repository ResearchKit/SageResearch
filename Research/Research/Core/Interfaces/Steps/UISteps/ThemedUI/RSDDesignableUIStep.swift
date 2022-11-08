//
//  RSDDesignableUIStep.swift
//  Research
//

import Foundation

public protocol RSDDesignableUIStep : RSDUIStep {
    
    /// The image theme.
    var imageTheme: RSDImageThemeElement? { get }
    
    /// The view theme.
    var viewTheme: RSDViewThemeElement? { get }
    
    /// The color mapping.
    var colorMapping: RSDColorMappingThemeElement? { get }
}
