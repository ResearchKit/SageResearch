//
//  ResourceInfo.swift
//  Research
//

import Foundation
import JsonModel

/// The resource data info describes additional information for a *specific* file.
public protocol RSDResourceDataInfo : ResourceInfo {
    
    /// The name of the resource.
    var resourceName: String { get }
    
    /// For a raw resource file, this is the file extension for getting at the resource.
    var rawFileExtension: String? { get }
    
    
    // MARK: Android
    
    /// The android-type of the resource.
    ///
    /// - note: This is different from the Apple bundle structure where you would use either the
    /// raw file extension or the initializer with the resource name and bundle to construct the
    /// object.
    var resourceType: String? { get }
}

extension RSDResourceDataInfo {
    
    /// The filename is the resourceName and the raw file extension (if provided).
    public var filename : String {
        var filename = self.resourceName
        if let ext = self.rawFileExtension {
            filename.append(".")
            filename.append(ext)
        }
        return filename
    }
}

