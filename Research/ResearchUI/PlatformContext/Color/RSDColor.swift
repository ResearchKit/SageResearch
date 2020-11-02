//
//  RSDColor.swift
//  ResearchPlatformContext
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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

#if os(macOS)
import AppKit
public typealias RSDColor = NSColor
#else
import UIKit
public typealias RSDColor = UIColor
#endif

import Research

extension RSDColor {
    
    #if os(watchOS)
    
    /// **Available** for watchOS.
    ///
    /// Get the color associated with the given coding key.
    ///
    /// 1. This will first check to see if the string is a HEX-coded string and initialize the string using the
    /// `UIColor.init?(hexString:)` initializer.
    ///
    /// 2. If this is not a hex color, then the asset catalog for the main bundle will be checked using the
    /// `UIColor.init?(named:)` initializer.
    ///
    /// 3. Finally, the method will look for a file imbedded in the given bundle named "ColorInfo.plist".
    /// This allows the app to define a mapping of colors in a single place using a plist with key/value pairs.
    /// The mapping is expected to include key/value pairs where the value is a hex-coded string. The plist
    /// method is slower (because the file must be openned and inspected) so it is only recommended for applications
    /// that need to support iOS 10.
    ///
    /// - parameters:
    ///     - name: The name of the color. Either a HEX-code or a custom-defined key.
    ///     - bundle: The bundle with the "ColorInfo.plist" file.
    /// - returns: The color created.
    open class func rsd_color(named name: String, in bundle: Bundle?) -> RSDColor? {
        if let color = RSDColor(hexString: name) {
            return color
        } else if #available(watchOSApplicationExtension 4.0, *), let color = RSDColor(named: name) {
            return color
        } else if let colorHex = ColorInfoPList(name: "ColorInfo", bundle: bundle).colorHex(for: name) {
            return RSDColor(hexString: colorHex)
        } else {
            return nil
        }
    }
    
    #elseif os(macOS)
    
    
    /// **Available** for macOS.
    ///
    /// Get the color associated with the given coding key.
    ///
    /// 1. This will first check to see if the string is a HEX-coded string and initialize the string using the
    /// `UIColor.init?(hexString:)` initializer.
    ///
    /// 2. If this is not a hex color, then the asset catalog for the main bundle will be checked using the
    /// `UIColor.init?(named:)` initializer.
    ///
    /// 3. Finally, the method will look for a file imbedded in the given bundle named "ColorInfo.plist".
    /// This allows the app to define a mapping of colors in a single place using a plist with key/value pairs.
    /// The mapping is expected to include key/value pairs where the value is a hex-coded string. The plist
    /// method is slower (because the file must be openned and inspected) so it is only recommended for applications
    /// that need to support iOS 10.
    ///
    /// - parameters:
    ///     - name: The name of the color. Either a HEX-code or a custom-defined key.
    ///     - bundle: The bundle with the "ColorInfo.plist" file.
    /// - returns: The color created.
    open class func rsd_color(named name: String, in bundle: Bundle?) -> RSDColor? {
        if let color = RSDColor(hexString: name) {
            return color
        } else if let color = RSDColor(named: name, bundle: bundle) {
            return color
        } else if let colorHex = ColorInfoPList(name: "ColorInfo", bundle: bundle).colorHex(for: name) {
            return RSDColor(hexString: colorHex)
        } else {
            return nil
        }
    }
    
    #else
    
    /// **Available** for iOS and tvOS.
    ///
    /// Get the color associated with the given coding key.
    ///
    /// 1. This will first check to see if the string is a HEX-coded string and initialize the string using the
    /// `UIColor.init?(hexString:)` initializer.
    ///
    /// 2. If this is not a hex color, then the asset catalog for the given bundle will be checked using the
    /// `UIColor.init?(named:, in:, compatibleWith:)` initializer.
    ///
    /// 3. Finally, the method will look for a file imbedded in the given bundle named "ColorInfo.plist".
    /// This allows the app to define a mapping of colors in a single place using a plist with key/value pairs.
    /// The mapping is expected to include key/value pairs where the value is a hex-coded string. The plist
    /// method is slower (because the file must be openned and inspected) so it is only recommended for applications
    /// that need to support iOS 10.
    ///
    /// - parameters:
    ///     - name: The name of the color. Either a HEX-code or a custom-defined key.
    ///     - bundle: The bundle with either the Color asset (iOS/tvOS 11) or the "ColorInfo.plist" file (all versions).
    ///     - traitCollection: The trait collection to use (if supported).
    /// - returns: The color created.
    @available(iOS 10.3, tvOS 10.2, *)
    open class func rsd_color(named name: String, in bundle: Bundle?, compatibleWith traitCollection: UITraitCollection? = nil) -> RSDColor? {
        if let color = RSDColor(hexString: name) {
            return color
        } else if let color = UIColor(named: name, in: bundle, compatibleWith: traitCollection) {
            return color
        } else if let colorHex = ColorInfoPList(name: "ColorInfo", bundle: bundle).colorHex(for: name) {
            return RSDColor(hexString: colorHex)
        } else {
            return nil
        }
    }
    #endif
    
    /// Initialize with a hex string that uses web hex format #rrggbb.
    ///
    /// - parameter hexString:  An RGB color defined using a hex code.
    /// - returns: A color if the hex is valid.
    public convenience init?(hexString: String) {
        if hexString == "#FFFFFF" || hexString == "white" {
            self.init(white: 1, alpha: 1)
        }
        else if hexString == "#000000" || hexString == "black" {
            self.init(white: 0, alpha: 1)
        }
        else {
            guard let (r,g,b,alpha) = rbgValues(from: hexString) else { return nil }
            self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(alpha))
        }
    }
    
    /// Returns a color in the same color space as the receiver with the specified saturation percent.
    ///
    /// - parameter multiplier: The multiplier for the saturation to either lighten or darken the color.
    public func withSaturationMultiplier(_ multiplier: CGFloat, minimumSaturation: CGFloat = 0.2) -> RSDColor {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha)
        guard sat > 0, alpha > 0, brightness > 0 else { return self }
        let saturation = max(min(sat * multiplier, 1.0), minimumSaturation)
        return RSDColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    /// Returns the RGB hex string for this color web hex format #rrggbb.
    public func toHexString() -> String? {
        
        // special-case black and white colors
        if self == RSDColor.white {
            return "#FFFFFF"
        }
        else if self == RSDColor.black {
            return "#000000"
        }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        #if os(macOS)
            getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        // If this is not rgb color space, look to see if it is gray scale.
        if !getRed(&r, green: &g, blue: &b, alpha: &a) {
            var w: CGFloat = 0
            if getWhite(&w, alpha: &a) {
                r = w; g = w; b = w
            }
            else {
                return nil
            }
        }
        #endif
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        let str = String(format:"#%06x", rgb)
        return str
    }
}

