//
//  RSDTaskInfoStepObject.swift
//  ResearchStack2
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

public struct RSDTaskInfoObject : RSDTaskInfo, RSDEmbeddedIconVendor, Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case identifier, title, subtitle, detail, icon, _estimatedMinutes = "estimatedMinutes", _embeddedResource = "taskTransformer", _schemaInfoObject = "schemaInfo"
    }
    
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
        get { return _estimatedMinutes ?? 0 }
        set { _estimatedMinutes = newValue }
    }
    private var _estimatedMinutes: Int?
    
    /// The icon used to display this task reference in a list of tasks.
    public var icon: RSDImageWrapper?

    /// Optional schema info to pass with the task info for this task.
    public var schemaInfo: RSDSchemaInfo? {
        get { return _schemaInfoObject ?? _schemaInfo }
        set { _schemaInfo = newValue }
    }
    private var _schemaInfoObject: RSDSchemaInfoObject?
    private var _schemaInfo: RSDSchemaInfo? = nil
    
    /// The resource transformer.
    public var resourceTransformer: RSDTaskTransformer? {
        get { return _embeddedResource ?? _taskTransformer }
        set { _taskTransformer = newValue }
    }
    private var _embeddedResource: RSDResourceTransformerObject?
    private var _taskTransformer: RSDTaskTransformer? = nil
    
    public init(with identifier: String) {
        self.identifier = identifier
    }
    
    public func copy(with identifier: String) -> RSDTaskInfoObject {
        var copy = RSDTaskInfoObject(with: identifier)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.estimatedMinutes = self.estimatedMinutes
        copy.icon = self.icon
        copy._taskTransformer = self.resourceTransformer
        copy._schemaInfo = self.schemaInfo
        return copy
    }
}


/// `RSDTaskInfoStepObject` is a concrete implementation of the `RSDTaskInfoStep` protocol.
public struct RSDTaskInfoStepObject : RSDTaskInfoStep {

    /// Returns the task info identifier.
    public var identifier: String {
        return self.taskInfo.identifier
    }
    
    /// For the task info step, the task info
    public let taskInfo : RSDTaskInfo

    /// The type of the step.
    public let stepType: RSDStepType
    
    /// The task transformer for vending a task.
    public var taskTransformer: RSDTaskTransformer!
    
    /// Default initializer.
    /// - parameter identifier: A short string that uniquely identifies the step.
    public init(with taskInfo: RSDTaskInfo, taskTransformer: RSDTaskTransformer? = nil, stepType: RSDStepType = .taskInfo) {
        self.taskInfo = taskInfo
        self.taskTransformer = taskTransformer ?? taskInfo.resourceTransformer
        self.stepType = .taskInfo
    }
    
    /// Copy the step to a new instance with the given identifier, but otherwise, equal.
    /// - parameter identifier: The new identifier.
    public func copy(with identifier: String) -> RSDTaskInfoStepObject {
        let taskInfo = self.taskInfo.copy(with: identifier)
        return RSDTaskInfoStepObject(with: taskInfo, taskTransformer: taskTransformer, stepType: stepType)
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


/// `RSDTaskInfoStepObject` is extended to implement the `RSDTaskGroup` protocol where the only item in the
/// task group is this object.
extension RSDTaskInfoObject : RSDTaskGroup {
    
    /// Returns `self` as the only item in the list.
    public var tasks: [RSDTaskInfo] {
        return [self]
    }
    
    /// Map the task info to the task info step and create a task path from the step.
    /// - parameter taskInfo: The task info to map from.
    /// - returns: A new task path.
    public func instantiateTaskPath(for taskInfo: RSDTaskInfo) -> RSDTaskPath? {
        let step = RSDTaskInfoStepObject(with: self)
        return RSDTaskPath(taskInfo: step)
    }
}

extension RSDTaskInfoObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .title, .subtitle, .detail, .icon, ._estimatedMinutes, ._embeddedResource, ._schemaInfoObject]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .title:
                if idx != 1 { return false }
            case .subtitle:
                if idx != 2 { return false }
            case .detail:
                if idx != 3 { return false }
            case .icon:
                if idx != 4 { return false }
            case ._estimatedMinutes:
                if idx != 5 { return false }
            case ._embeddedResource:
                if idx != 6 { return false }
            case ._schemaInfoObject:
                if idx != 7 { return false }
            }
        }
        return keys.count == 8
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
