//
//  RSDImageData.swift
//  Research
//

import JsonModel

/// The image data protocol is used to define a placeholder for image data.
public protocol RSDImageData {
    
    /// A unique identifier that can be used to validate that the image shown in a reusable view
    /// is the same image as the one fetched.
    var imageIdentifier: String { get }
}

/// A resource image data is embedded within a resource bundle using the given platform's standard
/// asset management tools.
public protocol RSDResourceImageData : RSDImageData, RSDResourceDataInfo {
}

extension RSDResourceImageData {
    
    /// The image identifier for a resource image is the `resourceName`.
    public var imageIdentifier: String {
        guard let bundleId = self.bundleIdentifier ?? self.packageName
            else {
                return self.resourceName
        }
        return "\(bundleId).\(self.resourceName)"
    }
    
    /// The Android resource type for an image is always "drawable".
    public var resourceType: String? {
        return "drawable"
    }
}

/// This framework includes different decodables that implement both the `RSDResourceImageData`
/// protocol and the `RSDImageThemeElement` protocol. This shared protocol provides for a
/// consistent implementation for both by setting the `resourceName` to the same as the `imageName`.
public protocol RSDThemeResourceImageData : RSDImageThemeElement, RSDResourceImageData, DecodableBundleInfo {
}

extension RSDThemeResourceImageData {
    
    public var resourceName: String {
        return self.imageName
    }
}
