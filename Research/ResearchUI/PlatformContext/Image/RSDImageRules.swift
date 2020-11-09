//
//  RSDImageRules.swift
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
import JsonModel
import Research

open class RSDImageRules {
    
    /// The version for the image rules. If the design rules change with future versions of this
    /// framework, then the current version number should be rev'd as well and any changes to this
    /// rule set that are not additive include logic to return the previous rules associated with
    /// a previous version.
    open private(set) var version: Int
    
    public init(version: Int? = nil) {
        self.version = version ?? RSDColorMatrix.shared.currentVersion
    }
    
    /// List of all the bundles to search for a given image. Only register your bundle if you need
    /// to make assets within that bundle available to tasks that are decoded from a *different*
    /// bundle from the image asset. If they are decoded from the same bundle, or from the main
    /// bundle, then the `ResourceInfo` on the image data or theme will include the bundle.
    open private(set) var registeredBundles: [Bundle] = []
    
    /// Insert a bundle into `registeredBundles` at a given index. If the index is beyond the range
    /// of `registeredBundles`, then the bundle will be appended to the end of the array. If the
    /// bundle was previously in the array, then the previous instance will be moved to the new
    /// index.
    @objc(insertBundle:atIndex:)
    public func insert(bundle: Bundle, at index: UInt) {
        if let idx = registeredBundles.firstIndex(of: bundle) {
            registeredBundles.remove(at: idx)
        }
        if (index < registeredBundles.count) {
            registeredBundles.insert(bundle, at: Int(index))
        } else {
            registeredBundles.append(bundle)
        }
    }
    
    /// When searching for an image asset, should the `UIImage(systemName:)` SF images be checked
    /// *before* searching within the bundles? Default is `false`. Setting this to `true` will allow
    /// applications to include an image for system images defined by iOS 13 while still using the
    /// system image on platforms where it is available.
    open var shouldPreferSystemImage: Bool = false
    
    #if os(iOS) || os(tvOS)
    
    /// Get the image path for a given image.
    open func imagePath(for resourceName: String,
                        in bundle: Bundle?,
                        ofType defaultExtension: String?,
                        compatibleWith traitCollection: UITraitCollection? = nil) -> String? {
        
        // Define the bundle and the extension.
        let ext = defaultExtension ?? "png"
        let rBundle = bundle ?? Bundle.main
        
        #if os(iOS)
        
        let scale = Int(traitCollection?.displayScale ?? UIScreen.main.scale)
        
        // If on iOS, first check to see if the image has a dark mode version and exit early if
        // a path to the dark version is found.
        if #available(iOS 13.0, *),
            let style = traitCollection?.imageConfiguration.traitCollection?.userInterfaceStyle,
            style == .dark {
            let imageName = "\(resourceName)-dark@\(scale)x"
            if let path = rBundle.path(forResource: imageName, ofType: ext) {
                return path
            }
        }
        
        // Otherwise, drop through to the previous implementation for iOS 12 and other platforms.
        let imageName = "\(resourceName)@\(scale)x"
        #elseif os(tvOS)
        let scale = Int(UIScreen.main.scale)
        let imageName = "\(resourceName)@\(scale)x"
        #else
        let imageName = resourceName
        #endif
        
        return rBundle.path(forResource: imageName, ofType: ext)
    }
    
    
    /// As of this writing, there is a bug in some versions of iOS supported by this framework
    /// that causes larger images to crash the application b/c of low memory and improper release
    /// of the cache. As a result of this issue, large images should *not* be stored in the asset
    /// catalog. Instead, they should be stored as files using the iOS convention of `imageName@2x`
    /// and `imageName@2x` so that they can be created using the `UIImage(contentsOfFile:)` method.
    /// syoung 12/12/2019
    ///
    /// This method is written to look *first* for the image using the `UIImage(contentsOfFile:)`
    /// initializer. If not found, it will then look for the image in the asset bundles.
    ///
    /// - seealso: https://forums.developer.apple.com/thread/18767
    ///
    /// - parameters:
    ///     - resourceName: The name of the image.
    ///     - resourceInfo: The resource info associated with this asset.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: Image if found.
    open func largeImage(named resourceName: String,
                         using resourceInfo: ResourceInfo? = nil,
                         compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        
        return _getFileImage(resourceName, resourceInfo, traitCollection) ??
            _getAssetImage(resourceName, resourceInfo, traitCollection)
    }
    
