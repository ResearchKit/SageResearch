//
//  CRFArchiveManager.swift
//  CRFTestApp
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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
import Research

public class CRFArchiveManager : NSObject, RSDDataArchiveManager {

    
    
    static let shared = CRFArchiveManager()
    
    public var dataArchives = [CRFDataArchive]()
    
    public func shouldContinueOnFail(for archive: RSDDataArchive, error: Error) -> Bool {
        return false
    }
    
    public func dataArchiver(for taskResult: RSDTaskResult, scheduleIdentifier: String?, currentArchive: RSDDataArchive?) -> RSDDataArchive? {
        if currentArchive != nil {
            return currentArchive
        } else {
            let dataArchive = CRFDataArchive(identifier: taskResult.identifier)
            dataArchives.append(dataArchive)
            return dataArchive
        }
    }
    
    public func encryptAndUpload(taskResult: RSDTaskResult, dataArchives: [RSDDataArchive], completion: @escaping (() -> Void)) {
        // Do nothing - this is only to test that archiving doesn't blow up. For an actual app, this archive manager would be
        // replaced with a manager that can handle the upload services.
    }
    
    public func handleArchiveFailure(taskResult: RSDTaskResult, error: Error, completion: @escaping (() -> Void)) {
        debugPrint("Failed to archive \(taskResult) : \(error)")
    }
}

public class CRFDataArchive : NSObject, RSDDataArchive {

    public let identifier: String
    public var scheduleIdentifier: String?
    
    public var filenames = [String]()
    public var manifestList = [RSDFileManifest]()
    
    public var outputDirectory: URL! = {
        let tempDir = NSTemporaryDirectory()
        let formatter = ISO8601DateFormatter()
        let dir = RSDFileResultUtility.filename(for: formatter.string(from: Date()))
        let path = (tempDir as NSString).appendingPathComponent(dir)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: [ .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication ])
            } catch let error as NSError {
                print ("Error creating file: \(error)")
                return nil
            }
        }
        return URL(fileURLWithPath: path, isDirectory: true)
    }()
    
    public var isComplete = false
    
    public init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
    
    public func shouldInsertData(for filename: RSDReservedFilename) -> Bool {
        return true
    }
    
    public func archivableData(for result: RSDResult, sectionIdentifier: String?, stepPath: String?) -> RSDArchivable? {
        return result as? RSDArchivable
    }
    
    public func insertDataIntoArchive(_ data: Data, manifest: RSDFileManifest) throws {
        guard !isComplete, !self.manifestList.contains(manifest) else {
            assertionFailure("Failed to add \(manifest.filename) : \(manifest)")
            return
        }
        let filename = manifest.filename
        let url = self.outputDirectory.appendingPathComponent(filename)
        try data.write(to: url)
        self.manifestList.append(manifest)
        
        if manifest.filename == "answers.json" {
            let json = String(data: data, encoding: .utf8)
            #if DEBUG
                print("answers.json:\n\(json!)")
            #endif
        }
    }
    
    public func completeArchive(with metadata: RSDTaskMetadata) throws {
        let encoder = RSDFactory.shared.createJSONEncoder()
        let jsonData = try encoder.encode(metadata)
        let json = String(data: jsonData, encoding: .utf8)
        #if DEBUG
        print("Archive complete. outputDirectory: \(String(describing: outputDirectory))\n\n\(json!)")
        #endif
        isComplete = true
    }
}
