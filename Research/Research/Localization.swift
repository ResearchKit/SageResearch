//
//  Localization.swift
//  Research
//
//  Copyright © 2016-2018 Sage Bionetworks. All rights reserved.
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

/// `LocalizationBundle` is a wrapper for returning a bundle along with a table name and target suffixes.
/// This is used by the `Localization` class to return localized strings that are defined in a strings
/// file embedded in the given bundle.
open class LocalizationBundle : NSObject {
    
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
    
    /// Convenience initializer that uses the default `tableName` and `targetSuffixes`.
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

/// `Localization` is a wrapper class for getting a localized string that allows overriding the
/// bundles to search for a given string. To use this class, call one of the localization methods.
/// To override the value returned by one of the bundles, add the string to a bundle higher up in
/// the list order of the `allBundles` property.
open class Localization: NSObject {
    
    /// List of all the bundles to search for a given localized string. This is an ordered set
    /// of all the bundles to search for a localized string. To add a bundle to this set, use
    /// the `insert(bundle:, at:)` method.
    public private(set) static var allBundles: [LocalizationBundle] = {
        return [LocalizationBundle(Bundle.main), LocalizationBundle(Bundle(for: Localization.self))]
    }()
    
    /// Insert a bundle into `allBundles` at a given index. If the index is beyond the range of
    /// `allBundles`, then the bundle will be appended to the end of the array. If the bundle was
    /// previously in the array, then the previous instance will be moved to the new .
    @objc(insertBundle:atIndex:)
    public static func insert(bundle: LocalizationBundle, at index: UInt) {
        if let idx = allBundles.firstIndex(of: bundle) {
            allBundles.remove(at: idx)
        }
        if (index < allBundles.count) {
            allBundles.insert(bundle, at: Int(index))
        } else {
            allBundles.append(bundle)
        }
    }

    /// Return the localized string for the given key.
    /// - seealso: `NSLocalizedString`
    /// - parameter key: The key into the `Strings` file.
    /// - returns: The localized string or the key if not found.
    public static func localizedString(_ key: String) -> String {
        // Look in these bundles for a localization for the given key
        for bundle in allBundles {
            if let str = bundle.findLocalizedString(for: key) {
                return str
            }
        }
        // Fallback to the key
        return key
    }
    
    /// Return a localized formatted string for the given key and arguments.
    ///
    /// - deprecated: Use `String.localizedStringWithFormat(Localization.localizedString(key), CVarArg...)` instead. This method can crash with an invalid pointer if passed an argument that is not an Obj-c pointer.
    ///
    /// - parameters:
    ///     - key: The key into the `Strings` file.
    ///     - arguments: The argument list for the localized formatted string.
    /// - returns: The localized string or the key if not found.
    @available(*, deprecated, message: "Use `String.localizedStringWithFormat(Localization.localizedString(key), CVarArg...)` instead. This method can crash with an invalid pointer if passed an argument that is not an Obj-c pointer.")
    public static func localizedStringWithFormatKey(_ key: String, _ arguments: CVarArg...) -> String {
        return withVaList(arguments) {
            (NSString(format: localizedString(key), locale: Locale.current, arguments: $0) as String)
            } as String
    }

    /// Join the list of text strings using a localized "or".
    ///
    /// - example:
    /// ````
    ///     let groceryList1 = ["apples", "oranges"]
    ///     print (Localization.localizedJoin(groceryList1))  // "apples or oranges"
    ///
    ///     let groceryList2 = ["apples", "oranges", "bananas", "grapes"]
    ///     print (Localization.localizedJoin(groceryList2))  // "apples, oranges, bananas, or grapes"
    /// ````
    ///
    /// - note: This function is currently written to support US English. Any other language is untested.
    ///
    /// - parameter textList: The list of text values to join.
    /// - returns: A localized `String` with the joined values.
    public static func localizedOrJoin(_ textList: [String]) -> String {
        return _localizedAndOrJoin(textList, or: true)
    }
    
