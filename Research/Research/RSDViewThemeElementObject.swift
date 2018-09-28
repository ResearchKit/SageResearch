//
//  RSDViewThemeElementObject.swift
//  Research
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

/// `RSDViewThemeElementObject` tells the UI where to find the view controller to use when instantiating
/// the `RSDStepController`.
public struct RSDViewThemeElementObject: RSDViewThemeElement, RSDDecodableBundleInfo, Codable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case viewIdentifier, bundleIdentifier, storyboardIdentifier
    }
    
    /// The storyboard view controller identifier or the nib name for this view controller.
    public let viewIdentifier: String
    
    /// The bundle identifier for the nib or storyboard.
    public let bundleIdentifier: String?
    
    /// If the storyboard identifier is non-nil then the view is assumed to be accessible within the
    /// storyboard via the `viewIdentifier`.
    public let storyboardIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - viewIdentifier: The storyboard view controller identifier or the nib name for this view
    ///       controller.
    ///     - bundleIdentifier: The bundle identifier for the nib or storyboard. Default = `nil`.
    ///     - storyboardIdentifier: The storyboard identifier. Default = `nil`.
    public init(viewIdentifier: String, bundleIdentifier: String? = nil, storyboardIdentifier: String? = nil) {
        self.viewIdentifier = viewIdentifier
        self.bundleIdentifier = bundleIdentifier
        self.storyboardIdentifier = storyboardIdentifier
    }
}

extension RSDViewThemeElementObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func viewThemeExamples() -> [RSDViewThemeElementObject] {
        let viewThemeA = RSDViewThemeElementObject(viewIdentifier: "FooStepNibIdentifier", bundleIdentifier: "org.example.SharedResources")
        let viewThemeB = RSDViewThemeElementObject(viewIdentifier: "FooStepViewIdentifier", bundleIdentifier: nil, storyboardIdentifier: "FooBarStoryboard")
        return [viewThemeA, viewThemeB]
    }
    
    static func examples() -> [Encodable] {
        return viewThemeExamples()
    }
}
