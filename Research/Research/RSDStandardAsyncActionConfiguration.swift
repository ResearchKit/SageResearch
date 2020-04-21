//
//  RSDStandardAsyncActionConfiguration.swift
//  Research
//
//  Copyright © 2017-2020 Sage Bionetworks. All rights reserved.
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

/// `RSDStandardAsyncActionConfiguration` is a concrete implementation of `RSDRecorderConfiguration` that can be used to
/// decode an async configuration for a recorder.
public struct RSDStandardAsyncActionConfiguration : RSDRecorderConfiguration, Codable {
    
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, type, startStepIdentifier, stopStepIdentifier, _permissions = "permissions", _requiresBackgroundAudio = "requiresBackgroundAudio"
    }

    /// A short string that uniquely identifies the asynchronous action within the task. If started asynchronously,
    /// then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    public let identifier: String
    
    /// The async action type associated with this configuration.
    public let type: RSDAsyncActionType
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    public let startStepIdentifier: String?
    
    /// An identifier marking the step at which to stop the action. If `nil`, then the action will be
    /// stopped when the task is stopped.
    public var stopStepIdentifier: String?
    
    /// List of the permissions required for this action.
    public var permissionTypes: [RSDPermissionType] {
        return _permissions ?? {
            guard let permissionType = RSDStandardPermissionType(rawValue: type.stringValue) else { return [] }
            return [permissionType]
        }()
    }
    private var _permissions: [RSDStandardPermissionType]?

    /// Whether or not the recorder requires background audio. Default = `false`.
    ///
    /// If `true` then background audio can be used to keep the recorder running if the screen is locked
    /// because of the idle timer turning off the device screen.
    ///
    /// If the app uses background audio, then the developer will need to turn `ON` the "Background Modes"
    /// under the "Capabilities" tab of the Xcode project, and will need to select "Audio, AirPlay, and
    /// Picture in Picture".
    ///
    public var requiresBackgroundAudio: Bool {
        return _requiresBackgroundAudio ?? false
    }
    private var _requiresBackgroundAudio: Bool?
    
    /// Default initializer.
    ///
    /// - parameters:
    ///     - identifier: The identifier for this recorder.
    ///     - type: The async action type associated with this recorder.
    ///     - startStepIdentifier: The start step identifier (if any).
    ///     - stopStepIdentifier: The stop step identifier (if any).
    public init(identifier: String, type: RSDAsyncActionType, startStepIdentifier: String?, stopStepIdentifier: String?) {
        self.identifier = identifier
        self.type = type
        self.startStepIdentifier = startStepIdentifier
        self.stopStepIdentifier = stopStepIdentifier
    }
    
    /// Validate the async action to check for any configuration that should throw an error.
    /// This method does nothing but is required by the `RSDAsyncActionConfiguration` protocol.
    public func validate() throws {
        // Do nothing
    }
}
