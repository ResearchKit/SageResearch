//
//  RSDFontData.swift
//  Research
//

import Foundation

/// The font data protocol is used to define a placeholder for font data.
public protocol RSDFontData {
    
    var fontIdentifier: String { get }
}

/// A resource font data is embedded within a resource bundle using the given platform's standard
/// asset management tools.
public protocol RSDResourceFontData : RSDFontData, RSDResourceDataInfo {
}

extension RSDResourceFontData {
    
    /// The font identifier for a resource font is the `resourceName`.
    public var fontIdentifier: String {
        return self.resourceName
    }
    
    /// The Android resource type for a font is always "font".
    public var resourceType: String? {
        return "font"
    }
}
