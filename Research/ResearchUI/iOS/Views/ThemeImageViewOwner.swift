//
//  ThemeImageViewOwner.swift
//  ResearchUI (iOS)
//

import Foundation
import Research
import UIKit

protocol ThemeImageViewOwner : AnyObject {
    func themeImageIdentifier(withKey key: String) -> String?
}

extension ThemeImageViewOwner {
    
    func loadImage(withKey key: String,
                   using imageTheme: RSDImageThemeElement,
                   into imageView: UIImageView,
                   using designSystem: RSDDesignSystem?,
                   compatibleWith traitCollection: UITraitCollection) {
        imageTheme.fetchImage(using: designSystem, compatibleWith: traitCollection) { [weak self, weak imageView] (imageLoader, image) in
            guard let strongSelf = self, let imageView = imageView,
                imageLoader.imageIdentifier == strongSelf.themeImageIdentifier(withKey: key)
                else {
                    return
            }
            if let duration = image?.duration,
                let images = image?.images,
                images.count > 0 {
                let repeatCount = (imageLoader as? RSDAnimatedImageThemeElement)?.animationRepeatCount ?? 0
                UIView.transition(with: imageView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    imageView.image = image },
                                  completion: { (finished) in
                                    // If there is more than one image in the collection, then animate them.
                                    if finished, images.count > 1, duration > 0 {
                                        imageView.animationImages = images
                                        imageView.animationDuration = duration
                                        imageView.animationRepeatCount = repeatCount
                                        imageView.startAnimating()
                                        // Always set the last image as the one to show when/if the animation ends.
                                        imageView.image = images.last
                                    }
                })
            }
            else {
                // Otherwise, set the view to the image
                imageView.image = image
            }
        }
    }
}
