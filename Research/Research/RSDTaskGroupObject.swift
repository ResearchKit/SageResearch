//
//  RSDTaskGroupObject.swift
//  Research
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

/// `RSDTaskGroupObject` is a concrete implementation of the `RSDTaskGroup` protocol.
public struct RSDTaskGroupObject : RSDTaskGroup, RSDEmbeddedIconVendor, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case identifier, title, detail, icon, tasks
    }

    /// A short string that uniquely identifies the task group.
    public let identifier: String
    
    /// The primary text to display for the task group in a localized string.
    public var title: String?
    
    /// Additional detail text to display for the task group in a localized string.
    public var detail: String?
    
    /// The optional `RSDImageWrapper` with the pointer to the image.
    public var icon: RSDImageWrapper?
    
    /// A list of the task references included in this group.
    public let tasks: [RSDTaskInfo]
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the task group.
    ///     - tasks: A list of the task references included in this group.
    public init(with identifier: String, tasks: [RSDTaskInfo]) {
        self.identifier = identifier
        self.tasks = tasks
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `tasks`.
    ///
    /// - example:
    ///
    ///     ```
    ///        let json = """
    ///                {
    ///                    "identifier": "foobar",
    ///                    "title": "Foobarific",
    ///                    "detail": "This is a task group containing foo and bar",
    ///                    "icon": "foobarIcon",
    ///                    "tasks" : [{
    ///                               "identifier": "foo",
    ///                               "schemaRevision" : 2,
    ///                               "title": "Hello Foo!",
    ///                               "detail": "This is a test of foo.",
    ///                               "copyright": "This is a copyright string for foo.",
    ///                               "estimatedMinutes": 5,
    ///                               "icon": "fooIcon",
    ///                               "taskTransformer" : { "resourceName": "TaskFoo",
    ///                                                     "bundleIdentifier": "org.example.SharedResources" }
    ///                               },
    ///                               {
    ///                               "identifier": "bar",
    ///                               "schemaRevision" : 4,
    ///                               "title": "Hello Bar!",
    ///                               "detail": "This is a test of bar.",
    ///                               "estimatedMinutes": 7,
    ///                               "icon": "barIcon"
    ///                               }]
    ///                }
    ///            """.data(using: .utf8)! // our data in native (JSON) format
    ///     ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.icon = try container.decodeIfPresent(RSDImageWrapper.self, forKey: .icon)
        
        let factory = decoder.factory
        var nestedContainer: UnkeyedDecodingContainer = try container.nestedUnkeyedContainer(forKey: .tasks)
        var decodedTasks : [RSDTaskInfo] = []
        while !nestedContainer.isAtEnd {
            let taskDecoder = try nestedContainer.superDecoder()
            let task = try factory.decodeTaskInfo(from: taskDecoder)
            decodedTasks.append(task)
        }
        self.tasks = decodedTasks
    }
}

extension RSDTaskGroupObject : RSDDocumentableDecodableObject {
    
    static func codingKeys() -> [CodingKey] {
        return allCodingKeys()
    }
    
    private static func allCodingKeys() -> [CodingKeys] {
        let codingKeys: [CodingKeys] = [.identifier, .title, .detail, .icon, .tasks]
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
            case .detail:
                if idx != 2 { return false }
            case .icon:
                if idx != 3 { return false }
            case .tasks:
                if idx != 4 { return false }
            }
        }
        return keys.count == 5
    }
    
    static func examples() -> [[String : RSDJSONValue]] {
        let json: [String : RSDJSONValue] = [
                    "identifier": "foobar",
                    "title": "Foobarific",
                    "detail": "This is a task group containing foo and bar",
                    "icon": "foobarIcon",
                    "tasks" : [[
                               "identifier": "foo",
                               "schemaRevision" : 2,
                               "title": "Hello Foo!",
                               "detail": "This is a test of foo.",
                               "copyright": "This is a copyright string for foo.",
                               "estimatedMinutes": 5,
                               "icon": "fooIcon",
                               "taskTransformer" : [ "resourceName": "TaskFoo",
                                                     "bundleIdentifier": "org.example.SharedResources" ]
                               ],
                               [
                               "identifier": "bar",
                               "schemaRevision" : 4,
                               "title": "Hello Bar!",
                               "detail": "This is a test of bar.",
                               "estimatedMinutes": 7,
                               "icon": "barIcon"
                               ]]
                ]
        return [json]
    }
}
