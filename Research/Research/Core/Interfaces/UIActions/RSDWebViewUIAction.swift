//
//  RSDWebViewUIAction.swift
//  Research
//

import Foundation

/// `RSDWebViewUIAction` implements an extension of the base protocol where the action includes a pointer
/// to a url that can display in a webview. The url can either be fully qualified or optionally point to
/// an embedded resource. The resource bundle is assumed to be the main bundle if the `bundleIdentifier`
/// property is `nil`.
public protocol RSDWebViewUIAction : RSDUIAction, RSDResourceTransformer {
    
    /// The url to load in the webview. If this is not a fully qualified url string, then it is assumed to refer
    /// to an embedded resource.
    var url: String { get }
    
    /// Should this webview be presented with a `<-` style of closure or a `X` style of closure?
    /// If nil, then the default will assume `X`.
    ///
    /// - note: This is only applicable to devices that use a back button or close button. Otherwise, it is
    /// ignored.
    var usesBackButton: Bool? { get }
    
    /// The title to show in a title bar or header.
    var title: String? { get }
    
    /// Optional title for a close button. If non-nil, this will be rendered on iPhone devices using a footer.
    var closeButtonTitle: String? { get }
}
