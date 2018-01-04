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

/// `RSDTaskInfoStepObject` is a concrete implementation of the `RSDTaskInfoStep` protocol.
public struct RSDTaskInfoStepObject : RSDTaskInfoStep, RSDSchemaInfo, RSDEmbeddedIconVendor, Decodable {

    private enum CodingKeys : String, CodingKey {
        case identifier
        case stepType = "type"
        case _schemaIdentifier = "schemaIdentifier"
        case schemaRevision
        case title
        case subtitle
        case detail
        case copyright
        case estimatedMinutes
        case icon
        case taskTransformer
    }

    /// A short string that uniquely identifies the task. The identifier is reproduced as the identifier for the
    /// associated `RSDTaskResult`.
    public let identifier: String
    
    /// The type of the step.
    public let stepType: RSDStepType
    
    /// The primary text to display for the task in a localized string.
    public var title: String?
    
    /// The subtitle text to display for the task in a localized string.
    public var subtitle: String?
    
    /// Additional detail text to display for the task.
    public var detail: String?
    
    /// Copyright information for the task.
    public var copyright: String?
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    public var estimatedMinutes: Int = 0
    
    /// The icon used to display this task reference in a list of tasks.
    public var icon: RSDImageWrapper?
    
    /// A short string that uniquely identifies the associated result schema.
    public var schemaIdentifier: String? {
        return _schemaIdentifier ?? identifier
    }
    private var _schemaIdentifier: String?
    
    /// A revision number associated with the result schema.
    public var schemaRevision: Int = 1
    
    /// The task transformer for vending a task.
    public var taskTransformer: RSDTaskTransformer!
    
    /// The estimated fetch time is determined by the task transformer.
    public var estimatedFetchTime: TimeInterval {
        return taskTransformer?.estimatedFetchTime ?? 0
    }

    /// Default initializer.
    /// - parameter identifier: A short string that uniquely identifies the step.
    public init(with identifier: String) {
        self.identifier = identifier
        self.stepType = .taskInfo
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
    ///             "copyright": "This is a copyright string for foo.",
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
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.stepType = try container.decodeIfPresent(RSDStepType.self, forKey: .stepType) ?? .taskInfo
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        self.icon = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .icon)
        self.estimatedMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedMinutes) ?? 0
        self._schemaIdentifier = try container.decodeIfPresent(String.self, forKey: ._schemaIdentifier)
        self.schemaRevision = try container.decodeIfPresent(Int.self, forKey: .schemaRevision) ?? 1

        if container.contains(.taskTransformer) {
            let nestedDecoder = try container.superDecoder(forKey: .taskTransformer)
            self.taskTransformer = try decoder.factory.decodeTaskTransformer(from: nestedDecoder)
        }
    }
    
    /// Fetch the task for this task info. Use the given factory to transform the task.
    ///
    /// - parameters:
    ///     - factory:     The factory to use for creating the task and steps.
    ///     - callback:    The callback with the task or an error if the task failed, run on the main thread.
    public func fetchTask(with factory: RSDFactory, callback: @escaping RSDTaskFetchCompletionHandler) {
        guard let transformer = self.taskTransformer else {
            let message = "Attempting to fetch a task with a nil transformer."
            assertionFailure(message)
            DispatchQueue.main.async {
                callback(self, nil, RSDValidationError.unexpectedNullObject(message))
            }
            return
        }
        transformer.fetchTask(with: factory, taskInfo: self, schemaInfo: self, callback: callback)
    }
    
    /// Instantiate a step result that is appropriate for this step.
    /// - returns: `RSDTaskResultObject` with the `identifier` from this task reference.
    public func instantiateStepResult() -> RSDResult {
        return RSDTaskResultObject(identifier: identifier)
    }
    
    /// Required method for the `RSDStep` protocol. No validation for this step.
    public func validate() throws {
        // do nothing
    }
}

extension RSDTaskInfoStepObject : Equatable {
    public static func ==(lhs: RSDTaskInfoStepObject, rhs: RSDTaskInfoStepObject) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.title == rhs.title &&
            lhs.detail == rhs.detail &&
            lhs.copyright == rhs.copyright &&
            lhs.estimatedMinutes == rhs.estimatedMinutes &&
            lhs.icon == rhs.icon
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
    public var tasks: [RSDTaskInfoStep] {
        return [self]
    }
}

extension RSDTaskInfoStepObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .stepType, ._schemaIdentifier, .schemaRevision, .title, .subtitle, .detail, .copyright, .estimatedMinutes, .icon, .taskTransformer]
        return codingKeys
    }
    
    static func validateAllKeysIncluded() -> Bool {
        let keys: [CodingKeys] = allCodingKeys()
        for (idx, key) in keys.enumerated() {
            switch key {
            case .identifier:
                if idx != 0 { return false }
            case .stepType:
                if idx != 1 { return false }
            case ._schemaIdentifier:
                if idx != 2 { return false }
            case .schemaRevision:
                if idx != 3 { return false }
            case .title:
                if idx != 4 { return false }
            case .subtitle:
                if idx != 5 { return false }
            case .detail:
                if idx != 6 { return false }
            case .copyright:
                if idx != 7 { return false }
            case .estimatedMinutes:
                if idx != 8 { return false }
            case .icon:
                if idx != 9 { return false }
            case .taskTransformer:
                if idx != 10 { return false }
                
            }
        }
        return keys.count == 11
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
