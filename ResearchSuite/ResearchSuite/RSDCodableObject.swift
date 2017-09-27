//
//  RSDCodableObject.swift
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

public struct RSDKeyMap : RawRepresentable {
    public typealias RawValue = String
    
    public private(set) var rawValue: String
    public let stringValue: String
    public let propertyKey: String
    
    public init?(rawValue: String) {
        let components = rawValue.components(separatedBy: ",")
        self.rawValue = rawValue
        self.propertyKey = components.first!
        self.stringValue = components.last!
    }
    
    public init(propertyKey: String, stringValue: String?) {
        self.propertyKey = propertyKey
        self.stringValue = stringValue ?? propertyKey
        self.rawValue = propertyKey.appending(stringValue != nil ? ",\(stringValue!)" : "")
    }
}

extension RSDKeyMap : Equatable {
    public static func ==(lhs: RSDKeyMap, rhs: RSDKeyMap) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension RSDKeyMap : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

open class RSDCodableObject : NSObject, NSCopying, RSDDictionaryRepresentable {
    
    public override init() {
        super.init()
    }
    
    public required init(dictionaryRepresentation dictionary: [AnyHashable : Any]) {
        super.init()
        for key in self.dictionaryRepresentationKeys {
            if let obj = dictionary[key.stringValue], !(obj is NSNull) {
                self.setValue(obj, forKey: key.propertyKey)
            }
        }
    }
    
    public func dictionaryRepresentation() -> [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        for key in self.dictionaryRepresentationKeys {
            if let obj = self.value(forKey: key.propertyKey) {
                let value = (obj as? RSDJSONValue)?.jsonObject() ?? obj
                if !(value is NSNull) {
                    dictionary[key.stringValue] = value
                }
            }
        }
        return dictionary
    }
    
    /**
     List of the key mapping to use the convert this object to/from a dictionary.
     */
    open var dictionaryRepresentationKeys : [RSDKeyMap] {
        return []
    }
    
    
    // MARK: NSObject KVO overrides
    
    open override func setValue(_ value: Any?, forKey key: String) {
        var obj = value
        if let dictionary = value as? [AnyHashable : Any] {
            obj = self.object(with: dictionary, forKey: key) ?? value
        }
        else if let array = value as? [Any] {
            obj = array.map { (anObj) -> Any in
                if let dictionary = value as? [AnyHashable : Any] {
                    return self.object(with: dictionary, forKey: key) ?? anObj
                }
                else {
                    return anObj
                }
            }
        }
        else if let stringObject = value as? String, let classT = self.classType(forKey: key) {
            if classT == Date.self {
                obj = RSDClassTypeMap.shared.timestampFormatter.date(from: stringObject)
            }
            else if classT == UUID.self {
                obj = UUID(uuidString: stringObject)
            }
            else if classT == URL.self {
                obj = URL(string: stringObject)
            }
            else if classT == DateComponents.self, let date = RSDClassTypeMap.shared.timestampFormatter.date(from: stringObject) {
                obj = Calendar(identifier: .gregorian).dateComponents(in: .current, from: date)
            }
        }
        super.setValue(obj, forKey: key)
    }
    
    /**
     Base class implementation of the class type for a given property key is nil if there is no default value. This is used to get the default class type for a given property key.
     */
    open func classType(forKey key: String) -> Any.Type? {
        guard let currentValue = self.value(forKey: key) else { return nil }
        return type(of: currentValue)
    }
    
    /**
     Objecte to return for the given dictionary with the given key.
     */
    open func object(with dictionaryRepresentation: [AnyHashable : Any], forKey key: String) -> Any? {
        if let classType = self.classType(forKey: key) as? AnyClass {
            return try? RSDClassTypeMap.shared.object(with: dictionaryRepresentation, defaultType: classType)
        }
        else {
            return try? RSDClassTypeMap.shared.object(with: dictionaryRepresentation)
        }
    }
    
    
    // MARK: Copying
    
    open func copy(with zone: NSZone? = nil) -> Any {
        let dictionary = self.dictionaryRepresentation()
        return type(of: self).init(dictionaryRepresentation: dictionary)
    }
    
    
    // MARK: Equality
    
    open override var hash: Int {
        return (self.dictionaryRepresentation() as NSDictionary).hash
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let castObject = object as? RSDCodableObject else { return false }
        return type(of: object!) == type(of: self) &&
            (castObject.dictionaryRepresentation() as NSDictionary).isEqual(to: self.dictionaryRepresentation())
    }
}
