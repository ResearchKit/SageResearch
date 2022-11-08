//
//  RSDViewThemeElement.swift
//  Research
//

import Foundation
import JsonModel


/// `RSDViewThemeElement` tells the UI where to find the view controller to use when instantiating the
/// `RSDStepController`.
public protocol RSDViewThemeElement : ResourceInfo {
    
    // MARK: Apple
    
    /// The storyboard view controller identifier or the nib name for this view controller.
    var viewIdentifier: String { get }
    
    /// If the storyboard identifier is non-nil then the view is assumed to be accessible within the storyboard
    /// via the `viewIdentifier`.
    var storyboardIdentifier: String? { get }
    
    // MARK: Android
    
    var fragmentIdentifier: String? { get }
    var fragmentLayout: String? { get }
}
