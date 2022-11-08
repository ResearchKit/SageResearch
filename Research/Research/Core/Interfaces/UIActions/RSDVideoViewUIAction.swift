//
//  RSDVideoViewUIAction.swift
//  Research
//

import Foundation

/// `RSDVideoViewUIAction` implements an extension of the base protocol where the action includes a pointer
/// to a url that can display a video in an `AVPlayerViewController`. The url can either be fully qualified or optionally point to
/// an embedded resource. The resource bundle is assumed to be the main bundle if the `bundleIdentifier`
/// property is `nil`.
public protocol RSDVideoViewUIAction : RSDUIAction, RSDResourceTransformer {
    
    /// The url to load in the `AVPlayerViewController`. If this is not a fully qualified url string, then it is assumed to refer
    /// to an embedded resource.
    var url: String { get }
}