fileprivate func rbgValues(from hexString: String) -> (red: Double, green: Double, blue: Double, alpha: Double)? {
    let r, g, b: Double
    
    // Look for the start of the hex numbers, stripping out the # or 0x if present
    let start = hexString.startIndex
    let prefix = "#"
    guard let range = hexString.range(of: prefix), range.lowerBound == start
    else {
        return nil
    }
    let hexColor = String(hexString[range.upperBound...])
    
    // If there aren't 6 characters in the hex color then drop through to return nil
    if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        // scan the string into a hex and drop through to nil if unsuccessful
        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double((hexNumber & 0x0000ff) >> 0) / 255
            
            return (r, g, b, 1.0)
        }
    }
    
    return nil
}

/// Private class used to store the ColorInfo pList.
fileprivate final class ColorInfoPList : NSObject {
    
    fileprivate let plist: [String : Any]?
    
    fileprivate init(name: String, bundle: Bundle?) {
        if let (url,_) = try? RSDResourceTransformerObject(resourceName: name).resourceURL(ofType: "plist", bundle: bundle),
            let dictionary = NSDictionary(contentsOf: url) as? [String : Any] {
            self.plist = dictionary
        } else {
            self.plist = nil
        }
        super.init()
    }
    
    fileprivate func colorHex(for colorKey: String) -> String? {
        return plist?[colorKey] as? String
    }
}
