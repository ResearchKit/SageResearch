//
//  RSDResourceImageDataObject.swift
//  Research
//

import Foundation
import JsonModel

extension String {
    
    /// Convenience utility for spliting a string that represents a file into it's name and extension.
    public func splitFilename(defaultExtension: String? = nil) -> (resourceName: String, fileExtension: String?) {
        var resource = self
        var ext = defaultExtension
        let split = self.components(separatedBy: ".")
        if split.count == 2 {
            ext = split.last!
            resource = split.first!
        }
        return (resource, ext)
    }
}

/// `RSDEmbeddedIconData` is a convenience protocol for fetching an codable image using an optional
/// `RSDResourceImageDataObject`. This protocol implements an extension method to fetch the icon.
public protocol RSDEmbeddedIconData {
    
    /// The optional `RSDResourceImageDataObject` with the pointer to the image.
    var icon: RSDResourceImageDataObject? { get }
}

extension RSDEmbeddedIconData {
    public var imageData: RSDImageData? {
        return icon
    }
}

/// Implementation of a resource image pointer that can be decoded from a string.
public struct RSDResourceImageDataObject : RSDThemeResourceImageData, Codable, Hashable {
    
    /// The name of the image.
    public let imageName: String
    
    /// For a raw resource file, this is the file extension for getting at the resource.
    public let rawFileExtension: String?
    
    /// Pointer to the factory bundle.
    public var factoryBundle: ResourceBundle?
    
    /// The package within which the resource is embedded on Android platforms.
    public var packageName: String?
    
    /// Bundle identifier is always `nil`. If set, this object uses the `factoryBundle`.
    public var bundleIdentifier: String? {
        return nil
    }
    
    /// Always returns `nil`.
    public var placementType: RSDImagePlacementType? {
        return nil
    }
    
    /// Always returns `nil`.
    public var imageSize: RSDSize? {
        return nil
    }
    
    public init(imageName: String, factoryBundle: ResourceBundle? = nil, packageName: String? = nil) {
        let splitFile = imageName.splitFilename()
        self.imageName = splitFile.resourceName
        self.rawFileExtension = splitFile.fileExtension
        self.factoryBundle = factoryBundle
        self.packageName = packageName
    }
    
    public init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let filename = try singleValueContainer.decode(String.self)
        let splitFile = filename.splitFilename()
        self.imageName = splitFile.resourceName
        self.rawFileExtension = splitFile.fileExtension
        self.factoryBundle = decoder.bundle
        self.packageName = decoder.packageName
    }
    
    public func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(self.filename)
    }
}

extension RSDResourceImageDataObject : RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String {
        self.filename
    }
    
    public init(rawValue: String) {
        self.init(imageName: rawValue)
    }
}

extension RSDResourceImageDataObject : ExpressibleByStringLiteral {
    /// Required initializer for conformance to `ExpressibleByStringLiteral`.
    /// - parameter stringLiteral: The `imageName` for this image wrapper.
    public init(stringLiteral value: String) {
        self.init(imageName: value)
    }
}

extension RSDResourceImageDataObject : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return ["happyFaceIcon"]
    }
}
