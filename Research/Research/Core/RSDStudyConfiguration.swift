//
//  RSDStudyConfiguration.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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
import JsonModel

/// The study configuration is intended as a shared singleton that contains any information that should be
/// applied to the entire study that may effect the presentation of a given module.
open class RSDStudyConfiguration {
    
    /// Singleton for the study configuration for a given app.
    open class var shared: RSDStudyConfiguration {
        get { return _shared }
        set { _shared = newValue }
    }
    private static var _shared: RSDStudyConfiguration = RSDStudyConfiguration()
    
    /// How often should a given task be displayed to the user with the full instructions?
    /// (Default = `always`)
    ///
    /// Setting this flag to `always` will result in modules that use this flag showing the full instruction
    /// sequence for every run. This can be used both to test the instruction flow as well as where a study
    /// uses the same mobile device for multiple participants and needs to display the instructions every
    /// time.
    ///
    /// Setting this flag to another value will result in modules that use this flag showing an abbreviated
    /// set of instructions for subsequent runs so that complicated and/or lengthy instructions can be
    /// limited to only being displayed sometimes (first run, on demand, etc.) rather than every time the
    /// *same* user runs the module. For this case, the frequency with which the app shows the full
    /// instructions is determined by the frequency type. For example, if set to `monthly` then the user is
    /// shown the full instructions once per month.
    ///
    open var fullInstructionsFrequency : RSDFrequencyType = .always
    
    /// - seealso: `fullInstructionsFrequency`
    open var alwaysShowFullInstructions : Bool {
        return self.fullInstructionsFrequency == .always
    }
    
    /// Is this device tied to a single participant or is the device being used in a study where there is a
    /// single mobile device that is being used to run tasks for multiple participants, such as a device used
    /// as part of a Phase 1 or Preclinical trial? (Default = `true`)
    open var isParticipantDevice : Bool = true
    
    /// A flag for whether or not tasks that support "remind me later" should show that action. (Default = `false`)
    open var shouldShowRemindMe: Bool = false
    
    /// `FileManager` is not fully implemented for non-Apple platforms. This allows for setting
    /// this property.
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    open var fileManager: RSDFileManager! = FileManager.default
    #else
    open var fileManager: RSDFileManager!
    #endif
}

/// The platform context info contains information about the current platform context that needs
/// to be accessed via a single entry point.
///
/// - seealso: `currentPlatformContext`.
public protocol RSDPlatformContextInfo : class {
    
    /// Information about the specific device.
    var deviceInfo: String { get }
    
    /// Specific model identifier of the device.
    /// - example: "Apple Watch Series 1"
    var deviceTypeIdentifier: String { get }
    
    /// The name of the application.
    var appName: String { get }
    
    /// The application version.
    var appVersion: String { get }
    
    /// Research framework version.
    var rsdFrameworkVersion: String { get }
    
    /// The localized name of the application.
    var localizedAppName : String { get }
}

/// Set the current platform on startup. If this value is set more than once then subsequent calls
/// will be ignored.
public var currentPlatformContext: RSDPlatformContextInfo! {
    get {
        return _currentPlatformContext
    }
    set {
        guard _currentPlatformContext == nil else { return }
        _currentPlatformContext = newValue
    }
}
private var _currentPlatformContext: RSDPlatformContextInfo?

/// The resource loader protocol is used to allow loading resources
public protocol RSDResourceLoader : class {
    
    /// Get the URL for the given resource.
    func url(for resourceInfo: RSDResourceTransformer, ofType defaultExtension: String?, using bundle: ResourceBundle?) throws -> (url: URL, resourceType: RSDResourceType)
}

/// Set the resource loader on startup. If this value is set more than once then subsequent calls
/// will be ignored.
public var resourceLoader: RSDResourceLoader? {
    get {
        return _resourceLoader
    }
    set {
        guard _resourceLoader == nil else { return }
        _resourceLoader = newValue
    }
}
private var _resourceLoader: RSDResourceLoader?
