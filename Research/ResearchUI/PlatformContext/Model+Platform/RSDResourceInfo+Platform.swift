//
//  ResourceInfo+Platform.swift
//  Research
//

import Foundation
import JsonModel

extension ResourceInfo {
    
    /// The bundle returned for the given `bundleIdentifier` or `factoryBundle` if `nil`.
    public var bundle: Bundle? {
        return bundleIdentifier.flatMap { Bundle(identifier: $0) } ?? (self.factoryBundle as? Bundle)
    }
}
