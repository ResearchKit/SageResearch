//
//  RSDColorPalette.swift
//  ResearchPlatformContext
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

extension CodingUserInfoKey {
    
    /// The key for the current step identifier to use when decoding a form step input field that should
    /// inherit the step identifier from the parent step.
    fileprivate static let paletteVersion = CodingUserInfoKey(rawValue: "RSDColorPalette.version")!
}


/// The color palette struct is used to describe the color palette for a given application.
/// This is intended for applications that use the Sage Design System.
///
/// - seealso: https://github.com/Sage-Bionetworks/DesignSystem
public struct RSDColorPalette : Codable, Equatable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case version, primary, secondary, accent, successGreen, errorRed, grayScale, text
    }
    
    /// The version for this color palette.
    public var version: Int?
    
    /// The primary color for the application.
    public var primary: RSDColorKey
    
    /// The secondary color for the application.
    public var secondary: RSDColorKey
    
    /// The accent color for the application.
    public var accent: RSDColorKey

    /// The color to use for "Success" green views and iconography.
    public var successGreen: RSDColorKey
    
    /// The color to use for "Error" red views and iconography.
    public var errorRed: RSDColorKey
    
    /// The gray scale values to use for the application.
    public var grayScale: RSDGrayScale
    
    /// The color family to use for text.
    public var text: RSDColorKey
    
    /// Wireframe color palette.
    public static let wireframe = RSDColorPalette(primaryName: .palette(.stone), .veryLight,
                                                   secondaryName: .palette(.slate), .dark,
                                                   accentName: .palette(.cloud), .dark)
    
    public static let spring = RSDColorPalette(primaryName: .palette(.royal), .light,
                                                   secondaryName: .palette(.rose), .medium,
                                                   accentName: .palette(.apricot), .medium)
    
    public static let beach = RSDColorPalette(primaryName: .palette(.powder), .light,
                                                secondaryName: .palette(.fern), .medium,
                                                accentName: .palette(.butterscotch), .medium)
    
    public static let twilight = RSDColorPalette(primaryName: .palette(.royal), .dark,
                                                secondaryName: .palette(.turquoise), .medium,
                                                accentName: .palette(.butterscotch), .medium)
    
    public static let midnight = RSDColorPalette(primaryName: .palette(.royal), .veryDark,
                                                 secondaryName: .palette(.lavender), .dark,
                                                 accentName: .palette(.rose), .veryDark)
    
    public static let test = RSDColorPalette(primaryName: .palette(.stone), .dark,
                                             secondaryName: .palette(.slate), .dark,
                                             accentName: .palette(.cloud), .dark,
                                             grayScale: .test)
    
    private init(primaryName: RSDReservedColorName, _ primaryShade: RSDColorSwatch.Shade,
                 secondaryName: RSDReservedColorName, _ secondaryShade: RSDColorSwatch.Shade,
                 accentName: RSDReservedColorName, _ accentShade: RSDColorSwatch.Shade,
                 grayScale: RSDGrayScale? = nil) {
        let version = RSDColorMatrix.shared.currentVersion
        let primary = RSDColorMatrix.shared.colorKey(for: primaryName, shade: primaryShade)
        let secondary = RSDColorMatrix.shared.colorKey(for: secondaryName, shade: secondaryShade)
        let accent = RSDColorMatrix.shared.colorKey(for: accentName, shade: accentShade)
        self.init(version: version, primary: primary, secondary: secondary, accent: accent, successGreen: nil, errorRed: nil, grayScale: grayScale)
    }
    
    public init(version: Int,
                primary: RSDColorKey,
                secondary: RSDColorKey,
                accent: RSDColorKey,
                successGreen: RSDColorKey? = nil,
                errorRed: RSDColorKey? = nil,
                grayScale: RSDGrayScale? = nil,
                text: RSDColorKey? = nil) {
        self.version = version
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.successGreen = successGreen ?? RSDColorMatrix.shared.colorKey(for: .special(.successGreen), shade: .medium)
        self.errorRed = errorRed  ??
            RSDColorMatrix.shared.colorKey(for: .special(.errorRed), shade: .medium)
        self.grayScale = grayScale ?? RSDGrayScale()
        self.text = text ??
            RSDColorMatrix.shared.colorKey(for: .special(.text), shade: .medium)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decodeIfPresent(Int.self, forKey: .version)
        
        let codingInfo = decoder.codingInfo
        codingInfo?.userInfo[.paletteVersion] = version
        
        self.primary = try container.decode(RSDColorKey.self, forKey: .primary)
        self.secondary = try container.decode(RSDColorKey.self, forKey: .secondary)
        self.accent = try container.decode(RSDColorKey.self, forKey: .accent)
        self.successGreen = try container.decodeIfPresent(RSDColorKey.self, forKey: .successGreen) ??
            RSDColorMatrix.shared.colorKey(for: .special(.successGreen), shade: .medium)
        self.errorRed = try container.decodeIfPresent(RSDColorKey.self, forKey: .errorRed) ??
            RSDColorMatrix.shared.colorKey(for: .special(.errorRed), shade: .medium)
        self.grayScale = try container.decodeIfPresent(RSDGrayScale.self, forKey: .grayScale) ?? RSDGrayScale()
        self.text = try container.decodeIfPresent(RSDColorKey.self, forKey: .text) ??
            RSDColorMatrix.shared.colorKey(for: .special(.text), shade: .medium)
        self.version = version

        codingInfo?.userInfo[.paletteVersion] = nil
    }
}

