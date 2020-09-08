//
//  RSDAsyncActionType.swift
//  Research
//
//  Copyright © 2018-2020 Sage Bionetworks. All rights reserved.
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

public final class AsyncActionConfigurationSerializer : IdentifiableInterfaceSerializer, PolymorphicSerializer {
    public var documentDescription: String? {
        """
        `AsyncActionConfiguration` defines general configuration for an asynchronous action that
        should be run in the background. Depending upon the parameters and how the action is set up,
        this could be something that is run continuously or else is paused or reset based on a
        timeout interval.
        
        The configuration is intended to be a serializable object and does not call services, record
        data, or anything else. It does include a step identifier that can be used to let the
        task controller know when to trigger the async action.
        """.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: "\n")
    }
    
    override init() {
        let examples: [SerializableAsyncActionConfiguration] = [
            RSDMotionRecorderConfiguration.examples().first!,
            RSDDistanceRecorderConfiguration.examples().first!,
            AudioRecorderConfiguration.examples().first!,
        ]
        self.examples = examples
    }
    
    public private(set) var examples: [RSDAsyncActionConfiguration]
    
    public override class func typeDocumentProperty() -> DocumentProperty {
        .init(propertyType: .reference(RSDAsyncActionType.documentableType()))
    }
    
    public func add(_ example: SerializableAsyncActionConfiguration) {
        if let idx = examples.firstIndex(where: {
            ($0 as! PolymorphicRepresentable).typeName == example.typeName }) {
            examples.remove(at: idx)
        }
        examples.append(example)
    }
}

public protocol SerializableAsyncActionConfiguration : RSDAsyncActionConfiguration, PolymorphicRepresentable, Encodable {
    var asyncActionType: RSDAsyncActionType { get }
}

public extension SerializableAsyncActionConfiguration {
    var typeName: String { return asyncActionType.rawValue }
}

/// The type of the async action configuration. This is used to decode async action configurations
/// using an instance of `RSDFactory`.
///
/// - seealso: `RSDAsyncActionConfiguration`
public struct RSDAsyncActionType : RSDFactoryTypeRepresentable, Codable, Hashable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Defaults to `RSDMotionRecorderConfiguration`.
    public static let motion: RSDAsyncActionType = "motion"
    
    /// Defaults to `RSDDistanceRecorderConfiguration`.
    public static let distance: RSDAsyncActionType = "distance"
    
    /// Defaults to `AudioRecorderConfiguration`.
    public static let microphone: RSDAsyncActionType = "microphone"
    
    fileprivate static func allBaseTypes() -> [RSDAsyncActionType] {
        return [.motion, .distance, .microphone]
    }
}

extension RSDAsyncActionType : ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RSDAsyncActionType : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return allBaseTypes().map{ $0.rawValue }
    }
}
