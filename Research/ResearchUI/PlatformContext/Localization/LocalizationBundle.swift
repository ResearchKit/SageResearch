//
//  LocalizationBundle.swift
//  Research
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
