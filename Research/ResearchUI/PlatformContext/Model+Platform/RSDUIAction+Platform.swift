//
//  RSDUIAction+Platform.swift
//  ResearchPlatformContext
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import Research

extension RSDUIAction {
    
    /// Convenience property for accessing the button icon.
    @available(*, deprecated, message: "Use `RSDImageRules.assetImage()` instead.")
    public var buttonIcon: RSDImage? {
        guard let imageName = self.iconName else { return nil }
        #if os(iOS) || os(tvOS)
        return RSDDesignSystem.shared.imageRules.assetImage(named: imageName,
                                                            using: self,
                                                            compatibleWith: nil)
        #elseif os(macOS)
        return RSDImage(named: .init(imageName))
        #else
        return RSDImage(named: imageName)
        #endif
    }
    
    #if os(iOS) || os(tvOS)
    
    /// Returns the button icon (if found).
    ///
    /// - parameters:
    ///     - resourceName: The name of the image.
    ///     - resourceInfo: The resource info associated with this asset.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: Image if found.
    public func buttonImage(using designSystem: RSDDesignSystem? = nil,
                    compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        guard let imageName = self.iconName else { return nil }
        let imageRules = designSystem?.imageRules ?? RSDDesignSystem.shared.imageRules
        return imageRules.assetImage(named: imageName, using: self, compatibleWith: traitCollection)
    }
    
    #endif
}
