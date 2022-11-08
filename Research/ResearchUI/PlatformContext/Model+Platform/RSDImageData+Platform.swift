//
//  RSDImageData+Platform.swift
//  ResearchPlatformContext
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import Foundation
import Research

extension RSDSize {
    
    /// The CGSize represented by this size.
    public var cgSize: CGSize {
        return CGSize(width: self.width, height: self.height)
    }
}

extension RSDImageData {
    
    #if os(iOS) || os(tvOS)
    
    /// Fetch the image.
    ///
    /// This method is used to work around supporting both iOS and Android with the same model.
    /// To do so, this extension checks the type of the image theme protocol and defines this
    /// method in an extension on that protocol rather than having the protocol define the method
    /// and each class (or struct) define the implementation.
    ///
    /// Therefore, this implementation *only* supports subprotocols and concrete implementations
    /// defined within this framework or the Research framework that contains the model definitions.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the image, run on the main thread.
    public func fetchImage(for size: CGSize, callback: @escaping ((String?, RSDImage?) -> Void)) {
        if let image = self as? RSDImage {
            DispatchQueue.main.async {
                callback(self.imageIdentifier, image)
            }
        }
        else if self.imageIdentifier.starts(with: "http"),
            let url = URL(string: self.imageIdentifier) {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            let task = URLSession.shared.dataTask(with: request) {(data, _, _) in
                    let image: RSDImage? = (data != nil) ? RSDImage(data: data!) : nil
                    DispatchQueue.main.async {
                        callback(self.imageIdentifier, image)
                    }
            }
            task.resume()
        }
        else if let resourceInfo = self as? RSDResourceDataInfo {
            let image = RSDDesignSystem.shared.imageRules.assetImage(named: resourceInfo.resourceName, using: resourceInfo)
            DispatchQueue.main.async {
                callback(self.imageIdentifier, image)
            }
        }
        else {
            DispatchQueue.main.async {
                callback(self.imageIdentifier, nil)
            }
        }
    }
    
    #endif
}

extension RSDResourceImageData {
    
    #if os(iOS) || os(tvOS)
    
    /// Get the embedded image for this resource info.
    ///
    /// - parameters:
    ///     - designSystem: The design system to use to fetch images.
    ///     - traitCollection: The trait collection for the presenting view.
    /// - returns: Image if found.
    public func embeddedImage(using designSystem: RSDDesignSystem? = nil,
                              compatibleWith traitCollection: UITraitCollection? = nil) -> RSDImage? {
        let designSystem = designSystem ?? RSDDesignSystem.shared
        return designSystem.imageRules.assetImage(named: self.resourceName,
                                                  using: self,
                                                  compatibleWith: traitCollection)
    }
    
    #endif
}
