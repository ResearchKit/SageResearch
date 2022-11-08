//
//  RSDImage.swift
//  ResearchPlatformContext
//

#if os(macOS)
import AppKit
public typealias RSDImage = NSImage
#else
import UIKit
public typealias RSDImage = UIImage
#endif

import JsonModel
import Research

extension RSDImage : RSDImageData {
    
    /// Returns `self.hash` as a string.
    public var imageIdentifier: String {
        return self.accessibilityIdentifier ?? "\(self.hash)"
    }
    
    #if os(macOS) || os(watchOS)
    var accessibilityIdentifier: String? {
        return nil
    }
    #endif
}

extension RSDImage : RSDImageThemeElement {

    /// The image name is the same as the image identifier.
    public var imageName: String {
        return imageIdentifier
    }
    
    /// Use `size`.
    public var imageSize: RSDSize? {
        return RSDSize(width: Double(self.size.width), height: Double(self.size.height))
    }
    
    /// MARK: Not used.
    
    public var placementType: RSDImagePlacementType? { return nil }
    public var factoryBundle: ResourceBundle? { return nil }
    public var bundleIdentifier: String? { return nil }
    public var packageName: String? { return nil }
}
