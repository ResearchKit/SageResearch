//
//  RSDImageWrapper.swift
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

/// `RSDEmbeddedIconVendor` is a convenience protocol for fetching an codable image using an optional
/// `RSDImageWrapper`. This protocol implements an extension method to fetch the icon.
public protocol RSDEmbeddedIconVendor {
    
    /// The optional `RSDImageWrapper` with the pointer to the image.
    var icon: RSDImageWrapper? { get }
}

extension RSDEmbeddedIconVendor {
    public var imageVendor: RSDImageVendor? {
        return icon
    }
}

/// The `RSDImageWrapperDelegate` is a singleton delegate that can be used to customize the rules for fetching
/// an image using the `RSDImageWrapper`. If defined and attached to the `RSDImageWrapper` using the static property
/// `sharedDelegate` then the image wrapper will ask the delegate for the appropriate image.
public protocol RSDImageWrapperDelegate {
    
    /// Get an image of the appropriate size.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - imageName:   The name of the image
    ///     - callback:    The callback with the image, run on the main thread.
    func fetchImage(for imageWrapper: RSDImageWrapper, callback: @escaping ((String?, UIImage?) -> Void))
}

/// `RSDImageWrapper` vends an image. It does not handle image caching. If your app using a custom image caching,
/// then you will need to use the shared delegate to implement this. The image wrapper is designed to allow coding of
/// images using an `imageName` property as a key for accessing the image.
public struct RSDImageWrapper {
    
    /// The name of the image to be fetched.
    public let imageName: String
    
    /// The size of the image.
    public let size: CGSize
    
    /// The `sharedDelegate` is a singleton delegate that can be used to customize the rules for fetching
    /// an image using the `RSDImageWrapper`. If defined and attached to the `RSDImageWrapper` using the
    /// this property, then the image wrapper will ask the delegate for the appropriate image.
    public static var sharedDelegate: RSDImageWrapperDelegate?

    /// Initialize the wrapper with a given image name.
    /// - parameter imageName: The name of the image to be fetched.
    /// - throws: `RSDValidationError.invalidImageName` if the wrapper cannot convert the `imageName` to an
    ///         image. This error will only be thrown if there is **not** a `sharedDelegate`. In that case,
    ///         this initializer will check that the image is either included in the main bundle or in the
    ///         bundle returned by a call to `RSDResourceConfig.resourceBundle()`.
    public init?(imageName: String) throws {
        self.size = try RSDImageWrapper.validate(imageName: imageName)
        self.imageName = imageName
    }
    
    private static func validate(imageName: String) throws -> CGSize {
        // Check that the input string can be converted to an image from an embedded resource bundle or that
        // there is a delegate. Otherwise, this is not a valid string and the wrapper doesn't know how to fetch
        // an image with it.
        guard sharedDelegate == nil else { return .zero }
        if let image = UIImage(named: imageName){
            return image.size
        }
        #if os(watchOS)
            throw RSDValidationError.invalidImageName("Invalid image name: \(imageName). Cannot use images on the watch that are not included in the main bundle.")
        #else
            guard let bundle = RSDResourceConfig.resourceBundle(for: imageName),
                let _ = UIImage(named: imageName, in: bundle, compatibleWith: nil)
                else {
                    throw RSDValidationError.invalidImageName("Invalid image name: \(imageName)")
            }
        #endif
        return .zero
    }
    
    /// Fetch the image.
    ///
    /// - parameters:
    ///     - size:        The size of the image to return.
    ///     - callback:    The callback with the image, run on the main thread.
    public func fetchImage(for size: CGSize, callback: @escaping ((String?, UIImage?) -> Void)) {
        if let delegate = RSDImageWrapper.sharedDelegate {
            delegate.fetchImage(for: self, callback: callback)
        }
        else if let image = UIImage(named: imageName) {
            DispatchQueue.main.async {
                callback(self.imageName, image)
            }
        }
        else if let url = URL(string: self.imageName) {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            let task = URLSession.shared.dataTask(with: request) {(data, _, _) in
                    let image: UIImage? = (data != nil) ? UIImage(data: data!) : nil
                    DispatchQueue.main.async {
                        callback(self.imageName, image)
                    }
            }
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                callback(self.imageName, nil)
            }
        }
    }
}

extension RSDImageWrapper : RawRepresentable {
    public typealias RawValue = String
    
    /// The `imageName` is used to represent the image wrapper.
    public var rawValue: String {
        return imageName
    }
    
    /// Required initializer for conformance to `RawRepresentable`. This will return `nil` if the image
    /// is not valid.
    public init?(rawValue: String) {
        do {
            try self.init(imageName: rawValue)
        } catch let err {
            assertionFailure("Failed to create image: \(err)")
            return nil
        }
    }
}

extension RSDImageWrapper : Equatable {
    public static func ==(lhs: RSDImageWrapper, rhs: RSDImageWrapper) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func ==(lhs: String, rhs: RSDImageWrapper) -> Bool {
        return lhs == rhs.rawValue
    }
    public static func ==(lhs: RSDImageWrapper, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension RSDImageWrapper : ExpressibleByStringLiteral {    
    /// Required initializer for conformance to `ExpressibleByStringLiteral`.
    /// - parameter stringLiteral: The `imageName` for this image wrapper.
    public init(stringLiteral value: String) {
        self.size = try! RSDImageWrapper.validate(imageName: value)
        self.imageName = value
    }
}

extension RSDImageWrapper : Decodable {
    
    /// Required initializer for conformance to `Decodable`.
    /// - parameter decoder: The decoder to use to decode this value. This is expected to have a single value container.
    /// - throws: `DecodingError` if the value is not a `String` or `RSDValidationError.invalidImageName` if the wrapper
    ///         cannot convert the string to an image.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let imageName = try container.decode(String.self)
        self.size = try RSDImageWrapper.validate(imageName: imageName)
        self.imageName = imageName
    }
}

extension RSDImageWrapper : Encodable {
}

extension RSDImageWrapper : RSDDocumentableStringLiteral {
    static func examples() -> [String] {
        return ["happyFaceIcon"]
    }
}
