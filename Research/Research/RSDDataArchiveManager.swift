//
//  RSDDataArchiveManager.swift
//  Research
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

/// The data archive manager controls vending a new archive (as appropriate) and handling state. It is a
/// composite protocol of the methods defined using Swift, which are required but can include Swift objects
/// and methods that conform to Objective-C protocols which allows for optional implementation of the
/// included methods.
public protocol RSDDataArchiveManager : RSDSwiftDataArchiveManager, RSDObjCDataArchiveManager {
}

public protocol RSDSwiftDataArchiveManager : class, NSObjectProtocol {
    
    /// Should the task result archiving be continued if there was an error adding data to the current
    /// archive?
    /// - parameters:
    ///     - archive: The current archive being built.
    ///     - error: The encoding error that was thrown.
    func shouldContinueOnFail(for archive: RSDDataArchive, error: Error) -> Bool
    
    /// When archiving a task result, it is possible that the results of a task need to be split into
    /// multiple archives -- for example, when combining two or more activities within the same task. If the
    /// task result components should be added to the current archive, then the manager should return
    /// `currentArchive` as the response. If the task result *for this section* should be ignored, then the
    /// manager should return `nil`. This allows the application to only upload data that is needed by the
    /// study, and not include information that is ignored by *this* study, but may be of interest to other
    /// researchers using the same task protocol.
    func dataArchiver(for taskResult: RSDTaskResult, scheduleIdentifier: String?, currentArchive: RSDDataArchive?) -> RSDDataArchive?
    
    /// Encrypt and upload the packaged archives. This method should encrypt and upload all the archives and
    /// then call the completion handler when upload is completed.
    ///
    /// When the completion handler is called, the `RSDTaskPath` will clean up the task by deleting the
    /// output directory.
    func encryptAndUpload(taskPath: RSDTaskPath, dataArchives: [RSDDataArchive], completion:@escaping (() -> Void))
    
    /// Handle the failure to archive the results.
    ///
    /// When the completion handler is called, the `RSDTaskPath` will clean up the task by deleting the
    /// output directory.
    func handleArchiveFailure(taskPath: RSDTaskPath, error: Error, completion:@escaping (() -> Void))
    
}

@objc public protocol RSDObjCDataArchiveManager : class, NSObjectProtocol {
    
    /// Returns the answer key for a given `RSDAnswerResult` to be included in the answer map. This allows
    /// the manager to return a different key mapping than the default key. If not implemented or if the
    /// returned `String` is `nil`, then the default of `"\(sectionIdentifier).\(result.identifier)"` will
    /// be used.
    ///
    /// - parameters:
    ///     - resultIdentifier: The identifier for the answer result.
    ///     - sectionIdentifier: The identifier for the section (if any).
    /// - returns: Key to use in the answer map or `nil` if undefined.
    @objc optional
    func answerKey(for resultIdentifier: String, with sectionIdentifier: String?) -> String?
}

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

/// A data archive is a class object that can be used to add multiple files to a zipped archive for upload as
/// a package. The data archive could also be a service that implements the logic for uploading results where
/// the results are sent individually. It is the responsibility of the developer who implements this protocol
/// for their services to ensure that the data is cached (if offline) and to re-attempt upload of the
/// encrypted results.
public protocol RSDDataArchive : class, NSObjectProtocol {
    
    /// A unique identifier for this archive.
    var identifier: String { get }
    
    /// Identifier for this task that can be mapped back to a notification. This may be the same
    /// as the task identifier, or it might be that a task is scheduled multiple times per day,
    /// and the app needs to track what the scheduled timing is for the task.
    var scheduleIdentifier: String? { get }
    
    /// Should the data archive include inserting data for the given reserved filename?
    func shouldInsertData(for filename: RSDReservedFilename) -> Bool
    
    /// Method for adding data to an archive.
    /// - parameters:
    ///     - data: The data to insert.
    ///     - manifest: The file manifest for this data.
    func insertDataIntoArchive(_ data: Data, manifest: RSDFileManifest) throws
    
