//
//  UIColor+Utilities.swift
//  ResearchSuite
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

extension UIColor {
    
    /// Get the color associated with the given coding key.
    ///
    /// This will first check to see if the string is a HEX-coded string and initialize the string using the
    /// `UIColor.init?(hexString:)` initializer.
    ///
    /// If this is not a hex color, then if this is an iOS 11 implementation, the asset catalog for the given
    /// bundle will be checked using the `UIColor.init?(named:, in:, compatibleWith:)` initializer.
    ///
    /// Finally, the method will look for a file imbedded in the given bundle named "ColorInfo.plist".
    /// This allows the app to define a mapping of colors in a single place using a plist with key/value pairs.
    /// The mapping is expected to include key/value pairs where the value is a hex-coded string. The plist
    /// method is slower (because the file must be openned and inspected) so it is only recommended for applications
    /// that need to be reverse-compatible to iOS 10.
    ///
    /// - parameters:
    ///     - name: The name of the color. Either a HEX-code or a custom-defined key.
    ///     - bundle: The bundle with either the Color asset (iOS 11) or the "ColorInfo.plist" file (iOS 10)
    ///     - traitCollection: The trait collection (if supported)
    /// - returns: The color created.
    open class func rsd_color(named name: String, in bundle: Bundle?, compatibleWith traitCollection: UITraitCollection?) -> UIColor? {
        if let color = UIColor(hexString: name) {
            return color
        } else if #available(iOS 11.0, *), let color = UIColor(named: name, in: bundle, compatibleWith: traitCollection) {
            return color
        } else {
            return RSDColorInfo(name: "ColorInfo", bundle: bundle).color(for: name)
        }
    }
    
    /// Initialize a `UIColor` with a hex string.
    /// - parameter hexString:  An RGB color defined using a hex code.
    /// - returns: A color if the hex is valid.
    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        
        // Look for the start of the hex numbers, stripping out the # or 0x if present
        var start = hexString.startIndex
        let prefixes = ["#", "0x"]
        for prefix in prefixes {
            if let range = hexString.range(of: prefix) {
                if range.lowerBound == start {
                    start = range.upperBound
                    break
                }
                else {
                    return nil
                }
            }
        }
        let hexColor = String(hexString[start...])
        
        // If there aren't 6 characters in the hex color then drop through to return nil
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            // scan the string into a hex and drop through to nil if unsuccessful
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }
        
        return nil
    }
}

/// Private class used to store the ColorInfo pList.
fileprivate final class RSDColorInfo : NSObject {
    
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
    
    fileprivate func color(for colorKey: String) -> UIColor? {
        guard let colorHex = plist?[colorKey] as? String else {
            return nil
        }
        return UIColor(hexString: colorHex)
    }
}

