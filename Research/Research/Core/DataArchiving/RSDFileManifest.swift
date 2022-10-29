//
//  RSDFileManifest.swift
//  Research
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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
