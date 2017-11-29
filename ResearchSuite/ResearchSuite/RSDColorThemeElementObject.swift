//
//  RSDColorThemeElementObject.swift
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

/// `RSDColorThemeElementObject` tells the UI what the background color and foreground color are for a given view as
/// well as whether or not the foreground elements should use "light style".
public struct RSDColorThemeElementObject : RSDColorThemeElement, RSDDecodableBundleInfo, Codable {
    let _backgroundColorName: String?
    let _foregroundColorName: String?
    let _usesLightStyle: Bool?
    
    public let bundleIdentifier: String?

    private enum CodingKeys: String, CodingKey {
        case _backgroundColorName = "backgroundColor"
        case _foregroundColorName = "foregroundColor"
        case _usesLightStyle = "usesLightStyle"
        case bundleIdentifier
    }
    
    /// Hint for whether or not the view uses light style for things like the progress bar and navigation buttons.
    public var usesLightStyle: Bool {
        return _usesLightStyle ?? false
    }
    
    /// The background color for this step.
    #if os(watchOS)
    public func backgroundColor() -> UIColor? {
        guard let name = _backgroundColorName else { return nil }
        return UIColor.rsd_color(named: name, in: bundle)
    }
    #else
    public func backgroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor? {
        guard let name = _backgroundColorName else { return nil }
        return UIColor.rsd_color(named: name, in: bundle, compatibleWith: traitCollection)
    }
    #endif
    
    /// The foreground color for this step.
    #if os(watchOS)
    public func foregroundColor() -> UIColor? {
        guard let name = _backgroundColorName else { return nil }
        return UIColor.rsd_color(named: name, in: bundle)
    }
    #else
    public func foregroundColor(compatibleWith traitCollection: UITraitCollection?) -> UIColor? {
        guard let name = _backgroundColorName else { return nil }
        return UIColor.rsd_color(named: name, in: bundle, compatibleWith: traitCollection)
    }
    #endif
    
    /// Default initializer.
    ///
    /// - note: The color names used by this `Codable` object can be defined as either:
    /// 1. HEX-code values.
    /// 2. Using a Color Asset if targeting devices that support this feature. For example, iOS 11 and above.
    ///     See https://developer.apple.com/documentation/uikit/uicolor/2877380-init for more information.
    /// 3. A mapping file called "ColorInfo.plist" that includes key/value pairs where the `key` is the name included
    ///     here and the `value` is a HEX-code color.
    ///
    /// - parameters:
    ///     - usesLightStyle: Hint for whether or not the view uses light style for things like the progress bar. Default = `false`.
    ///     - backgroundColorName: The name of the background color. Default = `nil`.
    ///     - foregroundColorName: The name of the foreground color. Default = `nil`.
    ///     - bundleIdentifier: The bundle identifier for where to find the color asset or plist mapping file. Default = `nil`.
    public init(usesLightStyle: Bool = false, backgroundColorName: String?, foregroundColorName: String? = nil, bundleIdentifier: String? = nil) {
        self._usesLightStyle = usesLightStyle
        self._backgroundColorName = backgroundColorName
        self._foregroundColorName = foregroundColorName
        self.bundleIdentifier = bundleIdentifier
    }
}

extension RSDColorThemeElementObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [._backgroundColorName, ._foregroundColorName, ._usesLightStyle, .bundleIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case ._backgroundColorName:
                if idx != 0 { return false }
            case ._foregroundColorName:
                if idx != 1 { return false }
            case ._usesLightStyle:
                if idx != 2 { return false }
            case .bundleIdentifier:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func colorThemeExamples() -> [RSDColorThemeElementObject] {
        let colorThemeA = RSDColorThemeElementObject(usesLightStyle: true, backgroundColorName: "blueBlack")
        let colorThemeB = RSDColorThemeElementObject(usesLightStyle: false, backgroundColorName: nil, foregroundColorName: "mintGreen", bundleIdentifier: "org.example.SharedCodeBundle")
        return [colorThemeA, colorThemeB]
    }
    
    static func examples() -> [Encodable] {
        return colorThemeExamples()
    }
}
