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

public enum RSDResourceTransformerError : Error {
    case nullResourceName
    case notFound
    case invalidResourceType
}

public protocol RSDResourceTransformer {
    var classType: String? { get }
    var resourceName: String? { get }
    var resourceBundle: String? { get }
}

extension RSDResourceTransformer {
    
    public func resourceData(ofType defaultExtension: String? = nil, bundle: Bundle? = nil) throws -> (Data, RSDResourceType) {
        guard let resourceNamed = self.resourceName else {
            throw RSDResourceTransformerError.nullResourceName
        }
        var resource = resourceNamed
        var ext = defaultExtension ?? RSDResourceType.json.rawValue
        let split = resourceNamed.components(separatedBy: ".")
        if split.count == 2 {
            ext = split.last!
            resource = split.first!
        }
        let rBundle = bundle ?? (resourceBundle != nil ? Bundle(identifier: resourceBundle!) : nil) ?? Bundle.main
        guard let path = rBundle.path(forResource: resource, ofType: ext) else {
            throw RSDResourceTransformerError.notFound
        }
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return (data, RSDResourceType(rawValue: ext)!)
    }
}
