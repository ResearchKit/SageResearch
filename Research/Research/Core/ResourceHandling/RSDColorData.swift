//
//  RSDColorData.swift
//  Research
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
