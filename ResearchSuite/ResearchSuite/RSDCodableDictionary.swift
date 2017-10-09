//
//  RSDCodableDictionary.swift
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

/**
 Work-around for a `Codable Dictionary` that does not use a String as it's key.
 
 See https://stackoverflow.com/questions/44725202/swift-4-decodable-dictionary-with-enum-as-key
 
 Example usage:
 
 ````
 enum AnEnum : String, CodingKey {
     case enumValue
 }
 
 struct AStruct: Codable {
 
     let dictionary: [AnEnum: String]
 
     private enum CodingKeys : CodingKey {
         case dictionary
     }
 
     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         dictionary = try container.decode(CodableDictionary.self, forKey: .dictionary).decoded
     }
 
     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(CodableDictionary(dictionary), forKey: .dictionary)
     }
 }
 ````
 */
public struct RSDCodableDictionary<Key : Hashable, Value : Codable> : Codable where Key : CodingKey {
    
    let decoded: [Key: Value]
    
    init(_ decoded: [Key: Value]) {
        self.decoded = decoded
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: Key.self)
        
        decoded = Dictionary(uniqueKeysWithValues:
            try container.allKeys.lazy.map {
                (key: $0, value: try container.decode(Value.self, forKey: $0))
            }
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Key.self)
        
        for (key, value) in decoded {
            try container.encode(value, forKey: key)
        }
    }
}
