//
//  RSDImageThemeObject.swift
//  Research
//
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


public struct RSDFetchableImageThemeElementObject : RSDThemeResourceImageData, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case imageName, bundleIdentifier, packageName, imageSize = "size", placementType, rawFileExtension = "fileExtension"
    }
    
    /// The name of the resource.
    public let imageName: String
    
    /// For a raw resource file, this is the file extension for getting at the resource.
    public let rawFileExtension: String?
    
    /// Pointer to the factory bundle.
    public var factoryBundle: RSDResourceBundle?
    
    /// The identifier of the bundle within which the resource is embedded on Apple platforms.
    public let bundleIdentifier: String?
    
    /// The package within which the resource is embedded on Android platforms.
    public var packageName: String?
    
    /// The size of the image (if known).
    public let imageSize: RSDSize?
    
    /// The preferred placement of the image. Included for conformance to image theme elements.
    public let placementType: RSDImagePlacementType?
    
    public var resourceName: String {
        return imageName
    }
    
    public init(imageName: String, bundle: RSDResourceBundle? = nil, packageName: String? = nil, bundleIdentifier: String? = nil) {
        let splitFile = imageName.splitFilename()
        self.imageName = splitFile.resourceName
        self.rawFileExtension = splitFile.fileExtension
        self.factoryBundle = bundle
        self.bundleIdentifier = bundleIdentifier
        self.packageName = packageName
        self.imageSize = nil
        self.placementType = nil
    }
}


/// `RSDAnimatedImageThemeElementObject` is a `Codable` concrete implementation of `RSDAnimatedImageThemeElement`.
public struct RSDAnimatedImageThemeElementObject : RSDAnimatedImageThemeElement, RSDThemeResourceImageData, Codable {

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case imageNames, animationDuration, animationRepeatCount, bundleIdentifier, packageName, placementType, imageSize = "size", rawFileExtension = "fileExtension"
    }
    
    /// The list of image names for the images to include in this animation.
    public let imageNames: [String]
    
    /// The animation duration for the image animation.
    public let animationDuration: TimeInterval
    
    /// This is used to set how many times the animation should be repeated where `0` means infinite.
    public let animationRepeatCount: Int?
    
    /// The preferred placement of the image.
    public let placementType: RSDImagePlacementType?
    
    /// The bundle identifier for the image resource bundle.
    public let bundleIdentifier: String?
    
    /// The image size.
    public let imageSize: RSDSize?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: RSDResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// The raw file
    public let rawFileExtension: String?
    
    /// The animation images for this theme element.
    public var animationImageNames: [String]? {
        return self.imageNames
    }
    
    /// The image name is the name of the first image in the series.
    public var imageName: String {
        return self.imageNames.first ?? "null"
    }

    /// Default initializer.
    ///
    /// - parameters:
    ///     - imageNames: The names of the images.
    ///     - bundleIdentifier: The bundle identifier for the image resource bundle. Default = `nil`.
    ///     - animationDuration: The animation duration.
    ///     - placementType: The preferred placement of the image. Default = `nil`.
    ///     - size: The image size. Default = `nil`.
    public init(imageNames: [String], animationDuration: TimeInterval, bundleIdentifier: String? = nil, placementType: RSDImagePlacementType? = nil, size: RSDSize? = nil, animationRepeatCount: Int = 0) {
        self.imageNames = imageNames
        self.bundleIdentifier = bundleIdentifier
        self.animationDuration = animationDuration
        self.imageSize = size
        self.placementType = placementType
        self.animationRepeatCount = animationRepeatCount
        self.rawFileExtension = nil
    }
}

extension RSDAnimatedImageThemeElementObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    static func imageThemeExamples() -> [RSDAnimatedImageThemeElementObject] {
        let imageA = RSDAnimatedImageThemeElementObject(imageNames: ["blueDog1", "blueDog2", "blueDog3"], animationDuration: 2)
        let imageB = RSDAnimatedImageThemeElementObject(imageNames: ["redCat1", "redCat2", "redCat3"], animationDuration: 2, bundleIdentifier: "org.example.SharedResources", placementType: .topBackground, size: RSDSize(width: 100, height: 120))
        return [imageA, imageB]
    }
    
    static func examples() -> [Encodable] {
        return imageThemeExamples()
    }
}
