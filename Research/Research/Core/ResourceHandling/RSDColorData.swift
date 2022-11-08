//
//  RSDColorData.swift
//  Research
//

import Foundation

/// The color data protocol is used to define a placeholder for color data.
public protocol RSDColorData {
    
    /// A unique identifier that can be used to identify the color. Because not all colors are
    /// defined using RGB color space *and* because with Apple's dark mode model, different colors
    /// can be defined to use the same identifier depending upon their context, this is the unique
    /// identifier for the color.
    var colorIdentifier: String { get }
    
    /// Should text, images, etc. that are displayed on top of this color use light-colored elements
    /// to be accessible?
    ///
    /// For example, the color BLACK would have `usesLightStyle = true` and the color WHITE would
    /// have `usesLightStyle = false`. The use of this terminology predates Apple iOS support of
    /// "dark mode" and is related, but different from it. Instead, it is intended to allow a view
    /// to be designed with text or images that are tinted appropriately to be drawn on top of a
    ///  background of a given color independently of the dark mode setting.
    var usesLightStyle: Bool { get }
}

/// A resource color data is embedded within a resource bundle using the given platform's standard
/// asset management tools.
public protocol RSDResourceColorData : RSDColorData, RSDResourceDataInfo {
}

extension RSDResourceColorData {
    
    /// The color identifier for a resource color is the `resourceName`.
    public var colorIdentifier: String {
        return self.resourceName
    }
    
    /// The Android resource type for a color is always "color".
    public var resourceType: String? {
        return "color"
    }
}
