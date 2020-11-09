//
//  RSDFont+Lato.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension RSDFont {
    
    /// Returns the most appropriate Lato font found by the system. This will first check for the
    /// Lato font that matches the requested weight. If not found (because this framework only
    /// includes a subset of the full Lato font family), then it will fall back to the most
    /// appropriate font registered from this framework.
    ///
    /// This framework does not include all the possible sizes and weights for the Lato font
    /// because the full font family is about 11 mb.
    ///
    /// - parameters:
    ///     - fontSize: The size of the font requested.
    ///     - weight: The weight of the font requested.
    /// - returns: The closest font to the one requested that is registered for this application.
    public static func latoFont(ofSize fontSize: CGFloat, weight: RSDFont.Weight = .regular) -> RSDFont {
        let fontName = LatoFontWrapper.shared.fontName(weight)
        let registeredFont = RSDFont(name: fontName.preferred, size: fontSize) ??
            RSDFont(name: fontName.fallback, size: fontSize)
        guard let font = registeredFont else {
            print("WARNING! Failed to return font `\(fontName)`. Using system font.")
            return RSDFont.systemFont(ofSize: fontSize, weight: weight)
        }
        return font
    }
    
    /// Returns the Lato italic font embedded in this framework.
    /// - seealso: `latoFont()`
    public static func italicLatoFont(ofSize fontSize: CGFloat, weight: RSDFont.Weight = .regular) -> RSDFont {
        let fontName = LatoFontWrapper.shared.italicFontName(weight)
        let registeredFont = RSDFont(name: fontName.preferred, size: fontSize) ??
            RSDFont(name: fontName.fallback, size: fontSize)
        guard let font = registeredFont else {
            print("WARNING! Failed to return font `\(fontName)`. Using system font.")
            #if os(macOS)
            // Mac does not have the `italicSystemFont()` method.
            return RSDFont.systemFont(ofSize: fontSize, weight: weight)
            #else
            // System italic does not have weight.
            return RSDFont.italicSystemFont(ofSize: fontSize)
            #endif
        }
        return font
    }
    
    /// https://stackoverflow.com/questions/30507905/xcode-using-custom-fonts-inside-dynamic-framework
    static func registerFont(filename: String, bundle: Bundle) {
        guard let pathForResourceString = bundle.path(forResource: filename, ofType: nil) else {
            print("WARNING! Failed to register font \(filename) - path for resource not found")
            return
        }
        
        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("WARNING! Failed to register font \(filename) - font data for could not be loaded.")
            return
        }
        
        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("WARNING! Failed to register font \(filename) - data provider could not be loaded.")
            return
        }
        
        guard let font = CGFont(dataProvider) else {
            print("WARNING! Failed to register font \(filename) - font could not be loaded.")
            return
        }
        
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("WARNING! Failed to register font \(filename) - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}

/// The wrapper is used here to register the Lato fonts once only.
fileprivate class LatoFontWrapper {
    
    static let shared = LatoFontWrapper()
    
    private init() {
        let bundle = Bundle.module
        RSDFont.registerFont(filename: "lato_black.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_bold.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_bolditalic.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_italic.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_light.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_lightitalic.ttf", bundle: bundle)
        RSDFont.registerFont(filename: "lato_regular.ttf", bundle: bundle)
    }
    
    func fontName(_ weight: RSDFont.Weight) -> (preferred: String, fallback: String) {
        switch weight {
        case .ultraLight:
            return ("Lato-Hairline","Lato-Light")
        case .thin:
            return ("Lato-Thin","Lato-Light")
        case .light:
            return ("Lato-Light","Lato-Light")
        case .semibold:
            return ("Lato-Semibold","Lato-Bold")
        case .heavy:
            return ("Lato-Heavy","Lato-Bold")
        case .bold:
            return ("Lato-Bold","Lato-Bold")
        case .black:
            return ("Lato-Black","Lato-Black")
        case .medium:
            return ("Lato-Medium","Lato-Regular")
        default:
            return ("Lato-Regular","Lato-Regular")
        }
    }
    
    func italicFontName(_ weight: RSDFont.Weight) -> (preferred: String, fallback: String) {
        switch weight {
        case .ultraLight:
            return ("Lato-HairlineItalic","Lato-LightItalic")
        case .thin:
            return ("Lato-ThinItalic","Lato-LightItalic")
        case .light:
            return ("Lato-LightItalic","Lato-LightItalic")
        case .semibold:
            return ("Lato-SemiboldItalic","Lato-BoldItalic")
        case .bold:
            return ("Lato-BoldItalic","Lato-BoldItalic")
        case .heavy:
            return ("Lato-HeavyItalic","Lato-BoldItalic")
        case .black:
            return ("Lato-BlackItalic","Lato-BoldItalic")
        case .medium:
            return ("Lato-MediumItalic","Lato-Italic")
        default:
            return ("Lato-Italic","Lato-Italic")
        }
    }
}