    /// Returns the image asset (if found).
    ///
    /// If `shouldPreferSystemImage == true` this method will look for an image in the SF images
    /// first and *then* look for it in the resource info, main bundle, and registered bundles.
    /// If `shouldPreferSystemImage == false`, then it will search the bundles and *then* look for
    /// the asset in the SF image catalog.
    ///
    /// - parameters:
    ///     - resourceName: The name of the image.
    ///     - resourceInfo: The resource info associated with this asset.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: Image if found.
    open func assetImage(named resourceName: String,
                    using resourceInfo: ResourceInfo? = nil,
                    compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        
        if shouldPreferSystemImage {
            return _getSystemImage( resourceName, traitCollection) ??
                _getAssetImage(resourceName, resourceInfo, traitCollection)
        }
        else {
            return _getAssetImage(resourceName, resourceInfo, traitCollection) ??
                _getSystemImage( resourceName, traitCollection)
        }
    }
    
    /// Get an SF system image if the OS supports this feature.
    private func _getSystemImage(_ resourceName:String, _ traitCollection: UITraitCollection?) -> RSDImage? {
        #if os(tvOS)
        if #available(tvOS 13.0, *) {
            return RSDImage(systemName: resourceName, compatibleWith: traitCollection)
        }
        #elseif os(iOS)
        if #available(iOS 13.0, *) {
            return RSDImage(systemName: resourceName, compatibleWith: traitCollection)
        }
        #endif
        return nil
    }
    
    /// Get an image from an asset catalog and then add default accessibility traits.
    private func _getAssetImage(_ resourceName: String,
                                _ resourceInfo: ResourceInfo?,
                                _ traitCollection: UITraitCollection?) -> RSDImage? {
        guard let image = self.searchBundlesForAsset(named: resourceName, using: resourceInfo, compatibleWith: traitCollection)
            else {
                return nil
        }
        
        // Apparently, there is currently no means of setting accessibility properties of an image
        // through the asset catalog. This may be resolved in future OS versions. syoung 12/12/2019
        if image.accessibilityIdentifier == nil {
            image.accessibilityIdentifier = resourceName
        }
        image.accessibilityLabel = Localization.localizedString(resourceName)
        
        return image
    }
    
    /// Get an image from a file and then add default accessibility traits.
    private func _getFileImage(_ resourceName: String,
                                _ resourceInfo: ResourceInfo?,
                                _ traitCollection: UITraitCollection?) -> RSDImage? {
        guard let image = self.searchBundlesForImageFile(named: resourceName, using: resourceInfo, compatibleWith: traitCollection)
            else {
                return nil
        }
        
        // Because the image was accessed directly using the contents method, we need to manually
        // set the accessibility for this image.
        if image.accessibilityIdentifier == nil {
            image.accessibilityIdentifier = resourceName
        }
        image.accessibilityLabel = Localization.localizedString(resourceName)
        
        return image
    }
    
    /// Look in each bundle for an asset image, in priority order.
    private func searchBundlesForAsset(named resourceName: String,
                                       using resourceInfo: ResourceInfo? = nil,
                                       compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        
        // Exit early if found in either the resource info bundle or main bundle.
        if let rBundle = resourceInfo?.bundle,
            let image = RSDImage(named: resourceName, in: rBundle, compatibleWith: traitCollection) {
            return image
        }
        else if let image = RSDImage(named: resourceName, in: Bundle.main, compatibleWith: traitCollection) {
            return image
        }
        
        // Loop through the registered bundles to look for the asset.
        for rBundle in self.registeredBundles {
            if let image = RSDImage(named: resourceName, in: rBundle, compatibleWith: traitCollection) {
                return image
            }
        }
        
        // If not found in any of the bundles, return nil
        return nil
    }
    
    /// Look in each bundle for a file image, in priority order.
    private func searchBundlesForImageFile(named resourceName: String,
                                           using resourceInfo: ResourceInfo? = nil,
                                           compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        
        // Exit early if found in either the resource info bundle or main bundle.
        if let rBundle = resourceInfo?.bundle,
            let path = self.imagePath(for: resourceName, in: rBundle, ofType: nil, compatibleWith: traitCollection),
            let image = RSDImage(contentsOfFile: path) {
            return image
        }
        else if let path = self.imagePath(for: resourceName, in: Bundle.main, ofType: nil, compatibleWith: traitCollection),
            let image = RSDImage(contentsOfFile: path) {
            return image
        }
        
        // Loop through the registered bundles to look for the asset.
        for rBundle in self.registeredBundles {
            if let path = self.imagePath(for: resourceName, in: rBundle, ofType: nil, compatibleWith: traitCollection),
                let image = RSDImage(contentsOfFile: path) {
                return image
            }
        }
        
        // If not found in any of the bundles, return nil.
        return nil
    }
    
    #endif
}
