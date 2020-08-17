//
//  RSDTaskInfoObject.swift
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
extension RSDTaskInfoObject : RSDTaskGroup {
    
    /// Returns `self` as the only item in the list.
    public var tasks: [RSDTaskInfo] {
        return [self]
    }
}
