//
//  ResourceLoader.swift
//  Research
//

import Foundation
import JsonModel
import Research

public final class ResourceLoader : RSDResourceLoader {
    
    public init() {
    }

    public func url(for resourceInfo: RSDResourceTransformer, ofType defaultExtension: String?, using bundle: ResourceBundle?) throws -> (url: URL, resourceType: RSDResourceType) {
        
        // get the resource name and extension
        let splitValue = resourceInfo.resourceName.splitFilename(defaultExtension: defaultExtension)
        let resource = splitValue.resourceName
        let ext = splitValue.fileExtension ?? RSDResourceType.json.rawValue
        let resourceType = RSDResourceType(rawValue: ext)
        
        // get the bundle
        let rBundle: Bundle
        if let inBundle = bundle as? Bundle {
            rBundle = inBundle
        }
        else if let factoryBundle = resourceInfo.bundle {
            rBundle = factoryBundle
        }
        else if let bundleIdentifier = resourceInfo.bundleIdentifier {
            let bundleIds = Bundle.allBundles.compactMap { $0.bundleIdentifier }
            throw RSDResourceTransformerError.bundleNotFound("\(bundleIdentifier) Not Found. Available identifiers: \(bundleIds.joined(separator: ","))")
        }
        else {
            rBundle = Bundle.main
        }

        // get the url
        guard let url = rBundle.url(forResource: resource, withExtension: ext) else {
            throw RSDResourceTransformerError.fileNotFound("\(resource) not found in \(String(describing: rBundle.bundleIdentifier))")
        }
        
        return (url, resourceType)
    }
}