    /// Join the list of text strings using a localized "and".
    ///
    /// - example:
    /// ````
    ///     let groceryList1 = ["apples", "oranges"]
    ///     print (Localization.localizedJoin(groceryList1))  // "apples and oranges"
    ///
    ///     let groceryList2 = ["apples", "oranges", "bananas", "grapes"]
    ///     print (Localization.localizedJoin(groceryList2))  // "apples, oranges, bananas, and grapes"
    /// ````
    ///
    /// - note: This function is currently written to support US English. Any other language is untested.
    ///
    /// - parameter textList: The list of text values to join.
    /// - returns: A localized `String` with the joined values.
    public static func localizedAndJoin(_ textList: [String]) -> String {
        return _localizedAndOrJoin(textList, or: false)
    }
    
    private static func _localizedAndOrJoin(_ textList: [String], or: Bool) -> String {
        switch (textList.count) {
        case 0:
            return ""
        case 1:
            return textList[0]
        case 2:
            let key = or ? "TWO_ITEM_LIST_OR_FORMAT_%1$@_%2$@" : "TWO_ITEM_LIST_AND_FORMAT_%1$@_%2$@"
            return String.localizedStringWithFormat(localizedString(key), textList[0], textList[1])
        default:
            var list: [String] = textList
            let text3 = list.removeLast()
            let text2 = list.removeLast()
            let text1 = list.removeLast()
            let key = or ? "THREE_ITEM_LIST_OR_FORMAT_%1$@_%2$@_%3$@" : "THREE_ITEM_LIST_AND_FORMAT_%1$@_%2$@_%3$@"
            let endText = String.localizedStringWithFormat(localizedString(key), text1, text2, text3)
            list.append(endText)
            let delimiter = localizedString("LIST_FORMAT_DELIMITER")
            return list.joined(separator: delimiter)
        }
    }

    // MARK: Localized App Name
    
    /// The localized name of this App. This method looks at the plist for the main bundle and
    /// returns the most appropriate display name.
    public static let localizedAppName : String = {
        let mainBundle = Bundle.main
        if let bundleInfo = mainBundle.localizedInfoDictionary ?? mainBundle.infoDictionary {
            if let name = bundleInfo["CFBundleDisplayName"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleName"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleExecutable"] as? String {
                return name
            }
        }
        return "???"
    }()
    
    // MARK: Common button titles
    
    /// Localized button title for a "Yes" button.
    @objc open class func buttonYes() -> String {
        return localizedString("BOOL_YES")
    }
    
    /// Localized button title for a "No" button.
    @objc open class func buttonNo() -> String {
        return localizedString("BOOL_NO")
    }
    
    /// Localized button title for an "OK" button.
    @objc open class func buttonOK() -> String {
        return localizedString("BUTTON_OK")
    }
    
    /// Localized button title for a "Cancel" button.
    @objc open class func buttonCancel() -> String {
        return localizedString("BUTTON_CANCEL")
    }
    
    /// Localized button title for a "Done" button.
    @objc open class func buttonDone() -> String {
        return localizedString("BUTTON_DONE")
    }
    
    /// Localized button title for a "Close" button.
    @objc open class func buttonClose() -> String {
        return localizedString("BUTTON_CLOSE")
    }
    
    /// Localized button title for a "Next" button.
    @objc open class func buttonNext() -> String {
        return localizedString("BUTTON_NEXT")
    }
    
    /// Localized button title for a "Back" button.
    @objc open class func buttonBack() -> String {
        return localizedString("BUTTON_BACK")
    }
    
    /// Localized button title for an skip button. Default is "Prefer not to answer".
    @objc open class func buttonSkip() -> String {
        return localizedString("BUTTON_SKIP")
    }
    
    /// Localized button title for a button to skip a task. Default is "I can't do this now".
    @objc open class func buttonSkipTask() -> String {
        return localizedString("BUTTON_SKIP_TASK")
    }
    
    /// Localized button title for a "Get Started" button.
    @objc open class func buttonGetStarted() -> String {
        return localizedString("BUTTON_GET_STARTED")
    }
    
    /// Localized button title for a "Learn more" button.
    @objc open class func buttonLearnMore() -> String {
        return localizedString("BUTTON_LEARN_MORE")
    }
    
    /// Localized button title for a "Pause" button.
    @objc open class func buttonPause() -> String {
        return localizedString("BUTTON_PAUSE")
    }
    
    /// Localized button title for a "Resume" button.
    @objc open class func buttonResume() -> String {
        return localizedString("BUTTON_RESUME")
    }
}