/// The color key is a model object that contains the information needed by the color design system to
/// describe the colors associated with a given set of components.
public struct RSDColorKey : Codable, Equatable, Hashable, RSDColorMapping {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case index, swatch, swatchName, colorName
    }
    
    /// The level for the color as described in the design documents for a given app.
    public let index: Int
    
    /// The swatch of colors associated with this color key.
    public let swatch: RSDColorSwatch
    
    /// A list of the color tiles within this swatch.
    public var colorTiles: [RSDColorTile] {
        return self.swatch.colorTiles
    }
    
    public init?(index: Int, swatch: RSDColorSwatch) {
        guard swatch.colorTiles.count > index, index >= 0 else { return nil }
        self.index = index
        self.swatch = swatch
    }

    public init(from decoder: Decoder) throws {
        
        let swatch: RSDColorSwatch
        let index: Int
        
        if let singleValueContainer = try? decoder.singleValueContainer(),
            let colorName = try? singleValueContainer.decode(String.self) {
            if let fm = RSDColorMatrix.shared.findColorKey(for: colorName) {
                swatch = fm.swatch
                index = fm.index
            }
            else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                    debugDescription: "The color \(colorName) was not defined in the shared color matrix and the swatch cannot be built.")
                throw DecodingError.dataCorrupted(context)
            }
        }
        else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            index = try container.decode(Int.self, forKey: .index)
            // Get the swatch using either the swatch name or using the color matrix.
            if let swatchName = try container.decodeIfPresent(RSDReservedColorName.self, forKey: .swatchName) {
                let swatchVersion = decoder.codingInfo?.userInfo[.paletteVersion] as? Int
                guard let fm = RSDColorMatrix.shared.colorSwatch(for: swatchName, version: swatchVersion)
                    else {
                        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                            debugDescription: "The color swatch \(swatchName) was not defined in the shared color matrix.")
                        throw DecodingError.dataCorrupted(context)
                }
                swatch = fm
            }
            else {
                swatch = try container.decode(RSDColorSwatch.self, forKey: .swatch)
            }
            // Validate the index against the tile count.
            guard swatch.colorTiles.count > index else {
                let context = DecodingError.Context(codingPath: decoder.codingPath,
                                                    debugDescription: "The color swatch \(swatch.name) does not have enough tiles to match the color index of \(String(describing: index))")
                throw DecodingError.dataCorrupted(context)
            }
        }
        self.index = index
        self.swatch = swatch
    }
    
    /// The encoder will always encode the color swatch so that apps can reference a color swatch specifically
    /// without having to be concerned with level rules.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.index, forKey: .index)
        try container.encode(self.swatch, forKey: .swatch)
    }
}
