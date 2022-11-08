//
//  RSDColorMappingThemeElement+Platform.swift
//  ResearchPlatformContext
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import Research

extension RSDColorMappingThemeElement {
    
    #if os(watchOS) || os(macOS)
    /// **Available** for watchOS and macOS.
    ///
    /// The background color for this step. If undefined then the background color will be determined by the
    /// step view controller.
    /// - returns: The color or `nil` if undefined.
    public func backgroundColor(for placement: RSDColorPlacement, using colorRules: RSDColorRules) -> RSDColorTile? {
        let style = self.backgroundColorStyle(for: placement)
        if let tile = colorRules.mapping(for: style) {
            return tile.normal
        }
        else if let custom = self.customColorData,
            let color = RSDColor.rsd_color(named: custom.colorIdentifier, in: self.bundle) {
            return RSDColorTile(color, usesLightStyle: custom.usesLightStyle)
        }
        else {
            return nil
        }
    }
    
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// The background color for this step. If undefined then the background color will be determined by the
    /// step view controller.
    /// - returns: The color or `nil` if undefined.
    public func backgroundColor(for placement: RSDColorPlacement, using colorRules: RSDColorRules, compatibleWith traitCollection: UITraitCollection?) -> RSDColorTile? {
        let style = self.backgroundColorStyle(for: placement)
        if let tile = colorRules.mapping(for: style) {
            return tile.normal
        }
        else if let custom = self.customColorData,
            let color = RSDColor.rsd_color(named: custom.colorIdentifier, in: self.bundle, compatibleWith: traitCollection) {
            return RSDColorTile(color, usesLightStyle: custom.usesLightStyle)
        }
        else {
            return nil
        }
    }
    
    #endif
}
