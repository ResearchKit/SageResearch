//
//  CodableObjectTests.swift
//  ResearchTests
//

import XCTest
import Research
import JsonModel
@testable import Research_UnitTest

class BundleWrapper {
    class var bundleIdentifier: String? {
        return Bundle.module.bundleIdentifier
    }
}

struct TestResourceWrapper : RSDResourceTransformer, Codable {

    private enum CodingKeys : String, CodingKey, CaseIterable {
        case resourceName, bundleIdentifier, classType
    }
    
    let resourceName: String
    let bundleIdentifier: String?
    let classType: String?
    var factoryBundle: ResourceBundle? = nil
    var packageName: String? = nil

    public init(resourceName: String, bundleIdentifier: String?) {
        self.resourceName = resourceName
        self.bundleIdentifier = bundleIdentifier
        self.classType = nil
    }
}

var decoder: JSONDecoder {
    setupPlatformContext()
    return RSDFactory.shared.createJSONDecoder()
}

var encoder: JSONEncoder {
    return RSDFactory.shared.createJSONEncoder()
}
