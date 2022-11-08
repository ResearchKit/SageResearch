//
//  RSDTaskInfoObject.swift
//  Research
//

import Foundation
import JsonModel

public struct RSDTaskInfoObject : RSDTaskInfo, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case identifier, title, subtitle, detail, footnote, icon, _estimatedMinutes = "estimatedMinutes", embeddedResource = "taskTransformer", schemaInfoObject = "schemaInfo"
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
    
    public var footnote: String?
    
    /// The estimated number of minutes that the task will take. If `0`, then this is ignored.
    public var estimatedMinutes: Int {
        get { return _estimatedMinutes ?? 0 }
        set { _estimatedMinutes = newValue }
    }
    private var _estimatedMinutes: Int?
    
    /// The icon used to display this task reference in a list of tasks.
    public var icon: RSDResourceImageDataObject?
    
    /// The icon associated with this task info.
    public var imageData: RSDImageData? {
        return self.icon
    }

    /// Optional schema info to pass with the task info for this task.
    public var schemaInfo: RSDSchemaInfo? { schemaInfoObject }
    public var schemaInfoObject: RSDSchemaInfoObject?
    
    /// The resource transformer.
    public var resourceTransformer: RSDTaskTransformer? { embeddedResource }
    public var embeddedResource: RSDResourceTransformerObject?
    
    public init(with identifier: String) {
        self.identifier = identifier
    }
    
    public func copy(with identifier: String) -> RSDTaskInfoObject {
        var copy = RSDTaskInfoObject(with: identifier)
        copy.title = self.title
        copy.subtitle = self.subtitle
        copy.detail = self.detail
        copy.footnote = self.footnote
        copy.estimatedMinutes = self.estimatedMinutes
        copy.icon = self.icon
        copy.embeddedResource = self.embeddedResource
        copy.schemaInfoObject = self.schemaInfoObject
        return copy
    }
}

extension RSDTaskInfoObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        return CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .identifier
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .identifier:
            return .init(propertyType: .primitive(.string))
        case .title, .subtitle, .detail, .footnote:
            return .init(propertyType: .primitive(.string))
        case .icon:
            return .init(propertyType: .reference(RSDResourceImageDataObject.documentableType()))
        case ._estimatedMinutes:
            return .init(propertyType: .primitive(.integer))
        case .embeddedResource:
            return .init(propertyType: .reference(RSDResourceTransformerObject.documentableType()))
        case .schemaInfoObject:
            return .init(propertyType: .reference(RSDSchemaInfoObject.documentableType()))
        }
    }
    
    public static func examples() -> [RSDTaskInfoObject] {
        [RSDTaskInfoObject(with: "foo")]
    }
}

@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTaskInfoObject : Equatable {
    public static func ==(lhs: RSDTaskInfoObject, rhs: RSDTaskInfoObject) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.detail == rhs.detail &&
            lhs.estimatedMinutes == rhs.estimatedMinutes &&
            lhs.icon?.imageIdentifier == rhs.icon?.imageIdentifier
    }
}

/// `RSDTaskInfoStepObject` is extended to implement the `RSDTaskGroup` protocol where the only item in the
/// task group is this object.
@available(*,deprecated, message: "Will be deleted in a future version.")
extension RSDTaskInfoObject : RSDTaskGroup {
    
    /// Returns `self` as the only item in the list.
    public var tasks: [RSDTaskInfo] {
        return [self]
    }
}
