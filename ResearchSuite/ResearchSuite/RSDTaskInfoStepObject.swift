//
//  RSDTaskInfoStepObject.swift
//  ResearchSuite
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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

public struct RSDTaskInfoObject : RSDTaskInfo, RSDEmbeddedIconVendor, Codable {
    
    /// A short string that uniquely identifies the task. The identifier is reproduced as the
    /// identifier for the associated `RSDTaskResult`.
    public let identifier: String
    
    /// The primary text to display for the task in a localized string.
    public var title: String?
    
    /// The subtitle text to display for the task in a localized string.
    public var subtitle: String?
    
    /// Additional detail text to display for the task. Generally, this would be displayed
    /// while the task is being fetched.
    public var detail: String?
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    public var estimatedMinutes: Int {
        get {
            return _estimatedMinutes ?? 0
        }
        set {
            _estimatedMinutes = newValue
        }
    }
    private var _estimatedMinutes: Int?
    
    /// The icon used to display this task reference in a list of tasks.
    public var icon: RSDImageWrapper?
    
    private enum CodingKeys : String, CodingKey {
        case identifier, title, subtitle, detail, _estimatedMinutes = "estimatedMinutes", icon
    }
    
    public init(with identifier: String) {
        self.identifier = identifier
    }
    
    public func copy(with identifier: String) -> RSDTaskInfoObject {
        var copy = RSDTaskInfoObject(with: identifier)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy._estimatedMinutes = self._estimatedMinutes
        copy.icon = self.icon
        return copy
    }
}

extension RSDTaskInfoObject : Equatable {
    public static func ==(lhs: RSDTaskInfoObject, rhs: RSDTaskInfoObject) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.detail == rhs.detail &&
            lhs.estimatedMinutes == rhs.estimatedMinutes &&
            lhs.icon == rhs.icon
    }
}

/// `RSDTaskInfoStepObject` is a concrete implementation of the `RSDTaskInfoStep` protocol.
public struct RSDTaskInfoStepObject : RSDTaskInfoStep, Decodable {

    private enum CodingKeys : String, CodingKey {
        case stepType = "type", schemaIdentifier, schemaRevision, taskTransformer
    }

    /// Returns the task info identifier.
    public var identifier: String {
        return self.taskInfoObject.identifier
    }
    
    /// Returns the task info title.
    public var title: String? {
        return self.taskInfoObject.title
    }
    
    /// Returns the task info subtitle
    public var subtitle: String? {
        return self.taskInfoObject.subtitle
    }
    
    /// Returns the task info detail.
    public var detail: String? {
        return self.taskInfoObject.detail
    }

    /// Returns the task info estimated minutes
    public var estimatedMinutes: Int {
        return self.taskInfoObject.estimatedMinutes
    }
    
    /// Returns the task info image vendor
    public var imageVendor: RSDImageVendor? {
        return self.taskInfoObject.imageVendor
    }
    
    /// For the task info step, the task info
    public var taskInfoObject : RSDTaskInfoObject
    
    /// Additional information about the result schema.
    public var schemaInfo: RSDSchemaInfo?

    /// The type of the step.
    public var stepType: RSDStepType
    
    /// The task transformer for vending a task.
    public var taskTransformer: RSDTaskTransformer!
    
    /// The estimated fetch time is determined by the task transformer.
    public var estimatedFetchTime: TimeInterval {
        return taskTransformer?.estimatedFetchTime ?? 0
    }

    /// Default initializer.
    /// - parameter identifier: A short string that uniquely identifies the step.
    public init(with identifier: String) {
        self.taskInfoObject = RSDTaskInfoObject(with: identifier)
        self.stepType = .taskInfo
    }
    
    /// Default initializer.
    /// - parameter identifier: A short string that uniquely identifies the step.
    public init(with taskInfo: RSDTaskInfoObject) {
        self.taskInfoObject = taskInfo
        self.stepType = .taskInfo
    }
    
