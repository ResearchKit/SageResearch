//
//  RSDWebViewUIAction.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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
