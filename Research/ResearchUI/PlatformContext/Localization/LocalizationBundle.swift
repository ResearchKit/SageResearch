//
//  LocalizationBundle.swift
//  Research
//
//  Copyright © 2016-2020 Sage Bionetworks. All rights reserved.
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
import Research

/// `LocalizationBundle` is a wrapper for returning a bundle along with a table name and target suffixes.
/// This is used by the `Localization` class to return localized strings that are defined in a strings
/// file embedded in the given bundle.
open class LocalizationBundle : NSObject, LocalizationResourceBundle {
    
    public static func registerDefaultBundlesIfNeeded() {
        Localization.insertIfNeeded(bundle: LocalizationBundle(Bundle.module), at: 0)
        Localization.insertIfNeeded(bundle: LocalizationBundle(Bundle.main), at: 0)
    }
    
    /// The bundle to check for a localized string.
    public let bundle: Bundle
    
    /// The table name used as the parameter of the `NSLocalizedString` method.
    public let tableName: String?
    
    /// Any additional target suffixes to remove from the table name in order to search for
    /// a shared strings file.
    public let targetSuffixes: [String]
    
    /// Convenience initializer that uses the default `tableName` and `targetSuffixes`.
    /// - parameter bundle: The bundle to check for a localized string.
    public convenience init(_ bundle: Bundle) {
        let tableName = bundle.bundleIdentifier?.components(separatedBy: ".").last
        let targetSuffixes = ["-iOS", "-tvOS", "-watchOS", "-macOS"]
        self.init(bundle: bundle, tableName: tableName, targetSuffixes: targetSuffixes)
    }
    
    /// - parameters:
    ///     - bundle: The bundle to check for a localized string.
    ///     - tableName: The table name used as the parameter of the `NSLocalizedString` method.
    ///     - targetSuffixes: Any additional target suffixes to remove from the table name in order to
    ///                       search for a shared strings file.
    public init(bundle: Bundle, tableName: String?, targetSuffixes: [String] = []) {
        self.bundle = bundle
        self.tableName = tableName
        self.targetSuffixes = targetSuffixes
    }
    
    /// Find the localized string in this bundle (if any) with the given key.
    /// - parameter key: The key into the `Strings` file.
    /// - returns: The localized string or `nil` if not found.
    open func findLocalizedString(for key: String) -> String? {
        let nilTableStr = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
        if nilTableStr != key {
            // If something is found here then return
            return nilTableStr
        }
        let bundleStr = NSLocalizedString(key, tableName: tableName, bundle: bundle, value: key, comment: "")
        if bundleStr != key {
            // If something is found here then return
            return bundleStr
        }
        if let tableName = tableName {
            // Otherwise, look in the resource that is shared between targets.
            for suffix in targetSuffixes {
                if let range = tableName.range(of: suffix) {
                    let sharedName = String(tableName.prefix(upTo: range.lowerBound))
                    let sharedStr = NSLocalizedString(key, tableName: sharedName, bundle: bundle, value: key, comment: "")
                    if sharedStr != key {
                        // If something is found here then return.
                        return sharedStr
                    }
                }
            }
        }
        
        // If nothing found then return nil
        return nil
    }
    
    // MARK: Equality
    
    override open var hash: Int {
        return bundle.hash ^ RSDObjectHash(tableName as NSString?) ^ RSDObjectHash(targetSuffixes as NSArray)
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let castObject = object as? LocalizationBundle else { return false }
        return castObject.bundle == self.bundle &&
            castObject.tableName == self.tableName &&
            castObject.targetSuffixes == self.targetSuffixes
    }
}