    private init(taskInfo: RSDTaskInfoObject, stepType: RSDStepType, schemaInfo: RSDSchemaInfo?, taskTransformer: RSDTaskTransformer!) {
        self.taskInfoObject = taskInfo
        self.stepType = stepType
        self.schemaInfo = schemaInfo
        self.taskTransformer = taskTransformer
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDTaskInfoStepObject {
        let taskInfoObject = self.taskInfoObject.copy(with: identifier)
        return RSDTaskInfoStepObject(taskInfo: taskInfoObject, stepType: stepType, schemaInfo: schemaInfo, taskTransformer: taskTransformer)
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///     ```
    ///        let json = """
    ///             {
    ///             "identifier": "foo",
    ///             "type": "taskInfo",
    ///             "schemaIdentifier": "bar",
    ///             "schemaRevision": 2,
    ///             "title": "Hello Foo!",
    ///             "subtitle": "This is a subtitle.",
    ///             "detail": "This is a test of foo.",
    ///             "estimatedMinutes": 5,
    ///             "icon": "fooIcon",
    ///             "taskTransformer" : { "resourceName": "TaskFoo",
    ///                                    "bundleIdentifier": "org.example.SharedResources" }
    ///            }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError` if there is a decoding error.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stepType = try container.decodeIfPresent(RSDStepType.self, forKey: .stepType) ?? .taskInfo
        let taskInfo = try RSDTaskInfoObject(from: decoder)
        self.taskInfoObject = taskInfo
        let schemaIdentifier = try container.decodeIfPresent(String.self, forKey: .schemaIdentifier)
        if let schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaRevision) {
            self.schemaInfo = RSDSchemaInfoObject(identifier: schemaIdentifier ?? taskInfo.identifier, revision: schemaVersion)
        }
        if container.contains(.taskTransformer) {
            let nestedDecoder = try container.superDecoder(forKey: .taskTransformer)
            self.taskTransformer = try decoder.factory.decodeTaskTransformer(from: nestedDecoder)
        }
    }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: `RSDTaskResultObject` with the `identifier` from this task reference.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    /// Required method for the `RSDStep` protocol. No validation for this step.
    public func validate() throws {
    }
}

extension RSDTaskInfoStepObject : Equatable {
    public static func ==(lhs: RSDTaskInfoStepObject, rhs: RSDTaskInfoStepObject) -> Bool {
        return lhs.taskInfoObject == rhs.taskInfoObject
    }
}

extension RSDTaskInfoStepObject : Hashable {
    public var hashValue : Int {
        return self.identifier.hashValue
    }
}

/// `RSDTaskInfoStepObject` is extended to implement the `RSDTaskGroup` protocol where the only item in the
/// task group is this object.
extension RSDTaskInfoStepObject : RSDTaskGroup {
    
    /// Returns `self` as the only item in the list.
    public var tasks: [RSDTaskInfo] {
        return [self]
    }
    
    /// Map the task info to the task info step and create a task path from the step.
    /// - parameter taskInfo: The task info to map from.
    /// - returns: A new task path.
    public func instantiateTaskPath(for taskInfo: RSDTaskInfo) -> RSDTaskPath? {
        return RSDTaskPath(taskInfo: self)
    }
}

extension RSDTaskInfoStepObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.stepType, .schemaIdentifier, .schemaRevision, .taskTransformer]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .stepType:
                if idx != 0 { return false }
            case .schemaIdentifier:
                if idx != 1 { return false }
            case .schemaRevision:
                if idx != 2 { return false }
            case .taskTransformer:
                if idx != 3 { return false }
            }
        }
        return keys.count == 4
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let json: [String : RSDJSONValue] = [
            "identifier": "foo",
            "schemaIdentifier": "foo.1.2",
            "schemaRevision": 2,
            "title": "Hello Foo!",
            "subtitle": "This is a subtitle",
            "detail": "This is a test of foo.",
            "copyright": "This is a copyright string for foo.",
            "estimatedMinutes": 5,
            "icon": "fooIcon",
            "taskTransformer" : [ "resourceName": "TaskFoo",
                                  "bundleIdentifier": "org.example.SharedResources" ]
            ]
        return [json]
    }
}