    /// Mark the archive as completed.
    /// - parameter metadata: The metadata for this archive.
    func completeArchive(with metadata: RSDTaskMetadata) throws
    
    /// Returns an archivable object for the given result.
    ///
    /// - parameters:
    ///     - result: The result to archive.
    ///     - sectionIdentifier: The section identifier for the task.
    ///     - stepPath: The full step path to the given result.
    /// - returns: An archivable object or `nil` if the result should be skipped.
    func archivableData(for result: RSDResult, sectionIdentifier: String?, stepPath: String?) -> RSDArchivable?
}

/// An archivable result is an object wrapper for results that allows them to be transformed into
/// data for a zipped archive or service.
public protocol RSDArchivable {
    
    /// Build the archiveable or uploadable data for this result.
    func buildArchiveData(at stepPath: String?) throws -> (manifest: RSDFileManifest, data: Data)?
}

extension RSDArchivable {
    
    /// Convenience method for calling `buildArchiveData()` without a step path.
    public func buildArchiveData() throws -> (manifest: RSDFileManifest, data: Data)? {
        return try self.buildArchiveData(at: nil)
    }
}

/// A manifest for a given file that includes the filename, content type, and creation timestamp.
public struct RSDFileManifest : Codable, Hashable, Equatable {
    
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
    
    /// Default initializer.
    public init(filename: String, timestamp: Date, contentType: String?, identifier: String? = nil, stepPath: String? = nil) {
        self.filename = filename
        self.timestamp = timestamp
        self.contentType = contentType
        self.identifier = identifier
        self.stepPath = stepPath
    }
    
    /// A hash for the manifest.
    public var hashValue: Int {
        return filename.hashValue ^ timestamp.hashValue
    }
    
    /// The file manifest files are equal if the filename, timestamp, and contentType are the same.
    public static func ==(lhs: RSDFileManifest, rhs: RSDFileManifest) -> Bool {
        return lhs.filename == rhs.filename && lhs.timestamp == rhs.timestamp
    }
}


/// The metadata for a task result archive that can be zipped using the app developer's choice of
/// third-party archival tools.
public struct RSDTaskMetadata : Codable {
    
    /// Information about the specific device.
    public let deviceInfo: String
    
    /// Specific model identifier of the device.
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
    public let taskRunUUID: UUID
    
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
        #if os(watchOS)
            let device = WKInterfaceDevice.current()
            self.deviceInfo = "\(device.machineName); \(device.systemName)/\(device.systemVersion)"
            self.deviceTypeIdentifier = device.deviceTypeIdentifier
        #else
            let device = UIDevice.current
            self.deviceInfo = "\(device.machineName); \(device.systemName)/\(device.systemVersion)"
            self.deviceTypeIdentifier = device.deviceTypeIdentifier
        #endif
        self.appName = Bundle.main.executableName
        self.appVersion = Bundle.main.fullVersion
        self.rsdFrameworkVersion = Bundle(for: RSDTaskPath.self).fullVersion
        self.taskIdentifier = taskResult.identifier
        self.taskRunUUID = taskResult.taskRunUUID
        self.startDate = taskResult.startDate
        self.endDate = taskResult.endDate
        self.schemaIdentifier = taskResult.schemaInfo?.schemaIdentifier
        self.schemaRevision = taskResult.schemaInfo?.schemaVersion
        self.files = files
    }
}

internal class TaskArchiver : NSObject {
    
    let manager: RSDDataArchiveManager
    let taskResult: RSDTaskResult
    let archive: RSDDataArchive?
    
    fileprivate var childArchives: [RSDDataArchive] = []
    fileprivate var files: Set<RSDFileManifest> = []
    fileprivate var answerMap: [String : AnswerResultWrapper] = [:]
    
    init(manager: RSDDataArchiveManager, taskResult: RSDTaskResult, scheduleIdentifier: String?) {
        self.archive = manager.dataArchiver(for: taskResult, scheduleIdentifier: scheduleIdentifier, currentArchive: nil)
        self.taskResult = taskResult
        self.manager = manager
        super.init()
    }
    
