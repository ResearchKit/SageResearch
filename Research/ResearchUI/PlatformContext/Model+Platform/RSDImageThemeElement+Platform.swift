//
//  RSDImageThemeElement+Platform.swift
//  ResearchPlatformContext
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
