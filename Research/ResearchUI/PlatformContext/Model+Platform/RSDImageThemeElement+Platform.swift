//
//  RSDImageThemeElement+Platform.swift
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

import Research

extension RSDImageThemeElement {
    
    #if os(iOS) || os(tvOS)
    
    /// Fetch the images represented by this theme element.
    ///
    /// This method is used to work around supporting both iOS and Android with the same model.
    /// To do so, this extension checks the type of the image theme protocol and defines this
    /// method in an extension on that protocol rather than having the protocol define the method
    /// and each class (or struct) define the implementation.
    ///
    /// Therefore, this implementation *only* supports subprotocols and concrete implementations
    /// defined within this framework or the Research framework that contains the model definitions.
    /// Any custom loading must be handled using a subclass of `RSDImageRules` that overrides
    /// `largeImage(named:, using:, compatibleWith:)` to include its own implementation.
    ///
    /// Additionally, this method currently does not support loading images from an online resource.
    /// When, or if, that is supported in Research framework, then this method should be updated to
    /// include support for that protocol.
    ///
    /// - parameters:
    ///     - designSystem: The design system to use to fetch images.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: The image (if found).
    public func fetchImage(using designSystem: RSDDesignSystem?,
                           compatibleWith traitCollection: UITraitCollection?,
                           callback: @escaping ((RSDImageThemeElement, RSDImage?) -> Void)) {
        DispatchQueue.global().async {
            let image = self._getImage(designSystem, traitCollection)
            DispatchQueue.main.async {
                callback(self, image)
            }
        }
    }
    
    private func _getImage(_ designSystem: RSDDesignSystem?,
                           _ traitCollection: UITraitCollection?) -> UIImage? {
        let designSystem = designSystem ?? RSDDesignSystem.shared
        if let image = self as? RSDImage {
            return image
        }
        else if let animatedTheme = self as? RSDAnimatedImageThemeElement,
            let imageNames = animatedTheme.animationImageNames,
            imageNames.count > 0 {
            let images = imageNames.compactMap {
                designSystem.imageRules.largeImage(named: $0, using: self, compatibleWith: traitCollection)
            }
            guard images.count > 0 else { return nil }
            let image = UIImage.animatedImage(with: images, duration: animatedTheme.animationDuration)
            _applyAccessibility(to: image)
            return image
        }
        else {
            let image = designSystem.imageRules.largeImage(named: self.imageName, using: self, compatibleWith: traitCollection)
            _applyAccessibility(to: image)
            return image
        }
    }
    
    private func _applyAccessibility(to image: RSDImage?) {
        image?.accessibilityIdentifier = self.imageIdentifier
        image?.accessibilityLabel = Localization.localizedString(self.imageName)
    }
    
    #endif
}
