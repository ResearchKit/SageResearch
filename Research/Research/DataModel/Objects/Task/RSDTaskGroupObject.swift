//
//  RSDTaskGroupObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDTaskGroupObject` is a concrete implementation of the `RSDTaskGroup` protocol.
@available(*,deprecated, message: "Will be deleted in a future version.")
public struct RSDTaskGroupObject : RSDTaskGroup, Codable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case identifier, title, detail, icon, _tasks = "tasks"
    }

    /// A short string that uniquely identifies the task group.
    public let identifier: String
    
    /// The primary text to display for the task group in a localized string.
    public var title: String?
    
    /// Additional detail text to display for the task group in a localized string.
    public var detail: String?
    
    /// The optional `RSDImageData` with the pointer to the image.
    public var imageData: RSDImageData? { return icon }
    private var icon: RSDResourceImageDataObject?
    
    /// A list of the task references included in this group.
    public var tasks: [RSDTaskInfo] { _tasks }
    private var _tasks: [RSDTaskInfoObject]
    
    /// Default initializer.
    /// - parameters:
    ///     - identifier: A short string that uniquely identifies the task group.
    ///     - tasks: A list of the task references included in this group.
    public init(with identifier: String, tasks: [RSDTaskInfoObject]) {
        self.identifier = identifier
        self._tasks = tasks
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTaskGroupObject : DocumentableObject {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isOpen() -> Bool { false }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .identifier, ._tasks:
            return true
        default:
            return false
        }
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .title, .detail:
            return .init(propertyType: .primitive(.string))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        case ._tasks:
            return .init(propertyType: .referenceArray(RSDTaskInfoObject.documentableType()))
        }
    }
    
    public static func jsonExamples() throws -> [[String : JsonSerializable]] {
        let json: [String : JsonSerializable] = [
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
