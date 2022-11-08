//
//  RSDImageVendor.swift
//  Research
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import Research

/// `RSDImageVendor` is a protocol for defining an abstract method for fetching an image.
@available(*, deprecated, message: "Use `RSDImageData` instead.")
public protocol RSDImageVendor : RSDImageData {
    
    /// The size of the image.
    var size: CGSize { get }
    
    /// Fetch the image.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the identifier and image, run on the main thread.
    func fetchImage(for size: CGSize, callback: @escaping ((String?, RSDImage?) -> Void))
}
