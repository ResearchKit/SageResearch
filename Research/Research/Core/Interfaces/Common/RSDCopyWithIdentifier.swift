//
//  RSDCopyWithIdentifier.swift
//  Research
//

import Foundation


/// A lightweight protocol for copying objects with a new identifier.
public protocol RSDCopyWithIdentifier {
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    func copy(with identifier: String) -> Self
}
