//
//  RSDColorSwatch.swift
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

public protocol RSDColorFamily {
    var colorTiles: [RSDColorTile] { get }
}

extension RSDColorFamily {
    
    /// Look at the colors included in this family and return a mapping if found.
    public func mapping(forColor color: RSDColor) -> RSDColorMapping? {
        guard let idx = self.colorTiles.firstIndex(where: { $0.color == color }) else { return nil }
        return ColorMapping(index: idx, colorTiles: self.colorTiles)
    }
}

/// A color swatch refers to a series of color tiles within the same family.
public struct RSDColorSwatch : Codable, Equatable, Hashable, RSDColorFamily  {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case name, colorTiles
    }
    
    public enum Shade : Int, Codable, CaseIterable {
        case veryLight = 0, light, medium, dark, veryDark
    }
    
    /// The name of the color swatch.
    public let name: String
    
    /// The color tiles included in this swatch.
    public let colorTiles: [RSDColorTile]
    
    public init(name: String, colorTiles: [RSDColorTile]) {
        self.name = name
        self.colorTiles = colorTiles
    }
    
    /// Get the mapping for a given shade.
    /// - parameter shade: The shade of the color.
    /// - returns: The color mapping for that shade.
    public func mapping(forShade shade: Shade) -> RSDColorMapping {
        let idx: Int = {
            switch shade {
            case .veryLight:
                return 0
            case .veryDark:
                return self.colorTiles.count - 1
            case .medium:
                return self.colorTiles.count / 2
            case .dark:
                return min(self.colorTiles.count / 2 + 1, self.colorTiles.count - 1)
            case .light:
                return max(self.colorTiles.count / 2 - 1, 0)
            }
        }()
        return RSDColorKey(index: idx, swatch: self)!
    }
}

/// A color mapping holds a reference to a given index within a set of color tiles.
public protocol RSDColorMapping {
    var index: Int { get }
    var colorTiles: [RSDColorTile] { get }
}

extension RSDColorMapping {
    
    /// The color tile for one shade lighter if available, otherwise returns `normal`.
    public var veryLight: RSDColorTile {
        let idx = index - 2
        if idx >= 0 {
            return self.colorTiles[idx]
        }
        else {
            return self.light
        }
    }
    
    /// The color tile for one shade lighter if available, otherwise returns `normal`.
    public var light: RSDColorTile {
        let idx = index - 1
        if idx >= 0 {
            return self.colorTiles[idx]
        }
        else {
            return self.normal
        }
    }
    
    /// The main color within the color swatch.
    public var normal: RSDColorTile {
        return self.colorTiles[index]
    }
    
    /// The color tile for one shade darker if available, otherwise returns `normal`.
    public var dark: RSDColorTile {
        let idx = index + 1
        if idx < self.colorTiles.count {
            return self.colorTiles[idx]
        }
        else {
            return self.normal
        }
    }
    
    /// The color tile for one shade darker if available, otherwise returns `normal`.
    public var veryDark: RSDColorTile {
        let idx = index + 2
        if idx < self.colorTiles.count {
            return self.colorTiles[idx]
        }
        else {
            return self.dark
        }
    }
}

fileprivate struct ColorMapping : RSDColorMapping {
    let index: Int
    let colorTiles: [RSDColorTile]
}

/// A special-case color swatch for gray scale components.
public struct RSDGrayScale : Codable, Equatable, Hashable, RSDColorFamily {
    public enum Shade : String, CodingKey, CaseIterable {
        case white, veryLightGray, lightGray, gray, darkGray, veryDarkGray, black
        
        public var defaultColorTile : RSDColorTile {
            switch self {
            case .white:
                return RSDColorTile("#FFFFFF", false)
            case .veryLightGray:
                return RSDColorTile("#EAEBEE", false)
            case .lightGray:
                return RSDColorTile("#C3C7D1", false)
            case .gray:
                return RSDColorTile("#9DA3B3", false)
            case .darkGray:
                return RSDColorTile("#777F95", true)
            case .veryDarkGray:
                return RSDColorTile("#575E71", true)
            case .black:
                return RSDColorTile("#2A2A2A", true)
            }
        }
        
        var test : RSDColorTile {
            switch self {
            case .white:
                return RSDColorTile("#ffe0d3", false)
            case .veryLightGray:
                return RSDColorTile("#ffb191", false)
            case .lightGray:
                return RSDColorTile("#ff834f", false)
            case .gray:
                return RSDColorTile("#3bab22", true)
            case .darkGray:
                return RSDColorTile("#3bab22", true)
            case .veryDarkGray:
                return RSDColorTile("#236614", true)
            case .black:
                return RSDColorTile("#17440d", true)
            }
        }
    }

