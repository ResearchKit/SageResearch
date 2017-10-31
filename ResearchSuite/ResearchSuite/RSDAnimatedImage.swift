//
//  RSDAnimatedImage.swift
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

public struct RSDAnimatedImage : Codable {
    
    public let imageNames: [String]
    public let bundleIdentifier: String?
    public let animationDuration: TimeInterval
    
    private let backgroundColorName: String?
    private let width: CGFloat?
    private let height: CGFloat?
    
    public var size: CGSize? {
        guard let ww = width, let hh = height else { return nil }
        return CGSize(width: ww, height: hh)
    }
    
    public var bundle: Bundle? {
        guard let name = bundleIdentifier else { return nil }
        return Bundle(identifier: name)
    }
    
    public func backgroundColor(compatibleWith traitCollection: UITraitCollection? = nil) -> UIColor? {
        guard let name = backgroundColorName else { return nil }
        if #available(iOS 11.0, *) {
            return UIColor(named: name, in: bundle, compatibleWith: traitCollection)
        } else {
            return nil
        }
    }

    public func images(compatibleWith traitCollection: UITraitCollection? = nil) -> [UIImage] {
        return imageNames.rsd_mapAndFilter {
            UIImage(named: $0, in: bundle, compatibleWith: traitCollection)
        }
    }
    
    public init(imageNames: [String], bundleIdentifier: String?, animationDuration: TimeInterval, size: CGSize) {
        self.imageNames = imageNames
        self.bundleIdentifier = bundleIdentifier
        self.animationDuration = animationDuration
        self.width = size.width
        self.height = size.height
        self.backgroundColorName = nil
    }
}
