//
//  RSDResourceTransformer.swift
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

public struct RSDResourceType : RawRepresentable, Equatable, Hashable {
    public typealias RawValue = String
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public static func ==(lhs: RSDResourceType, rhs: RSDResourceType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public static let json = RSDResourceType(rawValue: "json")!
    public static let plist = RSDResourceType(rawValue: "plist")!
    public static let html = RSDResourceType(rawValue: "html")!
    public static let pdf = RSDResourceType(rawValue: "pdf")!
}

public enum RSDResourceTransformerError : Error, CustomNSError {
    case nullResourceName(String)
    case bundleNotFound(String)
    case fileNotFound(String)
    case invalidResourceType(String)
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "RSDResourceTransformerErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .nullResourceName(_):
            return -1
        case .bundleNotFound(_):
            return -2
        case .fileNotFound(_):
            return -3
        case .invalidResourceType(_):
            return -4
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        let description: String
        switch(self) {
        case .nullResourceName(let str): description = str
        case .bundleNotFound(let str): description = str
        case .fileNotFound(let str): description = str
        case .invalidResourceType(let str): description = str
        }
        return ["NSDebugDescription": description]
    }
}

public protocol RSDResourceTransformer {
    var classType: String? { get }
    var resourceName: String? { get }
    var resourceBundle: String? { get }
}

extension RSDResourceTransformer {
    
    public func resourceData(ofType defaultExtension: String? = nil, bundle: Bundle? = nil) throws -> (Data, RSDResourceType) {
        
        // get the resource name and extention
        guard let resourceName = self.resourceName else {
            throw RSDResourceTransformerError.nullResourceName("\(self) does not have a resource name")
        }
        var resource = resourceName
        var ext = defaultExtension ?? RSDResourceType.json.rawValue
        let split = resourceName.components(separatedBy: ".")
        if split.count == 2 {
            ext = split.last!
            resource = split.first!
        }
        
        // get the bundle
        let rBundle: Bundle
        if bundle != nil {
            rBundle = bundle!
        }
        else if let bundleIdentifier = resourceBundle {
            if let bundle = Bundle(identifier: bundleIdentifier) {
                rBundle = bundle
            }
            else {
                let bundleIds = Bundle.allBundles.mapAndFilter { $0.bundleIdentifier }
                throw RSDResourceTransformerError.bundleNotFound("\(bundleIdentifier) Not Found. Available identifiers: \(bundleIds.joined(separator: ","))")
            }
        }
        else {
            rBundle = Bundle.main
        }

        // get the url
        guard let url = rBundle.url(forResource: resource, withExtension: ext) else {
            throw RSDResourceTransformerError.fileNotFound("\(resourceName) not found in \(String(describing: rBundle.bundleIdentifier))")
        }
        
        // get the data
        let data = try Data(contentsOf: url)
        return (data, RSDResourceType(rawValue: ext)!)
    }
}