    init?(manager: RSDDataArchiveManager, taskResult: RSDTaskResult, inputArchive: RSDDataArchive?) {
        guard let archive = manager.dataArchiver(for: taskResult, scheduleIdentifier: nil, currentArchive: inputArchive),
            (archive.identifier != inputArchive?.identifier)
            else {
                return nil
        }
        self.taskResult = taskResult
        self.manager = manager
        self.archive = archive
        super.init()
    }
    
    func buildArchives() throws -> [RSDDataArchive] {
        
        // recursively add all the archives to this archiver.
        try recursiveAddFunc(nil, nil, taskResult.stepHistory)
        if self.archive != nil, let asyncResults = taskResult.asyncResults {
            try recursiveAddFunc(nil, nil, asyncResults)
        }
        
        // The archives include any child archives
        var archives = childArchives
        
        if let archive = self.archive {
            do {
                // Check if there are any answers to add.
                if answerMap.count > 0, archive.shouldInsertData(for: .answers) {
                    let data = try answerMap.rsd_jsonEncodedData()
                    let manifest = RSDFileResultUtility.fileManifest(for: .answers)
                    try archive.insertDataIntoArchive(data, manifest: manifest)
                    self.files.insert(manifest)
                }
                
                // Check if there is a task result to add.
                if archive.shouldInsertData(for: .taskResult) {
                    let data = try taskResult.rsd_jsonEncodedData()
                    let manifest = RSDFileResultUtility.fileManifest(for: .taskResult)
                    try archive.insertDataIntoArchive(data, manifest: manifest)
                    self.files.insert(manifest)
                }
                
                // Only include the task archive if it is not empty.
                let metadata = RSDTaskMetadata(taskResult: self.taskResult, files: Array(self.files))
                try archive.completeArchive(with: metadata)
                archives.insert(archive, at: 0)
                
            } catch let err {
                // If this is not swallowed, then rethrow the error.
                // Otherwise, ignore the failure to add the archive and continue.
                if !manager.shouldContinueOnFail(for: archive, error: err) {
                    throw err
                }
            }
        }
        
        return archives
    }
    
    func recursiveAddFunc(_ sectionIdentifier: String?, _ stepPath: String?, _ results: [RSDResult]) throws {
        for result in results {
            if let taskResult = result as? RSDTaskResult {
                if let subArchiver = TaskArchiver(manager: manager, taskResult: taskResult, inputArchive: archive) {
                    // If there is an archiver for this subtask, then append the archives with that result.
                    let archives = try subArchiver.buildArchives()
                    self.childArchives.append(contentsOf: archives)
                }
                else {
                    // Otherwise, recuse into the task result and add its results to this archive.
                    let path = (stepPath != nil) ? "\(stepPath!)/\(taskResult.identifier)" : taskResult.identifier
                    try recursiveAddFunc(taskResult.identifier, path, taskResult.stepHistory)
                    if let asyncResults = taskResult.asyncResults {
                        try recursiveAddFunc(taskResult.identifier, path, asyncResults)
                    }
                }
            }
            else {
                try addToArchive(sectionIdentifier, stepPath, result)
            }
        }
    }
    
    func addToArchive(_ sectionIdentifier: String?, _ stepPath: String?, _ result: RSDResult) throws {
        // If there is no archive for this level, then all the non-task results are ignored.
        guard let archive = self.archive else { return }
        
        // Look to see if the result conforms to the archivable protocol or the collection
        // protocol. If it conforms to both, then *only* archive it at this level and do not
        // recurse into the result.
        if let archivable = archive.archivableData(for: result, sectionIdentifier: sectionIdentifier, stepPath: stepPath) {
            do {
                if let (manifest, data) = try archivable.buildArchiveData(at: stepPath) {
                    try self.archive?.insertDataIntoArchive(data, manifest: manifest)
                    self.files.insert(manifest)
                }
            } catch let err {
                // If this is not swallowed, then rethrow the error
                if !manager.shouldContinueOnFail(for: archive, error: err) {
                    throw err
                }
            }
        }
        else if let collection = result as? RSDCollectionResult {
            let path = (stepPath != nil) ? "\(stepPath!)/\(collection.identifier)" : collection.identifier
            try recursiveAddFunc(sectionIdentifier, path, collection.inputResults)
        }
        
        // If this result conforms to the answer result protocol then add it to the answer map
        if let answerResult = result as? RSDAnswerResult {
            if let answer = answerResult.value, !(answer is NSNull) {
                let answerIdentifier: String = {
                    if let key = self.manager.answerKey?(for: answerResult.identifier, with: sectionIdentifier) {
                        return key
                    }
                    else if let section = sectionIdentifier {
                        return "\(section).\(result.identifier)"
                    }
                    else {
                        return result.identifier
                    }
                }()
                answerMap[answerIdentifier] = AnswerResultWrapper(answerResult: answerResult)
            }
        }
    }
}

