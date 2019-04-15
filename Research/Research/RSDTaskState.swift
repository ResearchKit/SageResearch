//
//  RSDTaskState.swift
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

/// The task state object is a base class implementation that can upload and archive results, return
/// the encoded result, and manage file cleanup.
open class RSDTaskState : NSObject {
    
    /// The result associated with this path component.
    public var taskResult: RSDTaskResult
    
    /// Identifier for this task that can be mapped back to a notification. This may be the same
    /// as the task identifier, or it might be that a task is scheduled multiple times per day,
    /// and the app needs to track what the scheduled timing is for the task.
    open var scheduleIdentifier: String?
    
    public init(taskResult: RSDTaskResult) {
        self.taskResult = taskResult
        super.init()
    }
    
    // MARK: Task Finalization - The methods included in this section should **not** be called until the task is finished.
    
    /// A queue that can be used to serialize archiving and cleaning up the file output.
    public let fileManagementQueue = DispatchQueue(label: "org.sagebase.Research.fileQueue.\(UUID())")
    
    /// Convenience method for encoding a result. This is a work-around for a limitation of the encoder
    /// where it cannot encode an object without a Type for the object.
    /// - parameter encoder: The factory top-level encoder.
    /// - returns: The encoded result.
    public func encodeResult(to encoder: RSDFactoryEncoder) throws -> Data {
        return try self.taskResult.rsd_encodeObject(to: encoder)
    }
    
    /// Cleanup the task following archive and upload.
    open func cleanup(error: Error?, completion: ((_ error: Error?) -> Void)? = nil) {
        completion?(error)
    }
    
    /// Build an archive from the task result.
    ///
    /// This method will recurse through the task result and pull out data for archiving using the given
    /// `RSDDataArchiveManager` to manage vending `RSDDataArchive` instances as appropriate. The completion
    /// handler will be called on the `fileManagementQueue` so that the app can manage any post-processing
    /// that must be serialized as appropriate.
    ///
    /// This method will call `RSDDataArchive.insertDataIntoArchive()` for each `RSDArchivable` result found
    /// in the collection.
    ///
    /// This method will insert the `RSDTaskResult` as JSON-encoded Data unless
    /// `RSDDataArchive.shouldInsertData(for: .taskResult) == false`
    ///
    /// Finally, it will recursively look through the task result step history and async results for
    /// `RSDAnswerResult` objects. The answer results will be added to a consolidated mapping dictionary of
    /// answers where the key = `\(section.identifier).\(result.identifier)` and the value is the `value`
    /// property. This dictionary will be serialized as JSON-encoded Data.
    ///
    /// The file results will be added to the files list in a JSON serialized file named "metadata.json"
    /// that includes information about the device, application, task, and a file manifest.
    ///
    public func archiveResults(with manager: RSDDataArchiveManager, completion: ((_ error: Error?) -> Void)? = nil) {
        fileManagementQueue.async {
            do {
                let taskArchiver = TaskArchiver(manager: manager, taskResult: self.taskResult, scheduleIdentifier: self.scheduleIdentifier)
                let archives = try taskArchiver.buildArchives()
                manager.encryptAndUpload(taskResult: self.taskResult, dataArchives: archives) {
                    self.cleanup(error: nil, completion: completion)
                }
            } catch let error {
                manager.handleArchiveFailure(taskResult: self.taskResult, error: error) {
                    self.cleanup(error: error, completion: completion)
                }
            }
        }
    }
}
