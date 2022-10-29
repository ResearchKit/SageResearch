//
//  RSDTaskMetadata.swift
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

import Foundation
import JsonModel
import ResultModel

/// The metadata for a task result archive that can be zipped using the app developer's choice of
/// third-party archival tools.
public struct RSDTaskMetadata : Codable, DocumentableRootObject, DocumentableStruct {
    private enum CodingKeys : String, OrderedEnumCodingKey {
        case deviceInfo,
             deviceTypeIdentifier,
             appName,
             appVersion,
             rsdFrameworkVersion,
             taskIdentifier,
             taskRunUUID,
             startDate,
             endDate,
             schemaIdentifier,
             schemaRevision,
             versionString,
             files
    }

    /// Information about the specific device.
    public let deviceInfo: String
    
    /// Specific model identifier of the device.
    /// - example: "Apple Watch Series 1"
    public let deviceTypeIdentifier: String
    
    /// The name of the application.
    public let appName: String
    
    /// The application version.
    public let appVersion: String
    
    /// Research framework version.
    public let rsdFrameworkVersion: String
    
    /// The identifier for the task.
    public let taskIdentifier: String
    
    /// The task run UUID.
    public let taskRunUUID: UUID?
    
    /// The timestamp for when the task was started.
    public let startDate: Date
    
    /// The timestamp for when the task was ended.
    public let endDate: Date
    
    /// The identifier for the schema associated with this task result.
    public let schemaIdentifier: String?
    
    /// The revision for the schema associated with this task result.
    public let schemaRevision: Int?
    
    /// The version string associated with this task.
    public let versionString: String?
    
    /// A list of the files included in this package of results.
    public let files: [RSDFileManifest]
    
    /// Default initializer.
    /// - parameters:
    ///     - taskResult: The task result to use to pull information included in the top-level metadata.
    ///     - files: A list of files included with this metadata.
    public init(taskResult: RSDTaskResult, files: [RSDFileManifest]) {
        let platformInfo = PlatformContextInfo()
        self.deviceInfo = platformInfo.deviceInfo
        self.deviceTypeIdentifier = platformInfo.deviceTypeIdentifier
        self.appName = platformInfo.appName
        self.appVersion = platformInfo.appVersion
        
        if let platformContext = currentPlatformContext {
            self.rsdFrameworkVersion = platformContext.rsdFrameworkVersion
        }
        else {
            self.rsdFrameworkVersion = "Unknown"
        }
        self.taskIdentifier = taskResult.identifier
        self.startDate = taskResult.startDate
        self.endDate = taskResult.endDate
        self.files = files
        if let runResult = taskResult as? AssessmentResult {
            self.taskRunUUID = runResult.taskRunUUID
            self.schemaIdentifier = runResult.schemaIdentifier
            self.versionString = runResult.versionString
            self.schemaRevision = Int(runResult.versionString ?? "null")
        }
        else {
            self.taskRunUUID = nil
            self.schemaIdentifier = nil
            self.schemaRevision = nil
            self.versionString = nil
        }
    }
    
    public init() {
        self.init(taskResult: RSDTaskResultObject(identifier: "example"), files: [
            .init(filename: "foo.json",
                  timestamp: ISO8601TimestampFormatter.date(from: "2017-10-16T22:28:09.000-07:00")!,
                  contentType: "application/json",
                  identifier: "foo",
                  stepPath: "Goo/foo",
                  jsonSchema: .init(string: "https://example.com/foo.json"),
                  metadata: .object(["foo" : "baroo"]))
        ])
    }
    
    // Documentation
    
    public var jsonSchema: URL = .init(string: "TaskMetadata.json", relativeTo: kSageJsonSchemaBaseURL)!
    
    public var documentDescription: String? {
        "The metadata for a task result archive that can be zipped using the app developer's choice of third-party archival tools."
    }
    
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        switch key {
        case .deviceInfo,.deviceTypeIdentifier,.appName,.appVersion,.taskIdentifier:
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
        case .appName:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Name of the app that built the archive.")
        case .appVersion:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Version of the app that built the archive.")
        case .deviceInfo:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Information about the specific device.")
        case .deviceTypeIdentifier:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Specific model identifier of the device.")
        case .files:
            return .init(propertyType: .referenceArray(RSDFileManifest.documentableType()),
                         propertyDescription: "A list of the files included in this archive.")
        case .taskIdentifier:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The identifier for the task.")
        case .rsdFrameworkVersion:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "Research framework version.")
        case .startDate, .endDate:
            return .init(propertyType: .format(.dateTime))
        case .taskRunUUID:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The task run UUID.")
        case .schemaIdentifier:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "The Bridge Exporter 2.0 Schema Identifier used to map to Synapse.")
        case .schemaRevision:
            return .init(propertyType: .primitive(.integer),
                         propertyDescription: "The Bridge Exporter 2.0 Schema Revision used to map to Synapse.")
        case .versionString:
            return .init(propertyType: .primitive(.string),
                         propertyDescription: "A version string that can be used by an assessment to track version.")

        }
    }
    
    public static func examples() -> [RSDTaskMetadata] {
        [.init()]
    }
}

