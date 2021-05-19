//
//  ThemeImageViewOwner.swift
//  ResearchUI (iOS)
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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
