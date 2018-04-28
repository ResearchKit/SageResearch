//
//  RSDResourceTransformerObject.swift
//  ResearchStack2
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

/// `RSDResourceTransformerObject` is a concrete implementation of a codable resource transformer.
/// The transformer can be used to create an object decoded from an embedded resource.
public final class RSDResourceTransformerObject : Codable {
    
    /// Either a fully qualified URL string or else a relative reference to either an embedded resource or
    /// a relative URL defined globally by overriding the `RSDResourceConfig` class methods.
    public let resourceName: String
    
    /// The bundle identifier for the embedded resource.
    public let bundleIdentifier: String?
    
    /// The classType for converting the resource to an object. This is a hint that subclasses of
    /// `RSDFactory` can use to determine the type of object to instantiate.
    public let classType: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: Bundle? = nil
    
    private enum CodingKeys: String, CodingKey {
        case resourceName, bundleIdentifier, classType
    }
    
    /// Default initializer for creating the object.
    ///
    /// - parameters:
    ///     - resourceName: The name of the resource.
    ///     - bundleIdentifier: The bundle identifier for the embedded resource.
    ///     - classType: The classType for converting the resource to an object.
    public init(resourceName: String, bundleIdentifier: String? = nil, classType: String? = nil) {
        self.resourceName = resourceName
        self.bundleIdentifier = bundleIdentifier
        self.classType = classType
    }
    
    /// Default initializer for creating the object.
    ///
    /// - parameters:
    ///     - resourceName: The name of the resource.
    ///     - bundleIdentifier: The bundle identifier for the embedded resource.
    ///     - classType: The classType for converting the resource to an object.
    public init(resourceName: String, bundle: Bundle, classType: String? = nil) {
        self.resourceName = resourceName
        self.bundleIdentifier = bundle.bundleIdentifier
        self.factoryBundle = bundle
        self.classType = classType
    }
}

extension RSDResourceTransformerObject : RSDTaskResourceTransformer {
}

extension RSDResourceTransformerObject : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.resourceName, .bundleIdentifier, .classType]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .resourceName:
                if idx != 0 { return false }
            case .bundleIdentifier:
                if idx != 1 { return false }
            case .classType:
                if idx != 2 { return false }
            }
        }
        return keys.count == 3
    }
    
    static func codingMap() -> Array<(CodingKey, Any.Type, String)> {
        let codingKeys: [CodingKeys] = [.resourceName, .bundleIdentifier, .classType]
        return codingKeys.map {
            switch $0 {
            case .resourceName:
                return ($0, String.self, "Either a fully qualified URL string or else a relative reference to either an embedded resource or a relative URL defined globally by overriding the `RSDResourceConfig` class methods.")
            case .bundleIdentifier:
                return ($0, String.self, "The bundle identifier for the embedded resource.")
            case .classType:
                return ($0, String.self, "The classType for converting the resource to an object. This is a hint that subclasses of `RsDFactory` can use to determine the type of object to instantiate.")
            }
        }
    }

    static func examples() -> [Encodable] {
        let exampleA = RSDResourceTransformerObject(resourceName: "FactoryTest_TaskFoo", bundleIdentifier: "org.sagebase.ResearchStack2Tests", classType: "RSDTaskObject")
        let exampleB = RSDResourceTransformerObject(resourceName: "TaskBar")
        return [exampleA, exampleB]
    }
}