    public let white: RSDColorTile
    public let veryLightGray: RSDColorTile
    public let lightGray: RSDColorTile
    public let gray: RSDColorTile
    public let darkGray: RSDColorTile
    public let veryDarkGray: RSDColorTile
    public let black: RSDColorTile
    
    public var colorTiles: [RSDColorTile] {
        return [white, veryLightGray, lightGray, gray, darkGray, veryDarkGray, black]
    }
    
    /// Get the mapping for a given shade.
    /// - parameter shade: The shade of the color.
    /// - returns: The color mapping for that shade.
    public func mapping(forShade shade: Shade) -> RSDColorMapping {
        let index = Shade.allCases.firstIndex(of: shade)!
        return ColorMapping(index: index, colorTiles: colorTiles)
    }

    public init(white: RSDColorTile = Shade.white.defaultColorTile,
                veryLightGray: RSDColorTile = Shade.veryLightGray.defaultColorTile,
                lightGray: RSDColorTile = Shade.lightGray.defaultColorTile,
                gray: RSDColorTile = Shade.gray.defaultColorTile,
                darkGray: RSDColorTile = Shade.darkGray.defaultColorTile,
                veryDarkGray: RSDColorTile = Shade.veryDarkGray.defaultColorTile,
                black: RSDColorTile = Shade.black.defaultColorTile) {
        self.white = white
        self.veryLightGray = veryLightGray
        self.lightGray = lightGray
        self.gray = gray
        self.darkGray = darkGray
        self.veryDarkGray = veryDarkGray
        self.black = black
    }
    
    static let test = RSDGrayScale( white: Shade.white.test,
                                    veryLightGray: Shade.veryLightGray.test,
                                    lightGray: Shade.lightGray.test,
                                    gray: Shade.gray.test,
                                    darkGray: Shade.darkGray.test,
                                    veryDarkGray: Shade.veryDarkGray.test,
                                    black: Shade.black.test)
}

/// A color tile is a single color and whether or not that color uses light style.
public struct RSDColorTile : Codable, Equatable, Hashable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case color, usesLightStyle
    }
    
    fileprivate init(_ hex: String, _ usesLightStyle: Bool) {
        self.color = RSDColor(hexString: hex)!
        self.usesLightStyle = usesLightStyle
        self.colorName = hex
    }
    
    /// The color defined for this tile.
    public let color: RSDColor
    
    /// Hint for whether or not the view uses light style for things like the progress bar, text, and
    /// navigation buttons shown on top of this color. This is used primarily to denote whether or not the
    /// color is "light" or "dark", where a dark color showing white text would set `usesLightStyle = true`
    /// and a light color showing dark text would set `usesLightStyle = false`.
    public let usesLightStyle: Bool
    
    /// The color name (hex code, special, or asset) used to decode the color from a color file.
    public let colorName: String?
    
    /// Initialize from a color and light style.
    public init(_ color: RSDColor, usesLightStyle: Bool) {
        self.color = color
        self.usesLightStyle = usesLightStyle
        self.colorName = color.toHexString()
    }
    
    /// Initialize from a decoder.
    ///
    /// - example:
    /// ```
    ///         // Example JSON dictionary that includes a spoken instruction map.
    ///         let json = """
    ///         {
    ///            "color": "#5A478F",
    ///            "usesLightStyle": false
    ///         }
    ///         """.data(using: .utf8)! // our data in native (JSON) format
    /// ```
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorName = try container.decode(String.self, forKey: .color)
        let bundle = decoder.bundle as? Bundle
        if let color = RSDColor.rsd_color(named: colorName, in: bundle) {
            self.color = color
        }
        else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode '\(colorName)' into a color.")
            throw DecodingError.dataCorrupted(context)
        }
        self.usesLightStyle = try container.decode(Bool.self, forKey: .usesLightStyle)
        self.colorName = colorName
    }
    
    /// Encode the color tile where the color is encoded as RGB.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.usesLightStyle, forKey: .usesLightStyle)
        if let hex = self.colorName {
            try container.encode(hex, forKey: .color)
        }
        else {
            let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Could not convert the color to a HEX color for encoding.")
            throw EncodingError.invalidValue(self.color, context)
        }
    }
    
    public static func == (lhs: RSDColorTile, rhs: RSDColorTile) -> Bool {
        return lhs.color == rhs.color && lhs.usesLightStyle == rhs.usesLightStyle
    }
}
