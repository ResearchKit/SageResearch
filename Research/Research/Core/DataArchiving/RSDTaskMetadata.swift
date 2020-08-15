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

/// The metadata for a task result archive that can be zipped using the app developer's choice of
/// third-party archival tools.
public struct RSDTaskMetadata : Codable {

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
    
    /// A list of the files included in this package of results.
    public let files: [RSDFileManifest]
    
    /// Default initializer.
    /// - parameters:
    ///     - taskResult: The task result to use to pull information included in the top-level metadata.
    ///     - files: A list of files included with this metadata.
    public init(taskResult: RSDTaskResult, files: [RSDFileManifest]) {
        if let platformContext = currentPlatformContext {
            self.deviceInfo = platformContext.deviceInfo
            self.deviceTypeIdentifier = platformContext.deviceTypeIdentifier
            self.appName = platformContext.appName
            self.appVersion = platformContext.appVersion
            self.rsdFrameworkVersion = platformContext.rsdFrameworkVersion
        }
        else {
            self.deviceInfo = "Unknown"
            self.deviceTypeIdentifier = "Unknown"
            self.appName = "Unknown"
            self.appVersion = "Unknown"
            self.rsdFrameworkVersion = "Unknown"
        }
        self.taskIdentifier = taskResult.identifier
        self.startDate = taskResult.startDate
        self.endDate = taskResult.endDate
        self.files = files
        if let runResult = taskResult as? RSDTaskRunResult {
            self.taskRunUUID = runResult.taskRunUUID
            self.schemaIdentifier = runResult.schemaInfo?.schemaIdentifier
            self.schemaRevision = runResult.schemaInfo?.schemaVersion
        }
        else {
            self.taskRunUUID = nil
            self.schemaIdentifier = nil
            self.schemaRevision = nil
        }
    }
}

