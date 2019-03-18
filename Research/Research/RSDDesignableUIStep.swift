//
//  RSDDesignableUIStep.swift
//  Research
//
//  Created by Shannon Young on 3/18/19.
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
//

import Foundation

public protocol RSDDesignableUIStep : RSDUIStep {
    
    /// The image theme.
    var image: RSDImageThemeElement? { get }
    
    /// The view theme.
    var viewTheme: RSDViewThemeElement? { get }
    
    /// The color mapping.
    var colorMapping: RSDColorMappingThemeElement? { get }
}

/// `RSDUIThemeElement` is used to tell the application UI view controllers how to style a given step.
public protocol RSDUIThemeElement {
    
    /// The resource bundle to use for fetching the theme elements.
    var bundle: Bundle? { get }
}
