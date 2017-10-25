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

/**
 A protocol for vending an image of the appropriate size for the given rect.
 */
public protocol RSDResizableImage {
    
    /**
     A value that can be used to identify the image as unique.
     */
    var identifier: String { get }
    
    /**
     Get an image of the appropriate size.
     
     @param size        The size of the image to return.
     @param callback    The callback with the image, run on the main thread.
     */
    func fetchImage(for size: CGSize, callback: @escaping ((UIImage?) -> Void))
}

public protocol RSDImageWrapperDelegate {
    
    /**
     Get an image of the appropriate size.
     
     @param size        The size of the image to return.
     @param imageName   The name of the image
     @param callback    The callback with the image, run on the main thread.
     */
    func fetchImage(for size: CGSize, with imageName: String, callback: @escaping ((UIImage?) -> Void))
}

/**
 The image wrapper vends an image. It does not handle image caching. If your app using a custom image caching, then you will need to use the shared delegate to implement this.
 */
public struct RSDImageWrapper : RSDResizableImage {
    public let imageName: String
    
    public var identifier: String {
        return imageName
    }
    
    public static var sharedDelegate: RSDImageWrapperDelegate?
    
    public static func fetchImage(image: RSDImageWrapper?, for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        guard let wrapper = image else {
            DispatchQueue.main.async {
                callback(nil)
            }
            return
        }
        wrapper.fetchImage(for: size, callback: callback)
    }

    public init?(imageName: String) throws {
        try RSDImageWrapper.validate(imageName: imageName)
        self.imageName = imageName
    }
    
    private static func validate(imageName: String) throws {
        // Check that the input string can be converted to an image, url or that there is a delegate.
        // Otherwise, this is not a valid string and the wrapper doesn't know how to fetch an image with it.
        guard (sharedDelegate != nil) ||
            (UIImage(named: imageName) != nil) ||
            (URL(string: imageName) != nil)
            else {
                throw RSDValidationError.invalidImageName("Invalid image name: \(imageName)")
        }
    }
    
    public func fetchImage(for size: CGSize, callback: @escaping ((UIImage?) -> Void)) {
        if let delegate = RSDImageWrapper.sharedDelegate {
            delegate.fetchImage(for: size, with: self.imageName, callback: callback)
        }
        else if let image = UIImage(named: imageName) {
            DispatchQueue.main.async {
                callback(image)
            }
        }
        else if let url = URL(string: self.imageName) {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
            let task = URLSession.shared.dataTask(with: request) {(data, _, _) in
                    let image: UIImage? = (data != nil) ? UIImage(data: data!) : nil
                    DispatchQueue.main.async {
                        callback(image)
                    }
            }
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                callback(nil)
            }
        }
    }
}


extension RSDImageWrapper : RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String {
        return imageName
    }
    
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
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

extension RSDImageWrapper : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let imageName = try container.decode(String.self)
        try RSDImageWrapper.validate(imageName: imageName)
        self.imageName = imageName
    }
}

extension RSDImageWrapper : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.imageName)
    }
}
