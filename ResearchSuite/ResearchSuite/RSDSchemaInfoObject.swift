//
//  RSDSchemaInfoObject.swift
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

/// `RSDSchemaInfoObject` is a concrete implementation of the `RSDSchemaInfo` protocol.
public struct RSDSchemaInfoObject : RSDSchemaInfo, Codable {
    private let identifier: String
    private let revision: Int
    
    /// A short string that uniquely identifies the associated result schema.
    public var schemaIdentifier: String? {
        return identifier
    }
    
    /// A revision number associated with the result schema.
    public var schemaRevision: Int {
        return revision
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier, revision
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the associated result schema.
    ///     - revision: A revision number associated with the result schema.
    public init(identifier: String, revision: Int) {
        self.identifier = identifier
        self.revision = revision
    }
}

extension RSDSchemaInfoObject : Equatable {
    public static func ==(lhs: RSDSchemaInfoObject, rhs: RSDSchemaInfoObject) -> Bool {
        return lhs.schemaIdentifier == rhs.schemaIdentifier &&
            lhs.schemaRevision == rhs.schemaRevision
    }
}

extension RSDSchemaInfoObject : Hashable {
    public var hashValue : Int {
        return (schemaIdentifier?.hashValue ?? 0) ^ schemaRevision
    }
}

extension RSDSchemaInfoObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .revision]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .revision:
                if idx != 1 { return false }
            }
        }
        return keys.count == 2
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let json: [String : RSDJSONValue] = [
            "identifier": "foo",
            "revision": 3 ]
        return [json]
    }
}

