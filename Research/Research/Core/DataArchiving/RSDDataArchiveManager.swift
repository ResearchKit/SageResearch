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
    /// When the completion handler is called, the `RSDTaskViewModel` will clean up the task by deleting the
    /// output directory.
    func encryptAndUpload(taskResult: RSDTaskResult, dataArchives: [RSDDataArchive], completion:@escaping (() -> Void))
    
    /// Handle the failure to archive the results.
    ///
    /// When the completion handler is called, the `RSDTaskViewModel` will clean up the task by deleting the
    /// output directory.
    func handleArchiveFailure(taskResult: RSDTaskResult, error: Error, completion:@escaping (() -> Void))
    
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