fileprivate struct AnswerResultWrapper : Encodable {
    let answerResult : RSDAnswerResult
    
    func encode(to encoder: Encoder) throws {
        try answerResult.answerType.encode(answerResult.value, to: encoder)
    }
}

extension Bundle {
    
    /// The executable name is the bundle's non-localized name.
    fileprivate var executableName: String {
        if let bundleInfo = infoDictionary {
            if let name = bundleInfo["CFBundleExecutable"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleName"] as? String {
                return name
            }
            else if let name = bundleInfo["CFBundleDisplayName"] as? String {
                return name
            }
        }
        return "???"
    }
    
    /// The full version is a non-localized string that uses both the "short version"
    /// string and the build number.
    fileprivate var fullVersion: String {
        guard let bundleInfo = infoDictionary,
            let version = bundleInfo["CFBundleShortVersionString"],
            let build = bundleInfo[(kCFBundleVersionKey as String)]
            else {
                return "???"
        }
        return "version \(version), build \(build)"
    }
}

#if os(watchOS)
    import WatchKit
    
    extension WKInterfaceDevice {
        
        /// An identifier for the device type pulled from the system info.
        fileprivate var deviceTypeIdentifier: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
        
        /// A human-readable mapped name for a given device type.
        fileprivate var machineName: String {
            let identifier = deviceTypeIdentifier
            switch identifier {
            case "Watch1":                                      return "Apple Watch Series 1"
            case "Watch2,6","Watch2,7","Watch2,3","Watch2,4":   return "Apple Watch Series 2"
            case "Watch3,1","Watch3,2","Watch3,3","Watch3,4":   return "Apple Watch Series 3"
            case "i386", "x86_64":                              return "Apple Watch Simulator"
                
            default:                                            return identifier
            }
        }
    }
#else
    extension UIDevice {
        
        /// An identifier for the device type pulled from the system info.
        fileprivate var deviceTypeIdentifier: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
        
        /// A human-readable mapped name for a given device type.
        fileprivate var machineName: String {
            let identifier = deviceTypeIdentifier
            switch identifier {
            case "iPod5,1":                                     return "iPod Touch 5"
            case "iPod7,1":                                     return "iPod Touch 6"
                
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":         return "iPhone 4"
            case "iPhone4,1":                                   return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                      return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                      return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                      return "iPhone 5s"
            case "iPhone7,2":                                   return "iPhone 6"
            case "iPhone7,1":                                   return "iPhone 6 Plus"
            case "iPhone8,1":                                   return "iPhone 6s"
            case "iPhone8,2":                                   return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                      return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                      return "iPhone 7 Plus"
            case "iPhone8,4":                                   return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                    return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                    return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                    return "iPhone X"
                
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":    return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":               return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":               return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":               return "iPad Air"
            case "iPad5,3", "iPad5,4":                          return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                        return "iPad 5"
            case "iPad2,5", "iPad2,6", "iPad2,7":               return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":               return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":               return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                          return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                          return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                          return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                          return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                          return "iPad Pro 10.5 Inch"
                
            case "AppleTV5,3":                                  return "Apple TV"
            case "AppleTV6,2":                                  return "Apple TV 4K"
                
            case "AudioAccessory1,1":                           return "HomePod"
                
            case "i386", "x86_64":                              return "Simulator"
                
            default:                                            return identifier
            }
        }
    }
#endif
