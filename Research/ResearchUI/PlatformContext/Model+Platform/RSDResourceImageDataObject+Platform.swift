//
//  RSDResourceImageDataObject+Platform.swift
//  Research
//

import Foundation
import Research

extension RSDResourceImageDataObject {

    /// Initialize the wrapper with a given image name.
    /// - parameter imageName: The name of the image to be fetched.
    /// - throws: `RSDValidationError.invalidImageName` if the wrapper cannot convert the `imageName` to an
    ///         image. This error will only be thrown if there is **not** a `sharedDelegate`. In that case,
    ///         this initializer will check that the image is either included in the main bundle or in the
    ///         bundle returned by a call to `RSDResourceConfig.resourceBundle()`.
    public init?(imageName: String, bundle: Bundle?) throws {
        try validateImage(imageName: imageName, bundle: bundle)
        self.init(imageName: imageName)
        self.factoryBundle = bundle
        self.packageName = nil
    }
}

fileprivate func validateImage(imageName: String, bundle: Bundle?) throws {
    // Check that the input string can be converted to an image from an embedded resource bundle or that
    // there is a delegate. Otherwise, this is not a valid string and the wrapper doesn't know how to fetch
    // an image with it.
    #if os(watchOS) || os(macOS)
    guard let _ = RSDImage(named: imageName)
        else {
            throw RSDValidationError.invalidImageName("Invalid image name: \(imageName). Cannot use images on the watch that are not included in the main bundle.")
    }
    #else
    guard let _ = RSDImage(named: imageName, in: bundle, compatibleWith: nil)
        else {
            throw RSDValidationError.invalidImageName("Invalid image name: \(imageName)")
    }
    #endif
}
