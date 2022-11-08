//
//  Dictionary+Utilities.swift
//  Research
//

import Foundation

public protocol RSDDictionaryExtension {
}

extension Dictionary : RSDDictionaryExtension {
    
    /// Returns a `Dictionary` containing the results of transforming the keys
    /// over `self` where the returned values are the mapped keys.
    /// - parameter transform: The function used to transform the input keys into the output key
    /// - returns: A dictionary of key/value pairs.
    public func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            let transformedKey = try transform(key)
            result[transformedKey] = value
        }
        return result
    }
}
