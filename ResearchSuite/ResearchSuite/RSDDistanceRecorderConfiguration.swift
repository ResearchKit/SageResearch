//
//  RSDDistanceRecorderConfiguration.swift
//  ResearchSuite
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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


/// The default configuration to use for a `RSDDistanceRecorder`.
///
/// - example:
///
/// ```
///     // Example json for a codable configuration.
///        let json = """
///             {
///                "identifier": "foo",
///                "type": "distance",
///                "motionStepIdentifier": "run"
///                "startStepIdentifier": "countdown",
///                "stopStepIdentifier": "rest",
///            }
///            """.data(using: .utf8)! // our data in native (JSON) format
/// ```
@available(iOS 10.0, *)
public struct RSDDistanceRecorderConfiguration : RSDRecorderConfiguration, RSDAsyncActionControllerVendor, Codable {
    
    /// A short string that uniquely identifies the asynchronous action within the task. If started
    /// asynchronously, then the identifier maps to a result stored in `RSDTaskResult.asyncResults`.
    public let identifier: String
    
    /// The standard permission type associated with this configuration.
    public let type: RSDAsyncActionType
    
    /// Identifier for the step that records distance travelled. The recorder uses this step to record
    /// distance travelled while the other steps in the task are assumed to be standing still.
    public let motionStepIdentifier: String
    
    /// An identifier marking the step to start the action. If `nil`, then the action will be started when
    /// the task is started.
    public let startStepIdentifier: String?
    
    /// An identifier marking the step to stop the action. If `nil`, then the action will be started when
    /// the task is started.
    public let stopStepIdentifier: String?
    
    private enum CodingKeys : String, CodingKey {
        case identifier, type, motionStepIdentifier, startStepIdentifier, stopStepIdentifier
    }
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: The configuration identifier.
    ///     - motionStepIdentifier: Optional identifier for the step that records distance travelled.
    ///     - startStepIdentifier: An identifier marking the step to start the action. Default = `nil`.
    ///     - stopStepIdentifier: An identifier marking the step to stop the action.  Default = `nil`.
    public init(identifier: String, motionStepIdentifier: String, startStepIdentifier: String? = nil, stopStepIdentifier: String? = nil) {
        self.identifier = identifier
        self.type = .distance
        self.motionStepIdentifier = motionStepIdentifier
        self.startStepIdentifier = startStepIdentifier
        self.stopStepIdentifier = stopStepIdentifier
    }
    
    /// Returns `location` and `motion` on iOS. Returns an empty set on platforms that do not
    /// support distance recording.
    public var permissions: [RSDPermissionType] {
        #if os(iOS)
            return [RSDStandardPermissionType.location, RSDStandardPermissionType.motion]
        #else
            return []
        #endif
    }
    
    /// Returns true. Background audio is required for this configuration.
    public var requiresBackgroundAudio: Bool {
        return true
    }
    
    /// Do nothing. No validation is required for this recorder.
    public func validate() throws {
    }
    
    /// Instantiate a `RSDDistanceRecorder` (iOS only).
    /// - parameter taskPath: The current task path to use to initialize the controller.
    /// - returns: A new instance of `RSDMotionRecorder` or `nil` if the platform does not
    ///            support distance recording.
    public func instantiateController(with taskPath: RSDTaskPath) -> RSDAsyncActionController? {
        #if os(iOS)
            return RSDDistanceRecorder(configuration: self, taskPath: taskPath, outputDirectory: taskPath.outputDirectory)
        #else
            return nil
        #endif
    }
}

extension RSDDistanceRecorderConfiguration : RSDDocumentableCodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .type, .motionStepIdentifier, .startStepIdentifier, .stopStepIdentifier]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .type:
                if idx != 1 { return false }
            case .motionStepIdentifier:
                if idx != 2 { return false }
            case .startStepIdentifier:
                if idx != 3 { return false }
            case .stopStepIdentifier:
                if idx != 4 { return false }
            }
        }
        return keys.count == 5
    }
    
    static func examples() -> [Encodable] {
        let example = RSDDistanceRecorderConfiguration(identifier: "distance", motionStepIdentifier: "run", startStepIdentifier: "countdown", stopStepIdentifier: "rest")
        return [example]
    }
}
