//
//  RSDImageThemeObject.swift
//  ResearchSuite
//
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

extension RSDImageWrapper : RSDFetchableImageThemeElement {

    public var placementType: RSDImagePlacementType? {
        return nil
    }
    
    public var size: CGSize? {
        return nil
    }
    
    public var bundle: Bundle? {
        return nil
    }
}

public struct RSDAnimatedImageThemeElementObject : RSDAnimatedImageThemeElement, RSDDecodableBundleInfo, Codable {
    
    public let placementType: RSDImagePlacementType?
    public let bundleIdentifier: String?
    
    private let imageNames: [String]?
    private let imageName: String?
    
    private let _animationDuration: TimeInterval?
    public var animationDuration: TimeInterval {
        return _animationDuration ?? 0.0
    }
    
    private let width: CGFloat?
    private let height: CGFloat?
    
    public var size: CGSize? {
        guard let ww = width, let hh = height else { return nil }
        return CGSize(width: ww, height: hh)
    }
    
    private enum CodingKeys: String, CodingKey {
        case placementType
        case imageName, imageNames
        case bundleIdentifier
        case _animationDuration = "animationDuration"
        case width
        case height
    }
    
    public func images(compatibleWith traitCollection: UITraitCollection? = nil) -> [UIImage] {
        let names: [String] = imageNames ?? ((imageName != nil) ? [imageName!] : [])
        return names.rsd_mapAndFilter {
            UIImage(named: $0, in: bundle, compatibleWith: traitCollection)
        }
    }
    
    public init(imageName: String, bundleIdentifier: String?, size: CGSize?, placementType: RSDImagePlacementType?) {
        self.imageNames = nil
        self.imageName = imageName
        self.bundleIdentifier = bundleIdentifier
        self._animationDuration = 0
        self.width = size?.width
        self.height = size?.height
        self.placementType = placementType
    }
    
    public init(imageNames: [String], bundleIdentifier: String?, animationDuration: TimeInterval, size: CGSize?, placementType: RSDImagePlacementType?) {
        self.imageNames = imageNames
        self.imageName = nil
        self.bundleIdentifier = bundleIdentifier
        self._animationDuration = animationDuration
        self.width = size?.width
        self.height = size?.height
        self.placementType = placementType
    }
    
    public var identifier: String {
        return "image\(placementType?.rawValue ?? "above")"
    }
    
    public func fetchImage(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        let fetchedImages = self.images(compatibleWith: nil)
        callback(fetchedImages.first)
    }
}
