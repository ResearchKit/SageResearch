//
//  RSDColorMappingThemeElement.swift
//  Research
//

import Foundation
import JsonModel

/// The color mapping theme element defines the colors to use on a given screen. Typically, this
/// includes the background color for the header or a background color that is applied to the
/// full screen.
public protocol RSDColorMappingThemeElement : ResourceInfo {
    
    /// The custom color data needed to get a background color that is not one of the standard
    /// colors (primary, secondary, accent, system background, black, white).
    ///
    /// - seealso: `backgroundColorStyle(for:)`
    var customColorData: RSDColorData? { get }
    
    /// The background color style for a given placement.
    /// - parameter placement: The placement of the view element.
    /// - returns: For a given placement (header, body, footer), returns the color style
    func backgroundColorStyle(for placement: RSDColorPlacement) -> RSDColorStyle
}
