//
//  Localization.swift
//  Research
//

import Foundation

@objc
public protocol LocalizationResourceBundle : NSObjectProtocol {
    func findLocalizedString(for key: String) -> String?
}

/// `Localization` is a wrapper class for getting a localized string that allows overriding the
/// bundles to search for a given string. To use this class, call one of the localization methods.
/// To override the value returned by one of the bundles, add the string to a bundle higher up in
/// the list order of the `allBundles` property.
open class Localization: NSObject {
    
    /// List of all the bundles to search for a given localized string. This is an ordered set
    /// of all the bundles to search for a localized string. To add a bundle to this set, use
    /// the `insert(bundle:, at:)` method.
    public private(set) static var allBundles: [LocalizationResourceBundle] = []
    
    /// Insert a bundle into `allBundles` at a given index. If the index is beyond the
    /// range of `allBundles`, then the bundle will be appended to the end of the array.
    /// If the bundle was previously in the array, then the bundle will be moved to the
    /// new index position.
    @objc(insertBundle:atIndex:)
    public static func insert(bundle: LocalizationResourceBundle, at index: UInt) {
        if let idx = allBundles.firstIndex(where: { $0.isEqual(bundle) }) {
            allBundles.remove(at: idx)
        }
        if (index < allBundles.count) {
            allBundles.insert(bundle, at: Int(index))
        } else {
            allBundles.append(bundle)
        }
    }
    
    /// Insert a bundle into `allBundles` at a given index if and only if the list of
    /// bundles does not already include the bundle. If the index is beyond the range of
    /// `allBundles`, then the bundle will be appended to the end of the array.
    public static func insertIfNeeded(bundle: LocalizationResourceBundle, at index: UInt) {
        guard !allBundles.contains(where: { $0.isEqual(bundle) }) else { return }
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
    @available(*, deprecated, message: "Use `currentPlatformContext.localizedAppName` instead.")
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
