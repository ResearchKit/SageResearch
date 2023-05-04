//
//  RSDFileManifest.swift
//  Research
//

import JsonModel
import ResultModel
import Foundation

/// A list of reserved filenames for data added to an archive that is keyed to a custom-built data file.
public enum RSDReservedFilename : String {
    
    /// The answers file is a mapping of key/value pairs for all the `RSDAnswerResult` objects found in the
    /// task result. The results are encoded using the JSON encoding defined by the `RSDFactory.shared`
    /// instance.
    case answers = "answers"
    
    /// The task result file is the `RSDTaskResult` encoded using the JSON encoding defined by the
    /// `RSDFactory.shared` instance.
    case taskResult = "taskResult"
    
    /// The `RSDTaskMetadata` encoded using the JSON encoding defined by the `RSDFactory.shared` instance.
    case metadata = "metadata"
}

/// A manifest for a given file that includes the filename, content type, and creation timestamp.
@available(*, deprecated, message: "Support for BridgeSDK archive and export is deprecated. Please use BridgeClient and implement `FileArchivable` directly instead of `RSDArchivable`.")
public struct RSDFileManifest : Codable, Hashable, Equatable {
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case filename, timestamp, contentType, identifier, stepPath, jsonSchema, metadata
    }
    
    /// The filename of the archive object. This should be unique within the manifest. It may include
    /// a relative path that points to a subdirectory.
    public let filename: String
    
    /// The file creation date.
    public let timestamp: Date
    
    /// The content type of the file.
    public let contentType: String?
    
    /// The identifier for the result. This value may *not* be unique if a step is run more than once
    /// during a task at different stages.
    public let identifier: String?
    
    /// The full path to the result if it is within the step history.
    public let stepPath: String?
    
    /// The uri for the json schema if the content type is "application/json".
    public let jsonSchema: URL?
    
    /// Any additional metadata about this file.
    public let metadata: JsonElement?
    
    /// Default initializer.
    public init(filename: String, timestamp: Date, contentType: String?, identifier: String? = nil, stepPath: String? = nil, jsonSchema: URL? = nil, metadata: JsonElement? = nil) {
        self.filename = filename
        self.timestamp = timestamp
        self.contentType = contentType
        self.identifier = identifier
        self.stepPath = stepPath
        self.jsonSchema = jsonSchema
        self.metadata = metadata
    }
    
    public init(from fileInfo: FileInfo) {
        self.init(filename: fileInfo.filename,
                  timestamp: fileInfo.timestamp,
                  contentType: fileInfo.contentType,
                  identifier: fileInfo.identifier,
                  stepPath: fileInfo.stepPath,
                  jsonSchema: fileInfo.jsonSchema,
                  metadata: fileInfo.metadata
        )
    }
    
    /// A hash for the manifest.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
        hasher.combine(timestamp)
    }
    
    /// The file manifest files are equal if the filename, timestamp, and contentType are the same.
    public static func ==(lhs: RSDFileManifest, rhs: RSDFileManifest) -> Bool {
        return lhs.filename == rhs.filename && lhs.timestamp == rhs.timestamp
    }
}

@available(*, deprecated, message: "Support for BridgeSDK archive and export is deprecated. Please use BridgeClient and implement `FileArchivable` directly instead of `RSDArchivable`.")
extension RSDFileManifest : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .filename || key == .timestamp
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .filename:
            return .init(propertyType: .format(.uriRelative), propertyDescription:
                            "The filename of the archive object. This should be unique within the manifest.")
        case .timestamp:
            return .init(propertyType: .format(.dateTime), propertyDescription:
                            "The file creation date.")
        case .contentType:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "The content type of the file.")
        case .identifier:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "The identifier for the result.")
        case .stepPath:
            return .init(propertyType: .primitive(.string), propertyDescription:
                            "The full path to the result if it is within the step history.")
        case .jsonSchema:
            return .init(propertyType: .format(.uri), propertyDescription:
                            "The uri for the json schema if the content type is 'application/json'.")
        case .metadata:
            return .init(propertyType: .any, propertyDescription:
                            "Any additional metadata about this file.")
        }
    }
    
    public static func examples() -> [RSDFileManifest] {
        [.init(filename: "foo.json",
               timestamp: Date(),
               contentType: "application/json",
               identifier: "foo",
               stepPath: "Bar/foo",
               jsonSchema: URL(string: "http://example.org/schemas/v1/Foo.json"),
               metadata: .object(["value" : 1]))
        ]
    }
}

@available(*, deprecated, message: "Support for BridgeSDK archive and export is deprecated. Please use BridgeClient and implement `FileArchivable` directly instead of `RSDArchivable`.")
extension FileInfo {
    init(from fileManifest: RSDFileManifest) {
        self.init(filename: fileManifest.filename,
                  timestamp: fileManifest.timestamp,
                  contentType: fileManifest.contentType,
                  identifier: fileManifest.identifier,
                  stepPath: fileManifest.stepPath,
                  jsonSchema: fileManifest.jsonSchema,
                  metadata: fileManifest.metadata
        )
    }
}
